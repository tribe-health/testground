#!/bin/bash

my_dir="$(dirname "$0")"
source "$my_dir/header.sh"

testground plan import --from plans/placebo
testground build single --builder docker:go --plan placebo | tee build.out
export ARTIFACT=$(awk -F\" '/generated build artifact/ {print $8}' build.out)
docker tag $ARTIFACT testplan:placebo

# The placebo:stall does not require a sidecar.
# To prevent kind from attempting to download the image from DockerHub, build and load the image before executing it.
# The plan is renamed as `testplan:placebo` because kind will check DockerHub if the tag is `latest`.
kind load docker-image testplan:placebo

testground run single --runner cluster:k8s --builder docker:go --use-build testplan:placebo --instances 2 --plan placebo --testcase stall &
sleep 20
BEFORE=$(kubectl get pods | grep placebo | grep Running | wc -l)
testground terminate --runner=cluster:k8s
sleep 10
AFTER=$(kubectl get pods | grep placebo | grep Running | wc -l)
test $BEFORE -gt $AFTER
