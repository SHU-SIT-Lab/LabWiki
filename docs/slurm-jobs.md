# Submitting Slurm Jobs

## Interactive jobs (`srun`)

Use an interactive job for debugging and quick tests. This requests a GPU and
opens a shell on the allocated resources:

```bash
srun --gres=gpu:1 --cpus-per-task=8 --mem=32G --pty bash
```

## Batch jobs (`sbatch`)

Use a batch job for long-running work. Write a script and submit it:

```bash title="train.sbatch"
#!/bin/bash
#SBATCH --job-name=my-training-run
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

log "Running on $(hostname)"
nvidia-smi

heartbeat() {
  while sleep 60; do
    log "Training is still running."
  done
}

heartbeat &
heartbeat_pid=$!
cleanup() { kill "$heartbeat_pid" 2>/dev/null || true; }
trap cleanup EXIT

log "Starting training"
python -u train.py --epochs 10
log "Training completed"
```

Submit it:

```bash
mkdir -p logs
sbatch train.sbatch
```

For an actual implemented example that you can follow file by file, see the
[LLM smoke test](llm-smoke-test.md). It includes the Python test program,
dependency list, and complete Slurm submission script, and checks that a small
LLM returns the expected answers.

## Watch a running job's log

Jobs can spend several minutes waiting for a container image or model to
download on their first run. Add timestamped progress messages to your script
and watch the output live:

```bash
tail -f logs/<job-name>-<job-id>.out
```

Press `Ctrl+C` to stop watching the log; this does **not** cancel the job.

## Useful commands

| Command | What it does |
|---|---|
| `sinfo` | Show node status |
| `squeue` | Show queued and running jobs |
| `squeue -u $USER` | Show only your jobs |
| `scancel <jobid>` | Cancel a job |
| `sacct -j <jobid>` | Show accounting and history for a finished job |
| `scontrol show job <jobid>` | Show detailed job information |

## Common `sbatch` and `srun` flags

| Flag | Meaning |
|---|---|
| `--gres=gpu:N` | Request N GPUs |
| `--cpus-per-task=` | CPU cores requested |
| `--mem=` | Memory requested |
| `--time=` | Wall-clock time limit (`HH:MM:SS`) |
| `--job-name=` | Name shown in `squeue` |
| `--output=` / `--error=` | Where standard output and errors are written |

## Multi-GPU and multi-node jobs

Add `--gres=gpu:N` to request multiple GPUs. Add `--nodes=` and
`--ntasks-per-node=` for multi-node jobs when your workload supports it.
