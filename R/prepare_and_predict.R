#' @title Prepare data and predict with a loaded model
#' @description Given an expression matrix and a pheno tibble, prepare the data for a
#' certain model and predict with this model.
#' @param expr_mat numeric matrix. The expression matrix with genes in rows and samples
#' in columns.
#' @param pheno_tbl tibble. The pheno data with samples in rows and variables in columns.
#' @param data_spec DataSpec S3 object. Specifications on the data. See the the
#' constructor `DataSpec()` for details.
#' @param model_spec ModelSpec S3 object. Specifications on the model. See the the
#' constructor `ModelSpec()` for details.
#' @return A list with two elements: 
#' * `"predictions"`, a numeric one-column matrix holding predicted scores, and
#' *  "y", a numeric vector holding the true response.
#' @export
prepare_and_predict <- function(
    expr_mat,
    pheno_tbl,
    data_spec,
    model_spec
){
    if(!inherits(model_spec, "ModelSpec")){
        stop("model_spec must be a ModelSpec object")
    }
    if(!inherits(data_spec, "DataSpec")){
        stop("data_spec must be a DataSpec object")
    }

    x_y <- prepare(
        expr_mat = expr_mat,
        pheno_tbl = pheno_tbl,
        response_type = "binary", # we always evaluate on the binary response
        include_from_continuous_pheno = model_spec$include_from_continuous_pheno,
        include_from_discrete_pheno = model_spec$include_from_discrete_pheno,
        patient_id_col = data_spec$patient_id_col,
        pfs_col = data_spec$pfs_col,
        progression_col = data_spec$progression_col,
        pfs_leq = model_spec$pfs_leq
    )
    
    # Retrieve model
    fit_path <- file.path(model_spec$save_dir, model_spec$fit_fname)
    if(!file.exists(fit_path)){
        stop("Model object does not exist at ", fit_path)
    }
    fit_obj <- readRDS(file.path(model_spec$save_dir, model_spec$fit_fname))

    predictions <- predict(fit_obj, newx = x_y[["x"]])
    res <- list(
        "predictions" = predictions, 
        "y" = x_y[["y"]]
    )
    return(res)
}