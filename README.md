# zsh-prompt-benchmark
**zsh-prompt-benchmark** allows you to measure how long it takes for your zsh
prompt to render. Roughly speaking, if you press and hold `[ENTER]`, how many
prompts will be printed per second?

# Installation

## Manually

Download
[zsh-prompt-benchmark.plugin.zsh](https://github.com/romkatv/zsh-prompt-benchmark/blob/master/zsh-prompt-benchmark.plugin.zsh)
and source it.

```zsh
wget https://raw.githubusercontent.com/romkatv/zsh-prompt-benchmark/master/zsh-prompt-benchmark.plugin.zsh
source ./zsh-prompt-benchmark.plugin.zsh
```

## With Oh My Zsh

Clone the repo.

```zsh
git clone https://github.com/romkatv/zsh-prompt-benchmark.git "$ZSH_CUSTOM/plugins/zsh-prompt-benchmark"
```

Enable `zsh-prompt-benchmark` plugin in your `.zshrc`.

```zsh
# ~/.zshrc
plugins=(
  ...
  zsh-prompt-benchmark
)
```

# Usage

Type `zsh-prompt-benchmark` in an interactive zsh shell and press and hold
`[ENTER]` until you see benchmark results. It'll take 15 seconds with default arguments. The output
also includes your prompt with all non-ascii characters escaped. This is to enable you to easily
share the results with others (e.g., if you want to complain to your zsh theme provider about high
prompt latency). Not only will they see how fast (or how slow!) your prompt renders but also what it
actually looks like.

You can pass two optional arguments to `zsh-prompt-benchmark`:

  * `$1` -- Benchmark for this many seconds. Default is 5.
  * `$2` -- Sleep for this many seconds before benchmarking to fill the keyboard input buffer.
            This mitigates the problem caused by slow key repeat rate (see below). Default is 10.

Make sure your repeat key rate is high enough that your shell is unable to keep up. While not
benchmarking, press and hold `[ENTER]`. If you see empty lines between prompts or if prompts keep
being printed after you release `[ENTER]`, your repeat key rate is sufficient. If it's not,
you can artificially boost it by buffering keyboard input buffer. Your effective key repeat
rate is multiplied by `1 + $2 / $1`. With default settings this is `1 + 10 / 5` == `3`.

Example output:

```
************************************************************
                Prompt Benchmark Results
************************************************************
Warmup duration           10s
Benchmarked prompts       1737
Total time                5.002s
Time per prompt           2.88ms
************************************************************

PROMPT=$'\342'$'\225'$'\255'$'\342'$'\224'$'\200'%f%b%k%K\{004\}\ %F\{000\}$'\357'$'\201'$'\274'\ %F\{000\}\~/.oh-my-zsh/custom/themes/powerlevel10k\ %K\{002\}%F\{004\}$'\356'$'\202'$'\260'\ %F\{000\}$'\357'$'\204'$'\223'\ $'\357'$'\204'$'\246'\ master\ %k%F\{002\}$'\356'$'\202'$'\260'%f\ $'\n'$'\342'$'\225'$'\260'$'\342'$'\224'$'\200'\ 

RPROMPT=%\{$'\033'\[1A%\}%f%b%k%F\{102\}$'\356'$'\202'$'\262'%K\{102\}\ %F\{002\}%F\{002\}$'\357'$'\200'$'\214'\ %F\{005\}$'\356'$'\202'$'\262'%K\{005\}\ %F\{000\}%D\{%H:%M:%S\}\ %F\{000\}$'\357'$'\200'$'\227'\ %E%\{$'\033'\[00m%\}%\{$'\033'\[1B%\}

Tip: To print one of the reported prompts, execute the
following command with ${P} replaced by the prompt string.

  print -lP BEGIN ${P} '' END

For example, here's how you can print the same left prompt
(PROMPT) that was benchmarked:

  print -lP BEGIN $'\342'$'\225'$'\255'$'\342'$'\224'$'\200'%f%b%k%K\{004\}\ %F\{000\}$'\357'$'\201'$'\274'\ %F\{000\}\~/.oh-my-zsh/custom/themes/powerlevel10k\ %K\{002\}%F\{004\}$'\356'$'\202'$'\260'\ %F\{000\}$'\357'$'\204'$'\223'\ $'\357'$'\204'$'\246'\ master\ %k%F\{002\}$'\356'$'\202'$'\260'%f\ $'\n'$'\342'$'\225'$'\260'$'\342'$'\224'$'\200'\  END
************************************************************
```

# Why

I wrote it while optimizing prompt generation in
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k) ZSH theme, which resulted in
the much faster [Powerlevel10k](https://github.com/romkatv/powerlevel10k).
