# LLM smoke test: load a model and check its answers

This example downloads the small instruction-tuned model
[`Qwen/Qwen2.5-0.5B-Instruct`](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct),
runs it on a GPU, and checks two deliberately simple answers. It is a useful
first test of a new LLM workflow: if either answer is unexpected, the Slurm
job fails and the job log explains why.

The model is about 0.5 billion parameters, so it is suitable for a quick
single-GPU test rather than serious evaluation or training.

!!! note
    The compute node needs access to Hugging Face the first time this is run.
    The model is then retained in your personal cache under your home
    directory.

## 1. Create a project directory

Work in your home directory. Every account can write here.

```bash
mkdir -p "$HOME/llm-smoke-test/logs"
mkdir -p "$HOME/.cache/huggingface"
cd "$HOME/llm-smoke-test"
```

## 2. Add the Python dependencies

Create `requirements.txt`:

```text title="requirements.txt"
transformers==4.48.3
safetensors==0.5.2
```

## 3. Add the answer checks

Create `test_llm.py`:

```python title="test_llm.py"
import sys
import unittest

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


MODEL_ID = "Qwen/Qwen2.5-0.5B-Instruct"


class LLMAnswerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        print("Loading tokenizer...", flush=True)
        cls.tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)

        print("Tokenizer loaded. Loading model; the first run may download it...", flush=True)
        cls.model = AutoModelForCausalLM.from_pretrained(
            MODEL_ID, torch_dtype=torch.bfloat16
        ).to("cuda")
        cls.model.eval()
        print(f"Model ready on {torch.cuda.get_device_name(0)}.", flush=True)

    @classmethod
    def answer(cls, question):
        print(f"Asking: {question}", flush=True)
        messages = [
            {
                "role": "system",
                "content": "Reply with only the requested answer. Do not explain.",
            },
            {"role": "user", "content": question},
        ]
        inputs = cls.tokenizer.apply_chat_template(
            messages, add_generation_prompt=True, return_tensors="pt"
        ).to("cuda")

        with torch.inference_mode():
            output = cls.model.generate(
                inputs,
                do_sample=False,
                max_new_tokens=8,
                pad_token_id=cls.tokenizer.eos_token_id,
            )

        answer_tokens = output[0][inputs.shape[-1] :]
        answer = cls.tokenizer.decode(answer_tokens, skip_special_tokens=True).strip()
        print(f"Received: {answer}", flush=True)
        return answer

    def test_basic_arithmetic(self):
        self.assertEqual(self.answer("What is 2 + 2?"), "4")

    def test_capital_city(self):
        self.assertEqual(
            self.answer("What is the capital of France?"), "Paris"
        )


if __name__ == "__main__":
    runner = unittest.TextTestRunner(stream=sys.stdout, verbosity=2)
    unittest.main(testRunner=runner)
```

`do_sample=False` makes generation deterministic for a fixed model, prompt,
and software stack. These are smoke tests, not a measure of an LLM's quality:
for research evaluation, use a task-specific dataset and scoring method.

## 4. Submit the job

Create `llm-smoke-test.sbatch`:

The script has three parts: the `#SBATCH` lines request resources, the small
background loop writes a status update every 30 seconds, and `srun` starts the
container and runs the test. All messages go to one `.out` file, including
normal Pyxis container-import messages.

```bash title="llm-smoke-test.sbatch"
#!/bin/bash
# Ask Slurm for the resources this small test needs.
#SBATCH --job-name=llm-smoke-test
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:30:00
#SBATCH --output=logs/%x-%j.out

set -euo pipefail

# Write a reassuring update while the first container or model download runs.
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Job started on $(hostname)."
while sleep 30; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Still running - preparing the container, installing packages, downloading the model, or testing."
done &
heartbeat_pid=$!
trap 'kill "$heartbeat_pid" 2>/dev/null || true' EXIT

# Run the commands below inside the GPU container. The first run may take
# several minutes while Pyxis imports the image. Pyxis cannot create directories so ensure all directories exist before running the job.
mkdir -p "$HOME/.cache/huggingface"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting the container."
srun --container-image=docker://nvcr.io/nvidia/pytorch:25.06-py3 \
     --container-mounts="$SLURM_SUBMIT_DIR:/workspace,$HOME/.cache/huggingface:/hf-cache" \
     --container-workdir=/workspace \
     bash -lc '
       set -euo pipefail
       echo "Installing Python dependencies."
       python -m pip install --disable-pip-version-check --target /workspace/.packages -r requirements.txt
       echo "Dependencies are ready. Loading and testing the model."
       PYTHONPATH=/workspace/.packages HF_HOME=/hf-cache python -u test_llm.py
     '

echo "[$(date '+%Y-%m-%d %H:%M:%S')] All LLM smoke tests completed successfully."
```

!!! tip
    `bash -lc '...'` in the `srun` command simply means “run these commands
    inside the container.” It first installs the two Python packages, then
    runs `test_llm.py`.

The job writes a timestamped progress update every 30 seconds, including while
the container is being prepared or the model is downloading.

Submit it:

```bash
sbatch llm-smoke-test.sbatch
```

## 5. Watch the job and read the result

Check whether the job is waiting or running:

```bash
squeue -u $USER
```

Once `sbatch` prints a job ID, watch its output live. Replace `<job-id>` with
that ID:

```bash
tail -f logs/llm-smoke-test-<job-id>.out
```

Press `Ctrl+C` to stop watching the log; this does **not** cancel the job.
On success, the end of the log includes:

```text
test_basic_arithmetic ... ok
test_capital_city ... ok

OK
[YYYY-MM-DD HH:MM:SS] All LLM smoke tests completed successfully.
```

The first run takes longer because it downloads the container dependencies and
the model. Later runs reuse the model cache and the Python packages stored in
your home directory.
