# Cluster changes: what users need to do

Updated **16 October 2026**. These instructions apply to all ordinary cluster
accounts, including accounts created later.

## Run GPU work through Slurm, inside a container

**All GPU workloads must run in an Enroot/Pyxis container launched through
Slurm.** This includes training, inference, notebooks that use CUDA, and Ollama.
Connect to the manager, `spark-c3d8.local`, to edit files and submit jobs. Request
a GPU and start the container with `srun`; use `sbatch` for work that should
continue after you disconnect.

On the manager, ordinary SSH sessions, personal background services and containers
started directly from those sessions are blocked from GPU devices. A container
by itself does not reserve a GPU. A CPU-only Slurm job also cannot use a GPU.
The technical restriction enforces scheduled GPU access on the manager; using a
container is the lab's required workflow for GPU jobs on every node.

Start with the [first GPU job](getting-started.md#4-your-first-gpu-job),
[interactive and batch examples](slurm-jobs.md), or [container guide](containers.md).
Submit from the manager and let Slurm select an available node. Direct worker
logins are not a way to bypass scheduling.

If you previously ran GPU work directly:

1. Move the workload into a compatible container and request its CPU, RAM, GPU
   and time limit in Slurm.
2. Stop your old background workload or personal service once its work is saved.
   `tmux`, `screen`, `nohup`, and personal services do not create allocations.
3. Use the job ID, its log and `sacct` to check the result. Stop a server job when
   you have finished using it so its GPU becomes available to others.

## Keep login activity small

The manager's ordinary sessions and personal services have an existing aggregate
limit of **8 GiB RAM and two CPUs' worth of CPU time per user**. These are shared
by all your ordinary processes on that machine, not separate limits for every
terminal. Use the login shell for editing, submission and lightweight checks;
schedule substantial computation, downloads/preparation that need more resources,
and servers through Slurm.

Slurm jobs use the resources requested for the allocation. The login limit is
not an 8 GiB GPU-memory allowance and does not reserve any GPU capacity.

## Your home follows you between nodes

Your personal `/home/<username>` is stored on the manager and mounted at the
same path on both workers. Keep project scripts, inputs, logs and results there,
and mount the project into your container. Matching usernames and numeric user
and group IDs are managed across the cluster.

Only these personal homes are guaranteed shared by this setup. `/shared` is
node-local despite its name. `/home/data` is managed storage on the manager;
ask Josh about availability on other nodes before using it in a job.

Leave Enroot's runtime, cache and data paths at their system defaults. The workers
have local per-user container storage. Redirecting those paths into your NFS home
can create large shared-storage writes and stalls. Model caches and saved results
are separate from Enroot's working files; arrange storage for large datasets and
model collections with Josh. Keep another copy of important results.

Ask Josh to change or reset a password across the cluster. Running `passwd` on
one machine does not automatically synchronize the other machines. Continue to
use your own account and the SSH authentication method set up for it.

## Check your own queue and saved history

Job history has been enabled since **12 October 2026**. Ordinary users can see
their own job details and history; administrators can see all users' records.
An empty personal queue does not mean that the cluster is empty. Use `sinfo`
for node availability, `squeue -u "$USER"` for your queue, and `sacct` after a job
leaves the queue. See [Job History](job-history.md) for copyable commands.

## Choose resources for this cluster

There are three Sparks in partition `gpu`: `spark-c3d8` (manager and compute
node), `spark-91d0` and `spark-2c1b`. Each has **one GB10 GPU and 20 CPUs**.
Requesting two GPUs on one node cannot work here; multiple GPUs require multiple
nodes and a distributed application.

The workers have a tested fast link to each other. The manager's fast-network
connection is still awaiting cabling, and shared homes currently use its Wi-Fi
connection. Ask Josh before scaling a communication-heavy workload across nodes.
Adding `--nodes=2` does not make a single-process training script distributed.

## Report storage or node problems

If a job hangs while importing a container or writing files, collect the job ID,
allocated node, last log lines and time, then contact
[Josh Bamforth](mailto:josh.bamforth@shu.ac.uk). A drained node is intentionally
unavailable. Administrators check it before returning it to scheduling; users
should not try to clear its drain or reboot it.
