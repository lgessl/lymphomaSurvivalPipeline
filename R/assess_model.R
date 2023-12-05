#' @title Assess a model on a data set in terms of classifying high-risk patients
#' @description Given a data-model pair, assess the model's performance in terms of
#' classifying high-risk patients by plotting one binary-classifier characteristic
#' (e.g. prevalance) versus another one (e.g. precision) and comparing it to a
#' benchmark classifier (e.g. the International Prognostic Index (IPI) for DLBCL).
#' @param expr_mat numeric matrix. The expression matrix. Rows are samples, columns
#' are genes, their identifiers are given as row and column names, respectively.
#' @param pheno_tbl tibble. The phenotype table. Observations are samples, columns 
#' are variables.
#' @param data_spec DataSpec object specifying `expr_mat` and `pheno_tbl`. See the 
#' constructor `DataSpec()` for details.
#' @param model_spec ModelSpec object. The model to be assessed. See the constructor
#' `ModelSpec()` for details.
#' @param perf_plot_spec PerfPlotSpec object. The specifications for the plot. See
#' the constructor `PerfPlotSpec()` for details. The `pfs_leq` attribute of
#' `perf_plot_spec` will override the same in `model_spec` if both are given.
#' @return A named list of two tibbles:
#' * `model_spec$name`: The performance measures for the model with three variables:
#' `perf_plot_spec$x_metric`, `perf_plot_spec$y_metric`, and `"cutoff"`.
#' * `perf_plot_spec$benchmark`: The performance measures for the benchmark classifier
#' with the same three variables.
#' @details The assessment views every model as a binary classifier for high-risk (pfs <
#' `pfs_leq`) versus low-risk (pfs >= `pfs_leq`) patients (where `pfs_leq` is determined
#' as described above).
assess_model <- function(
    expr_mat,
    pheno_tbl,
    data_spec,
    model_spec,
    perf_plot_spec
){
    # Infer reasonable values for missing plot specs
    if(!is.null(perf_plot_spec$pfs_leq)){
        model_spec$pfs_leq <- perf_plot_spec$pfs_leq # plot spec overrides model spec
    } else if(is.null(model_spec$pfs_leq)){
            stop("You need to specify the `pfs_leq` atrribute in at least ",
                "one of `data_spec` and `model_spec`.")
    }
    if(is.null(perf_plot_spec$title)){
        perf_plot_spec$title <- stringr::str_c(
            data_spec$name, ", pfs < ", model_spec$pfs_leq
        )
    }

    # Prepare, predict and calcualte performance metric
    # (a) For model
    pred_act <- prepare_and_predict(
        expr_mat = expr_mat,
        pheno_tbl = pheno_tbl,
        data_spec = data_spec,
        model_spec = model_spec
    )
    actual <- pred_act[["actual"]]
    predicted <- pred_act[["predicted"]]
    perf_tbl_model <- calculate_perf_metric(
        predicted = predicted,
        actual = actual,
        perf_plot_spec = perf_plot_spec
    )

    # (b) For benchmark (if given)
    perf_tbl_bm <- NULL
    if(!is.null(perf_plot_spec$benchmark)){
        perf_tbl_bm <- add_benchmark_perf_metric(
            pheno_tbl = pheno_tbl,
            data_spec = data_spec,
            perf_plot_spec = perf_plot_spec,
            model_spec = model_spec
        )
    }

    # Combine both into tibble
    perf_tbl_list <- list()
    perf_tbl_list[[model_spec$name]] <- perf_tbl_model
    if(!is.null(perf_tbl_bm)){
        perf_tbl_list[[perf_plot_spec$benchmark]] <- perf_tbl_bm
    }
    perf_tbl <- dplyr::bind_rows(perf_tbl_list, .id = "model")

    # Plot
    if(perf_plot_spec$also_single_plots){
        plot_perf_metric(
            perf_tbl = perf_tbl,
            perf_plot_spec = perf_plot_spec
        )
    }
    # Save to csv (if wanted)
    if(perf_plot_spec$single_csvs){
        csv_fname <- stringr::str_replace(perf_plot_spec$fname, "\\..+", ".csv")
        readr::write_csv(perf_tbl_model, csv_fname)
    }

    return(perf_tbl_list)
}