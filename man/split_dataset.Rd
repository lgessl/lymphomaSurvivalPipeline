% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/split_dataset.R
\name{split_dataset}
\alias{split_dataset}
\title{Split a data set into train and test data}
\usage{
split_dataset(
  expr_tbl,
  pheno_tbl,
  data_spec,
  train_prop,
  pfs_cut = NULL,
  based_on_pfs_cut = FALSE,
  quiet = FALSE
)
}
\arguments{
\item{expr_tbl}{A tibble holding the expression data (see \code{DataSpec()}
for details).}

\item{pheno_tbl}{A tibble holding the pheno data (see \code{DataSpec()}
for details).}

\item{data_spec}{A \code{DataSpec} object referring to \code{expr_tbl} and \code{pheno_tbl}.}

\item{train_prop}{numeric. The proportion of samples to be included in the
train data set.}

\item{pfs_cut}{numeric in (0, 1) or NULL. The cut-off for progression-free survival
(PFS) to distinguish between high- and low-risk patients. Default is \code{NULL}, but must
be specified if \code{based_on_pfs_cut} is \code{TRUE}.}

\item{based_on_pfs_cut}{logical. If \code{TRUE}, split the data set into high-risk, low-risk,
NA (where PFS < \code{pfs_cut} cannot be inferred from \code{pheno_tbl}) patients based on \code{pfs_cut}
and preserve the ratio of these three groups in the resulting train and test data sets.
Default is \code{FALSE}, in which case train and test samples are drawn randomly without
any further constraints.}

\item{quiet}{logical. If \code{TRUE}, suppress all messages. Default is \code{FALSE}.}
}
\description{
Split a data set into train and test data sets, (optionally)
preserving the ratio of high- and low-risk patients.
}
