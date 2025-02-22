#  File R/ergm.utility.R in package ergm, part of the
#  Statnet suite of packages for network analysis, https://statnet.org .
#
#  This software is distributed under the GPL-3 license.  It is free,
#  open source, and has the attribution requirements (GPL Section 7) at
#  https://statnet.org/attribution .
#
#  Copyright 2003-2021 Statnet Commons
################################################################################
#==============================================================
# This file contains the following 21 utility functions:
#      <ostar2deg>                  
#      <is.invertible>          <summary.statsmatrix.ergm>
#      <is.ergm>                <ergm.t.summary>
#      <is.latent>
#      <degreedist>             <is.latent.cluster>
#      <espartnerdist>          <dspartnerdist>         
#      <rspartnerdist>         
#      <twopathdist>            <copy.named>
#      <compress.data.frame>    <sort.data.frame>
#      <catchToList>
#==============================================================      

#' @rdname ergm
#' @importFrom methods is
#' @export
is.ergm <- function(object)
{
    is(object,"ergm")
}

###############################################################################
# The <degreedist> function computes and returns the degree distribution for
# a given network
#
# --PARAMETERS--
#   g    : a network object
#   print: whether to print the degree distribution; default=TRUE
#
# --RETURNED--
#   degrees:
#      if directed  -- a matrix of the distributions of in and out degrees;
#                      this is row bound and only contains degrees for which
#                      one of the in or out distributions has a positive count
#      if bipartite -- a list containing the degree distributions of b1 and b2
#      otherwise    -- a vector of the positive values in the degree
#                      distribution
###############################################################################



#' Computes and Returns the Degree Distribution Information for a Given Network
#' 
#' The \code{degreedist} generic computes and returns the degree
#' distribution (number of vertices in the network with each degree
#' value) for a given network. This help page documents the
#' function. For help about [the ERGM sample space constraint with
#' that name][degreedist-ergmConstraint], try
#' `help("degreedist-constraint")`.
#' 
#' @param object a \code{network} object or some other object for
#'   which degree distribution is meaningful.
#' @param \dots Additional arguments to functions.
#' @return If directed, a matrix of the distributions of in and out
#'   degrees; this is row bound and only contains degrees for which
#'   one of the in or out distributions has a positive count.  If
#'   bipartite, a list containing the degree distributions of b1 and
#'   b2.  Otherwise, a vector of the positive values in the degree
#'   distribution
#' @examples
#' 
#' data(faux.mesa.high)
#' degreedist(faux.mesa.high)
#' 
#' @export
degreedist <- function(object, ...) UseMethod("degreedist")

#' @describeIn degreedist Method for [`network`] objects.
#' @param print logical, whether to print the degree distribution.
#' @export
degreedist.network <- function(object, print=TRUE, ...)
{
 g <- object
 if(is.directed(g)){                                      
   mesp <- paste("c(",paste(0:(network.size(g)-1),collapse=","),")",sep="")
   outdegrees <- summary(as.formula(paste('g ~ odegree(',mesp,')',sep="")))
   indegrees <- summary(as.formula(paste('g ~ idegree(',mesp,')',sep="")))
   temp <- outdegrees > 0 | indegrees > 0
   outdegrees <- outdegrees[temp]
   indegrees <- indegrees[temp]
   if(!is.null(outdegrees) & print){print(outdegrees[outdegrees>0])}
   if(!is.null(indegrees) & print){print(indegrees[indegrees>0])}
   degrees <- rbind(indegrees, outdegrees)
 }else{
  if(is.bipartite(g)){
   nb1 <- get.network.attribute(g,"bipartite")
   nb2 <- network.size(g) - nb1
   mesp <- paste("c(",paste(0:nb2,collapse=","),")",sep="")
   b1degrees <- summary(as.formula(paste('g ~ b1degree(',mesp,')',sep="")))
   mesp <- paste("c(",paste(0:nb1,collapse=","),")",sep="")
   b2degrees <- summary(as.formula(paste('g ~ b2degree(',mesp,')',sep="")))
   names(b2degrees) <- 0:nb1
   if(!is.null(b2degrees) & print){
    cat("Bipartite mode 2 degree distribution:\n")
    if(any(b2degrees>0)){print(b2degrees[b2degrees>0])}
   }
   names(b1degrees) <- 0:nb2
   if(!is.null(b1degrees) & print){
    cat("Bipartite mode 1 degree distribution:\n")
    if(any(b1degrees>0)){print(b1degrees[b1degrees>0])}
   }
   degrees <- list(b2=b2degrees, b1=b1degrees)
  }else{              
   mesp <- paste("c(",paste(0:(network.size(g)-1),collapse=","),")",sep="")
   degrees <- summary(as.formula(paste('g ~ degree(',mesp,')',sep="")))
   degrees <- degrees[degrees > 0]
   if(!is.null(degrees) & print){print(degrees)}
  }
 }
 invisible(degrees)
}


