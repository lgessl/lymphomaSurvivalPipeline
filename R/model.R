#' @title An R6 class for a model
#' @description A Model specifies how a model looks like, prepares the data, fits it, 
#' stores it and predicts from it.
Model <- R6::R6Class("Model",
    public = list(

        #' @field name A telling name for the model.
        name = NULL,
        #' @field directory Store/find the models in this directory.
        directory = NULL,
        #' @field fitter The model fitting function to be used.
        fitter = NULL,
        #' @field split_index Split the given data into training and test cohort
        #' `length(split_index)` times.
        split_index = NULL,
        #' @field time_cutoffs Threshold and censor the outcome accordingly.
        time_cutoffs = NULL,
        #' @field optional_fitter_args Optional arguments passed to `fitter`.
        optional_fitter_args = NULL,
        #' @field response_type The type of response to be used.
        response_type = NULL,
        #' @field response_colnames Use as column names for the response matrix.
        response_colnames = NULL,
        #' @field include_from_continuous_pheno The names of the continuous variables in the
        #' pheno data (to be) included in the predictor matrix.
        include_from_continuous_pheno = NULL,
        #' @field include_from_discrete_pheno The names of the discrete variables in the
        #' pheno data (to be) included in the predictor matrix.
        include_from_discrete_pheno = NULL,
        #' @field append_to_includes Append this to the names of features from the pheno data
        #' when adding them to the predictor matrix.
        append_to_includes = NULL,
        #' @field create_directory Whether to create `directory` if it does not exist, yet.
        create_directory = NULL,
        #' @field plot_file Store the plots resulting from `plot(fit_obj)` in `directory` under
        #' this name.
        plot_file = NULL,
        #' @field plot_ncols Arrange the above mentioned plots in this number of columns. 
        plot_ncols = NULL,
        #' @field plot_title_line Pass this as the `line` argument to [`graphics::title()`]
        #' when calling `plot(fit_obj)`.
        plot_title_line = NULL,
        #' @field fit_file Store this Model object under this name in `directory`.
        fit_file = NULL,
        #' @field fits A list holding fits (e.g. zeroSum objects).
        fits = NULL,

        #' @description Create a new Model instance.
        #' @param name string. A telling name for the model.
        #' @param directory string. The directory to store the models in. For every value in 
        #' `time_cutoffs`, find the corresponding model in a subdirectory named after this value. 
        #' @param fitter function. The model fitting function to be used. Must take `x` and
        #' `y` as first two positional arguments. Further arguments can be passed via
        #' `optional_fitter_args` (below). Its return value must be an S3 object with a `plot()` 
        #' method, and (ideally, for assessment) with a `predict()` method. Default is `NULL`.
        #' @param time_cutoffs numeric vector.
        #' * If `response_type == "survival_censored"`: For every value in `time_cutoffs`, censor
        #' all patients where the event ouccured after `time_cutoffs` at this value and train the 
        #' specified model.
        #' * If `response_type == "binary"`: For every value in `time_cutoffs`, binarize the 
        #' outcome depending on whether it occured before or after this value, and train the 
        #' specified model.
        #' @param split_index integer vector. Split the given data into training and test samples 
        #' `length(split_index)` times, i.e., every index in `split_index` will get its own split. 
        #' @param optional_fitter_args list. Optional arguments passed to `fitter`, e.g. alpha 
        #' in case of an elastic net. Default is `list()`, i.e., no arguments other than `x`, `y`
        #' passed to `fitter`.
        #' @param response_type string. The type of response to be used. One of `"binary"` or
        #' `"survival_censored"`. Default is `NULL`.
        #' @param response_colnames string vector of length 2. If `response_type == "survival_censored"`,
        #' use as column names for the response matrix. 
        #' * The first element is the name of the column holding the time until the event or 
        #' censoring, and 
        #' * the second one is the anme of the column holding the event status (1 = event, 0 =
        #' censoring). 
        #' @param include_from_continuous_pheno vector of strings. The names of the 
        #' *continuous* variables in the pheno data (to be) included in the predictor matrix. The
        #' values will be coerced to numeric. Default is `NULL`, which means no continuous pheno
        #' variables are or will be included.
        #' @param include_from_discrete_pheno vector of strings. The names of the *discrete*
        #' variables in the pheno data (to be) included in the predictor matrix. A discrete
        #' variable with n levels will be converted to n-1 binary variables. Default is `NULL`,
        #' which means no discrete pheno variables are or will be included.
        #' @param append_to_includes string. Append this to the names of features from the pheno
        #' data when adding them to the predictor matrix. Default is `"++"`.
        #' @param create_directory logical. Whether to create `directory` if it does not exist, yet. 
        #' Default is `TRUE`.
        #' @param plot_file string. Store the plot resulting from `plot(fit_obj)` in `directory`
        #' under this name. Default is `"training_error.pdf"`.
        #' @param plot_ncols integer. The number of columns in the plot. Default is `2`.
        #' @param plot_title_line numeric or NULL. Pass this as the `line` argument to [`graphics::title()`] 
        #' after calling `plot(fit_obj)`. This is the distance (in inches) between the title text and 
        #' the upper limit of the figure. Default is `2.5`.
        #' @param fit_file string. The name of the model-fits file inside `directory`.
        #' Default is `"fit_obj.rds"`.
        #' @return A `Model` R6 object.
        #' @details Strictly speaking, one `Model` instance specifies
        #' `length(time_cutoffs) * length(split_index)` models. In terms of storing 
        #' and assessing models, we consider the models obtained via repeated 
        #' splitting according to `split_index` as one model; we view models 
        #' obtained via different values of `time_cutoffs`, in contrast, as 
        #' different models; e.g., we can compare them against one another in an 
        #' assessment.
        initialize = function(
            name,
            fitter,
            directory,
            split_index,
            time_cutoffs,
            optional_fitter_args = NULL,
            response_type = c("binary", "survival_censored"),
            response_colnames = c("time", "status"),
            include_from_continuous_pheno = NULL,
            include_from_discrete_pheno = NULL,
            append_to_includes = "++",
            create_directory = TRUE,
            plot_file = "training_error.pdf",
            plot_ncols = 2,
            plot_title_line = 2.5,
            fit_file = "models.rds"
        )
            model_initialize(self, private, name, fitter, directory, split_index, 
                time_cutoffs, optional_fitter_args, response_type, response_colnames, 
                include_from_continuous_pheno, include_from_discrete_pheno, 
                append_to_includes, create_directory, plot_file, plot_ncols,
                plot_title_line, fit_file),  

        #' @description Fit the model to a data set for all splits into training 
        #' and test cohort. However, we do not support multiple time 
        #' cutoffs at this step; enabling them is the job of [`training_camp()`].
        #' @param data Data object. Read it in if needed.
        #' @param quiet logical. Whether to suppress messages. Default is `FALSE`.
        #' @param msg_prefix string. Prefix for messages. Default is `""`.
        #' @return The `Model` object itself with the `fits` attribute set to a 
        #' list holding the object returned by the `fitter` attribute for every
        #' split. 
        #' @seealso [`training_camp()`].
        #' @details This method expects the `Model` object to have a single time
        #' cutoff and the `directory` field be set accordingly. You may therefore 
        #' want to apply the `at_time_cutoff()` method to the `Model` object before.
        fit = function(
            data,
            quiet = FALSE,
            msg_prefix = ""
        )
            model_fit(self, private, data, quiet, msg_prefix),

        #' @description Predict for a data set and all splits into training and 
        #' test cohort. We don't support multiple time cutoffs here. Additonally 
        #' return the true values of the response and, if the `benchmark_col` 
        #' attribute of the `Data` object is not `NULL`, the values of the 
        #' benchmark.
        #' @param data Data object. Specifications on the data. Read it in if 
        #' needed.
        #' @param lambda string or numeric. The lambda regularization parameter 
        #' of the model to predict with. Technically, we will pass it to the `s` 
        #' parameter of the `predict()`method of the object returned by the 
        #' `fitter` attribute of the `Model` object. See, e.g., 
        #' [`zeroSum::predict.zeroSum()`].
        #' @param pivot_time_cutoff numeric. Time-to-event threshold that divides 
        #' samples into a high/low-risk (time to event below/above 
        #' `pivot_time_cutoff`) group. 
        #' @return A list holding:
        #' 
        #' * `"predicted"`: a list of named numeric vectors, the scores output by the model for 
        #'  each split (split index corresponding to list index).
        #' *  "actual": a list of named numeric vectors, for each split the actual values of 
        #' whether time to event was above or below `model$time_cutoffs`, encoded as 1 
        #'  ("high risk") and 0 ("low risk"), respectively. 
        #' * "benchmark": A list of named numeric vectors, for each split the values of the
        #'  benchmark classifier. If `data$benchmark` is NULL, it is an empty list.
        #' 
        #' For every split, the names of all three vectors match.
        #' @importFrom stats predict
        #' @export
        predict = function(
            data,
            pivot_time_cutoff,
            lambda = "lambda.min"
        )
            model_predict(self, private, data, lambda, pivot_time_cutoff),

        #' @description Infer the model at a specific time cutoff.
        #' @param time_cutoff numeric. The time cutoff to set.
        at_time_cutoff = function(time_cutoff)
            model_at_time_cutoff(self, private, time_cutoff)
    ),

    private = list(
        dummy = "dummy"
    )
)