generate_mock_data <- function(
    n_samples = 10,
    n_genes = 2,
    n_na_in_pheno = 3,
    to_csv = NULL,
    split_index = 1:3
){
    # expression matrix
    expr_mat <- matrix(
        sample(1:10, n_samples*n_genes, replace = TRUE),
        nrow = n_samples
    ) |> log()
    rownames(expr_mat) <- stringr::str_c("sample_", 1:n_samples)
    colnames(expr_mat) <- stringr::str_c("gene_", 1:n_genes)
    # to expression tibble
    expr_tbl <- expr_mat |> t() |> tibble::as_tibble(rownames = "gene_id")

    # pheno (n_samples x 5 tibble)
    pheno_tbl <- tibble::tibble(.rows = n_samples)
    pheno_tbl[["patient_id"]] <- rownames(expr_mat)
    pheno_tbl[["progression"]] <- sample(
        0:1,
        size = n_samples,
        replace = TRUE,
        prob = c(.3, .7)
    )
    pheno_tbl[["pfs_years"]] <- runif(n_samples, 0, 4)
    pheno_tbl[["discrete_var"]] <- sample(1:3, size = n_samples, replace = TRUE)
    pheno_tbl[["continuous_var"]] <- rnorm(n_samples, 10, 10)
    pheno_tbl[["ipi"]] <- sample(1:5, size = n_samples, replace = TRUE)
    pheno_tbl[["ipi"]][1] <- NA
    for(i in split_index){
        pheno_tbl[[paste0("split_", i)]] <- sample(
            c("train", "test"),
            size = n_samples,
            replace = TRUE
        )
    }
    # insert NAs
    na_rows <- sample(1:n_samples, n_na_in_pheno, replace = TRUE)
    na_cols <- sample(4:6, n_na_in_pheno, replace = TRUE)
    if(n_na_in_pheno > 0){
        for(i in 1:n_na_in_pheno){
            pheno_tbl[na_rows[i], na_cols[i]] <- NA
        }
    }

    if(is.character(to_csv)){
        if(!dir.exists(to_csv)) dir.create(to_csv, recursive = TRUE)
        readr::write_csv(expr_tbl, file.path(to_csv, "expr.csv"))
        readr::write_csv(pheno_tbl, file.path(to_csv, "pheno.csv"))
    }

    if(is.null(to_csv)) to_csv <- "mock_dir"
    data <- Data$new(
        name = "mock",
        directory = to_csv,
        train_prop = 0.7,
        pivot_time_cutoff = 0.5,
        expr_file = "expr.csv",
        pheno_file = "pheno.csv",
        cohort = "train",
        patient_id_col = "patient_id",
        time_to_event_col = "pfs_years",
        event_col = "progression",
        benchmark_col = "ipi",
        gene_id_col = "gene_id",
        split_col_prefix = "split_"
    )
    data$expr_mat <- expr_mat
    data$pheno_tbl <- pheno_tbl
    return(data)
}


apb <- function(
    n_samples,
    split_index,
    fluctuating_availability = TRUE
){
    l <- list()
    for(i in 1:3){
        l[[i]] <- list()
        for(j in split_index){
            # Simulate fluctuating availability
            if(fluctuating_availability)
                n_samples <- n_samples + sample(c(-1, 1), size = 1)
            if(i == 1){
                l[[i]][[j]] <- sample(c(0, 1), n_samples, replace = TRUE)
            } else {
                l[[i]][[j]] <- rnorm(n_samples)
            }
            names(l[[i]][[j]]) <- paste0("sample_", 1:n_samples)
            l[[i]][[j]][sample(1:n_samples, 1)] <- NA
        }
    }
    names(l) <- c("actual", "predicted", "benchmark")
    return(l)
}
