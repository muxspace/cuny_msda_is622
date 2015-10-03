matrix_triplet <- function(values, nrow, ncol) {
  x <- expand.grid(1:nrow,1:ncol)
  x$val <- values
  colnames(x) <- c('row','col','val')
  as.data.frame(t(x))
}

vec <- rnorm(100)
mat <- matrix_triplet(rnorm(10000), 100,100)
p1 <- mapreduce(mat, 
  map=function(k,v) keyval(as.integer(v[[1]]), v[[3]] * vec[v[[2]]]),
  reduce=function(k,v) keyval(k, sum(v))
)
p1 <- prod[sprintf("%s",1:100)]

mat2 <- as.matrix(mat[3,])
dim(mat2) <- c(100,100)
p2 <- mat2 %*% vec


head(p1)
head(p2)


