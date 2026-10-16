<div class="landing-hero">
  <div class="landing-hero__content">
    <p class="eyebrow">SHU SIT LAB &middot; RESEARCH COMPUTING</p>
    <h1>Move from idea to GPU job.</h1>
    <p class="landing-lede">A practical guide to using the lab's DGX Spark system: schedule GPU work with Slurm and run reproducible environments with Enroot and Pyxis.</p>
    <p class="hero-actions">
      <a class="md-button md-button--primary" href="getting-started/">Run your first job</a>
      <a class="md-button" href="llm-smoke-test/">Try the LLM example</a>
    </p>
  </div>
  <dl class="hero-facts">
    <div>
      <dt>Compute</dt>
      <dd>DGX Spark</dd>
    </div>
    <div>
      <dt>Scheduling</dt>
      <dd>Slurm</dd>
    </div>
    <div>
      <dt>Environments</dt>
      <dd>Enroot + Pyxis</dd>
    </div>
  </dl>
</div>

!!! important "GPU workflow updated — 16 October 2026"
    Run GPU work in a **Slurm allocation using an Enroot/Pyxis container**.
    Ordinary SSH sessions on the manager cannot access the GPU. Read
    [what changed for users](cluster-updates.md), including shared homes,
    login-session limits and [job history](job-history.md).

## Choose your next step

<div class="journey-grid">
  <a class="journey-card" href="getting-started/">
    <span class="journey-card__number">01</span>
    <span class="journey-card__title">Get connected</span>
    <span class="journey-card__body">Set up NVIDIA Sync, check the system, and submit your first GPU job.</span>
    <span class="journey-card__link">Start here &rarr;</span>
  </a>
  <a class="journey-card" href="llm-smoke-test/">
    <span class="journey-card__number">02</span>
    <span class="journey-card__title">Follow a complete example</span>
    <span class="journey-card__body">Load a small LLM and run tests that verify its expected answers.</span>
    <span class="journey-card__link">Run the LLM test &rarr;</span>
  </a>
  <a class="journey-card" href="containers/">
    <span class="journey-card__number">03</span>
    <span class="journey-card__title">Run your own work</span>
    <span class="journey-card__body">Use a containerised environment for reproducible Python, CUDA, and ML workloads.</span>
    <span class="journey-card__link">Work with containers &rarr;</span>
  </a>
</div>

<div class="storage-callout">
  <div>
    <p class="eyebrow">KEEP PROJECTS ORGANISED</p>
    <h2>Start personal work in your home directory.</h2>
  </div>
  <p>Your personal <code>$HOME</code> is shared across all three nodes. Use it for project files, logs, and results; leave Enroot's working caches at their system defaults. Ask Josh about managed storage under <code>/home/data</code> and which nodes can access a project directory.</p>
</div>

## What is on the system?

| Component | What it is for |
|---|---|
| **DGX Spark** | NVIDIA GPU compute for research workloads |
| **Slurm** | Requests resources and runs interactive or batch jobs |
| **Enroot + Pyxis** | Runs containers directly through Slurm without `sudo` |

## Need help?

If a job fails or you need an account, contact **Josh Bamforth** at
[josh.bamforth@shu.ac.uk](mailto:josh.bamforth@shu.ac.uk). The
[FAQ & Troubleshooting](faq.md) page covers common job and container issues.
