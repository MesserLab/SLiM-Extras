#
#              testPopGenCalcs.py
#
#              by Nick Bailey, currently affiliated with University of St Andrews, 11 Mar 2025; see README for details
#

import numpy as np
import allel

# Define sequences

sequences = [
  "ATGCTAGCTAAT",
  "ATGCTAGCTATT",
  "ATGCGAGCTATT",
  "ATGCGAGCTATA"
]

# Convert sequences to a numpy array of characters
seq_array = np.array([list(seq) for seq in sequences])

# Transpose array to get sites as rows
seq_array = seq_array.T

# Encode sequences as numeric alleles (ACGT -> 0, 1, 2, 3, N -> -1)
def encode(base):
    mapping = {'A': 0, 'C': 1, 'G': 2, 'T': 3, 'N': -1}
    return mapping.get(base, -1)

encoded_array = np.array([[encode(base) for base in row] for row in seq_array])

# Convert to HaplotypeArray
genotypes = allel.HaplotypeArray(encoded_array)

# Count alleles
allel_counts = genotypes.count_alleles(max_allele=3)

pi = allel.sequence_diversity(pos=np.arange(seq_array.shape[0]), ac=allel_counts)
watterson_theta = allel.watterson_theta(pos=np.arange(seq_array.shape[0]), ac=allel_counts)
tajimas_d = allel.tajima_d(pos=np.arange(seq_array.shape[0]), ac = allel_counts)

# Print the result
print("Watterson's theta:", watterson_theta)
print("Pi:", pi)
print("Tajima's D:", tajimas_d)

