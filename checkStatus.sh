#!/bin/bash

# this script automatically retrives the summary of the job from the container that runs the workflow
set -e

containerID=$(docker ps -a -q -f status=running -f "name=fastqc"  -f ancestor=mizzouceri/fastqc_wf:V2)

job_id=$(docker logs $containerID | grep " pegasus-status -l " | cut -d' ' -f5) >/dev/null 2>&1

echo "Printing the status of the Job: "
docker exec $containerID bash -c ". ~/condor-8.8.9/condor.sh && pegasus-status -l $job_id" 2>&1
echo -e "\n"

echo "Printing the statistics of the Job: "
docker exec $containerID bash -c ". ~/condor-8.8.9/condor.sh && pegasus-statistics $job_id -s all" 2>&1
echo -e "\n"

echo "Printing the summary of the Job: "
summary=$(echo $job_id | cut -d'/' -f5,6) && grep 'Workflow wall time' /output/$summary/statistics/summary.txt
echo -e "\n"
