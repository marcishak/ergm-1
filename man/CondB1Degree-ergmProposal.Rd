% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/InitErgmProposal.R
\name{CondB1Degree-ergmProposal}
\alias{CondB1Degree-ergmProposal}
\alias{InitErgmProposal.CondB1Degree}
\title{MHp for b1degree constraints}
\description{
MHp for \eqn{constraints= ~b1degrees}. For bipartite networks, randomly select an edge {B1i, B2j}
and an empty dyad with the same node B1i, {B1i, B2k}, and propose to toggle both {B1i, B2j} and {B1i, B2k}.
This ensures that the degrees of individual nodes in mode 1 are preserved.
}
\details{
\if{html}{\Sexpr[results=rd,stage=render]{ergm:::.formatProposalsHtml(ergm:::.buildProposalsList(proposal="CondB1Degree"))}}
\if{text}{\Sexpr[results=rd,stage=render]{ergm:::.formatProposalsText(ergm:::.buildProposalsList(proposal="CondB1Degree"))}}
\if{latex}{\Sexpr[results=rd,stage=render]{ergm:::.formatProposalsLatex(ergm:::.buildProposalsList(proposal="CondB1Degree"))}}
}
