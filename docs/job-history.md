# Job history and resource use

Slurm saves job history from **12 October 2026** onward. Your job leaving
`squeue` means it is no longer queued or running; check its saved state to find
out whether it succeeded, failed, timed out or was cancelled.

Run these commands on the manager, `spark-c3d8.local`, using your own account.
Ordinary users see their own records. Administrators can view other users' jobs.

## Your jobs from the last seven days

```bash
sacct -X -S now-7days --format=JobID,JobName,Elapsed,State,ExitCode,NodeList
```

`-X` shows one summary row per job. A successful job normally reports
`COMPLETED` with exit code `0:0`. Read the output log as well: a job script must
propagate application failures for its exit code to be meaningful. The examples
in this wiki use `set -euo pipefail` for this reason.

## Details and memory use for one job

Replace `1234` with your job ID:

```bash
sacct -j 1234 --format=JobID,JobName,State,ExitCode,Elapsed,TotalCPU,MaxRSS,AllocTRES
```

Keep the step rows here: `MaxRSS` and CPU measurements are often recorded for a
step such as `1234.0`, rather than the top-level job. `MaxRSS` is the largest
measured task resident-memory value, not the sum across all tasks. Sampling is
periodic, so brief peaks may be missed.

`AllocTRES` describes the allocated CPUs, memory and GPUs. It does not measure
continuous GPU utilization or GPU-memory consumption. A recorded GPU allocation
alone does not prove that an application performed useful GPU work.

## Interpret the result

| State | Next step |
|---|---|
| `COMPLETED`, exit `0:0` | Read the log and check the application's outputs |
| `FAILED` | Read the error log and the job-step exit codes |
| `OUT_OF_MEMORY` | Check memory measurements and adjust the workload or RAM request |
| `TIMEOUT` | Check progress and request a suitable time limit for the next run |
| `CANCELLED` | The job was cancelled; the record may identify the cancelling user |
| `PENDING` with `JobHeldUser` | The job is held; it will not start until its owner releases it |

To release a job you deliberately submitted with `sbatch --hold`:

```bash
scontrol release 1234
```

Only release it when its inputs and dependencies are ready. A held job is not
doing computation and Slurm cannot predict when you will release it.

The shared accounting account is `hpc`; it is an administrative grouping, not
a separate Linux login. Its existence does not add a per-user GPU quota. Jobs
completed before history was enabled are not recovered.
