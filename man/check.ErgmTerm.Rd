% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check.ErgmTerm.R
\name{check.ErgmTerm}
\alias{check.ErgmTerm}
\title{Ensures an Ergm Term and its Arguments Meet Appropriate Conditions}
\usage{
check.ErgmTerm(
  nw,
  arglist,
  directed = NULL,
  bipartite = NULL,
  nonnegative = FALSE,
  varnames = NULL,
  vartypes = NULL,
  defaultvalues = list(),
  required = NULL,
  dep.inform = rep(FALSE, length(required)),
  dep.warn = rep(FALSE, length(required))
)
}
\arguments{
\item{nw}{the network that term X is being checked against}

\item{arglist}{the list of arguments for term X}

\item{directed}{logical, whether term X requires a directed
network; default=NULL}

\item{bipartite}{whether term X requires a bipartite network (T or
F); default=NULL}

\item{nonnegative}{whether term X requires a network with only
nonnegative weights; default=FALSE}

\item{varnames}{the vector of names of the possible arguments for
term X; default=NULL}

\item{vartypes}{the vector of types of the possible arguments for
term X, separated by commas; an empty string (\code{""}) or \code{NA} disables the check for that argument, and also see Details; default=NULL}

\item{defaultvalues}{the list of default values for the possible
arguments of term X; default=list()}

\item{required}{the logical vector of whether each possible
argument is required; default=NULL}

\item{dep.inform, dep.warn}{a list of length equal to the number of
arguments the term can take; if the corresponding element of the
list is not \code{FALSE}, a \code{\link[=message]{message()}} or a \code{\link[=warning]{warning()}} respectively
will be issued if the user tries to pass it; if the element is a
character string, it will be used as a suggestion for
replacement.}
}
\value{
A list of the values for each possible argument of term X;
user provided values are used when given, default values
otherwise. The list also has an \code{attr(,"missing")} attribute
containing a named logical vector indicating whether a particular
argument had been set to its default.
}
\description{
Helper functions for implementing \code{\link[=ergm]{ergm()}}
terms, to check whether the term can be used with the specified
network.  For information on ergm terms, see
\link{ergmTerm}. \code{ergm.checkargs},
\code{ergm.checkbipartite}, and \code{ergm.checkderected} are
helper functions for an old API and are deprecated. Use
\code{check.ErgmTerm}.
}
\details{
The \code{check.ErgmTerm} function ensures for the
\code{\link{InitErgmTerm}.X} function that the term X: \itemize{
\item is applicable given the 'directed' and 'bipartite' attributes
of the given network \item is not applied to a directed bipartite
network \item has an appropiate number of arguments \item has
correct argument types if arguments where provided \item has
default values assigned if defaults are available } by halting
execution if any of the first 3 criteria are not met.

As a convenience, if an argument is optional \emph{and} its
default is \code{NULL}, then \code{NULL} is assumed to be an acceptable
argument type as well.
}
