################################################################################
##
## [ PROJ ] Olivia Morales
## [ FILE ] chapter_2.R
## [ AUTH ] Olivia Morales @onmorales23
## [ INIT ] 10/30/22
##
################################################################################


## ---------------------------
## libraries
## ---------------------------


libs <- c("tidyverse","lobstr", "bench")
sapply(libs, require, character.only = TRUE)

## ---------------------------
## quiz
## ---------------------------

## 1.

df <- data.frame(runif(3), runif(3))
names(df) <- c(1, 2)
df$`3` <- df$`1` + df$`2`

## R will typically register numbers automatically as integers, not character strings
## so you have to add special ticks/marks to indicate the number is actually a name/
## character, not an integer

## 2.
x <- runif(1e6)
y <- list(x, x, x)

## 24 MB ? // sike it's 8

## 3. 

a <- c(1, 5, 3, 2)
b <- a
b[[1]] <- 10

## second line // apparently it's when b is modified but i don't buy it

## Chapter 2 Notes

# 2.2

x <- c(1, 2, 3)

# what is this code actually doing? it's creating a vector of values and binding
# it to an object named x. Thus, the name is a REFERENCE to a value

y <- x

# this isn't a copy, it's just binding this value to a different object

obj_addr(x)
obj_addr(y)

# non-syntatic names

# _abc <- 1
# Error: unexpected input in "_"

# if <- 10
# Error: unexpected assignment in "if <-"

# get around errors with backticks

`_abc` <- 1
`_abc`

`if` <- 10
`if`

## 2.2 Exercises

# 1. 

# a is a object assigned to a vector of numbers (1-10); b and c are new bindings
# to the same vector and d is a completely new object assigned to the same numbers
# (1-10)

# 2. 

mean_functions <- list(
  mean,
  base::mean,
  get("mean"),
  evalq(mean),
  match.fun("mean")
)

unique(obj_addrs(mean_functions))

# all have the same address

# 3. 

# column names can actually be data, so make.names() will mess with the data. Make
# sure col_names is false in this case

# 4.

# if names begins with ., R will prepend name with an X and non-valid characters
# are replaced by a dot. If you try to use reserved R keywords, names are followed 
# by a dot

# 5.

# Because the dot is followed by a number (not allowed)

# 2.3
x <- c(1, 2, 3)
y <- x

y[[3]] <- 4
x

# the y[[3]] <- 4 line is where x was copied and then binded to another object
# y with one value changed. This is called copy-on-modify

x <- c(1, 2, 3)
cat(tracemem(x), "/n")

y <- x
y[[3]] <- 4
y[[3]] <- 5
untracemem(x)


# functions
f <- function(a) {
  a
}

x <- c(1, 2, 3)
cat(tracemem(x), "\n")


z <- f(x)
# there's no copy here!

untracemem(x)

l1 <- list(1,2,3)
l2 <- l1
l2[[3]] <- 4

ref(l1, l2)

# data frames

d1 <- data.frame(x = c(1, 5, 6), y = c(2, 4, 3))
d2 <- d1

# columns
d2[, 2] <- d2[, 2] * 2

# rows
d3 <- d1
d3[1, ] <- d3[1, ] * 3

# character vectors
x <- c("a", "a", "abc", "d")

ref(x, character = TRUE)

## 2.3 Exercises

# 1. 

# The list of numbers is not binded to anything, so it won't show any relevant
# copying mechanisms, etc.

# 2.

x <- c(1L, 2L, 3L)
tracemem(x)

x[[3]] <- 4

# Because it's assigning a double (4) to the third element, instead of an integer
# (4L)

# 3.

a <- 1:10
b <- list(a, a)
c <- list(b, a, 1:10)

# a is just binded to integer values 1-10, b builds a list of two, each item with
# the integer values 1-10. c is a list of 3, with the first item being the previous
# list of 2, the second and the third are integer values of 1-10. *connected*

# 4.

x <- list(1:10)
x[[2]] <- x

# x is binded to a list of integer values 1-10 and the second line copy/modifies
# the second line adds a second item to the list, the previous list with the integer
# values. Copy-on-modify is triggered and now the list references the integer vector
# twice

# 2.4 

obj_size(letters)
obj_size(ggplot2::diamonds)

x <- runif(1e6)
obj_size(x)

y <- list(x, x, x)
obj_size(y)

banana <- "bananas bananas bananas"
obj_size(banana)
obj_size(rep(banana, 100))

obj_size(x, y)

obj_size(1:3)
obj_size(1:1e3)
obj_size(1:1e6)
obj_size(1:1e9)

# 2.4 Exercises

# 1.
y <- rep(list(runif(1e4)), 100)

object.size(y)

obj_size(y)


# object.size() does not detect if values are shared

# 2.
funs <- list(mean, sd, var)
obj_size(funs)


# functions are already loaded in R

# 3.

a <- runif(1e6)
obj_size(a)

b <- list(a, a)
obj_size(b)
obj_size(a, b)

b[[1]][[1]] <- 10
obj_size(b)
obj_size(a, b)

b[[2]][[1]] <- 10
obj_size(b)
obj_size(a, b)

# first chunk: probably around 8 MB 
# second chunk: won't be that much bigger than a, b and a,b will be the same
# third chunk: replaces the first element in embedded list (first item) with 10; 
# the size will get bigger b/c loss of common values
# fourth chunk: replaces second element in embedded list (first item) with 10;
# individual object is the same size, combination is bigger 

# 2.5

# Modify-in-place 

# Objects with a single binding

v <- c(1, 2, 3)
v[[3]] <- 4

# case study with for loops
x <- data.frame(matrix(runif(5 * 1e4), ncol = 5))
medians <- vapply(x, median, numeric(1))

for (i in seq_along(medians)) {
  x[[i]] <- x[[i]] - medians[[i]]
}

cat(tracemem(x), "\n")


for (i in 1:5) {
  x[[i]] <- x[[i]] - medians[[i]]
}

untracemem(x)

# solution: use a list instead

y <- as.list(x)
cat(tracemem(y), "\n")

for (i in 1:5) {
  y[[i]] <- y[[i]] - medians[[i]]
}

# environments (always modified in place)

e1 <- rlang::env(a = 1, b = 2, c = 3)
e2 <- e1

e1$c <- 4
e2$c

e <- rlang::env()
e$self <- e

ref(e)

# 2.5 Exercises

# 1.

x <- list()
x[[1]] <- x

# it's modifying in place 

# 2. 

x <- data.frame(matrix(runif(5 * 1e4), ncol = 5))

f1 <- for (i in seq_along(medians)) {
  x[[i]] <- x[[i]] - medians[[i]]
}

y <- as.list(x)
f2<- for (i in 1:5) {
  y[[i]] <- y[[i]] - medians[[i]]
}

bench::mark(f1, f2)

# 3.

tracemem(e1)

# you get an error, environments are always modified in place

# 2.6 

x <- 1:3
x <- 2:4
rm(x)

# how do objects get deleted? garbage collector or gc()

gc()
mem_used()