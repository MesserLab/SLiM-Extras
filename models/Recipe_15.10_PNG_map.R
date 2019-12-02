# Read in a PNG map and convert it into a file Eidos can parse

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

