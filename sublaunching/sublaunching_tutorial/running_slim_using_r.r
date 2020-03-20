#  Created by Sam Champer, 2020.
#  A product of the Messer Lab, http://messerlab.org/slim/

#  Sam Champer, Ben Haller and Philipp Messer, the authors of this code, hereby
#  place the code in this file into the public domain without restriction.
#  If you use this code, please credit SLiM-Extras and provide a link to
#  the SLiM-Extras repository at https://github.com/MesserLab/SLiM-Extras.
#  Thank you.

# Running SLiM in R is easy and clean!

# Run slim using the system() function. Store the output in slim_out.
slim_out <- system("slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.01 minimal_gene_drive.slim", intern=TRUE)

# Print only the last line, which is the desired output of this particular SLiM file.
print(substring(slim_out[length(slim_out)],5))


# A little more advanced:
# Running an array of simulations in parallel:

# NOTE: Installing the future library may not work on
# a mac if xcode isn't installed.
# To install xcode, open a terminal and run "xcode-select --install"

library(foreach)
library(doParallel)
library(future)
cl <- makeCluster(future::availableCores())
registerDoParallel(cl)

# Vectors to vary the params. This will run a 4X4 array of SLiM runs:
HOMING <- 0:3 * 0.01 + 0.9
RES <- 0:3 * 0.002

# Run SLiM in parallel:
raw_slim_output_matrix <- foreach(h = HOMING) %:%
  foreach(r = RES) %dopar% {
    # Use string maniputaion functions to configure the command line args,
    # then run SLiM with system(),
    # then keep only the last line.
    slim_out <- system(sprintf("slim -d HOMING_SUCCESS_RATE=%f -d RESISTANCE_FORMATION_RATE=%f minimal_gene_drive.slim", h, r), intern=TRUE)
  }
stopCluster(cl)

# Elements in raw_slim_output_matrix contain all of the text that SLiM outputs.
# It could be parsed and put into a matrix, or just flattened into a list, as below:
parsed_output = c()
for (col in raw_slim_output_matrix)
  for (row in col)
    for (line in row)
      if (startsWith(line, "OUT:"))
        # Strip off the "OUT:" from the beginning of the line.
        parsed_output = c(parsed_output, substring(line, 5))

# Print each  output line:
for (line in parsed_output)
  print(line)
