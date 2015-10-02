mat <- matrix(rnorm(10000),ncol=100)
vec <- rnorm(100)

o <- mapreduce(triplet,
  map=function(k,v) keyval(i, m[i,j] * vec[j]),
  reduce=function(k,v) keyval(k,sum(v))
)

