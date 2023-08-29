# MongoDB Log Collector

This tool is designed to SCP log files and diagnostic data from a MongoDB environment based off a configuration file.

## Prerequisites

1. A SSH key that is authorized on the host machines
2. The user of the SSH key is part of the group that owns the log and diagnostic data
3. The group has read-only access to the log and diagnostic data
4. Network connectivity to the host machines from wherever the script is executed from

## Environment variables

The following environment variables are expected. They should be set to appropriate values

export NODES_CONFIG=$WORKDIR/nodes.cfg
export LOG_DIR=/tmp/mlc
export SSH_KEY=~/.ssh/mongoadm.pem
export SSH_USER=mongoadm

## Configuration file format

The configuration file is a space-delimited file containing information for the FQDN, host type, host purpose and data centre.

The expected format is show below:

```
index host type purpose dc
0 example-mms0.mdbrecruit.net APP FRONTEND DC1
1 example-mms0.mdbrecruit.net APP BACKUPD DC1
2 example-mms0.mdbrecruit.net APP RESTORED DC1
3 example-rs0.mdbrecruit.net NOSQL MONGOD DC1
```

Note that adding additional columns or changing to a CSV or TSV structure will require modification to the script but this is trivial to do.

IMPORTANT: the configuration file should end with a new line character

## Usage

### Top-Level

```
Usage: cli.sh [command]

Commands:
collect   Collect logs
*         Help
```

### Collect Command

```
Command: collect

Usage:
collect

Flags:
-t          filter by type
-d          filter by data centre
-p          filter by purpose
-i          filter by index
```

The flags are used to filter the hosts in the configuration file and determine which hosts to retrieve the logs from.

The location of the log and diganostic files are hardcoded but this could be added to the configuration file and passed through to the SCP function.

Example:
```
> ./cli.sh collect -t NOSQL
Filters (1):
  Type=NOSQL

matching nodes:
  3 example-rs0.mdbrecruit.net NOSQL MONGOD DC1
Collecting logs...
  example-rs0.mdbrecruit.net
```
