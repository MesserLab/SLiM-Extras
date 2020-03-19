This folder is for code/scripts that help run a given SLiM model more than once, either for replication or for exploring different parameter values, and either on the local machine or on a computing cluster of some kind.  At present, it contains:

basic_r_usage_aggregateLocalAncestry.R : R script to replicate recipe 13.9 1000 times, aggregate the results, and produce a plot

basic_python_usage_gen_replicates.py : Python script to perform replicated runs and tabulate a binary metric from their output

external_running_tutorial : a tutorial on sublaunching via BASH, Python, or R that demonstrates a full workflow for running an included demo SLiM file through a grid of parameters.