#!/bin/bash

# Runs SLiM 8 times in parallel.

#  Created by Sam Champer, 2020.
#  A product of the Messer Lab, http://messerlab.org/slim/

#  Sam Champer, Ben Haller and Philipp Messer, the authors of this code, hereby
#  place the code in this file into the public domain without restriction.
#  If you use this code, please credit SLiM-Extras and provide a link to
#  the SLiM-Extras repository at https://github.com/MesserLab/SLiM-Extras.
#  Thank you.

mkdir -p nopy_data
slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.000 minimal_gene_drive.slim > nopy_data/1.part &
slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.005 minimal_gene_drive.slim > nopy_data/2.part &
slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.010 minimal_gene_drive.slim > nopy_data/3.part &
slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.015 minimal_gene_drive.slim > nopy_data/4.part &
slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.020 minimal_gene_drive.slim > nopy_data/5.part &
slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.025 minimal_gene_drive.slim > nopy_data/6.part &
slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.030 minimal_gene_drive.slim > nopy_data/7.part &
slim -d HOMING_SUCCESS_RATE=0.5 -d RESISTANCE_FORMATION_RATE=0.035 minimal_gene_drive.slim > nopy_data/8.part &
wait
cd nopy_data
grep "OUT:" *.part > array_without_python.csv
rm *.part
