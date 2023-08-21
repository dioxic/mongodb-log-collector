#!/usr/bin/env bash
cli_log() {
  script_name=${0##*/}
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "== $script_name $timestamp $1"
  echo "== $script_name $timestamp $1" >> $LOG_DIR/mlc.log
}

#export CONFIG_DIR=/home/mongoadm/cfg
#export LOG_DIR=/var/log/motk

print_nodes() {
  while IFS=" " read -r index host type purpose dc scratch logs
  do
    echo "Index-$index"
    echo "Host: $host"
    echo "Type: $type"
    echo "Purpose: $purpose"
    echo "Data Centre: $dc"
    echo "Scratch: $scratch"
    echo "Logs: $logs"
    echo ""
  done < <(tail -n +2 $1)
}

# args: file filtersNum filterArr
filter_nodes() {
#    local -n filtered_arr=$3

    while IFS=" " read -r index host type purpose dc scratch logs
    do
      matches=0

      if [[ ! -z "$fType" && $type == $fType ]]
      then
        matches=$((matches + 1))
      fi

      if [[ ! -z "$fHost" && $host == $fHost ]]
      then
        matches=$((matches + 1))
      fi

      if [[ ! -z "$fIndex" && $index == $fIndex ]]
      then
        matches=$((matches + 1))
      fi

      if [[ ! -z "$fPurpose" && $purpose == $fPurpose ]]
      then
        matches=$((matches + 1))
      fi

      if [[ ! -z "$fDC" && $dc == $fDC ]]
      then
        matches=$((matches + 1))
      fi

      if [ $matches -eq $2 ]
      then
        filtered_nodes+=( "$index $host $type $purpose $dc $scratch $logs" )
      fi

    done < <(tail -n +2 $1)
}

filter_nodes_old() {
  filtered_arr=()
  readarray nodes < $NODES_CONFIG

#  echo $nodes
  match=0

  for i in ${!nodes[@]}; do
    echo ${nodes[$i]} | IFS=" " read -r index host type purpose dc scratch logs

    echo $host
  done

  for t in ${nodes[@]}; do

#    echo $t
#    echo $t | read -r index host type purpose dc scratch logs

#    echo $tIndex
    filtered_arr+=t
    match=$(($match + 1))
  done

#  echo $match
}

export NODES_CONFIG=$WORKDIR/nodes.cfg
export LOG_DIR=/tmp/mlc