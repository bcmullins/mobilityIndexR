checkInputs <- function(dat, col_in, col_out, num_ranks, mixed_col, bounds){
  stopifnot(is.data.frame(dat))
  stopifnot(nrow(dat) > 0)
  stopifnot(is.character(col_in))
  stopifnot(is.character(col_out))
  if (!missing(num_ranks)) {
    stopifnot(is.numeric(num_ranks))
    stopifnot(nrow(dat) >= num_ranks)
  }
  if (!missing(mixed_col)) {
    stopifnot(is.character(mixed_col))
  }
  if (!missing(bounds)){
    if (min(dat[[col_in]]) < min(bounds)){
      stop('At least one data value falls below the first bound.')
    }
    if (max(dat[[col_in]]) > max(bounds)){
      stop('At least one data value falls above the last bound.')
    }
  }
}

makeRelativeRanks <- function(dat, col_in, col_out, num_ranks, exclude_value, strict){
  df <- dat[c('id', col_in)]
  if (strict) {
    if (missing(exclude_value)){
      if (max(table(df[col_in])/nrow(df)) >= 1/num_ranks) {
        stop(paste0('One of the values represents more than ', paste(1/num_ranks), ' of the data. Try using fewer ranks or setting strict to FALSE.'))
      }
    } else {
      control <- subset(df, df[[col_in]] != exclude_value)
      if (max(table(control[col_in])/nrow(control)) >= 1/num_ranks) {
        stop(paste0('One of the non-excluded values represents more than ', paste(1/num_ranks), ' of the non-excluded data. Try using fewer ranks or setting strict to FALSE.'))
      }
    }
  }
  if (missing(exclude_value)) {
    if (!strict) {
      df[[col_in]] <- df[[col_in]] + abs(rnorm(n = nrow(df), mean = 0.0000000000001, 0.0000000001))
    }
    cutoffs <- quantile(df[[col_in]], probs = c(0:num_ranks/num_ranks))
    df[[col_out]] <- cut(df[[col_in]], breaks = cutoffs, labels = 1:num_ranks, include.lowest = TRUE)
    df[[col_out]] <- as.numeric(df[[col_out]])
  } else {
    stopifnot(is.numeric(exclude_value))
    control <- subset(df, df[[col_in]] != exclude_value)
    if (!strict) {
      control[[col_in]] <- control[[col_in]] + abs(rnorm(n = nrow(control), mean = 0.0000000000001, 0.0000000001))
    }
    cutoffs <- quantile(control[[col_in]], probs = c(0:num_ranks/num_ranks))
    control[[col_out]] <- cut(control[[col_in]], breaks = cutoffs, labels = 1:num_ranks,
                              include.lowest = TRUE)
    exclude <- subset(df, df[[col_in]] == exclude_value)
    if (nrow(exclude) > 0) {
      exclude[[col_out]] <- 0
      df <- rbind(exclude, control)
    } else {
      df <- control
    }
    df[[col_out]] <- as.numeric(df[[col_out]])
    cutoffs <- c(exclude_value, cutoffs)
    names(cutoffs)[1] <- 'exclude_value'
  }
  output <- list('data' = df, 'bounds' = cutoffs)
  return(output)
}

makeMixedRanks <- function(dat, col_in, mixed_col, col_out, num_ranks, exclude_value, strict){
  df <- dat[c('id', col_in, mixed_col)]
  if (strict) {
    if (missing(exclude_value)){
      if (max(table(df[col_in])/nrow(df)) >= 1/num_ranks) {
        stop(paste0('One of the values represents more than ', paste(1/num_ranks), ' of the data. Try using fewer ranks or setting strict to FALSE.'))
      }
    } else {
      control <- subset(df, df[[col_in]] != exclude_value)
      if (max(table(control[col_in])/nrow(control)) >= 1/num_ranks) {
        stop(paste0('One of the non-excluded values represents more than ', paste(1/num_ranks), ' of the non-excluded data. Try using fewer ranks or setting strict to FALSE.'))
      }
    }
  }
  if (missing(exclude_value)) {
    if (!strict) {
      df[[mixed_col]] <- df[[mixed_col]] + abs(rnorm(n = nrow(df), mean = 0.0000000000001, 0.0000000001))
    }
    cutoffs <- quantile(df[[mixed_col]], probs = c(0:num_ranks/num_ranks))
    cutoffs[1] <- min(min(df[[mixed_col]]), min(df[[col_in]])) - 1
    cutoffs[num_ranks + 1] <- max(max(df[[mixed_col]]), max(df[[col_in]])) + 1
    df[[col_out]] <- cut(df[[col_in]], breaks = cutoffs, labels = 1:num_ranks, include.lowest = TRUE)
    df[[col_out]] <- as.numeric(df[[col_out]])
  } else {
    control_mixed <- subset(df, df[[mixed_col]] != exclude_value)
    if (!strict) {
      control_mixed[[mixed_col]] <- control_mixed[[mixed_col]] + abs(rnorm(n = nrow(control_mixed), mean = 0.0000000000001, 0.0000000001))
    }
    control <- subset(df, df[[col_in]] != exclude_value)
    cutoffs <- quantile(control_mixed[[mixed_col]], probs = c(0:num_ranks/num_ranks))
    cutoffs[1] <- min(min(control_mixed[[mixed_col]]), min(control[[col_in]])) - 1
    cutoffs[num_ranks + 1] <- max(max(control_mixed[[mixed_col]]), max(control[[col_in]])) + 1
    control[[col_out]] <- cut(control[[col_in]], breaks = cutoffs, labels = 1:num_ranks,
                              include.lowest = TRUE)
    control[[col_out]] <- as.numeric(control[[col_out]])
    exclude <- subset(df, df[[col_in]] == exclude_value)
    if (nrow(exclude) > 0){
      exclude[[col_out]] <- 0
      exclude[[col_out]] <- as.numeric(exclude[[col_out]])
      df <- rbind(control, exclude)
    } else {
      df <- control
    }
    cutoffs <- c(exclude_value, cutoffs)
    names(cutoffs)[1] <- 'exclude_value'
  }
  output <- list('data' = df, 'bounds' = cutoffs)
  return(output)
}

