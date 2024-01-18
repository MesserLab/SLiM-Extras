# landscape_ac.R
#
# Functions to generate landscapes with slope, curvature, and autocorrelated noise.
# Because of the slope and curvature terms, these landscapes are generated to be
# periodic in the y direction but not in the x direction by default. Setting 
# periodic_x=T in generateLandscape will make both dimensions periodic, so long
# as slope and curvature both equal 0.0.
#
# By Rupert Mazzucco, with minor modifications by Ben Haller, July 2010
#
# For discussion see B.C. Haller, R. Mazzucco, U. Dieckmann. (2013). Evolutionary branching in
# complex landscapes. American Naturalist 182(4), E127–E141. https://doi.org/10.1086/671907

# To use this script, do something like:
#
# Rscript --vanilla -e "source('landscape_ac.R'); m <- generateLandscape(0.0, 0.0, 1.0, 1.0, 64); cat(as.vector(m));"
#
# Then parse the output into an nxn matrix of landscape values, which you may wish to center
#
# Note that the package 'cubature' is required if amplitude and aclength are > 0.0


## functions producing white noise with expected variance sigma^2

# Gaussian white noise
wn_gauss <- function(n=1,sigma=1)
{
	return(rnorm(n,mean=0,sd=sigma))
}

## filter functions
# l0 is a "magic" multiple of the autocorrelation length
# where the function value has dropped to mostly zero; 
# the filter length is odd, the filter symmetric around the mean value;
# to preserve the white noise amplitude, the filter is normalized
# so that sum(f[i]^2)==1 (the kern() functions as given are normalized to one,
# which is of course unnecessary given the eventual renormalization of f)

# locations in (0,1) of the n points
xvec <- function(n,dx=NULL)
{
	if (is.null(dx)) return((1:n-0.5)/n) else return((1:n-0.5)*dx)
}

## 2D integration with adaptIntegrate() from package "cubature"

# Bessel filter 2D
flt_bessel_2D_even <- function(dx,acl=1)
{
	library(cubature)
	l0 <- 2.0
	m <- 2^(ceiling(log2(2*l0*acl/dx))-1)
	x <- (1:m)*dx
	kern <- function(y) besselK(sqrt(sum(y^2))/acl,0)/(2*pi*acl^2)
	r <- matrix(nrow=m,ncol=m,byrow=FALSE)
	for (j in 1:m)
		for (i in 1:m)
			r[i,j] <- adaptIntegrate(kern,c(x[i]-dx,x[j]-dx),c(x[i],x[j]))$integral
	f <- rbind(cbind(r[m:1,m:1],r[m:1,]),cbind(r[,m:1],r))
	return(f/sqrt(sum(f^2)))
}

### generate correlated noise
# n     ... number of points equidistant in (0,1)
# acl   ... desired autocorrelation length
# amp   ... amplitude of noise
# wn    ... function generating noise vector taking args (n,amp)
# flt   ... function generating impulse response vector taking args (x,acl)
#                               where x is a vector of locations

cn_2D <- function(acl, pts_per_acl=3, amp=1, wn=wn_gauss, flt=flt_bessel_2D_even, minSize=64, periodic_x=F)
{
	# calculate the size needed for the landscape; note that acl==0 does not work
	n <- 2^round(log2(pts_per_acl/acl))	# force power of 2
	
	# use at least 64x64, by default, so that curvature can be smoothly captured
	n <- max(n, minSize)
	
	# more than 1024x1024 is not reasonable, and makes R choke anyway...
	stopifnot(n <= 1024)
	
	f <- flt(1/n,acl)		# m x m-matrix of filter response
	m <- dim(f)[1]
	
	if (m>n)
	{
		# truncate filter
		f <- f[(1:n)+(m-n)/2,]
	}

	nx <- n
	if (periodic_x == F) {
	  # no periodicity in x direction; since the fft forces periodicity, we pad
	  # the grid with a sufficient number of points
	  while (nx-n < m)
	    nx <- 2*nx
	}
	
	# pad filter with zeros so that dim==(n,nx)
	if (m<n)
	{
		f <- cbind(matrix(0,m,(nx-m)/2),f,matrix(0,m,(nx-m)/2))
		f <- rbind(matrix(0,(n-m)/2,nx),f,matrix(0,(n-m)/2,nx))
	}
	else
		f <- cbind(matrix(0,n,(nx-m)/2),f,matrix(0,n,(nx-m)/2))
	# now create n x nx uncorrelated noise landscape
	w <- matrix(wn(n*nx,amp),n,nx)	# n x nx matrix of noise peaks
	h <- Re(fft(fft(f)*fft(w),inverse=TRUE))/(n*nx)
	return(h[,(1:n)+(nx-n)/2])
}

generateLandscape <- function(slope, curvature, amplitude, aclength, minSize=64, periodic_x=F)
{
  # Fail safe in case there are conflicting parameters
  if (periodic_x == T && (slope != 0.0 | curvature != 0.0))
    stop("Error: Cannot have slope/curvature with periodicity along x dimension.")
  
	if ((amplitude > 0.0) && (aclength > 0.0))
		noise <- cn_2D(acl=aclength, pts_per_acl=5, amp=amplitude, minSize=minSize, periodic_x=as.logical(periodic_x))
	else
		noise <- matrix(0, ncol=minSize, nrow=minSize)
	
	if (nrow(noise) != ncol(noise))
		stop('Error: matrix not quadratic.')
	
	if ((slope == 0.0) && (curvature == 0.0))
	{
		return(noise)
	}
	else
	{
		n <- ncol(noise)
		x <- xvec(n)
		return(matrix(slope*x + curvature*x^2, n, n, byrow=TRUE) + noise)
	}
}
