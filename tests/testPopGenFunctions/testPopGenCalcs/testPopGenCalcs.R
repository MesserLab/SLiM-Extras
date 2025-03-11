library(ape)      # For DNA sequence handling
library(pegas)    # For theta.s calculation

# Generate 4 haploid sequences each 12 sites long
sequences <- c(
  "ATGCTAGCTAAT",
  "ATGCTAGCTATT",
  "ATGCGAGCTATT",
  "ATGCGAGCTATA"
)

# Convert sequences to DNAbin object (required by pegas)
sequences_list <- lapply(sequences, function(x) as.DNAbin(matrix(unlist(strsplit(x, "")), nrow = 1)))
dna_bin <- do.call(rbind, sequences_list)

# Compute theta.s (Watterson's estimator)
theta_s <- theta.s(dna_bin) / 12
pi <- nuc.div(dna_bin)
tajimas_d <- tajima.test(dna_bin)$D

# Print the result
cat("Watterson's theta estimate:", theta_s, "\n")
cat("pi estimate:", pi, "\n")
cat("Tajima's D estimate:", tajimas_d, "\n")

