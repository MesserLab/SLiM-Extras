# Generates a bash script to run an 11x11 array of SLiM simulations locally in parallel.

#  Created by Sam Champer, 2020.
#  A product of the Messer Lab, http://messerlab.org/slim/

#  Sam Champer, Ben Haller and Philipp Messer, the authors of this code, hereby
#  place the code in this file into the public domain without restriction.
#  If you use this code, please credit SLiM-Extras and provide a link to
#  the SLiM-Extras repository at https://github.com/MesserLab/SLiM-Extras.
#  Thank you.

from multiprocessing import cpu_count

# Genearte a shell script to run a large array of SLiM simulations locally in parallel.
homing = 0.5
res = 0.0
print_header = True
run_number = 1
max_simultaneous_procs = cpu_count()
print("#!/bin/bash\nmkdir -p py_data")
for homing_steps in range(11):
    for resistance_steps in range(11):
        print(f"python3 minimal_slim_driver.py -homing {homing:.2f} -res {res:.3f}{' -header' if print_header else ''} > py_data/{run_number}.part &")
        print_header = False
        if run_number % max_simultaneous_procs == 0:
            # This sets a limit on how many instances of SLiM are allowed to run at once.
            # In terms of CPU utilization - this reduces efficiency, as threads that
            # finish earlier will idle until all others are finished.
            # However, this method saves a lot of memory, which may be more important,
            # depending on the SLiM file you are running.
            print("wait")
        run_number += 1
        res += 0.005
    res = 0.0
    homing += 0.01
print("wait\ncd py_data\ncat *.part > large_array_with_python.csv\nrm *.part")
