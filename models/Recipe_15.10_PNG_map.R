# Read in a PNG map and convert it into a file Eidos can parse

# BCH 10/25/2020: Note that the approach shown here, of generating a text file
# that represents the pixels in an image, is obsolete as of SLiM 3.5.  Now it
# is possible to simply load a PNG file with the Eidos class Image, and get a
# channel (like the red channel used here) as a matrix that can either be used
# directly with defineSpatialMap(), or can be modified prior to use.  So this
# code should probably not be used by anyone ever; it's a really ugly way of
# doing things, and there's no longer any reason to do it this way.


library("png")

i <- readPNG("Recipe_15.10_PNG_map.png", native = FALSE, info = FALSE)
str(i)

red <- i[,,1]
str(red)

land <- (red < 0.990)

str(land)

for (y in 1:217)
{
	for (x in 1:540)
	{
		if (land[y, x]) cat("#") else cat(" ")
	}
	cat("\n")
}

