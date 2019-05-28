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
#   $1 -- Benchmark for this many seconds. Default is 5.
#   $2 -- Sleep for this many seconds before benchmarking to fill the keyboard input buffer.
#         This mitigates the problem caused by slow key repeat rate (see below). Default is 10.
#
# After calling this function in an interactive shell you need to press and hold [ENTER] until
# you see benchmark results. It'll take 15 seconds with default arguments. The output also includes
# your prompt with all non-ascii characters escaped. This is to enable you to easily share the
# results with others (e.g., if you want to complain to your zsh theme provider about high prompt
# latency). Not only will they see how fast (or how slow!) your prompt renders but also what it
# actually looks like.
#
# Make sure your repeat key rate is high enough that your shell is unable to keep up. While not
# benchmarking, press and hold [ENTER]. If you see empty lines between prompts or if prompts keep
# being printed after you release [ENTER], your repeat key rate is sufficient. If it's not,
# you can artificially boost it by buffering keyboard input buffer. Your effective key repeat
# rate is multiplied by 1 + $2 / $1. With default settings this is 1 + 10 / 5 == 3.
function zsh-prompt-benchmark() {
  typeset -gF3 _benchmark_prompt_duration=${1:-5}
  typeset -gi  _benchmark_prompt_warmup_duration=${2:-10}
  typeset -gi  _benchmark_prompt_sample_idx=0
  typeset -gF3 _benchmark_prompt_start_time=0
  >&2 echo "Enabling prompt benchmarking for ${_benchmark_prompt_duration}s" \
           "after buffering keyboard input for ${_benchmark_prompt_warmup_duration}s."
  >&2 echo "Press and hold [ENTER] until you see benchmark results."
  zmodload zsh/datetime
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _zsh_prompt_benchmark_precmd

  function _zsh_prompt_benchmark_precmd() {
    local -F now=$EPOCHREALTIME
    ((++_benchmark_prompt_sample_idx))
    ((now >= _benchmark_prompt_start_time + _benchmark_prompt_duration)) || return
    (( _benchmark_prompt_start_time )) && {
      local -i n=$((_benchmark_prompt_sample_idx - 1))
      local -F3 t=$((now - _benchmark_prompt_start_time))
      local -F2 p=$((1000 * t / n))
      [[ -o prompt_subst ]] && {
        local lp=$(eval LC_ALL=C printf '%q' \"${PROMPT-}\")
        local rp=$(eval LC_ALL=C printf '%q' \"${RPROMPT-}\")
      } || {
        local lp=$(LC_ALL=C printf '%q' "${PROMPT-}")
        local rp=$(LC_ALL=C printf '%q' "${RPROMPT-}")
      }
      [[ -o prompt_percent ]] && local o=P || local o=''
      >&2 echo -E "************************************************************"
      >&2 echo -E "                Prompt Benchmark Results                    "
      >&2 echo -E "************************************************************"
      >&2 echo -E "Warmup duration           ${_benchmark_prompt_warmup_duration}s"
      >&2 echo -E "Benchmarked prompts       $n"
      >&2 echo -E "Total time                ${t}s"
      >&2 echo -E "Time per prompt           ${p}ms"
      >&2 echo -E "************************************************************"
      >&2 echo -E ""
      >&2 echo -E "PROMPT=${(%):-%K{green\}}$lp${(%):-%k}"
      >&2 echo -E ""
      >&2 echo -E "RPROMPT=${(%):-%K{green\}}$rp${(%):-%k}"
      >&2 echo -E ""
      >&2 echo -E "Tip: To print one of the reported prompts, execute the"
      >&2 echo -E "following command with \${p} replaced by the prompt string."
      >&2 echo -E ""
      >&2 echo -E "  print -l${o} BEGIN \${p} '' END"
      >&2 echo -E ""
      >&2 echo -E "For example, here's how you can print the same left prompt"
      >&2 echo -E "(PROMPT) that was benchmarked:"
      >&2 echo -E ""
      >&2 echo -E "  print -l${o} BEGIN ${(%):-%K{green\}}$lp${(%):-%k} END"
      >&2 echo -E "************************************************************"
      >&2 echo -E ""
      >&2 echo -E "Press 'q' to continue..."
      unset -m "_benchmark_prompt_*"
      unset -f _zsh_prompt_benchmark_precmd
      add-zsh-hook -D precmd _zsh_prompt_benchmark_precmd
      local r && IFS='' read -rsd q r
    } || {
      sleep $_benchmark_prompt_warmup_duration
      typeset -gF _benchmark_prompt_start_time=$EPOCHREALTIME
    }
  }
}
