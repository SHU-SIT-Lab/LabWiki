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
    The model is then retained in the cache mounted from `/home/data/containers`.

## 1. Create a project directory

```bash
mkdir -p /home/data/scratch/$USER/llm-smoke-test/logs
mkdir -p /home/data/containers/huggingface/$USER
cd /home/data/scratch/$USER/llm-smoke-test
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
import unittest

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


MODEL_ID = "Qwen/Qwen2.5-0.5B-Instruct"


class LLMAnswerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
        cls.model = AutoModelForCausalLM.from_pretrained(
            MODEL_ID, torch_dtype=torch.bfloat16
        ).to("cuda")
        cls.model.eval()

    @classmethod
    def answer(cls, question):
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
        return cls.tokenizer.decode(answer_tokens, skip_special_tokens=True).strip()

    def test_basic_arithmetic(self):
        self.assertEqual(self.answer("What is 2 + 2?"), "4")

    def test_capital_city(self):
        self.assertEqual(
            self.answer("What is the capital of France?"), "Paris"
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
```

`do_sample=False` makes generation deterministic for a fixed model, prompt,
and software stack. These are smoke tests, not a measure of an LLM's quality:
for research evaluation, use a task-specific dataset and scoring method.

## 4. Submit the job

Create `llm-smoke-test.sbatch`:

```bash title="llm-smoke-test.sbatch"
#!/bin/bash
#SBATCH --job-name=llm-smoke-test
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:20:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

srun --container-image=nvcr.io#nvidia/pytorch:24.05-py3 \
     --container-mounts=/home/data/scratch/$USER/llm-smoke-test:/workspace,/home/data/containers/huggingface/$USER:/hf-cache \
     --container-workdir=/workspace \
     bash -lc 'python -m pip install --disable-pip-version-check --target /workspace/.packages -r requirements.txt && PYTHONPATH=/workspace/.packages HF_HOME=/hf-cache python test_llm.py'
```

Submit it:

```bash
sbatch llm-smoke-test.sbatch
```

## 5. Read the result

Check the job is running or waiting:

```bash
squeue -u $USER
```

Once it has finished, inspect the output. Replace `<job-id>` with the ID
printed by `sbatch`:

```bash
cat logs/llm-smoke-test-<job-id>.out
```

On success, the end of the log includes:

```text
test_basic_arithmetic ... ok
test_capital_city ... ok

OK
```

The first run takes longer because it downloads the container dependencies and
the model. Later runs reuse the model cache and the Python packages stored in
the project directory.
