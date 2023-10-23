#!/usr/bin/env bash

set -e
export WORKDIR=$(cd $(dirname $0) && pwd)
. "$WORKDIR/common/common.sh"

cli_help() {
  cli_name=${0##*/}
  echo "
MongoDB Collector CLI
Version: 0.2
https://github.com/dioxic/mongodb-log-downloader

Usage: $cli_name [command]

Commands:
  collect   Collect logs
  *         Help
"
  exit 1
}

cmd=$1

if [ -z "$cmd" ]
then
  cli_help
fi

shift 1

case "$cmd" in
  collect)
    "$WORKDIR/commands/collect.sh" "$@" | tee -ia "$LOG_DIR/mlc.log"
    ;;
  *)
    echo "ERT"
    cli_help
    ;;
esac