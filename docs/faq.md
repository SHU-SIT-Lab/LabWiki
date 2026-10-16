# FAQ and troubleshooting

## CUDA or `nvidia-smi` fails in my manager SSH shell

GPU access is blocked for ordinary login sessions and personal services on the
manager. Start a GPU-allocated container through Slurm using the
[interactive example](slurm-jobs.md#interactive-gpu-container). A virtual
environment, `tmux` session or container started directly from the login shell
does not allocate a GPU. Do not change device permissions or use `sudo`.

## My container cannot see the GPU

Check that the **Slurm job requests `--gres=gpu:1`** and that the application is
the command run by `srun --container-image=...`. A CPU-only allocation cannot use
the GPU. Inside the allocated PyTorch container, check:

```bash
python -c "import torch; assert torch.cuda.is_available(); print(torch.cuda.get_device_name(0))"
```

Use an ARM64 image and a framework/CUDA version compatible with GB10. Errors
such as `exec format error` or `no kernel image is available` can indicate an
architecture mismatch. `nvidia-smi` inside the container is a useful driver
check; an actual calculation also verifies that the application can use the GPU.

## My job is pending

Run `squeue -u "$USER"`, then `scontrol show job <job-id>` and check `Reason`:

| Reason | Meaning |
|---|---|
| `Resources` | The requested resources are not currently available |
| `Priority` | Other eligible work has scheduling priority |
| `JobHeldUser` | You submitted or placed a hold; release it only when ready |
| `ReqNodeNotAvail` | A requested node may be down, drained or unavailable |
| An association/QOS limit | Check the exact reason with Josh; the shared `hpc` account itself adds no GPU quota |

Use `sinfo` for node availability. Ordinary users see their own queue details;
an empty queue does not show that the entire cluster is idle.

## I requested multiple GPUs and the job cannot start

Each node has **one GPU**. `--gres=gpu:2` requests two per node and cannot fit
here. Multi-GPU work needs multiple nodes, one GPU per node, and an application
with a correctly configured distributed launcher. See the
[resource guide](slurm-jobs.md#multiple-gpus-and-distributed-work).

## The first container or model download is slow

The first run may need to fetch and prepare a large image, then download model
weights. Allow preparation time within the job limit and watch the logs. Check
registry access/authentication if the log reports a pull failure. Do not launch
many duplicate imports or redirect Enroot's cache/data paths into your NFS home.

For a persistent stall, report the job ID, node, timestamp and last log lines to
Josh. A process waiting indefinitely for shared-storage I/O needs investigation;
repeated cancellation or resubmission may not resolve the underlying problem.

## My home or project files are missing on a worker

Personal homes should be mounted from the manager at `/home/<username>` on each
worker. Report missing or hanging mounts to Josh. Do not write replacement files
into an unmounted home directory. A worker whose required homes fail to mount
will not start its Slurm compute service.

`/home/data` and `/shared` are not automatically shared across nodes. Ask about
the storage provisioned for your project, or place your project in your own
shared home and bind it into the container.

## My manager shell or personal service runs out of memory

Ordinary processes share an **8 GiB RAM / two-CPU limit per user on the manager**.
Submit substantial work through Slurm with suitable resources. These login limits
do not describe the RAM allocated to your scheduled job or a GPU-memory allowance.

## My job disappeared from `squeue`

Check its saved history and application log:

```bash
sacct -j <job-id> --format=JobID,State,ExitCode,Elapsed,MaxRSS,AllocTRES
```

History is available from 12 October 2026. Job-step rows often hold the memory
measurements. See [Job History](job-history.md).

## Where do job logs go?

The paths in `#SBATCH --output` and `--error` determine this, usually under your
project's `logs/` directory. Create it before `sbatch`; Slurm needs to open the
files before your script executes. A failed setup may have no application log,
so check `sacct` and report the job ID if necessary.

## How do I change my password across the cluster?

Ask Josh to make a synchronized change. A bare `passwd` command changes only the
machine on which it runs. Keep using your own account and its configured SSH
authentication; do not share another person's login.

## Who do I ask for help?

Contact **Josh Bamforth** at [josh.bamforth@shu.ac.uk](mailto:josh.bamforth@shu.ac.uk).
Include the job ID, allocated node, time and useful error text. Do not send
passwords or private SSH keys.
