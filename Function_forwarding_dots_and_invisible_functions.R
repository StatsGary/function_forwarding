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

