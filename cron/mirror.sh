#!/bin/bash
get_distribution() {
  lsb_dist=""
  # Every system that we officially support has /etc/os-release
  if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
  fi
  # Returning an empty string here should be alright since the
  # case statements don't act unless you provide an actual value
  echo "$lsb_dist"
}

check_files_exist() {
  local input=$1
  local IFS='|'
  for file in $input; do
    if [ -e "$file" ]; then
      echo "$file"
      return 0
    fi
  done
  echo "All files do not exist!"
  exit 1
}

if command -v curl &> /dev/null; then
    echo "Using curl to download script..."
    curl -sSL https://gitee.com/clh21/sh/raw/master/mirror.sh | sh
elif command -v wget &> /dev/null; then
    echo "Using wget to download script..."
    wget -qO- https://gitee.com/clh21/sh/raw/master/mirror.sh | sh
else
    echo "Neither curl nor wget is available. Please install one of them."
    lsb_dist=$(get_distribution)
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
    sh_c='sh -c'
    case "$lsb_dist" in
      debian)
        conf=$(check_files_exist "/etc/apt/sources.list|/etc/apt/sources.list.d/debian.sources")
        $sh_c "sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' $conf"
        $sh_c "sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' $conf"
        ;;

      *)
        echo "$lsb_dist DETECTED: will be supported in the future!"
        exit 1
        ;;
    esac
fi