summary.statsmatrix.ergm <- function(object, ...){
 c(summary(round(object,digits=8), ...),
   round(ergm.t.summary(object),5))
}


###############################################################################
# The <ergm.t.summary> function conducts a t test for comparing the mean of a
# given vector and a hypothesized mean
#
# --PARAMETERS--
#   x          : a numeric vector
#   alternative: a string to indicate whether the test is two-sided or one-
#                sided to the left or right, as either "two.sided", "less",
#                or "greater"; default="two.sided"
#   mu         : the hypothesized mean; default = 0
#
# --IGNORED PARAMETERS--
#   var.equal : whether the variance of ?? is ??; default=FALSE
#   conf.level: the confidence level; default=0.95
#   ...       : ??
#
# --RETURNED--
#   rval: a vetor of the standard error, the t statistic, the p value, and the
#         standard deviation, consistent with 'alternative'; if the length of
#         x is <2, this vector will be predominently NA's
#
###############################################################################

ergm.t.summary <-
function(x, alternative = c("two.sided", "less", "greater"),
         mu = 0, var.equal = FALSE, conf.level = 0.95,
         ...)
{
    alternative <- match.arg(alternative)

    if(!missing(mu) && (length(mu) != 1 || is.na(mu)))
        stop("mu must be a single number")
    if(!missing(conf.level) &&
       (length(conf.level) != 1 || !is.finite(conf.level) ||
        conf.level < 0 || conf.level > 1))
        stop("conf.level must be a single number between 0 and 1")

    dname <- deparse(substitute(x))
    xok <- !is.na(x)
    yok <- NULL
    x <- x[xok]
    nx <- length(x)
    mx <- mean(x)
    rval <- c(NA, mx, NA, NA)
    names(rval) <- c("std. err.","std. t units.","p.value dev.","std. dev.")
    if(nx < 2){
#     stop("not enough x observations")
      return(rval)
    }
    vx <- var(x)
    estimate <- mx
    df <- nx-1
    stddev <- sqrt(vx)
    stderr <- sqrt(vx/nx)
    if(stderr < 10 *.Machine$double.eps * abs(mx)){
#       stop("data are essentially constant")
        return(rval)
    }
    tstat <- (mx-mu)/stderr
    method <- "One Sample t-test"
    names(estimate) <- "mean of x"
    if (alternative == "less") {
	pval <- pt(tstat, df)
    }
    else if (alternative == "greater") {
	pval <- pt(tstat, df, lower.tail = FALSE)
    }
    else {
	pval <- 2 * pt(-abs(tstat), df)
    }
    rval[1:4] <- c(stderr, tstat, pval, stddev)
    return(rval)
}

#' Copy network- and vertex-level attributes between two network objects
#' 
#' An internal ergm utility function to copy the network-level attributes and
#' vertex-level attributes from one \code{\link{network}} object to another,
#' ignoring some standard properties by default.
#' 
#' 
#' @param to the \code{\link{network}} that attributes should be copied to
#' @param from the \code{\link{network}} that attributes should be copied to
#' @param ignore vector of charcter names of network attributes that should not
#' be copied. Default is the standard list of network properties created by
#' \code{\link{network.initialize}}
#' @return returns the \code{to} network, with attributes copied from
#' \code{from}
#' @note does not check that networks are of the same size, etc
#' @seealso \code{\link{set.vertex.attribute}},
#' \code{\link{set.network.attribute}}
#' @keywords internal
#' @export nvattr.copy.network
nvattr.copy.network <- function(to, from, ignore=c("bipartite","directed","hyper","loops","mnext","multiple","n")){
  for(a in list.vertex.attributes(from)){
    if(! a%in%ignore)
      to <- set.vertex.attribute(to, a, get.vertex.attribute(from, a, unlist=FALSE))
  }
  for(a in list.network.attributes(from)){
    if(! a%in%ignore)
      to <- set.network.attribute(to, a, get.network.attribute(from, a, unlist=FALSE))
  }
  to
}

