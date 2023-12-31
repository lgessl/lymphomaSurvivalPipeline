test_that("qc_preprocess() works", {

  set.seed(234)

  n_samples <- 5
  n_genes <- 1

  dir <- withr::local_tempdir()
  data <- generate_mock_data(
    n_samples = n_samples,
    n_genes = n_genes,
    n_na_in_pheno = 0,
    to_csv = dir
  )
  expr_tbl <- data[["expr_tbl"]]
  pheno_tbl <- data[["pheno_tbl"]]
  data_spec <- DataSpec(
    name = "mock",
    directory = dir
  )

  expect_silent(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec
    )
  )
  expect_silent(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec,
      check_default = TRUE
    )
  )

  data_spec$expr_fname <- "nonexistent.csv"
  expect_error(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec
    ),
    regexp = "Expression file"
  )
  data_spec$expr_fname <- "expr.csv"

  pheno_tbl[["progression"]][1] <- 2
  expect_error(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec
    ),
    regexp = "either 1"
  )
  pheno_tbl[["progression"]][1] <- 0

  pheno_tbl[["patient_id"]][1] <- "sample_2"
  expect_error(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec
    ),
    regexp = "Patient ids"
  )
  pheno_tbl[["patient_id"]][1] <- "sample_1"

  pheno_tbl[["pfs_years"]][1] <- NA
  expect_warning(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec
    ),
    regexp = "missing values"
  )
  pheno_tbl[["pfs_years"]][1] <- 1

  expr_tbl[[2]] <- "some char"
  expect_error(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec
    ),
    regexp = "numeric"
  )
  expr_tbl[[2]] <- 1

  expr_tbl[[2]][1] <- NA
  expect_error(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec
    ),
    regexp = "missing values"
  )
  expr_tbl[[2]][1] <- 1

  pheno_tbl <- pheno_tbl[, c(2:ncol(pheno_tbl), 1)]
  expect_error(
    qc_preprocess(
      expr_tbl = expr_tbl,
      pheno_tbl = pheno_tbl,
      data_spec = data_spec
    ),
    regexp = "First column"
  )
})
