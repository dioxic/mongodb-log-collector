#!/usr/bin/env bash
set -e
. "$WORKDIR/common/common.sh"

cli_help_deploy() {
  echo "
Command: collect

Usage:
  collect project_name

Flags:
  -t          filter by type
  -d          filter by data centre
  -p          filter by purpose
  -i          filter by index"
  exit 1
}

[ ! -n "$1" ] && cli_help_deploy

filters=0

while getopts t:d:p:i:h: flag
do
    case "${flag}" in
        t)
          export fType=${OPTARG}
          filters=$(($filters + 1))
          ;;
        d)
          export fDC=${OPTARG}
          filters=$(($filters + 1))
          ;;
        p)
          export fPurpose=${OPTARG}
          filters=$(($filters + 1))
          ;;
        i)
          export fIndex=${OPTARG}
          filters=$(($filters + 1))
          ;;
        h)
          export fHost=${OPTARG}
          filters=$(($filters + 1))
          ;;
    esac
done

echo "Filters ($filters):"
[[ ! -z "$fType" ]] && echo "  Type=$fType";
[[ ! -z "$fDC" ]] && echo "  Data Center=$fDC";
[[ ! -z "$fPurpose" ]] && echo "  Purpose=$fPurpose";
[[ ! -z "$fIndex" ]] && echo "  Index=$fIndex";
[[ ! -z "$fHost" ]] && echo "  Host=$fHost";
echo ""

[ ! -f "$NODES_CONFIG" ] \
  && echo "ERROR: No nodes cfg found at $NODES_CONFIG. " \
  && exit 1

#print_nodes $NODES_CONFIG index host type purpose dc scratch logs
filtered_nodes=()
filter_nodes $NODES_CONFIG $filters

echo "matching nodes:"
for i in ${!filtered_nodes[@]}; do
  echo "  ${filtered_nodes[$i]}"
done

echo "Collecting logs..."
for i in ${!filtered_nodes[@]}; do
  iHost=$(get_host_cfg "${filtered_nodes[$i]}")
  iScratch=$(get_scratch_cfg "${filtered_nodes[$i]}")
  iLog=$(get_log_cfg "${filtered_nodes[$i]}")
  iPurpose=$(get_purpose_cfg "${filtered_nodes[$i]}")
  iType=$(get_type_cfg "${filtered_nodes[$i]}")

  prep_log_dir $iHost $iScratch
  copy_log_to_scratch $iHost $iScratch $iLog

  [[ "$iPurpose" == "APP" ]] && copy_mms_conf_to_scratch $iHost $iScratch
  if [[ "$iPurpose" == "NOSQL" ]]; then
    copy_mongod_ftdc_to_scratch $iHost $iScratch
    copy_mongod_conf_to_scratch $iHost $iScratch
  fi

  zip_scratch $iHost $iScratch $iPurpose
  scp_log_zip $iHost $iScratch
done