This folder contains an example of writing syntax-highlighted SLiM code
in LaTeX, using the package "listings": https://ctan.org/pkg/listings 
This was written by Peter Ralph.

In this folder is:

- example.tex

To compile it, run:

pdflatex example.tex

(perhaps with "pdflatex" replaced by the latex engine of your choice).
To use it in *your* document, copy the code marked "copy this into your header"
into the header of your LaTeX document,
and write code like is demonstrated there.


*Note:* this uses the same colors as the SLiMGui: see the .tex source for where these were found.
However, it's not (reasonably) possible to give a particular color to *numbers* as in SLiMGui;
this might be possible using minted (https://ctan.org/pkg/minted);
if you get this working then we'd like to see it.
