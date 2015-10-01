library(lambda.tools)

keyval <- function(k,v) {
  kv <- list(v)
  names(kv) <- k
  kv
}

mapreduce <- function(x, map=NULL, reduce=NULL, mjobs=10, rjobs=2) {
  iter_fn <- function(f) 
    function(i) {
      idx <- (mlength * (i-1) + 1) : (mlength * i)
      lapply(x[idx], function(a) f(names(a),a))
    }

  # Map stage
  if (!is.null(map)) {
    mlength <- ceiling(length(x) / mjobs)
    mresult <- do.call(c, do.call(c, lapply(1:mjobs, iter_fn(map))))
   
    # Sort
    sorted <- list()
    lapply(1:length(mresult), function(i) {
      key <- names(mresult)[i]
      if (nchar(key) == 0) return()
      sorted[[key]] <<- c(sorted[[key]], mresult[[i]])
    })
    x <- sorted
  }
 
  # Reduce stage
  if (!is.null(reduce)) {
    rlength <- ceiling(length(sorted) / rjobs)
    rresult <- do.call(c, do.call(c, lapply(1:rjobs, iter_fn(reduce))))

    x <- do.call(c, rresult)
    x[order(names(x))]
  }

  x
}
