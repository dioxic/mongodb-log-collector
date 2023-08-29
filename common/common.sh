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
  while IFS=" " read -r index host type purpose dc
  do
    echo "Index-$index"
    echo "Host: $host"
    echo "Type: $type"
    echo "Purpose: $purpose"
    echo "Data Centre: $dc"
    echo ""
  done < <(tail -n +2 $1)
}

# args: file filtersNum filterArr
filter_nodes() {
#    local -n filtered_arr=$3

    while IFS=" " read -r index host type purpose dc
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
        filtered_nodes+=( "$index $host $type $purpose $dc" )
      fi

    done < <(tail -n +2 $1)
}

#host path
scp_file() {
  scp -ri "$SSH_KEY" -o "StrictHostKeyChecking=no" "$SSH_USER"@"$1":"$2" "$WORKDIR"/$(basename $2)
}

# node line
get_host() {
  echo $1 | (IFS=" " read gIndex gHost gOther; echo $gHost)
}

export NODES_CONFIG=$WORKDIR/nodes.cfg
export LOG_DIR=/tmp/mlc
export SSH_KEY=~/.ssh/markbm.pem
export SSH_USER=ec2-user
