#!/usr/bin/env bash
used=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | tr -d ' ')
echo "${used}%"
