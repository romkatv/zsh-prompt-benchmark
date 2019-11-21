# Copyright 2019 Roman Perepelitsa
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Measures how long it takes for your zsh prompt to render. Roughly speaking,
# if you press and hold [ENTER], how many prompts will be printed per second?
#
# zsh-prompt-benchmark [duration [warmup [done]]]
#
# Optional positional arguments:
#
#   `duration` Benchmark for this many seconds. Default is 2.
#   `warmup`   Sleep for this many seconds before benchmarking to fill the keyboard input buffer.
#              This mitigates the problem caused by slow key repeat rate (see below). Default is 8.
#   `done`     Run this command (via `eval`) when done. Default is empty.
#
# After calling zsh-prompt-benchmark in an interactive shell you need to press and hold [ENTER]
# until you see benchmark results. It'll take 10 seconds with default arguments.
#
# Make sure your repeat key rate is high enough that your shell is unable to keep up. While not
# benchmarking, press and hold [ENTER]. If you see empty lines between prompts or if prompts keep
# being printed after you release [ENTER], your repeat key rate is sufficient. If it's not,
# you can artificially boost it by buffering keyboard input buffer. Your effective key repeat
# rate is multiplied by 1 + warmup / duration. With default settings this is 1 + 8 / 2 == 5.
function zsh-prompt-benchmark() {
  emulate -L zsh

  zmodload zsh/datetime
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _zsh_prompt_benchmark_precmd

  typeset -gF3 _benchmark_prompt_duration=${1:-2}
  typeset -gi  _benchmark_prompt_warmup_duration=${2:-8}
  typeset -g   _benchmark_prompt_on_done=${3:-}
  typeset -gi  _benchmark_prompt_sample_idx=0
  typeset -gF3 _benchmark_prompt_start_time=0

  >&2 echo "Enabling prompt benchmarking for ${_benchmark_prompt_duration}s" \
           "after buffering keyboard input for ${_benchmark_prompt_warmup_duration}s."
  >&2 echo "Press and hold [ENTER] until you see benchmark results."

  function _zsh_prompt_benchmark_precmd() {
    local -F now=EPOCHREALTIME
    ((++_benchmark_prompt_sample_idx))
    ((now >= _benchmark_prompt_start_time + _benchmark_prompt_duration)) || return
    (( _benchmark_prompt_start_time )) && {
      emulate -L zsh
      local REPLY on_done=$_benchmark_prompt_on_done
      local -i n=$((_benchmark_prompt_sample_idx - 1))
      local -F3 t=$((now - _benchmark_prompt_start_time))
      local -F2 p=$((1000 * t / n))
      >&2 print -lr --                                                         \
        "********************************************************************" \
        "                      Prompt Benchmark Results                      " \
        "********************************************************************" \
        "Warmup duration      ${_benchmark_prompt_warmup_duration}s"           \
        "Benchmark duration   ${t}s"                                           \
        "Benchmarked prompts  $n"                                              \
        "Time per prompt      ${p}ms  <-- prompt latency (lower is better)"    \
        "********************************************************************" \
        ""                                                                     \
        "Press 'q' to continue..."
      unset -m "_benchmark_prompt_*"
      add-zsh-hook -D precmd _zsh_prompt_benchmark_precmd
      unset -f _zsh_prompt_benchmark_precmd
      IFS='' read -rsd q
      eval $on_done || true
    } || {
      sleep $_benchmark_prompt_warmup_duration
      typeset -gF _benchmark_prompt_start_time=EPOCHREALTIME
    }
  }
}
