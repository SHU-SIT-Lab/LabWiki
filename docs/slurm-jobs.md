# Submitting Slurm jobs

Submit from **`spark-c3d8.local`**, using your own account. Run GPU workloads in
an Enroot/Pyxis container with a GPU allocation. The manager is also a compute
node, so Slurm may legitimately place a job there. Ordinary manager SSH sessions
cannot use its GPU. See [the current user rules](cluster-updates.md).

## Interactive GPU container

Create a project directory, then request a shell inside the container:

```bash
mkdir -p "$HOME/project"
cd "$HOME/project"
srun --account=hpc --partition=gpu --nodes=1 --ntasks=1 \
     --gres=gpu:1 --cpus-per-task=4 --mem=16G --time=00:30:00 \
     --mpi=none --container-image='nvcr.io#nvidia/pytorch:25.09-py3' \
     --no-container-remap-root \
     --container-mounts="$PWD:/workspace" --container-workdir=/workspace \
     --pty bash
```

Wait for Slurm to allocate resources and Pyxis to prepare the image. Inside the
container, run your application or check GPU access with:

```bash
python -c "import torch; assert torch.cuda.is_available(); print(torch.cuda.get_device_name(0))"
```

`exit` ends the shell and releases the allocation. An interactive job can end
when its connection closes; use a batch job for unattended work.

## Batch GPU container

Put `train.py` in your project directory and create this file there:

```bash title="train.sbatch"
#!/bin/bash
#SBATCH --job-name=my-training-run
#SBATCH --account=hpc
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -euo pipefail
echo "Starting job $SLURM_JOB_ID on $(hostname) at $(date -Is)"

srun --mpi=none \
     --container-image='nvcr.io#nvidia/pytorch:25.09-py3' \
     --no-container-remap-root \
     --container-mounts="$SLURM_SUBMIT_DIR:/workspace" \
     --container-workdir=/workspace \
     python -u train.py --epochs 10

echo "Training completed at $(date -Is)"
```

The image supplies PyTorch; add your application's other dependencies using
[the container guide](containers.md). Create the log directory **before**
submitting, because Slurm opens the logs before your script starts:

```bash
mkdir -p logs
sbatch train.sbatch
squeue -u "$USER"
```

The job continues after you close the submission terminal. Record its job ID.
For an example with application code and dependencies included, follow the
[LLM smoke test](llm-smoke-test.md).

## Watch progress and check completion

Container and model downloads can take several minutes on the first run:

```bash
tail -f logs/my-training-run-<job-id>.out
```

Press `Ctrl+C` to stop watching the log; this does not cancel the batch job.
After it leaves your queue, check its log and saved result:

```bash
sacct -j <job-id> --format=JobID,State,ExitCode,Elapsed,MaxRSS,AllocTRES
```

See [Job History](job-history.md) for memory measurements, completion states and
held jobs. `sbatch` accepting a job does not mean it has started or succeeded.

## Useful commands

| Command | What it does |
|---|---|
| `sinfo` | Show overall node availability |
| `squeue -u "$USER"` | Show your queued and running jobs |
| `scancel <job-id>` | Cancel your job and release its resources |
| `sacct -X -S now-7days` | Show your saved job summaries |
| `scontrol show job <job-id>` | Show your job's resources, node and pending reason |

Ordinary users see their own queue details and history. Administrators can see
all users' jobs. An empty personal queue is not a cluster-wide utilization report.

## Request resources for this cluster

Each Spark has **one GPU and 20 CPUs**. The scheduler exposes **118000 MiB RAM
per node**. Request what your application needs, leaving time for preparation
within the wall-clock limit.

| Flag | Meaning |
|---|---|
| `--account=hpc` | Use the cluster's shared accounting account |
| `--partition=gpu` | Use the partition containing all three Sparks |
| `--nodes=1 --ntasks=1` | Run one task on one node |
| `--gres=gpu:1` | Reserve the node's single GPU |
| `--cpus-per-task=4` | Reserve four CPUs for the task |
| `--mem=16G` | Request job RAM on the node |
| `--time=04:00:00` | Set the wall-clock limit |
| `--output=` / `--error=` | Choose logs whose parent directories already exist |

A CPU-only job does not get GPU access. Increasing `--mem` does not allocate a
GPU, and a GPU request does not replace a suitable RAM request. The manager's
8 GiB/two-CPU ordinary-login limit is separate from Slurm allocations.

For CPU-only work, omit the GPU request, for example:

```bash
srun --account=hpc --nodes=1 --ntasks=1 --cpus-per-task=2 --mem=4G --time=00:10:00 --mpi=none hostname
```

Use a container as well when the workload needs its own software environment.

## Multiple GPUs and distributed work

`--gres=gpu:2` asks for two GPUs **per node**, which cannot fit on a Spark here.
Two-GPU work needs two nodes, one GPU per node, and a program that launches
distributed ranks correctly. Increasing the node count does not distribute a
Python script.

The workers' MPI/NCCL communication has been tested over their fast link. The
manager is awaiting fast-network cabling. Ask Josh for a suitable distributed
container/launcher before scaling out. General examples use `--mpi=none`; the
system-wide PMIx runtime is not available for `srun --mpi=pmix`.
