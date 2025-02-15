#!/bin/bash

set -o errexit
set -e

err_report() {
    echo "Error on line $1 : $2"
}
FILENAME=`basename $0`
trap 'err_report $LINENO $FILENAME' ERR

function finish {
  kill -15 $DAEMONPID
}
trap finish EXIT

TEMPDIR=`mktemp -d`
mkdir -p /home/circleci/testground
cp env-kind.toml /home/circleci/testground/.env.toml
testground daemon > $TEMPDIR/daemon.out 2>&1 &
DAEMONPID=$!
sleep 2
