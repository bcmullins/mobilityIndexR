getPraisBibby <- function(dat, rank1, rank2){
  # Calculates Prais-Bibby Index for a dataset using rank1 and rank2
  # dat - data.frame
  # rank1 - string
  # rank2 - string
  numerator <- nrow(subset(dat, dat[[rank1]] == dat[[rank2]]))
  denominator <- nrow(dat)
  return(numerator/denominator)
}

getAverageMovement <- function(dat, rank1, rank2){
  # Calculates Average Movement Index for a dataset using rank1 and rank2
  # dat - data.frame
  # rank1 - string
  # rank2 - string
  movement <- abs(dat[[rank1]] - dat[[rank2]])
  return(mean(movement))
}

getOriginSpecific <- function(dat, rank1, rank2, where, variety = 'total'){
  # Computes one of several different origin specific indices depending on location and variety
  # dat - data.frame
  # rank1 - string
  # rank2 - string
  # where - string - the location of the index; 'top', 'bottom', and 'zero' are accepted
  # variety - string - does the index measure any movement or only far movement;
  # 'total' and 'far' are accepted
  n1 <- max(dat[[rank1]])
  n2 <- max(dat[[rank2]])
  if (where == 'top'){
    if (variety == 'total'){
      num <- nrow(subset(dat, dat[[rank1]] == n1 & dat[[rank2]] < n2))
      den <- nrow(subset(dat, dat[[rank1]] == n1))
      value <- num / den
      return(1 - value)
    } else if (variety == 'far') {
      num <- nrow(subset(dat, dat[[rank1]] == n1 & dat[[rank2]] < n2 - 1))
      den <- nrow(subset(dat, dat[[rank1]] == n1))
      value <- num / den
      return(1 - value)
    } else stop("Not a valid variety! Use total or far!")
  }
  else if (where == 'bottom'){
    if (variety == 'total'){
      num <- nrow(subset(dat, dat[[rank1]] == 2 & dat[[rank2]] > 2))
      den <- nrow(subset(dat, dat[[rank1]] == 2))
      value <- num / den
      return(1 - value)
    } else if (variety == 'far') {
      num <- nrow(subset(dat, dat[[rank1]] == 2 & dat[[rank2]] > 3))
      den <- nrow(subset(dat, dat[[rank1]] == 2))
      value <- num / den
      return(1 - value)
    } else stop("Not a valid variety! Use total or far!")
  }
  else if (where == 'zero'){
    if (variety == 'total'){
      num <- nrow(subset(dat, dat[[rank1]] == 0 & dat[[rank2]] > 0))
      den <- nrow(subset(dat, dat[[rank1]] == 0))
      value <- num / den
      return(1 - value)
    } else if (variety == 'far') {
      num <- nrow(subset(dat, dat[[rank1]] == 0 & dat[[rank2]] > 1))
      den <- nrow(subset(dat, dat[[rank1]] == 0))
      value <- num / den
      return(1 - value)
    } else stop("Not a valid variety! Use total or far!")
  } else stop("Not a valid where argument! Use top, bottom, or zero!")
}

getShorrocks <- function(dat, rank1, rank2){
  # Calculates the Shorrocks Index for a dataset using rank1 and rank2
  # dat - data.frame
  # rank1 - string
  # rank2 - string
  n <- max(max(dat[[rank1]]), max(dat[[rank2]]))
  r_num <- c()
  r_den <- c()
  q <- c()
  for (i in 0:n){
    r_num[i+1] <- nrow(subset(dat, dat[[rank1]] == i && dat[[rank2]] == i))
    r_den[i+1] <- nrow(subset(dat, dat[[rank1]] == i))
    q[i+1] <- r_num[i+1] / r_den[i+1]
  }
  value <- (n - sum(q))/(n-1)
  return(value)
}

getIndex <- function(dat, rel1, rel2, mixed2, index, type){
  # This function is a wrapper for all of the index functions. You pass in the the data, the index name,
  # and whether it is relative or mixed and the index is returned.
  # dat - data.frame
  # rel1 - string - name of relative ranking column at time 1
  # rel2 - string - name of relative ranking column at time 2
  # mixed2 - string - name of the mixed ranking column at time 2
  # index - string - name of the desired index; at present, 'prais-bibby', 'average movement',
  # 'shorrocks', and 'origin specific' are supported
  # type - string - indicates if the index is to be calculated as relative or mixed
  if (index == 'prais-bibby' && type == 'relative'){
    value <- getPraisBibby(dat, rel1, rel2)
    return(value)
  }
  else if (index == 'prais-bibby' && type == 'mixed'){
    value <- getPraisBibby(dat, rel1, mixed2)
    return(value)
  }
  else if (index == 'average movement' && type == 'relative'){
    value <- getAverageMovement(dat, rel1, rel2)
    return(value)
  }
  else if (index == 'average movement' && type == 'mixed'){
    value <- getAverageMovement(dat, rel1, mixed2)
    return(value)
  }
  else if (index == 'shorrocks' && type == 'relative'){
    value <- getShorrocks(dat, rel1, rel2)
    return(value)
  }
  else if (index == 'shorrocks' && type == 'mixed'){
    value <- getShorrocks(dat, rel1, mixed2)
    return(value)
  }
  else if (index == 'origin specific' && type == 'relative'){
    total_top_rel <- getOriginSpecific(dat, rel1, rel2, 'top', 'total')
    total_bottom_rel <- getOriginSpecific(dat, rel1, rel2, 'bottom', 'total')
    total_zero_rel <- getOriginSpecific(dat, rel1, rel2, 'zero', 'total')
    far_top_rel <- getOriginSpecific(dat, rel1, rel2, 'top', 'far')
    far_bottom_rel <- getOriginSpecific(dat, rel1, rel2, 'bottom', 'far')
    far_zero_rel <- getOriginSpecific(dat, rel1, rel2, 'zero', 'far')
    return(data.frame(total_top_rel, total_bottom_rel, total_zero_rel, far_top_rel, far_bottom_rel, far_zero_rel))
  }
  else if (index == 'origin specific' && type == 'mixed'){
    total_top_mix <- getOriginSpecific(dat, rel1, mixed2, 'top', 'total')
    total_bottom_mix <- getOriginSpecific(dat, rel1, mixed2, 'bottom', 'total')
    total_zero_mix <- getOriginSpecific(dat, rel1, mixed2, 'zero', 'total')
    far_top_mix <- getOriginSpecific(dat, rel1, mixed2, 'top', 'far')
    far_bottom_mix <- getOriginSpecific(dat, rel1, mixed2, 'bottom', 'far')
    far_zero_mix <- getOriginSpecific(dat, rel1, mixed2, 'zero', 'far')
    return(data.frame(total_top_mix, total_bottom_mix, total_zero_mix, far_top_mix, far_bottom_mix, far_zero_mix))
  }
  else (stop("Not a supported index!"))
}
