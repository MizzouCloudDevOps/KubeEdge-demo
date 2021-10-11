#!/bin/bash

# this script automatically retrives the summary of the job from the container that runs the workflow

containerID=$(docker ps -a -q -f status=running -f "name=fastqc"  -f ancestor=mizzouceri/fastqc_wf:V1)

job_id=$(docker logs $containerID | grep " pegasus-status -l " | cut -d' ' -f5) >/dev/null 2>&1

docker exec $containerID bash -c "pegasus-statistics $job_id -s all" >/dev/null 2>&1

summary=$(echo $job_id | cut -d'/' -f5,6) && grep 'Workflow wall time' /output/$summary/statistics/summary.txt
