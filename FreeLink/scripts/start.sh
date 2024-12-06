#!/system/bin/sh
clear
scripts=$(realpath $0)
scripts_dir=$(dirname ${scripts})
module_dir="/data/adb/modules/FreeLink"
# Determines a path that can be used for relative path references.
cd ${scripts_dir}

# Environment variable settings
export PATH="/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH"
source ${scripts_dir}/FreeLink.service
proxy_service() {
if [ ! -f "${module_dir}/disable" ]; then
  log Info "Module Enabled"
  log Info "start FreeLink"
  ${scripts_dir}/FreeLink.service enable > /dev/null 2>&1
else
  log Warn "Module Disabled"
  log Info "Module Disabled" > ${scripts_dir}/run.log
fi
${scripts_dir}/FreeLink.service description > /dev/null 2>&1
}

start_inotifyd() {
  PIDs=($(busybox pidof inotifyd))
  for PID in "${PIDs[@]}"; do
    if grep -q "${scripts_dir}/FreeLink.inotify" "/proc/$PID/cmdline"; then
      return
    fi
  done
  inotifyd "${scripts_dir}/FreeLink.inotify" "${module_dir}" > /dev/null 2>&1 &
}

proxy_service
start_inotifyd

# start.sh
