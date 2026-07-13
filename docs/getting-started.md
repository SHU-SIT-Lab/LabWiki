# Getting Started

## 1. Get an account

Accounts are created individually — there's no self-signup. Email
**Josh Bamforth** at [josh.bamforth@shu.ac.uk](mailto:josh.bamforth@shu.ac.uk)
to request access. You'll be given a username and asked to set a password,
which you'll then use to log in.

## 2. Log in with NVIDIA Sync

Connections to the cluster go through **NVIDIA Sync**, not a plain SSH
client — it handles the login for you using the credentials from step 1.

Download NVIDIA Sync from <https://build.nvidia.com/spark/connect-to-your-spark/sync>.
Once installed, connect to the Robotics WiFi in Sheaf 4114. In NVIDIA Sync,
add a device, give it a recognisable name, select **Hostname or IP**, and
choose **spark-c38d**. Enter the username and password from step 1.

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

This shows currently running and queued jobs — yours and everyone else's.

## 4. Your first training job

This example runs a short PyTorch training loop in an NVIDIA container and
writes its output to your home directory. Every account can write here. Copy
the commands into the shell opened by NVIDIA Sync.

```bash
mkdir -p "$HOME/first-training-job/logs"
cd "$HOME/first-training-job"
```

Create a file called `first-training.sbatch` containing:

```bash title="first-training.sbatch"
#!/bin/bash
#SBATCH --job-name=first-training
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:10:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

srun --container-image=pytorch/pytorch:2.7.1-cuda12.8-cudnn9-runtime \
     --container-mounts=$HOME/first-training-job:/workspace \
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
```

If it reports `Training test completed on`, you have successfully run a GPU
job. Keep your code and outputs in this project directory, then adapt the
container command to run your own training script.

## 5. Storage

Use your home directory (`$HOME`) for code, working files, logs, and personal
caches. It is available to every account and is the right place to start.

`/home/data` is managed shared storage. Its main areas are:

| Location | Intended use |
|---|---|
| `/home/data/containers` | Lab-managed container images and caches |
| `/home/data/datasets` | Lab-managed datasets |
| `/home/data/scratch` | Temporary working storage for provisioned projects |
| `/home/data/shared` | Files shared through provisioned project directories |

Do not create directories directly under `/home/data`. Ask Josh if you need a
project directory there or access to a shared dataset. Do not rely on the
Spark as the only copy of important results: copy finished work to University
OneDrive or your own machine.

Next, see:

- [LLM smoke test](llm-smoke-test.md) for a complete small-model example with answer checks
- [Submitting Slurm Jobs](slurm-jobs.md) for batch scripts and job options
- [Containers (Enroot & Pyxis)](containers.md) for running your actual workloads in containers