makeAbsoluteRanks <- function(dat, col_in, col_out, bounds) {
  df <- dat[c('id', col_in)]
  num_ranks <- length(bounds) - 1
  df[[col_out]] <- cut(df[[col_in]], breaks = bounds, labels = 1:num_ranks, include.lowest = TRUE)
  df[[col_out]] <- as.numeric(df[[col_out]])
  output <- list('data' = df, 'bounds' = bounds)
  return(output)
}

makeRanks <- function(dat, col_in, col_out, type, num_ranks, exclude_value, mixed_col, bounds, strict){
  checkInputs(dat = dat, col_in = col_in, col_out = col_out, num_ranks = num_ranks, mixed_col = mixed_col, bounds = bounds)
  if (type == 'relative'){
    df_out <- makeRelativeRanks(dat = dat, col_in = col_in, col_out = col_out,
                                num_ranks = num_ranks, exclude_value = exclude_value, strict = strict)
  } else if (type == 'mixed'){
    df_out <- makeMixedRanks(dat = dat, col_in = col_in, mixed_col = mixed_col, col_out = col_out,
                             num_ranks = num_ranks, exclude_value = exclude_value, strict = strict)
  } else if (type == 'absolute'){
    df_out <- makeAbsoluteRanks(dat = dat, col_in = col_in, col_out = col_out, bounds = bounds)
  } else {
    stop('Not a valid rank type! Try relative, mixed, or absolute.')
  }
  return(df_out)
}

makeTMatrix <- function(dat, rank_x, rank_y, probs){
  if (probs){
    tmatrix <- table(dat[[rank_x]], dat[[rank_y]])/nrow(dat)
  } else {
    tmatrix <- table(dat[[rank_x]], dat[[rank_y]])
  }
  return(tmatrix)
}

#' @title Calculates Transition Matrix
#'
#' @description Returns transition matrix from two columns in dataset. Supports relative, mixed,
#' and absolute transition matrices.
#'
#' @param dat a dataframe in the mobilityIndexR schema
#' @param col_x a character string denoting the first column to be used in the transition matrix
#' @param col_y a character string denoting the second column to be used in the transition matrix
#' @param type a character string indicating the type of transition matrix;
#' accepts relative, mixed, and absolute.
#' @param probs logical. If TRUE, values in transition matrix are probabilities;
#' if FALSE, values in transition matrix are counts
#' @param num_ranks an integer specifying the number of ranks for a relative or mixed transition matrix
#' @param exclude_value a single numeric value to relegate to an exclusive bottom rank in the transition matrix
#' @param bounds a sequence of numeric bounds for defining absolute transition matrix ranks
#' @param strict logical.
#'
#' @return Returns transition matrix as a Matrix
#' @export
#'
#' @examples
getTMatrix <- function(dat, col_x, col_y, type, probs = TRUE, num_ranks, exclude_value, bounds, strict = TRUE){
  df_rank_x <- makeRanks(dat = dat, col_in = col_x, col_out = 'rank_x', type = type,
                         num_ranks = num_ranks, exclude_value = exclude_value,
                         mixed_col = col_x, bounds = bounds, strict = strict)
  df_rank_y <- makeRanks(dat = dat, col_in = col_y, col_out = 'rank_y', type = type,
                         num_ranks = num_ranks, exclude_value = exclude_value,
                         mixed_col = col_x, bounds = bounds, strict = strict)
  df <- merge(df_rank_x$data, df_rank_y$data, by = 'id')
  tmatrix <- makeTMatrix(dat = df, rank_x = 'rank_x', rank_y = 'rank_y', probs = probs)
  output <- list('tmatrix' = tmatrix, 'col_x_bounds' = round(df_rank_x$bounds, digits = 6),
                 'col_y_bounds' = round(df_rank_y$bounds, digits = 6))
  return(output)
}
