# Running SLiM in arrays, from Python, from R, and on a computing cluster

#### Author: Samuel Champer

You may find yourself in the situation that you have a SLiM simulation with several defined parameters, and you want to try varying these parameters through a plausible range in order to determine how the model will perform in various configurations.

Naturally, you can just vary the parameters by hand and record the results. However, that wouldn't be very fun once you have more than two or three parameters that you want to vary. Furthermore, running SLiM many times sequentially takes a lot longer than doing it in parallel!

In this situation, there are several options. This folder is intended as a tutorial to demonstrate the basics of several methods of solving this problem. Just follow along with this readme!

Note: the scripts in this tutorial all assume that SLiM is in your PATH environment variable. To check if it is, open a console and type "slim". If the SLiM version info and command line help pops up, you're good to go. Otherwise, you'll need to add it to PATH. If you don't know how, the method for doing so varies between operating systems - search for a tutorial that is right for yours.

Note 2: The scripts in this tutorial require Python version 3.6 or above.

## 1 - Preparing your SLiM file for command line configuration

Just as you can use the defineConstant() function to... well... define constants within SLiM, you can use the command line "-d" argument to do so as well.

For example invoking: ``slim -d X=0 -d Y=1 filename.slim`` will run SLiM with X in the namespace as 0 and Y as 1. This can be used in conjunction with other tools to run many SLiM simulations while varying parameters.

However, you'll need to make sure not to define the same constants twice! Doing so results in an error. To define a constant "X" to have a default value within SLiM in such a way that it can also be defined via the command line without causing an error, use the following code:
```
if (!exists("X"))
    defineConstant(X, 1.0);
```
However, if you plan to use lots of configurable constants, this may start to take up a lot of space, and a small helper function can clean this up. See the "minimal_gene_drive.slim" file for an example of how this is done.

## 2 - Using bash to run SLiM

Once your SLiM file is prepared, running it with varying parameters using bash is easy. Just a simple list of the command line strings you want to run is sufficient, though you may also want to pipe the output of each simulation to its own file via "``>``" (e.g. "``command > output.txt``"). You can also run jobs in parallel very easily.

The "array_without_python.sh" file in this folder demonstrates how to accomplish parallel running with bash. The file can be run via ``bash array_without_python.sh``.

## 3 - Using Python to run SLiM

You might find that you want to do some complex analyses on your data which are inconvenient to do from within SLiM itself. If so, you can capture the results of SLiM within Python using the subprocess library, and then use all of your favorite python libraries to analyze the output.

For a complete though fairly minimal example of such a driver, see the "minimal_slim_driver.py" file.

## 4 - Using Python and bash to run an array in parallel

Running SLiM in parallel using bash and running SLiM with python can be combined. The "array_with_python.sh" script in this folder demonstrates this method, and can be run via ``bash array_with_python.sh``. This could also be combined with a script to generate a bash file: see "generate_large_local_array_run.py". This file can be invoked via ``python generate_large_local_array_run.py > large_local_array_run.sh``. The file that is generated can be run via ``bash large_local_array_run.sh``. Warning: this will cause as many SLiM processes to spawn as your computer has threads. Your CPU fan will definitely spin up a bit. Depending on the SLiM workload you are interested in running, this technique may be too memory intensive, in which case you can impose a limit on the number of processes that run at once, or use a computing cluster!

## 5 - Using Python, bash, and a job scheduler on a computing cluster to run an array in parallel

If you have access to a computing cluster, using it will likely entail submitting "jobs" to a "job scheduler". The jobs you submit will likely take the form of bash scripts, the exact details of which depend on exactly what job scheduler your computing cluster uses, so go talk to your friendly cluster administrator.

Included are scripts for running an array of jobs using two popular schedulers: the Sun Grid Engine (aka SGE), and SLURM. Files for these examples include "generate_params_file.py", which generates a file containing the command line strings that the cluster will be running. This is done via ``python generate_cluster_params_file.py > SGE\params.txt`` or ``python generate_cluster_params_file.py > SLURM\params.txt``. The cluster scripts themselves are "SGE.sh" and "SLURM.sh" (in the SGE and SLURM folders). These files must be configured with the directory from which you are running the script, as well as the path to your SLiM installation on your computing cluster. When ready, the SGE script can be enqueued via ``qsub SGE.sh``; the SLURM script can be enqueued via ``sbatch SLURM.sh``.

## 6 - SLiM in R

SLiM can also be run using R. The "running_slim_using_r.r" script in this tutorial demonstrates this, first in a very minimal way, then an example of how to run an array of SLiM simulations in parallel from within R.
