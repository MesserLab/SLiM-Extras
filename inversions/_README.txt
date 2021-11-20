This folder contains files related to SLiM manual recipe 14.4.  The current
version of this recipe was developed by Vince Buffalo, Andrew Kern, Peter
Ralph, Sara Schaal.  For further discussion you can see:

- the SLiM manual, section 14.4 ("Modeling chromosomal inversions with a recombination() callback")

- the GitHub issue where it was discussed: https://github.com/MesserLab/SLiM/issues/203

- the eventual paper that may be forthcoming from Buffalo, Ralph, & Kern on this topic.


The files in this folder are:

- inversion_overdominance.slim: the final SLiM script by Vince, Peter, and Sara, which differs from SLiM recipe 14.4 both in some cosmetic ways, and in using tree-sequence recording to record the results of runs

- inversion_conditioned.slim: another SLiM script like the one above, but inversions are neutral and the tree sequence is written when the inversion frequency is established at some threshold.

- inversion_recipe.ipynb : an iPython notebook to analyze results from that inversion_overdominance.slim and inversion_conditioned.slim.

- conditioned_0.5.png : a plot showing results conditioned on establishment of the inversion to a frequency of >= 0.5

- conditioned_0.8.png : a plot showing results conditioned on establishment of the inversion to a frequency of >= 0.8

- single_runs.png : two single runs of the model, with recombination rates of 1e-7 and 1e-8, with frequency-dependence

To run these examples, we first run SLiM:

    $ slim -d rbp=1e-7 inversion_overdominance.slim
    $ slim -d rbp=1e-8 inversion_overdominance.slim
    $ snakemake -j <num_cores> all # replace <num_cores>


The plots show the model run in two different ways.  For conditioned_0.5.png and conditioned_0.8.png, the model is run *without* frequency-dependence.  (To do this, remove the fitness() callback from the model code.)  This means that the inversion, which is then neutral, is often lost or fixed, and so results aggregated across even a large number of runs show little pattern (because so many runs where the inversion is not operating for most of the run are being averaged in).  For this reason, these plots show results conditioned on establishment to two different frequencies (in other words, runs where the inversion did not establish at the given frequency are excluded).  I believe they show an average across ~600 runs each.

Those plots remain difficult to interpret, however, as Vince discusses in the GitHub issue, because the conditioning alters the tree height, and thus background diversity.  Perhaps easier to interpret are the plots in single_runs.png, for which the model is run *with* frequency-dependence.  The inversion is therefore present, maintained at intermediate frequency, in every run.  Here the effect of the inversion can be seen from a single run, as shown in the plot for two different recombination rates.

If you have further questions, please contact the authors.  Thanks to Vince, Peter, Sara and Andy for contributing this improved recipe!


Ben Haller
8 October 2021
