modifyExcludeValueRank <- function(dat, rank_x, rank_y, rerank_exclude_value, bounds_x, bounds_y, exclude_value){
  if (rerank_exclude_value){
    bounds_x <- bounds_x[2:length(bounds_x)]
    bounds_y <- bounds_y[2:length(bounds_y)]
    bounds_x[1] <- min(bounds_x[1], exclude_value)
    bounds_y[1] <- min(bounds_y[1], exclude_value)
    bounds_x[length(bounds_x)] <- max(bounds_x[length(bounds_x)], exclude_value) + 1
    bounds_y[length(bounds_y)] <- max(bounds_y[length(bounds_y)], exclude_value) + 1
    replacement_exclude_x <- as.numeric(cut(exclude_value, breaks = bounds_x, labels = 1:max(dat[[rank_x]]),
                                            right = FALSE, include.lowest = TRUE))
    replacement_exclude_y <- as.numeric(cut(exclude_value, breaks = bounds_y, labels = 1:max(dat[[rank_y]]),
                                            right = FALSE, include.lowest = TRUE))
    if (replacement_exclude_x != replacement_exclude_y){
      warning('The exclude value is mapped to different ranks.')
    }
    dat[[rank_x]] <- ifelse(dat[[rank_x]] == 0, replacement_exclude_x, dat[[rank_x]])
    dat[[rank_y]] <- ifelse(dat[[rank_y]] == 0, replacement_exclude_y, dat[[rank_y]])
    return(dat)
  } else {
    condition_x <- dat[[rank_x]] != 0
    dat <- subset(dat, condition_x)
    condition_y <- dat[[rank_y]] != 0
    dat <- subset(dat, condition_y)
    return(dat)
  }
}

makePraisBibby <- function(dat, rank_x, rank_y){
  # Calculates Prais-Bibby Index for a dataset using rank_x and rank_y
  # dat - data.frame
  # rank_x - string
  # rank_y - string
  condition <- dat[[rank_x]] == dat[[rank_y]]
  numerator <- nrow(subset(dat, condition))
  denominator <- nrow(dat)
  value <- numerator/denominator
  return(1 - value)
}

makeAverageMovement <- function(dat, rank_x, rank_y){
  # Calculates Average Movement Index for a dataset using rank1 and rank2
  # dat - data.frame
  # rank1 - string
  # rank2 - string
  movement <- abs(dat[[rank_x]] - dat[[rank_y]])
  return(mean(movement))
}

makeOriginSpecific <- function(dat, rank1, rank2, where, variety){
  # Computes one of several different origin specific indices depending on location and variety
  # dat - data.frame
  # rank1 - string
  # rank2 - string
  # where - string - the location of the index; 'top' and 'bottom' are accepted
  # variety - string - does the index measure any movement or only far movement;
  # 'total' and 'far' are accepted
  # bounds - sequence - indicates the bounds for the rank
  n1 <- max(dat[[rank1]])
  n2 <- max(dat[[rank2]])
  if (where == 'top'){
    if (variety == 'total'){
      num <- nrow(subset(dat, dat[[rank1]] == n1 & dat[[rank2]] < n2))
      den <- nrow(subset(dat, dat[[rank1]] == n1))
      value <- num / den
      return(value)
    } else if (variety == 'far') {
      num <- nrow(subset(dat, dat[[rank1]] == n1 & dat[[rank2]] < n2 - 1))
      den <- nrow(subset(dat, dat[[rank1]] == n1))
      value <- num / den
      return(value)
    } else stop("Not a valid variety! Use total or far!")
  }
  else if (where == 'bottom'){
    if (variety == 'total'){
      num <- nrow(subset(dat, dat[[rank1]] == 1 & dat[[rank2]] > 1))
      den <- nrow(subset(dat, dat[[rank1]] == 1))
      value <- num / den
      return(value)
    } else if (variety == 'far') {
      num <- nrow(subset(dat, dat[[rank1]] == 1 & dat[[rank2]] > 2))
      den <- nrow(subset(dat, dat[[rank1]] == 1))
      value <- num / den
      return(value)
    } else stop("Not a valid variety! Use total or far!")
  } else stop("Not a valid where argument! Use top, bottom, or exclude!")
}

makeShorrocks <- function(dat, rank1, rank2){
  # Calculates the Shorrocks Index for a dataset using rank1 and rank2
  # dat - data.frame
  # rank1 - string
  # rank2 - string
  ranks <- unique(dat[[rank1]])
  n <- length(ranks)
  r_num <- c()
  r_den <- c()
  q <- c()
  for (i in 1:n){
    r_num[i] <- nrow(subset(dat, dat[[rank1]] == ranks[i] & dat[[rank2]] == ranks[i]))
    r_den[i] <- nrow(subset(dat, dat[[rank1]] == ranks[i]))
    q[i] <- r_num[i] / r_den[i]
  }
  value <- (n - sum(q))/(n-1)
  return(value)
}

