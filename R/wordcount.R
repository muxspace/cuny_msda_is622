

clean <- function(x) {
  gsub('[,.;:\'"()]','',tolower(x))
}

lines <- do.call(c, strsplit(clean(readLines('../data/amazon-10q.txt')), '\\s'))

o <- mapreduce(lines,
  map=function(k,v) keyval(v,1),
  reduce=function(k,v) keyval(k,sum(v))
)
