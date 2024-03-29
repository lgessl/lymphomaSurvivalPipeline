#' @title Set up a training camp to fit models
#' @description Given one data set and a list of models, fit all models for all 
#' splits and time cutoffs. Store the models.
#' @param model_list list of Model objects. The models to fit.
#' @param data Data object. The data set to fit on.
#' @param quiet logical. Whether to suppress messages. Default is `FALSE`.
#' @return NULL
#' @export 
training_camp <- function(
    model_list,
    data,
    quiet = FALSE
){
    if(!inherits(data, "Data")){
        stop("data must be a Data object")
    }
    stopifnot(is.logical(quiet))

    if(is.null(data$expr_mat) || is.null(data$pheno_tbl)) data$read()
    if(!quiet) message("\nTRAINING CAMP ON ", data$name, ": opens at ", 
        round.POSIXt(Sys.time(), units = "secs"))
    if(is.null(data$cohort)){
        data$cohort <- "train"
        if(!quiet) message("Setting data$cohort to 'train' since it was NULL")
    }
    data$pheno_tbl <- ensure_splits(
        pheno_tbl = data$pheno_tbl,
        data = data,
        model_list = model_list
    )
    expr_mat <- data$expr_mat
    pheno_tbl <- data$pheno_tbl

    for(i in seq_along(model_list)){
        model <- model_list[[i]]
        if(!quiet) message("# ", model$name)
        if(!inherits(model, "Model")){
            stop("model_list must be a list of Model objects")
        }
        for(time_cutoff in model$time_cutoffs){
            if(!quiet) message("## At time cutoff ", time_cutoff, 
                " (", round.POSIXt(Sys.time(), units = "secs"), ")")
            model_tc <- model$at_time_cutoff(time_cutoff)
            model_tc$fit(data, quiet = quiet, msg_prefix = "### ")
        }
    }
    if(!quiet) message("Training camp closes at ", round.POSIXt(Sys.time(), units = "secs"))
}