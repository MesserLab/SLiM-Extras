#!/bin/bash

# Runs SLiM 8 times in parallel via a python driver.

#  Created by Sam Champer, 2020.
#  A product of the Messer Lab, http://messerlab.org/slim/

#  Sam Champer, Ben Haller and Philipp Messer, the authors of this code, hereby
#  place the code in this file into the public domain without restriction.
#  If you use this code, please credit SLiM-Extras and provide a link to
#  the SLiM-Extras repository at https://github.com/MesserLab/SLiM-Extras.
#  Thank you.

mkdir -p py_data
python3 minimal_slim_driver.py -homing 0.5 -res 0.000 -header > py_data/1.part &
python3 minimal_slim_driver.py -homing 0.5 -res 0.005 > py_data/2.part &
python3 minimal_slim_driver.py -homing 0.5 -res 0.010 > py_data/3.part &
python3 minimal_slim_driver.py -homing 0.5 -res 0.015 > py_data/4.part &
python3 minimal_slim_driver.py -homing 0.5 -res 0.020 > py_data/5.part &
python3 minimal_slim_driver.py -homing 0.5 -res 0.025 > py_data/6.part &
python3 minimal_slim_driver.py -homing 0.5 -res 0.030 > py_data/7.part &
python3 minimal_slim_driver.py -homing 0.5 -res 0.035 > py_data/8.part &
wait
cd py_data
cat *.part > array_with_python.csv
rm *.part
