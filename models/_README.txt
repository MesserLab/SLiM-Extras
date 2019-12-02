This folder is for full SLiM models that might be of interest, but that we decided not to turn into a cookbook recipe.  At present, it contains:

HardyWeinberg_test.slim : test for significant departure from Hardy-Weinberg equilibrium each generation during a selective sweep.

autotetraploid.slim : An autotetraploid model with selection.

Recipe_14.8_Linux_1.slim, Recipe_14.8_Linux_2.slim: Modified versions of recipe 14.8 from Graham Gower.  These fix the live plotting methodology on recipe 14.8 to work on Linux, using two different strategies; see comments in each file for more information.

Recipe_15.10_OnLand.slim: A modified version of recipe 15.10 that shows how to draw initial positions anywhere on land in a vectorized fashion, as a demonstration of how to vectorize iterative operations.

Recipe_15.10_PNG_map.R and Recipe_15.10_PNG_map.png: The PNG image used as a basis for the Earth map in recipe 15.10, and the R script that converted that PNG image into a text file for use by the recipe's script.  Of course this may be adapted to handle continuous variables instead; in that case, rather than writing out just a ' ' or '#', one might generate a CSV file or similar, with one integer or float value per map pixel.  The readIntTable() function (also in SLiM-Extras) could be used to read in such a file easily.

landscape_ac.slim, landscape_ac.R: A modified version of recipe 15.11 that uses an R script to generate a random landscape map that is spatially autocorrelated.  See the files for further comments.
