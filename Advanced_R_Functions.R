#Function components
#All R functions have three parts:
#the body(), the code inside the function.
#the formals(), the list of arguments which controls how you can call the function.
#the environment(), the "map" of the location of the function's variables.
#When you print a function in R, it shows you these three important components. If the environment isn't displayed, it means that the function was created in the global environment.

f <- function(x) x^2
f

formals(f)
body(f)
environment(f)

#Primitive functions
#There is one exception to the rule that functions have three components. Primitive functions, like sum(), call C code directly with .Primitive() and contain no R code. Therefore their formals(), body(), and environment() are all NULL:

formals(sum)
body(sum)
environment(sum)


#Primitive functions are only found in the base package, and since they operate at a low level, they can be more efficient (primitive replacement functions don't have to make copies), and can have different rules for argument matching (e.g., switch and call). This, however, comes at a cost of behaving differently from all other functions in R. Hence the R core team generally avoids creating them unless there is no other option.


#------------------------ LEXICAL SCOPING -----------------------------------

x <- 10 
x
#Understanding scoping allows you to:
#build tools by composing functions, as described in functional programming.
#overrule the usual evaluation rules and do non-standard evaluation, as described in non-standard evaluation.
#R has two types of scoping: lexical scoping, implemented automatically at the language level, and dynamic scoping, used in select functions to save typing during interactive analysis. We discuss lexical scoping here because it is intimately tied to function creation. Dynamic scoping is described in more detail in scoping issues.
#Lexical scoping looks up symbol values based on how functions were nested when they were created, not how they are nested when they are called. With lexical scoping, you don't need to know how the function is called to figure out where the value of a variable will be looked up. You just need to look at the function's definition.
#The "lexical" in lexical scoping doesn't correspond to the usual English definition ("of or relating to words or the vocabulary of a language as distinguished from its grammar and construction") but comes from the computer science term "lexing", which is part of the process that converts code represented as text to meaningful pieces that the programming language understands.
#There are four basic principles behind R's implementation of lexical scoping:
#name masking
#functions vs. variables
#a fresh start
#dynamic lookup
#You probably know many of these principles already, although you might not have thought about them explicitly. Test your knowledge by mentally running through the code in each block before looking at the answers.


#-------------------------------Name masking ----------------------------------
f <- function() {
  x <- 1
  y <- 2
  c(x, y)
}

f()
rm(f)
#If a name isn't defined inside a function, R will look one level up.
x <- 2
g <- function() {
  y <- 1
  c(x, y)
}
g()
rm(x, g)


#The same rules apply if a function is defined inside another function: look inside the current function, then where that function was defined, and so on, all the way up to the global environment, and then on to other loaded packages. Run the following code in your head, then confirm the output by running the R code.
x <- 1
h <- function() {
  y <- 2
  i <- function() {
    z <- 3
    c(x, y, z)
  }
  i()
}
h()
rm(x, h)

#The same rules apply to closures, functions created by other functions. Closures will be described in more detail in functional programming; here we'll just look at how they interact with scoping. The following function, j(), returns a function. What do you think this function will return when we call it?
j <- function(x) {
  y <- 2
  function() {
    c(x, y)
  }
}
k <- j(1)
k()
rm(j, k)

#This seems a little magical (how does R know what the value of y is after the function has been called). It works because k preserves the environment in which it was defined and because the environment includes the value of y. Environments gives some pointers on how you can dive in and figure out what values are stored in the environment associated with each function.



# ------------------------- Functions vs variables ----------------------------#

l <- function(x) x + 1
m <- function() {
  l <- function(x) x * 2
  l(10)
}
m()
#> [1] 20
rm(l, m)

#For functions, there is one small tweak to the rule. If you are using a name in a context where it's obvious that you want a function (e.g., f(3)), R will ignore objects that are not functions while it is searching. In the following example n takes on a different value depending on whether R is looking for a function or a variable.
n <- function(x) x / 2
o <- function() {
  n <- 10
  n(n)
}

o()
#> [1] 5
rm(n, o)

#A fresh start
#What happens to the values in between invocations of a function? What will happen the first time you run this function? What will happen the second time? (If you haven't seen exists() before: it returns TRUE if there's a variable of that name, otherwise it returns FALSE.)

j <- function() {
  if (!exists("a")) {
    a <- 1
  } else {
    a <- a + 1
  }
  a
}
j()
rm(j)

#You might be surprised that it returns the same value, 1, every time. This is because every time a function is called, a new environment is created to host execution. A function has no way to tell what happened the last time it was run; each invocation is completely independent. (We'll see some ways to get around this in mutable state.)

#Dynamic lookup
#Lexical scoping determines where to look for values, not when to look for them. R looks for values when the function is run, not when it's created. This means that the output of a function can be different depending on objects outside its environment:

f <- function() x
x <- 15
f()

x <- 20 
f()

# generally want to avoid this behaviour because it means the function is no longer self-contained. This is a common error - if you make a spelling mistake in your code, you won't get an error when you create the function, and you might not even get one when you run the function, depending on what variables are defined in the global environment.

#One way to detect this problem is the findGlobals() function from codetools. This function lists all the external dependencies of a function:


f <- function() x + 1
codetools::findGlobals(f)

#Another way to try and solve the problem would be to manually change the environment of the function to the emptyenv(), an environment which contains absolutely nothing:

environment(f) <- emptyenv()
f()

#This doesn't work because R relies on lexical scoping to find everything, even the + operator. It's never possible to make a function completely self-contained because you must always rely on functions defined in base R or other packages.

