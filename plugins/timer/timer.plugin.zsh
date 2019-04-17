__timer_current_time() {
  perl -MTime::HiRes=time -e'print time'
}

__timer_format_duration() {
  local hours=$(printf '%.0f' $(($1 / 3600)))
  local mins=$(printf '%.0f' $((($1 - 3600 * hours) / 60)))
  local secs=$(printf "%.${TIMER_PRECISION:-2}f" $((($1 - 3600 * hours) - 60 * mins)))
  local duration_str=$(echo "${hours}h${mins}m${secs}s")
  local format="${TIMER_FORMAT:-/%d}"
  echo "${format//\%d/${${duration_str#0h}#0m}}"
}

__timer_save_time_preexec() {
  __timer_cmd_start_time=$(__timer_current_time)
}

__timer_display_timer_precmd() {
  if [ -n "${__timer_cmd_start_time}" ]; then
    local cmd_end_time=$(__timer_current_time)
    local tdiff=$((cmd_end_time - __timer_cmd_start_time))
    unset __timer_cmd_start_time
    local tdiffstr=$(__timer_format_duration ${tdiff})
    local cols=$((COLUMNS - ${#tdiffstr} - 1))
    echo -e "\033[1A\033[${cols}C ${tdiffstr}"
  fi
}

preexec_functions+=(__timer_save_time_preexec)
precmd_functions+=(__timer_display_timer_precmd)
