This folder contains stuff related to the modeling of pseudoautosomal regions, or PARs:

new PAR recipe extended version.slim: this provides an extended version (DJ remix) of the new PAR recipe that was rolled out when multichromosome support was added in SLiM 5.0.  This extended version adds some testing code that uses marker mutations of four types, positioned at the appropriate ends of the PARs and sex chromosomes, that are used to confirm that the PARs and sex chromosomes maintain the correct physical linkage patterns throughout the model run.  It's only of interest if you're delving deep into how this PAR recipe works internally; the version in the manual should suffice for almost everyone.

old PAR recipe.slim: this is the old PAR recipe that was section 14.5 of the SLiM manual before multichromosome support was added to SLiM.  It simulates a single PAR with and X and Y, using a variety of scripting tricks to make it all work despite the lack of multichromosome support at the time.  It should now be regarded as an interesting hack; the new PAR recipe is the approach that should now be used, but this old recipe uses some interesting scripting techniques.  This recipe was written by Melissa Jane Hubisz.

old PAR recipe writeup.pdf: this is the writeup in the manual for "old PAR recipe.slim", describing how it works under the hood.
