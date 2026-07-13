# FAQ & Troubleshooting

## My job is stuck in `PD` (pending) state

Run `squeue -u $USER` then `scontrol show job <jobid>` and check the
`Reason` field. Common reasons:

- `Resources` — cluster is full, job is waiting its turn
- `Priority` — a higher-priority job is ahead of you in the queue
- `AssocGrpGRES` / similar — you've hit a per-user or per-group GPU limit

## `srun: error: ... Invalid generic resource (gres) specification`

Usually means the `--gres=gpu:N` value does not match the configured GPU
resources. Check available GPU counts with `sinfo -o "%G"`.

## My container can't see the GPU

- Confirm you requested a GPU with `--gres=gpu:N`
- Run `nvidia-smi` inside the container as a first check
- Make sure you didn't accidentally drop Pyxis's default GPU passthrough by
  overriding container runtime flags

## Enroot image pull is slow or fails

*Fill in: known Docker Hub registry rate limits, whether credentials are
needed, and where to report persistent pull failures.*

## Where do my job's logs go?

By default, wherever `--output`/`--error` point in your `sbatch` script
(often `logs/<jobname>-<jobid>.out`). Make sure the `logs/` directory exists
before submitting, or Slurm will silently fail to write it.

## Who do I ask for help?

Contact **Josh Bamforth** at [josh.bamforth@shu.ac.uk](mailto:josh.bamforth@shu.ac.uk)
— he also handles account requests (see [Getting Started](getting-started.md)).
