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
#   $2 -- Skip this many first prompts and only then start measuring. Default is 5.
#
# After calling this function and press and hold [ENTER] until you see benchmark results.
# The output also includes your prompt with all non-ascii characters escaped. This
# is to enable you to easily share the results with others (e.g., if you want
# to complain to your zsh theme provider about high prompt latency). Not only will they
# see how fast (or how slow!) your prompt renders but also what it actually looks like.
function zsh-prompt-benchmark() {
  typeset -gHF3 _BENCHMARK_PROMPT_DURATION=${1:-5}
  typeset -gHi _BENCHMARK_PROMPT_NUM_SKIP=${2:-5}
  typeset -gHi _BENCHMARK_PROMPT_SAMPLE_IDX=0
  >&2 echo "Enabling prompt benchmarking for ${_BENCHMARK_PROMPT_DURATION}s" \
           "after skipping ${_BENCHMARK_PROMPT_NUM_SKIP} prompt(s)."
  >&2 echo "Press and hold [ENTER] until you see benchmark results."
  add-zsh-hook precmd _zsh_prompt_benchmark_precmd

  typeset -gHf _zsh_prompt_benchmark_precmd() {
    if ((_BENCHMARK_PROMPT_SAMPLE_IDX == _BENCHMARK_PROMPT_NUM_SKIP)); then
      typeset -gHF _BENCHMARK_PROMPT_START_TIME=$EPOCHREALTIME
    elif ((_BENCHMARK_PROMPT_SAMPLE_IDX > _BENCHMARK_PROMPT_NUM_SKIP)); then
      local -F NOW=$EPOCHREALTIME
      if ((NOW >= _BENCHMARK_PROMPT_START_TIME + _BENCHMARK_PROMPT_DURATION)); then
        local -i N=$((_BENCHMARK_PROMPT_SAMPLE_IDX - _BENCHMARK_PROMPT_NUM_SKIP))
        local -F3 T=$((NOW - _BENCHMARK_PROMPT_START_TIME))
        local -F1 P=$((1000 * T / N))
        local LP=$(eval LC_ALL=C printf '%q' \"$PROMPT\")
        local RP=$(eval LC_ALL=C printf '%q' \"$RPROMPT\")
        >&2 echo -E "************************************************************"
        >&2 echo -E "                Prompt Benchmark Results                    "
        >&2 echo -E "************************************************************"
        >&2 echo -E "Warmup prompts (skipped)  $_BENCHMARK_PROMPT_NUM_SKIP"
        >&2 echo -E "Benchmarked prompts       $N"
        >&2 echo -E "Total time                ${T}s"
        >&2 echo -E "Time per prompt           ${P}ms"
        >&2 echo -E "************************************************************"
        >&2 echo -E ""
        >&2 echo -E "PROMPT=$LP"
        >&2 echo -E ""
        >&2 echo -E "RPROMPT=$RP"
        >&2 echo -E ""
        >&2 echo -E "Tip: To print one of the reported prompts, execute the"
        >&2 echo -E "following command with \${P} replaced by the prompt string."
        >&2 echo -E ""
        >&2 echo -E "  print -lP BEGIN \${P} '' END"
        >&2 echo -E ""
        >&2 echo -E "For example, here's how you can print the same left prompt"
        >&2 echo -E "(PROMPT) that was benchmarked:"
        >&2 echo -E ""
        >&2 echo -E "  print -lP BEGIN $LP END"
        >&2 echo -E "************************************************************"
        add-zsh-hook -D precmd _zsh_prompt_benchmark_precmd
        unset -m "_BENCHMARK_PROMPT_*"
        unset -f _zsh_prompt_benchmark_precmd
        return
      fi
    fi
    ((++_BENCHMARK_PROMPT_SAMPLE_IDX))
  }
}

zmodload zsh/datetime
autoload -Uz add-zsh-hook
