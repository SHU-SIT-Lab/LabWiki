# Getting Started

## 1. Get an account

Accounts are created individually — there's no self-signup. Email
**Josh Bamforth** at [josh.bamforth@shu.ac.uk](mailto:josh.bamforth@shu.ac.uk)
to request access. You'll be given a username and asked to set a password,
which you'll then use with the authentication method set up for your account.
Use your own account. Josh manages account and password synchronization across
the nodes; a password change on one node alone is not synchronized automatically.

## 2. Log in with NVIDIA Sync

Use **NVIDIA Sync** to connect to the manager with your own account. A normal
SSH client also works once your account's authentication has been set up.

Download NVIDIA Sync from <https://build.nvidia.com/spark/connect-to-your-spark/sync>.
Once installed, connect to the Robotics WiFi in Sheaf 4114. In NVIDIA Sync,
add a device, give it a recognisable name, select **Hostname or IP**, and
choose **spark-c3d8.local**. Enter your own account details from step 1.
Submit jobs from this manager; Slurm starts them on the allocated node.

!!! important "GPU work uses Slurm containers"
    Run training, inference and GPU servers inside a container launched with
    Slurm. GPU access from ordinary SSH sessions on the manager is blocked.
    Starting a container directly from your login shell does not create a GPU
    allocation. Read [Cluster Changes for Users](cluster-updates.md) before
    migrating an existing workload.

## 3. Check the cluster is available

Once NVIDIA Sync has connected you and opened a shell:

```bash
sinfo
```

This lists node states. `idle` means free, `alloc` means fully in use, `mix`
means partially in use, and `down`/`drain` means unavailable.

```bash
squeue
```

Ordinary users see their own jobs. Use `squeue -u "$USER"` to request your queue
explicitly. Other users may be running work even when your queue is empty.
Each of the three nodes has one GPU; `sinfo` shows overall node availability.

## 4. Your first GPU job

This example runs a short PyTorch GPU calculation in an NVIDIA container and
writes its output to your shared home directory. Copy
the commands into the shell opened by NVIDIA Sync.

```bash
mkdir -p "$HOME/first-training-job/logs"
cd "$HOME/first-training-job"
```

Create a file called `first-training.sbatch` containing:

```bash title="first-training.sbatch"
#!/bin/bash
#SBATCH --job-name=first-training
#SBATCH --account=hpc
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:10:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -euo pipefail

srun --mpi=none \
     --container-image='nvcr.io#nvidia/pytorch:25.09-py3' \
     --no-container-remap-root \
     --container-mounts="$SLURM_SUBMIT_DIR:/workspace" \
     --container-workdir=/workspace \
     python -c "import torch; assert torch.cuda.is_available(); x = torch.rand(4096, 4096, device='cuda'); print('Training test completed on:', torch.cuda.get_device_name(0)); print('Result:', (x @ x).mean().item())"
```

Submit it and check its progress:

```bash
sbatch first-training.sbatch
squeue -u $USER
```

When the job is no longer listed in `squeue`, inspect its output. Replace
`<job-id>` with the ID printed by `sbatch`.

```bash
cat logs/first-training-<job-id>.out
sacct -j <job-id> --format=JobID,State,ExitCode
```

If it reports `Training test completed on`, you have successfully run a GPU
job. Keep your code and outputs in this project directory, then adapt the
container command to run your own training script.

## 5. Storage

Use your own home directory (`$HOME`, `/home/<username>`) for code, working
files, logs and results. It is stored on the manager and mounted at the same
path on both workers. Bind your project into the container as in the example.
Leave Enroot's container cache/runtime/data paths at their system defaults.

`/home/data` is managed storage on the manager. It is not automatically shared
with the workers. Ask Josh which nodes can access a provisioned project path.
Its main areas are:

| Location | Intended use |
|---|---|
| `/home/data/containers` | Lab-managed container assets |
| `/home/data/datasets` | Lab-managed datasets |
| `/home/data/scratch` | Temporary working storage for provisioned projects |
| `/home/data/shared` | Files shared through provisioned project directories |

Do not create directories directly under `/home/data`. Ask Josh if you need a
project directory there or access to a shared dataset. Do not rely on the
Spark as the only copy of important results: copy finished work to University
OneDrive or your own machine.

The directory `/shared` on a worker is local to that worker despite its name.
Only your personal home is guaranteed shared by this setup.

Next, see:

- [LLM smoke test](llm-smoke-test.md) for a complete small-model example with answer checks
- [Submitting Slurm Jobs](slurm-jobs.md) for batch scripts and job options
- [Containers (Enroot & Pyxis)](containers.md) for running your actual workloads in containers
