# Lab Cluster Docs

Welcome! This site explains how to use the lab's NVIDIA **DGX Spark** compute
system, managed with **Slurm**. GPU containers run through **Enroot** and
**Pyxis**.

If you're new here, start with [Getting Started](getting-started.md).

## What's on this cluster

- **Hardware:** NVIDIA DGX Spark node(s) — *fill in count, GPUs per node, memory, storage, and network details*
- **Scheduler:** [Slurm](https://slurm.schedmd.com/) — allocates compute resources and runs jobs
- **Containers:** [Enroot](https://github.com/NVIDIA/enroot) (an unprivileged container runtime) and [Pyxis](https://github.com/NVIDIA/pyxis) (the Slurm plugin for launching Enroot containers from `srun` and `sbatch`)

## Quick links

- [Getting Started](getting-started.md) — accounts, NVIDIA Sync access, and your first training job
- [LLM Smoke Test](llm-smoke-test.md) — run a small LLM and verify expected answers
- [Submitting Slurm Jobs](slurm-jobs.md) — `sbatch` and `srun`
- [Containers (Enroot & Pyxis)](containers.md) — running GPU containers on the cluster
- [FAQ & Troubleshooting](faq.md)

## Getting help

Contact **Josh Bamforth** at [josh.bamforth@shu.ac.uk](mailto:josh.bamforth@shu.ac.uk)
— he administers the cluster and creates new accounts.
