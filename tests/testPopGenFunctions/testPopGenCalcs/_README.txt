The testPopGenCalcs.slim script runs a simulation for the purpose of testing the calcTajimasD(), calcPi(), and calcWattersonsTheta() functions. This simulation is extremely brief, running for only a single generation. The simulation generates a constant ancestral sequence, a population of only two individuals (4 haplotypes), and inserts predefined mutations into some of these haplotypes. It then computes the above population genetic statistics on this population. This allows for simple hand calculations of the statistics as well as comparison to output from the R and Python scripts of the same name in this same directory.

The aforementioned R and Python scripts read in an alignment of 4 haplotypes identical to those of the slim simulation. Then they compute the population genetic statistics on this alignment using pegas (Paradis et al. 2010, Bioinformatics) and scikit-allel (Miles et al. 2024, no associated paper) respectively. These are well-cited programs for computing these statistics. Both programs are in agreement with my hand calculations of the statistics on the given alignment, which should all be:

Watterson's theta estimate: 0.1363636 
pi estimate: 0.1388889 
Tajima's D estimate: 0.1676558

Therefore, the calculations in the slim script can be validated by comparison to these values. Notably, pegas and scikit-allel differ in how they handle alignment gaps and missing data (generally represented as "-" in FASTA and "." or "./." in a VCF), which results in different values of these statistics. By default, no data is missing from SLiM and all sequences remain homologous (e.g. no indels/duplications) so this should only be an issue if someone induces these kinds of phenomena in their simulations.

	-- Nick Bailey, currently affiliated with University of St Andrews, 11 Mar. 2025
