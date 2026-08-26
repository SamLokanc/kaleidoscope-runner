#!/bin/bash

set -euo pipefail

# ----- Parse Flags -----
# Flags:
#  -p : Project name used to locate the scratch directory
#       (default: birdacoustics). Must match what was used
#       with 01-setup_scratch.sh.
#  -t : Threshold config value.
#  -e : Email address for Slurm job notifications.
PROJECT_NAME="kaleidoscope_runner"
EMAIL=""
while getopts "p:e:a:" flag; do
 case $flag in
  p) PROJECT_NAME="$OPTARG" ;;
  e) EMAIL="$OPTARG" ;;
  a) ALLOC_NAME="$OPTARG" ;;
  \?) echo "ERROR: Invalid option, exiting..." >&2; exit 1;;
 esac
done
shift $(( OPTIND-1 ))

# ----- Locate Scratch Directory -----
# This script expects setup_scratch.sh to have already been run.
# It picks the most recent matching directory, same convention
# used by the setup script.
export SCRATCH_BASE="/scratch/${ALLOC_NAME}"
if ! compgen -G "${SCRATCH_BASE}/${USER}/${USER}_${PROJECT_NAME}_*" > /dev/null; then
 echo "ERROR: No scratch directory found for project '${PROJECT_NAME}'." >&2
 echo " Run src/00-setup_scratch.sh first." >&2
 exit 1
fi
export SCRATCH=$(
 compgen -G "${SCRATCH_BASE}/${USER}/${USER}_${PROJECT_NAME}_*" |
 sort -t_ -k3 -r |
 head -n 1)

# ----- Set Project Directory -----
export PROJECT="/arc/project/${ALLOC_NAME}"

# ----- Set Path Variables -----
export IN_RAW="${SCRATCH}/data/raw"
export IN_PROCESSED="${SCRATCH}/data/processed"
export OUT="${SCRATCH}/results"
export SETTINGS="${SCRATCH}/settings.ini"
export KALEIDOSCOPE="${PROJECT}/kaleidoscope/kaleidoscope-5.6.8.sif"
export LICENSE="${SCRATCH_BASE}/.kaleidoscope"

# ----- Directory Existance Sanity Check -----
# Check SCRATCH is defined. If it does not exit the program.
if [ ! -d "${SCRATCH}" ]; then
  echo "ERROR: Scratch setup failed. Exiting..." >&2
  exit 1
fi
# Check PROJECT exists. If not exit the program.
if [ ! -d "${PROJECT}" ]; then
  echo "ERROR: Project directory does not exist. Exiting..." >&2
  exit 1
fi

# ----- Submit Slurm Job -----
KAL_JOBID=""

KAL_JOBID=$(sbatch \
  --account="${ALLOC_NAME}" \
  --chdir="${SCRATCH}" \
  --export=ALL \
  --parsable \
  ${EMAIL:+--mail-user "${EMAIL}"} \
  "${SCRATCH}/src/02a-run_kaleidoscope.slurm"
 )
 echo "Submitted Kaleidoscope job: ${KAL_JOBID}" >&2