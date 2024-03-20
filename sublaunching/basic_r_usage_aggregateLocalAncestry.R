#
#	aggregateLocalAncestry.R
#
#	Run a set of replicates of recipe 14.7, "True local ancestry",
#	aggregate the results, and generate a plot.
#
#	Created by Ben Haller, 10/30/2017
#	A product of the Messer Lab, http://messerlab.org/slim/

#	Ben Haller and Philipp Messer, the authors of this code, hereby place
#	the code in this file into the public domain without restriction.
#	If you use this code, please credit SLiM-Extras and provide a link to
#	the SLiM-Extras repository at https://github.com/MesserLab/SLiM-Extras.
#	Thank you.


# This script is designed to work with an old version of the recipe
# for section 14.7 in the SLiM manual.  Since that recipe has been
# changed, here is the original code for it; cut/paste this code
# into a file named "recipe.txt" to be run by the R script below.

# --------------------------------------------------------------------

initialize() {
	defineConstant("L", 1e4);                      // chromosome length
	
	initializeMutationRate(0);
	initializeMutationType("m1", 0.5, "f", 0.1);   // beneficial
	initializeMutationType("m2", 0.5, "f", 0.0);   // p1 marker
	m2.convertToSubstitution = F;
	initializeGenomicElementType("g1", m1, 1.0);
	initializeGenomicElement(g1, 0, L-1);
	initializeRecombinationRate(1e-7);
}
1 early() {
	sim.addSubpop("p1", 500);
	sim.addSubpop("p2", 500);
}
1 late() {
	// p1 and p2 are each fixed for one beneficial mutation
	p1.genomes.addNewDrawnMutation(m1, asInteger(L * 0.2));
	p2.genomes.addNewDrawnMutation(m1, asInteger(L * 0.8));
	
	// p1 has marker mutations at every position, to track ancestry
	p1.genomes.addNewMutation(m2, 0.0, 0:(L-1));
	
	// make p3 be an admixture of p1 and p2 in the next cycle
	sim.addSubpop("p3", 1000);
	p3.setMigrationRates(c(p1, p2), c(0.5, 0.5));
}
2 late() {
	// get rid of p1 and p2
	p3.setMigrationRates(c(p1, p2), c(0.0, 0.0));
	p1.setSubpopulationSize(0);
	p2.setSubpopulationSize(0);
}
2: late() {
	if (sim.mutationsOfType(m1).size() == 0)
	{
		p3g = p3.genomes;
		
		p1Total = sum(p3g.countOfMutationsOfType(m2));
		maxTotal = p3g.size() * L;
		p1TotalFraction = p1Total / maxTotal;
		catn("Fraction with p1 ancestry: " + p1TotalFraction);
		
		p1Counts = integer(L);
		for (g in p3g)
			p1Counts = p1Counts + integer(L, 0, 1, g.positionsOfMutationsOfType(m2));
		maxCount = p3g.size();
		p1Fractions = p1Counts / maxCount;
		catn("Fraction with p1 ancestry, by position:");
		catn(format("%.3f", p1Fractions));
		
		sim.simulationFinished();
	}
}
100000 late() {
	stop("Did not reach fixation of beneficial alleles.");
}

# --------------------------------------------------------------------
#
# The remainder of this file is the R script to sublaunch the above
# SLiM model and process the results.
#

# First of all, define the paths to slim and to the script; these
# are system-specific and will need to be tailored to your machine.
slim_path <- "/usr/local/bin/slim"
script_path <- "/Users/bhaller/Desktop/recipe.txt"

# A simple, general-purpose sublaunching script for SLiM in R.
doOneSLiMRun <- function(seed, script)
{
	system2(slim_path, args = c("-s", seed, shQuote(script)), stdout=T, stderr=T)
}

# Do replicated runs of the model, with different seed values, collect
# the results, and tabulate them into a vector that accumulates all of
# the data.
reps <- 1000             # each rep takes about 1 second on my machine
accumulator <- integer(reps)

for (iter in 1:reps)
{
	# collect output from running the script once
	output <- doOneSLiMRun(iter, script_path)
	
	# find a pattern line we know is in the output just before the data we want
	leadLineIndex <- which(grepl("^Fraction with p1 ancestry, by position:$", output))
	
	# extract the actual numeric data from the data line's string
	valuesLine <- output[leadLineIndex + 1]
	valuesList <- strsplit(valuesLine, " ", fixed=T)
	valuesString <- unlist(valuesList)
	values <- as.numeric(valuesString)
	
	# add the data into our accumulator buffer
	accumulator <- accumulator + values
}

# Deduce the chromosome length from the length of our accumulator.
L <- length(accumulator)

# Make a plot window; on OS X it is quartz(), but this is platform-specific.
quartz(width=4, height=4)

# Make the plot.
par(mar=c(4.0, 4.0, 1.5, 1.5))
plot(x=0:(L-1), y=accumulator/reps, type='l', lwd=2, xlab="chromosome position", ylab="fractional ancestry", xaxp=c(0, L-1, 1))
abline(v=L*0.2, col="red")
abline(v=L*0.8, col="red")
