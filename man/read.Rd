% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{read}
\alias{read}
\title{Read expression and pheno data from csv files into consistent format}
\usage{
read(data_spec)
}
\arguments{
\item{data_spec}{DataSpec S3 object. Specifications on the data. See the the
constructor \code{DataSpec()} for details.}
}
\value{
A list with a numeric matrix, named \code{expr}, and a tibble named \code{pheno}.
\code{expr} holds the expression data, with patient ids as row names and gene ids as
column names. I.e., we transpose the expression data. \code{pheno} holds the pheno data,
with the patient ids in the first column \code{patient_id_col}.
}
\description{
Read expression data into a matrix and pheno data into a tibble.
Both will hold patients as rows.
}