single.impute.dyads <- function(nw, constraints=NULL, constraints.obs=NULL, min_informative=NULL, default_density=NULL, output=c("network","ergm_state"), verbose=FALSE){
  output <- match.arg(output)
  stopifnot(!is.null(constraints)||is.null(constraints.obs))

  if(!is.null(constraints)){
    imputable <- as.rlebdm(constraints, constraints.obs, "missing")
    nae <- NVL3(imputable, sum(.), 0)
    if(nae) na.el <- as.edgelist(imputable) # FIXME: Avoid creating edgelists.
  }else{
    nae <- network.naedgecount(nw)
    if(nae) na.el <- as.edgelist(is.na(nw))
  }
  if(nae==0){
    if(output=="network") return(nw)
    else return(ergm_state(nw))
  }

  if(verbose) message("Imputing ", nae, " dyads is required.")

  el2s <- function(el) apply(el, 1, paste, collapse=",")
  s2el <- function(s) matrix(as.integer(do.call(rbind,strsplit(s,","))),ncol=2)

  min_informative <- NVL3(min_informative, if(is.function(.)) .(nw) else ., 0)
  default_density <- if(is.function(default_density)) default_density(nw)

  if(!is.null(constraints)){ # Constraints
    informative <- as.rlebdm(constraints, constraints.obs, "informative")
    nonzeros <- as.rlebdm(nw)
    if(!is.valued(nw)){
      d <-
        if(sum(informative)<min_informative){
          message("Number of informative dyads is too low. Using default imputation density.")
          default_density
        }else sum(nonzeros & informative)/sum(informative)
      nimpute <- round(d*nae)
    }else{
      if(sum(informative)<min_informative){
        message("Number of informative dyads is too low. Imputing valued relations is not possible.")
        return(nw)
      }
      x <- as.edgelist(nw,attrname=nw%ergmlhs%"response")
      x.el <- x[,1:2,drop=FALSE]
      x <- x.el[! el2s(x.el)%in%el2s(na.el),3]
      zeros <- sum(informative) - length(x)
    }
  }else{ # No Constraints
    if(!is.valued(nw)){
      d <-
        if(network.dyadcount(nw,na.omit=TRUE)<min_informative){
          message("Number of informative dyads is too low. Using default imputation density.")
          default_density
        }else network.edgecount(nw,na.omit=TRUE)/network.dyadcount(nw,na.omit=TRUE)
      nimpute <- round(d*nae)
    }else{
      if(network.dyadcount(nw,na.omit=TRUE)<min_informative){
        message("Number of informative dyads is too low. Imputing valued relations is not possible.")
        return(nw)
      }
      x <- as.edgelist(nw,attrname=nw%ergmlhs%"response")[,3]
      zeros <- network.dyadcount(nw,na.omit=TRUE)-length(x)
    }
  }
  
  if(!is.valued(nw)){
    if(verbose) message("Imputing ", nimpute, " edges at random.")
    i.new <- sample.int(nae,nimpute)
    if(output=="network"){
      y.cur <- nw[na.el]
      i.na <- which(is.na(y.cur))
      i.cur <- which(y.cur!=0)
      todel <- union(setdiff(i.cur, i.new), setdiff(i.na, i.new))
      toadd <- union(setdiff(i.new, i.cur), intersect(i.na, i.new))
      nw[na.el[c(todel,toadd),,drop=FALSE]] <- rep(0:1, c(length(todel),length(toadd)))
    }else{ # edgelist
      el <- s2el(union(setdiff(el2s(as.edgelist(nw)), el2s(na.el)), el2s(na.el[i.new,,drop=FALSE])))
      colnames(el) <- c(".tail",".head")
      nw <- ergm_state(el, nw=nw)
    }
  }else{
    if(output=="network"){
      nw[na.el,names.eval=nw%ergmlhs%"response",add.edges=TRUE] <- sample(c(0,x),nae,replace=TRUE,prob=c(zeros,rep(1,length(x))))
    }else{ # edgelist
      el <- as.edgelist(nw, attrname=nw%ergmlhs%"response")
      el <- el[!el2s(el[,-3,drop=FALSE])%in%el2s(na.el),,drop=FALSE]
      el <- rbind(el, cbind(na.el, sample(c(0,x),nae,replace=TRUE,prob=c(zeros,rep(1,length(x))))))
      el <- el[el[,3]!=0,,drop=FALSE]
      colnames(el) <- c(".tail",".head",nw%ergmlhs%"response")
      nw <- ergm_state(el, nw=nw)
    }
  }

  nw
}

# executes expression, returns the result in a list with any warnings and errors
.catchToList <- function(expr) {
  val <- NULL
  myWarnings <- NULL
  wHandler <- function(w) {
    myWarnings <<- c(myWarnings, w$message)
    invokeRestart("muffleWarning")
  }
  myError <- NULL
  eHandler <- function(e) {
    myError <<- e$message
    NULL
  }
  val <- tryCatch(withCallingHandlers(expr, warning = wHandler), error = eHandler)
  list(value = val, warnings = myWarnings, error=myError)
} 

## A is a matrix. V is a column vector that may contain Infs
## computes A %*% V, counting 0*Inf as 0
.multiply.with.inf <- function(A,V) {
  cbind(colSums(t(A)*c(V), na.rm=TRUE))
}

