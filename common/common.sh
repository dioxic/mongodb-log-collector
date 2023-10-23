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

scp_log_zip() {
    scp -ri "$SSH_KEY" -o "StrictHostKeyChecking=no" "$SSH_USER"@"$1":"$2/*-diag.tar.gz" "$WORKDIR"
}

prep_log_dir() {
  ssh -i "$SSH_KEY" -o "StrictHostKeyChecking=no" "$SSH_USER"@"$1" "rm -rf $2/log-collector; mkdir $2/log-collector"
}

# copy logs to scratch
copy_log_to_scratch() {
  ssh -i "$SSH_KEY" -o "StrictHostKeyChecking=no" "$SSH_USER"@"$1" "cp $3/* $2/log-collector"
}

copy_mms_conf_to_scratch() {
  ssh -i "$SSH_KEY" -o "StrictHostKeyChecking=no" "$SSH_USER"@"$1" "cp -r /opt/mongodb/mms/conf $2/log-collector"
}

copy_mongod_conf_to_scratch() {
  ssh -i "$SSH_KEY" -o "StrictHostKeyChecking=no" "$SSH_USER"@"$1" "cp /etc/mongod.conf $2/log-collector"
}

copy_mongod_ftdc_to_scratch() {
  ssh -i "$SSH_KEY" -o "StrictHostKeyChecking=no" "$SSH_USER"@"$1" "cp -r /mongod/diagnostic.data $2/log-collector"
}

# host scratch purpose
zip_scratch() {
  ssh -i "$SSH_KEY" -o "StrictHostKeyChecking=no" "$SSH_USER"@"$1" "cd $2; tar -czf $1-$3-diag.tar.gz log-collector"
}

# node column
get_host_cfg() {
  echo $1 | (IFS=" " read gIndex gHost gOther; echo $gHost)
}

# scratch column
get_scratch_cfg() {
  echo $1 | (IFS=" " read gIndex gHost gPurpose gType gDc gScratch gOther; echo $gScratch)
}

# log column
get_log_cfg() {
  echo $1 | (IFS=" " read gIndex gHost gPurpose gType gDc gScratch gLog; echo $gLog)
}

# purpose column
get_purpose_cfg() {
  echo $1 | (IFS=" " read gIndex gHost gPurpose gOther; echo $gPurpose)
}

# purpose column
get_type_cfg() {
  echo $1 | (IFS=" " read gIndex gHost gPurpose gType gOther; echo $gType)
}