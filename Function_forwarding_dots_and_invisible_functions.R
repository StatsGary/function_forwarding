revenue <- read.csv("revenue.csv",
                    header = FALSE)


RevSummary <- function(x, ...){
  if(!is.matrix(x) && !is.data.frame(x)){
    stop("'x' must be a matrix or data frame")
  }
  
  # Return dots to list to allow arbituary number
  # of arguments to be passed to list
  
  ellipsis.args <- list(...)
  
  rev.per.company <- colMeans(x, ...)
  rev.per.day <- rowMeans(x, ...)
  
  return(list(rev.per.company=rev.per.company,
              rev.per.day = rev.per.day,
              ellipsis.args = ellipsis.args))
  
  
}

RevSummary(data.frame(c(10,20,30, NA, 40, NA, 50, 45)),
           na.rm = TRUE)



# Using the invisible function instead of return to get rid
# of annoying outputs

invisible_function <- function(x,...) {
  rep_sequence <- rnorm(x, ...)
  if(rep_sequence < 0){
    warning("The value entered into x is below zero")
  } else{
    invisible(rep_sequence)
    return(rep_sequence)
  }
 
}

invisible_function(1000, mean = 300, sd = 30)


# Dots vs argument lists for function forwardign
# Using a formal parameter declaration to find the inputs passed into R


fn1 <- function(a, b, c){
  a + b + c
}
fn2 <- function(x, y, z){
  x - y - z
}

match_from_dots <- function(dots, fn){
  arg <- match(names(formals(fn)), names(dots))
  dots[arg[!is.na(arg)]]
}

wrap <- function(...){
  dots <- list(...)
  
  checkmate::assert_named(dots)
  
  list(
    fn1 = do.call("fn1", match_from_dots(dots, fn1)),
    fn2 = do.call("fn2", match_from_dots(dots, fn2))
  )
}

wrap(a = 1, x = 2, c = 3, b = 2, z = 3,  y = 1)