trim_env_const_formula <- function(x, keep=NULL){
  terms <- list_rhs.formula(x)
  needs_env <- FALSE
  basefn <- ls(baseenv())

  is_simple <- function(x, toplevel=FALSE){
    if(is.null(x) || is.character(x) || is.numeric(x) || is.logical(x) || is.complex(x) || identical(x, as.name("."))) TRUE
    else if(is.call(x)){
      fn <- as.character(x[[1]])
      if(!toplevel && ! fn%in%basefn) FALSE
      else all(sapply(as.list(x)[-1], is_simple))
    } else FALSE
  }

  for(trm in terms){
    if(is.call(trm) && !is_simple(trm, TRUE)){
        needs_env <- TRUE
        break
    }
  }

  if(needs_env) x else trim_env(x, keep)
}

#' Test if the object is a matrix that is symmetric and positive definite.
#' @param x the object to be tested.
#' @param tol the tolerance for the reciprocal condition number.
#' @noRd
is.SPD <- function(x, tol = .Machine$double.eps){
  is.matrix(x) &&
    nrow(x) == ncol(x) &&
    all(x == t(x)) &&
    rcond(x) >= tol &&
    all(eigen(x, symmetric=TRUE, only.values=TRUE)$values > 0)
}

# ssolve() and sginv() (for *s*caled) are thin wrappers around
# base::solve() and MASS::ginv() that first scale the matrix's rows
# and/or columns by its diagonal elements and then undo the scaling on
# the result. rcond() returns the reciprocal condition number net of
# the above scaling. snearPD() wraps nearPD() to scale the diagonal
# as well.
#
# This is useful when dealing with covariance matrices of variables
# with very different orders of magnitude. Such matrices have very
# large ratios between their greatest and their least eigenvalues,
# causing them to appear to their algorithms to be near-singular when
# they are actually very much SPD.
#
# NB: In R, vector * matrix and matrix * vector always scales
# corresponding rows.
ssolve <- function(a, b, ..., symm = TRUE){
  if(missing(b)){
    b <- diag(1, nrow(a))
    colnames(b) <- rownames(a)
  }

  d <- diag(as.matrix(a))
  d <- ifelse(d==0, 1, 1/d)

  if(symm){
    d <- sqrt(d)
    a <- a * d * rep(d, each = length(d))
    solve(a, b*d, ...) * d
  }else{
    solve(a*d, b*d, ...)
  }
}


sginv <- function(X, ..., symm = TRUE){
  d <- diag(as.matrix(X))
  d <- ifelse(abs(d - 0) < .Machine$double.eps, 1, 1/d)

  if(symm){
    d <- sqrt(d)
    dd <- rep(d, each = length(d)) * d
    X <- X * dd
    ginv(X, ...) * dd
  }else{
    dd <- rep(d, each = length(d))
    ginv(X*d, ...) * dd
  }
}

srcond <- function(x, ..., symm = TRUE){
  d <- diag(as.matrix(x))
  d <- ifelse(d==0, 1, 1/d)

  if(symm){
    d <- sqrt(d)
    dd <- rep(d, each = length(d)) * d
    rcond(x*dd)
  }else{
    rcond(x*d, ...)
  }
}

snearPD <- function(x, ...){
  d <- abs(diag(as.matrix(x)))
  d[d==0] <- 1
  d <- sqrt(d)
  dd <- rep(d, each = length(d)) * d
  x <- nearPD(x / dd, ...)
  x$mat <- x$mat * dd
  x
}

# These are somewhat inspired by emulator::quad.form.inv() and others.

# x^T A x
xTAx <- function(x, A){
  drop(crossprod(crossprod(A, x), x))
}
# x A x^T
xAxT <- function(x, A){
  drop(x %*% tcrossprod(A, x))
}

# xT A^-1 x
xTAx_ssolve <- function(x, A, ...){
  drop(crossprod(x, ssolve(A, x, ...)))
}

# xT A^-1 x, but using QR decomposition and confirming that x is in
# the span of A if A is singular; returns rank and nullity as
# attributes just in case subsequent calculations (e.g., hypothesis
# test degrees of freedom) are affected
xTAx_qrsolve <- function(x, A, tol = 1e-07, ...){
  Aqr <- qr(A, tol=tol, ...)
  nullity <- NCOL(A) - Aqr$rank
  if(nullity && !all(abs(crossprod(qr.Q(Aqr)[,-seq_len(Aqr$rank), drop=FALSE], x))<tol))
    stop("x is not in the span of A")
  structure(sum(x*qr.coef(Aqr, x), na.rm=TRUE), rank=Aqr$rank, nullity=nullity)
}

# Evaluate A^-1 B (A^T)^-1, minimising matrix inversion.
sandwich_ssolve <- function(A, B, ...){
  ssolve(A, t(ssolve(A, B, ...)), ...)
}
