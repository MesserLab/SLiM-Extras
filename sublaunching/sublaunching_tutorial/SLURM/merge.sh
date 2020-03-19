#!/bin/bash

# Merge a bunch of .part files into output.csv.

cat *.part > output.csv
rm *.part

