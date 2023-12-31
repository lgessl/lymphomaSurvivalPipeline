new_PerfPlotSpec <- function(
    fname,
    x_metric,
    y_metric,
    pfs_leq,
    benchmark,
    fellow_csv,
    scores_plot,
    show_plots,
    title,
    x_lab,
    y_lab,
    xlim,
    ylim,
    smooth_method,
    smooth_benchmark,
    alpha,
    colors,
    width,
    height,
    units
){
    stopifnot(is.character(fname))
    stopifnot(is.character(x_metric))
    stopifnot(is.character(y_metric))
    stopifnot(is.null(pfs_leq) || is.numeric(pfs_leq))
    stopifnot(is.character(benchmark))
    stopifnot(is.logical(fellow_csv))
    stopifnot(is.logical(scores_plot))
    stopifnot(is.logical(show_plots))
    stopifnot(is.character(title) || is.null(title))
    stopifnot(is.character(x_lab))
    stopifnot(is.character(y_lab))
    stopifnot(is.numeric(xlim) || is.null(xlim))
    stopifnot(is.numeric(ylim) || is.null(ylim))
    stopifnot(is.character(smooth_method) || is.null(smooth_method) ||
        is.function(smooth_method))
    stopifnot(is.logical(smooth_benchmark))
    stopifnot(is.numeric(alpha) && alpha >= 0 && alpha <= 1)
    stopifnot(is.character(colors) || is.null(colors))
    stopifnot(is.numeric(width) && width > 0)
    stopifnot(is.numeric(height) && height > 0)
    stopifnot(is.character(units))

    perf_plot_spec_list <- list(
        "fname" = fname,
        "x_metric" = x_metric,
        "y_metric" = y_metric,
        "pfs_leq" = pfs_leq,
        "benchmark" = benchmark,
        "fellow_csv" = fellow_csv,
        "scores_plot" = scores_plot,
        "show_plots" = show_plots,
        "title" = title,
        "x_lab" = x_lab,
        "y_lab" = y_lab,
        "xlim" = xlim,
        "ylim" = ylim,
        "smooth_method" = smooth_method,
        "smooth_benchmark" = smooth_benchmark,
        "alpha" = alpha,
        "colors" = colors,
        "width" = width,
        "height" = height,
        "units" = units
    )
    return(structure(perf_plot_spec_list, class = "PerfPlotSpec"))
}

#' @title Create a PerfPlotSpec object
#' @description A PlotSpec object holds all the info on how to create a model performance
#' plot and what to do with it. It is tailored for [assess_model()]. Its base object is a 
#' list containing:
#' @param fname string. The name of the file to save the plot to.
#' @param x_metric string. The name of the performance measure to be plotted on the x-axis.
#' All measures that can be passed to the `x.measure` parameter of [ROCR::performance()] are
#' valid.
#' @param y_metric string. The name of the performance measure to be plotted on the y-axis.
#' All measures that can be passed to the `measure` parameter of [ROCR::performance()] are
#' valid.
#' @param pfs_leq numeric. Progression-free survival threshold that divides samples into 
#' high-risk (PFS < `pfs_leq`) and low-risk (PFS >= `pfs_leq`) group. Model performance
#' will be measured in terms of how well it can separate these two groups as a binary
#' classifier. Default is `2.0`.
#' @param benchmark string. Column in the test pheno holding the numeric benchmark values.
#' Default is `"ipi"` (international prognostic index for DLBCL).
#' @param fellow_csv logical. If passed to [assess_multiple_models()], whether to also create a
#' csv file for every model-data pair. Default is `TRUE`.
#' @param scores_plot logical. Display the ordered scores output by the model in a scatter 
#' plot. Default is `TRUE`.  
#' @param show_plots logical. Whether to show the plots after creation in an interactive 
#' graphics device. Default is `FALSE`. 
#' @param title string. The title of the plot. Default is `NULL`.
#' @param x_lab,y_lab string. Axis labels. Default is `x_metric` and `y_metric`, respectively.
#' @param xlim,ylim numeric vector of length 2 or `NULL`. The limits for both axes. Default is
#' `NULL`, no limits.
#' @param smooth_method string or function. Smooth method to plot an additional smoothed graph.
#' If `NULL`, no smoothing. Else we pass `smooth_method` as the `method` parameter to
#' [ggplot2::geom_smooth()]. Default is `"loess"`.
#' @param smooth_benchmark logical. Whether to also smooth the benchmark data. Default is
#' `FALSE`.
#' @param alpha numeric in \[0, 1\]. The alpha value for the points and lines in the 
#' plot.
#' @param width numeric. The width of the plot in `units`. Default is `7`.
#' @param height numeric. The height of the plot in `units`. Default is `4`.
#' @param colors character vector. The colors to be used for the different models.
#' Default is `NULL`, which means that the default colors of `ggplot2` will be used.
#' @param units string. The units of `width` and `height`. Default is `"in"` (inches).
#' @return A PlotSpec S3 object.
#' @export
PerfPlotSpec <- function(
    fname,
    x_metric,
    y_metric,
    pfs_leq = NULL,
    benchmark = "ipi",
    fellow_csv = TRUE,
    scores_plot = TRUE,
    show_plots = FALSE,
    title = NULL,
    x_lab = NULL,
    y_lab = NULL,
    xlim = NULL,
    ylim = NULL,
    smooth_method = NULL,
    smooth_benchmark = FALSE,
    alpha = 0.5,
    width = 7,
    height = 4,
    colors = NULL,
    units = "in"
){
    if(is.null(x_lab)){
        x_lab <- x_metric
    }
    if(is.null(y_lab)){
        y_lab <- y_metric
    }
    perf_plot_spec <- new_PerfPlotSpec(
        fname = fname,
        x_metric = x_metric,
        y_metric = y_metric,
        pfs_leq = pfs_leq,
        benchmark = benchmark,
        fellow_csv = fellow_csv,
        scores_plot = scores_plot,
        x_lab = x_lab,
        y_lab = y_lab,
        xlim = xlim,
        ylim = ylim,
        smooth_method = smooth_method,
        smooth_benchmark = smooth_benchmark,
        alpha = alpha,
        width = width,
        height = height,
        units = units,
        title = title,
        colors = colors,
        show_plots = show_plots
    )
    return(perf_plot_spec)
}