makeIndex <- function(dat, rank_x, rank_y, index){
  if (index == 'prais-bibby') {
    value <- makePraisBibby(dat, rank_x = rank_x, rank_y = rank_y)
    return(list('prais-bibby' = value))
  }
  else if (index == 'average-movement') {
    value <- makeAverageMovement(dat, rank_x, rank_y)
    return(list('average-movement' = value))
  }
  else if (index == 'shorrocks') {
    value <- makeShorrocks(dat, rank_x, rank_y)
    return(list('shorrocks' = value))
  }
  else if (index == 'origin-specific') {
    total_top <- makeOriginSpecific(dat, rank_x, rank_y, 'top', 'total')
    far_top <- makeOriginSpecific(dat, rank_x, rank_y, 'top', 'far')
    total_bottom <- makeOriginSpecific(dat, rank_x, rank_y, 'bottom', 'total')
    far_bottom <- makeOriginSpecific(dat, rank_x, rank_y, 'bottom', 'far')
    value <- list('os_total_top' = total_top,
                  'os_far_top' = far_top,
                  'os_total_bottom' = total_bottom,
                  'os_far_bottom' = far_bottom)
    return(value)
  }
  else (stop('Not a supported index! See the mobilityIndexR::getIndices documentation.'))
}

#' @title Calculates Mobility Indices for Two Time Periods
#'
#' @description Calculates mobility indices from two columns in dataset. Supports Prais-Bibby,
#' Absolute Movement, Origin Specific, and Shorrocks indices and relative, mixed,
#' and absolute types of rankings in the calculation these indices.
#'
#' @param dat a dataframe in the mobilityIndexR schema
#' @param col_x a character string denoting the first column to be used in the index calculation
#' @param col_y a character string denoting the second column to be used in the index calculation
#' @param type a character string indicating the type of ranking;
#' accepts 'relative', 'mixed', and 'absolute'
#' @param indices a vector of character strings indicating which mobility indices are desired;
#' currently support 'prais-bibby', 'absolute-movement', 'shorrocks', and 'origin-specific'.
#' The default value is 'all'.
#' @param num_ranks an integer specifying the number of ranks for a relative or mixed ranking
#' @param exclude_value a single numeric value to assign exclusively to the zero rank in the column ranking
#' @param bounds a sequence of numeric bounds for defining absolute ranks
#' @param strict logical. If TRUE, rankings are calculated from the given values. If FALSE,
#' rankings are calculated by slightly jittering the values to ensure uniqueness of bounds.
#' The default value if 'true'.
#' @param rerankExcludeValue logical. If TRUE, the exclude value is reranked for both col_in and col_out
#' according the bounds used in the ranking for calculating indices. If FALSE, rows with an exclude value
#' are excludes from index calculations.
#'
#' @return Returns a named vector containing the desired index values
#' @export
#'
#' @examples
#' data(incomeMobility)
#' getMobilityIndices(dat = incomeMobility,
#'                    col_x = 't0',
#'                    col_y = 't2',
#'                    type = 'relative',
#'                    num_ranks = 5)
getMobilityIndices <- function(dat, col_x, col_y, type, indices = 'all', num_ranks, exclude_value, bounds, strict = TRUE, rerank_exclude_value = FALSE){
  df_rank_x <- makeRanks(dat = dat, col_in = col_x, col_out = 'rank_x', type = type,
                         num_ranks = num_ranks, exclude_value = exclude_value,
                         mixed_col = col_x, bounds = bounds, strict = strict)
  df_rank_y <- makeRanks(dat = dat, col_in = col_y, col_out = 'rank_y', type = type,
                         num_ranks = num_ranks, exclude_value = exclude_value,
                         mixed_col = col_x, bounds = bounds, strict = strict)
  df <- merge(df_rank_x$data, df_rank_y$data, by = 'id')
  output <- list()
  if (!missing(exclude_value)){
    df <- modifyExcludeValueRank(dat = df, rank_x = 'rank_x', rank_y = 'rank_y',
                                 rerank_exclude_value = rerank_exclude_value, bounds_x = df_rank_x$bounds,
                                 bounds_y = df_rank_y$bounds, exclude_value = exclude_value)
  }
  if (indices == 'all') {
    indices <- c('prais-bibby', 'average-movement', 'shorrocks', 'origin-specific')
  }
  for (index in indices){
    if (!(index %in% c('prais-bibby', 'average-movement', 'shorrocks', 'origin-specific'))){
      stop(paste('Index', index, 'not supported.'))
    }
    value <- makeIndex(dat = df, rank_x = 'rank_x', rank_y = 'rank_y', index = index)
    output <- c(output, value)
  }
  return(output)
}