#You can use this same idea to do other things that are extremely ill-advised. For example, since all of the standard operators in R are functions, you can override them with your own alternatives. If you ever are feeling particularly evil, run the following code while your friend is away from their computer:

#DONT RUN

# `(` <- function(e1) {
#   if (is.numeric(e1) && runif(1) < 0.1) {
#     e1 + 1
#   } else {
#     e1
#   }
# }
# replicate(50, (1 + 2))
# #>  [1] 3 3 3 3 4 3 3 3 3 3 3 3 3 3 4 3 3 4 3 3 4 3 4 4 3 3 3 3 3 3 3 3 3 3 3
# #> [36] 3 3 3 4 3 3 3 3 3 3 3 3 3 3 3
# rm("(")


# Every operation is a function call
# To understand computations in R, two slogans are helpful:
# - Everything that exists is an object
# - Everything that happens is a function call

# The previous example of redefining ( works because every operation in R is a function call, whether or not it looks like one. This includes infix operators like +, control flow operators like for, if, and while, subsetting operators like [] and $, and even the curly brace {. This means that each pair of statements in the following example is exactly equivalent. Note that `, the backtick, lets you refer to functions or variables that have otherwise reserved or illegal names:
x <- 10; y <- 5
x + y
`/`(x, y)# Another way to write functons

for (i in 1:2) print(i)
'for'(i, 1:2, print(i))

if (i == 1) print("yes!") else print("no.")

`if`(i == 1, print("yes!"), print("no."))

x[3]
`[`(x, 3)

#It is possible to override the definitions of these special functions, but this is almost certainly a bad idea. However, there are occasions when it might be useful: it allows you to do something that would have otherwise been impossible. For example, this feature makes it possible for the dplyr package to translate R expressions into SQL expressions. Domain specific languages uses this idea to create domain specific languages that allow you to concisely express new concepts using existing R constructs.
# It's more often useful to treat special functions as ordinary functions. For example, we could use sapply() to add 3 to every element of a list by first defining a function add(), like this:
add <- function(x, y) x + y
sapply(1:10, add, 3)


sapply(1:5, `+`, 3)
sapply(1:5, "+", 3)
#Note the difference between `+` and "+". The first one is the value of the object called +, and the second is a string containing the character +. The second version works because sapply can be given the name of a function instead of the function itself: if you read the source of sapply(), you'll see the first line uses match.fun() to find functions given their names.

x <- list(1:3, 4:9, 10:12)
sapply(x, "[", 2)
#> [1]  2  5 11

# equivalent to
sapply(x, function(x) x[2])

# Function arguments
#it's useful to distinguish between the formal arguments and the actual arguments of a function. The formal arguments are a property of the function, whereas the actual or calling arguments can vary each time you call the function. This section discusses how calling arguments are mapped to formal arguments, how you can call a function given a list of arguments, how default arguments work, and the impact of lazy evaluation.
#Calling functions
#When calling a function you can specify arguments by position, by complete name, or by partial name. Arguments are matched first by exact name (perfect matching), then by prefix matching, and finally by position.
f <- function(abcdef, bcde1, bcde2) {
  list(a = abcdef, b1 = bcde1, b2 = bcde2)
}
str(f(1, 2, 3))
str(f(2, 3, abcdef = 1))
str(f(2, 3, a = 1))
# But this doesn't work because abbreviation is ambiguous
str(f(1, 3, b = 1))

mean(1:10)
mean(1:10 , trim = 0.05)

# This is probably overkill

mean(x=1:10)


#-------------------- Calling a function given a list of arguments -------------

#Suppose you had a list of function arguments:
args <- list(1:10, na.rm = TRUE)

# The special do.call command

do.call(mean, args)
mean(1:10, na.rm = TRUE)


#--------------------- Default and missing arguments ----------------------------

f <- function(a=1, b=2){
  c(a,b)
}
f()

#Since arguments in R are evaluated lazily (more on that below), the default value can be defined in terms of other arguments:

g <- function(a = 1, b = a * 2) {
  c(a, b)
}

g(10)

#Default arguments can even be defined in terms of variables created within the function. This is used frequently in base R functions, but I think it is bad practice, because you can't understand what the default values will be without reading the complete source code.
h <- function(a = 1, b = d) {
  d <- (a + 1) ^ 2
  c(a, b)
}
h()

h(10)

#You can determine if an argument was supplied or not with the missing() function.

i <- function(a,b){
  c(missing(a), missing(b))
}
i()

i(a=1)
i(b=2)
i(1,2)

#Lazy evaluation

f <- function(x) {
  10
}
f(stop("This is an error!"))

#If you want to ensure that an argument is evaluated you can use force():

f <- function(x) {
  force(x)
  10
}
f(stop("This is an error!"))

#This is important when creating closures with lapply() or a loop:

add <- function(x) {
  function(y) x + y
}
adders <- lapply(1:10, add)
adders[[1]](10)
adders[[10]](10)

#x is lazily evaluated the first time that you call one of the adder functions. At this point, the loop is complete and the final value of x is 10. Therefore all of the adder functions will add 10 on to their input, probably not what you wanted! Manually forcing evaluation fixes the problem:
add <- function(x) {
  force(x)
  function(y) x + y
}
adders2 <- lapply(1:10, add)
adders2[[1]](10)
#This code is exactly equivalent to
add <- function(x) {
  x
  function(y) x + y
}
#because the force function is defined as force <- function(x) x. However, using this function clearly indicates that you're forcing evaluation, not that you've accidentally typed x.
#Default arguments are evaluated inside the function. This means that if the expression depends on the current environment the results will differ depending on whether you use the default value or explicitly provide one.


