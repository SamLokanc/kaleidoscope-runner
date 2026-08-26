# kaleidoscope-runner

## Table of Contents

1. [Project Overview](#project-overview)
2. [Workflow](#workflow)
3. [Prerequisites](#prerequisites)
   - [Software](#software)
   - [Kaleidoscope License](#kaleidoscope-license)
4. [Setup](#setup)
   - [Cloning the Repo](#cloning-the-repo)
5. [Usage](#usage)
   - [Scratch Directory Set-up](#scratch-directory-set-up)
   - [Importing Data](#importing-data)
   - [Submitting jobs](#submitting-jobs)
6. [Configuration](#configuration)
   - [Kaleidoscope Settings](#kaleidoscope-settings)
   - [Slurm Specifications](#slurm-specifications)

## Project Overview

This project serves as a quick and easy way to configure and run a project using Kaleidoscope software on the UBC sockeye computing cluster. Below is the documentation for how to configure a run.

## Workflow

Below is a table containing all the scripts (within in the `src/` directory) and their corresponding utility in the pipeline.
| Script | Description |
| --- | --- |
| `00-setup_scratch.sh` | Either creates or finds an existing scratch directory of the format `.../<user>/<user>_<project_name>_<YYYYMMDD>` |
| `01-submit.sh` | Point of entry for job submission. Submits Hawkears and/or Kaleidoscope jobs to the cluster. |
| `02-run_kaleidoscope.slurm` | Executes the kaleidoscope relevant scripts |
| `03-initialize_kaleidoscope.sh` | Creates the `settings.ini` file required for Kaleidoscope to run the batch file conversion. Can be modified to configure Kaleidoscope for different purposes. |
| `04-call_kaleidoscope.sh` | Uses the `Kaleidoscope` apptainer to run the kaleidoscope software based on the settings file specified in `03-initialize_kaleidoscope.sh` |

## Prerequisites

### Software
This project assumes that Kaleidoscope is downloaded and installed on Sockeye. If they have since been removed please get in touch to help troubleshoot reinstalling the software.

### Kaleidoscope License
An active Kaleidoscope license exists on Sockeye. Kaleidoscope limits the amount of active licenses by device, meaning that the license can only be activated on one compute node. This can significantly impact the amount of time required by the SLURM workload manager to allocate reseources to run a job.

If the the job fails because of an inactive kaleidoscope license you will have to manually reactivate it. Again, please get in touch to troubleshoot if this occurs.

## Setup

This data pipeline is intended to be run on an ARC computing cluster environment that uses the SLURM workload manager. More specifically, it is intended to run on the University of British Columbia's [Sockeye computing cluster](https://arc.ubc.ca/compute-storage/ubc-arc-sockeye). Clone this repository by navigating to your home directory on the computing cluster and entering one of the following commands:

### Cloning the Repo

Clone the repo using the following command **if this is your first time installing**:

```bash
cd ~ && git clone https://github.com/SamLokanc/kaleidoscope-runner.git && cd kaleidoscope-runner
```

Pull the repo **if you have already cloned it in the past**:

```bash
cd ~/kaleidoscope-runner && git pull origin main
```

## Usage

### Scratch Directory Set-up
Due to memory and job submission constraints on Sockeye cluster, the pipeline requires a scratch directory for data to be stored in and jobs to be submitted from. In order to set up the scratch directory run the following command from within the cloned repo (it is a good idea to run this before each job submission):

```bash
./src/00-setup_scratch.sh -p <project name> -a <allocation name>
```

| `00-setup_scratch.sh` Arguments | Description |
| --- | --- |
| `-p` | **Project Name**: Used for naming and organization, should be descriptive to allow for easier file navigation. |
| `-a` | **Allocation Name**: Used for navigation and Slurm authorization. |

### Importing Data
Once the scratch directory is set up you can import acoustic data using your desired method. The scratch setup created a data directory for you to import your data to.

### Submitting Jobs
To submit the Kaleidoscope Job simply run the following command:

```bash
./src/01-submit.sh -p <project name> -a <allocation_name> -e <email address>
```

| `00-setup_scratch.sh` Arguments | Description |
| --- | --- |
| `-a` | **Allocation Name**: Used for navigation and Slurm authorization. |
| `-p` | **Project Name**: Used for naming and organization, should be descriptive to allow for easier file navigation. |
| `-e` | **Email** (Optional Argument): Email address to send job updates to. |

Once run, wait for the submitted job to finish. If the email argument was provided you will receive an email when the jobs begin and when they are complete. You can also check the status of the job by running the following command on sockeye:

```bash
squeue -u $USER
```

## Configuration

### Kaleidoscope Settings

The specifications of the Kaleidoscope job can be configured by editing `03-initialize_kaleidoscope.sh` between the two `EOF` blocks to reflect your desired `settings.ini` file.

Edit this portion according to the options and guidelines specified in the [Kaleidoscope Pro Documentation](https://www.wildlifeacoustics.com/uploads/user-guides/Kaleidoscope11112024.pdf)

Ensure you run `src/00-setup_scratch.sh` after making your modifications.

### Slurm Specifications

This project submits two slurm jobs, each of which can be configured differently depending on the specific hardware requirements. The kaleidoscope job, defined in `src/02a-run_kaleidoscope.slurm`, has default settings requesting 4 cores, 2 hours of runtime, and 20GB of RAM.

The second job that gets run is the HawkEars job, defined in `src/02b-run_hawkears.slurm`. This job has default settings requesting 8 cores, 10 hours of runtime, and 100GB of RAM. 

Both of the default specifications should be more than enough for most use cases. In the event that you need to process a large number of files and receive a timeout error, consider processing the files in smaller batches and/or increasing the runtime requested by editing the SLURM directives a the beginning of `src/02a-run_kaleidoscope.slurm` and `src/02b-run_hawkears.slurm`. Ensure you run `src/00-setup_scratch.sh` after making any modifications to the `.slurm` scripts.