# Generates a params.txt file in order to run a
# 51x51 array of SLiM simulations on a computing cluster.

#  Created by Sam Champer, 2020.
#  A product of the Messer Lab, http://messerlab.org/slim/

#  Sam Champer, Ben Haller and Philipp Messer, the authors of this code, hereby
#  place the code in this file into the public domain without restriction.
#  If you use this code, please credit SLiM-Extras and provide a link to
#  the SLiM-Extras repository at https://github.com/MesserLab/SLiM-Extras.
#  Thank you.

# Genearte a params.txt file to use with the cluster scripts.
homing = 0.5
res = 0.0
print_header = True
for homing_steps in range(51):
    for resistance_steps in range(51):
        print(f"python3 minimal_slim_driver.py -homing {homing:.2f} -res {res:.3f}{' -header' if print_header else ''}")
        print_header = False
        res += 0.001
    res = 0.0
    homing += 0.01
