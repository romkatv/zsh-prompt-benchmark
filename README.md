# zsh-prompt-benchmark
**zsh-prompt-benchmark** allows you to measure how long it takes for your zsh
prompt to render. Roughly speaking, if you press and hold `[ENTER]`, how many
prompts will be printed per second?

# Installation

## Manually

```zsh
git clone https://github.com/romkatv/zsh-prompt-benchmark.git ~/zsh-prompt-benchmark
echo 'source ~/zsh-prompt-benchmark/zsh-prompt-benchmark.plugin.zsh' >>! ~/.zshrc
```

## With Oh My Zsh

Clone the repo.

```zsh
git clone https://github.com/romkatv/zsh-prompt-benchmark.git "$ZSH_CUSTOM/plugins/zsh-prompt-benchmark"
```

Enable `zsh-prompt-benchmark` plugin in `~/.zshrc`.

```zsh
plugins=(
  ...
  zsh-prompt-benchmark
)
```

# Usage

```zsh
zsh-prompt-benchmark [duration [warmup [done]]]
```

Optional positional arguments:

- `duration` -- Benchmark for this many seconds. Default is 2.
- `warmup` -- Sleep for this many seconds before benchmarking to fill the keyboard input buffer.
  This mitigates the problem caused by slow key repeat rate (see below). Default is 8.
- `done` -- Run this command (via `eval`) when done. Default is empty.

After calling `zsh-prompt-benchmark` in an interactive shell you need to press and hold `[ENTER]`
until you see benchmark results. It'll take 10 seconds with default arguments.

Make sure your repeat key rate is high enough that your shell is unable to keep up. While not
benchmarking, press and hold `[ENTER]`. If you see empty lines between prompts or if prompts keep
being printed after you release `[ENTER]`, your repeat key rate is sufficient. If it's not,
you can artificially boost it by buffering keyboard input buffer. Your effective key repeat
rate is multiplied by `1 + warmup / duration`. With default settings this is `1 + 8 / 2 == 5`.

Example output:

```
********************************************************************  
                      Prompt Benchmark Results                      
********************************************************************
Warmup duration      8s
Benchmark duration   2.003s
Benchmarked prompts  553
Time per prompt      3.62ms  <-- prompt latency (lower is better)
********************************************************************
```

# Why

I wrote it while optimizing [Powerlevel9k](https://github.com/powerlevel9k/powerlevel9k) ZSH theme,
which resulted in the much faster [Powerlevel10k](https://github.com/romkatv/powerlevel10k).
