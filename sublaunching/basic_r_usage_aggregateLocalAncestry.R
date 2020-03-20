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


# First of all, define the paths to slim and to the script; these
# are system-specific and will need to be tailored to your machine.
# This script is designed to work with the recipe for section 14.7 in
# the SLiM manual; the recipe is available for download online at
# https://messerlab.org/slim/.  For simplicity we'll assume the recipe
# has been renamed "recipe.txt" but the full name of the file can be
# used instead if you wish.
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
