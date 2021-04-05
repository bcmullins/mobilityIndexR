---
title: 'mobilityIndexR: an R package to calculate transition matrices and mobility indices from numeric data'
tags:
  - R
  - economics
  - mobility
  - income
  - education
authors:
  - name: Brett Mullins^[Corresponding author]
    affiliation: 1
  - name: Trevor Harkreader
    affiliation: 2
affiliations:
 - name: College of Information and Computer Sciences, UMass Amherst
   index: 1
 - name: Independent Researcher
   index: 2
date: 4 April 2021
bibliography: paper.bib
---

# Summary

`mobilityIndexR` is an R package for calculating transition matrices and mobility indices to measure mobility from two fields of numeric values in a dataset. For instance, collecting income information for a set of individuals at the beginning and end of a period of time allows one to measure the income mobility of that cohort over the time period. 

There are different types of transition matrices and mobility indices which each combine to capture various facets of mobility. Regarding transition matrices, this package supports relative, mixed, and absolute matrices. These correspond to distinct methods for discretising the numeric values into ranks. Regarding mobility indices, this package supports many commonly used indices such as Prais-Bibby [@bibby1975] and a generalized form of Shorrocks' M-hat called Weighted Group Mobility [@shorrocks1978]. Additionally, this package can estimate nonparametric confidence intervals for these indices as well as perform nonparametric hypothesis tests to compare indices between samples.

You can find the latest release of `mobilityIndexR` on CRAN (https://cran.r-project.org/web/packages/mobilityIndexR/index.html) and the development version on Github (https://github.com/bcmullins/mobilityIndexR). For an introduction to income mobility - the primary use case for `mobilityIndexR` - see @jantti2015 and @bradbury2016. 

# Statement of Need

`mobilityIndexR` is a package written in the R langauage [@R] designed to be used by social science and public policy researchers but can be used for general applications of measuring mobility. It was first used in @wallace2019 and provides the basis for measuring mobility in forthcoming publications within this project.

This package combines three functionalities and tailors them to a social science and public policy setting. The first is generating transition matrices. While several recent packages, e.g. @markovchain, allow the user to calculate transition matrices from numeric data, the user must manually adjust the data so to create various types of transition matrices (relative, mixed, and absolute). With `mobilityIndexR`, the user specifies the transition matrix type without any need for further data manipulation. The second is calculating mobility indices derived from the transition matrix. To the authors' knowledge, there is no package which bundles together calculations of several mobility indices. The third is nonparametric hypothesis tests. While recent packages, e.g. @nptest, offer efficient implementations of nonparametric hypothesis tests, their use in this application requires a great deal of data manipulation on the part of the user. 

# Examples

We provide examples for the three functionalities of `mobilityIndexR`. This package includes several demo datasets. For the examples below, we use `incomeMobility` which simulates the annual income of a cohort of 125 individuals over 10 years. 

## Transition Matrices

The `getTMatrix` function generates transition matrices. Let us calculate a relative transition matrix between the first and sixth year of the `incomeMobility` dataset. 

```r
  getTMatrix(dat = incomeMobility, col_x = "t0", col_y = "t5",
           type = "relative", num_ranks = 5, probs = TRUE)
```

```
#> $tmatrix
#>    
#>         1     2     3     4     5
#>   1 0.152 0.040 0.008 0.000 0.000
#>   2 0.048 0.080 0.048 0.024 0.000
#>   3 0.000 0.048 0.064 0.056 0.032
#>   4 0.000 0.008 0.024 0.120 0.048
#>   5 0.000 0.024 0.056 0.000 0.120
#>
#> $col_x_bounds
#>      0%     20%     40%     60%     80%    100%
#>   462.0 21543.4 42469.8 64061.6 77888.4 99557.0
#>
#> $col_y_bounds
#>          0%         20%         40%         60%         80%        100%
#>    340.2705  18204.9969  39710.3062  58494.6271  78178.6713 262909.3195
```

## Mobility Indices

The function `getMobilityIndices` calculates mobility indices. Let us calculate mobility indices from the relative transition matrix above between the first and sixth year of data. 

```r
getMobilityIndices(dat = incomeMobility, col_x = "t0", col_y = "t5",
                   type = "relative", num_ranks = 5)
```
```
#> $average_movement
#> [1] 0.64
#>
#> $os_far_bottom
#> [1] 0.04
#>
#> $os_far_top
#> [1] 0.4
#>
#> $os_total_bottom
#> [1] 0.24
#>
#> $os_total_top
#> [1] 0.4
#>
#> $prais_bibby
#> [1] 0.464
#>
#> $wgm
#> [1] 0.58
```
Additionally, setting `intervals = TRUE` returns nonparametric bootstrap confidence intervals with a specified interval size and number of bootstrap iterations. See our [introductory vignette](https://cran.r-project.org/web/packages/mobilityIndexR/vignettes/intro-to-mobilityIndexR.html) for more information on using this feature.

## Hypothesis Tests

There are several cases where one may want to compare mobility indices between two samples. The function `getHypothesisTest` calculates nonparametric one-sided hypothesis tests for each index specified. Below, we compare the income mobility experienced between two time periods, e.g. $t_0$ to $t_3$ and $t_5$ to $t_8$. 

```r
getHypothesisTest(dat_A = incomeMobility, dat_B = incomeMobility,
                  cols_A = c("t0", "t3"), cols_B = c("t5", "t8"),
                  type = "relative", num_ranks = 5, bootstrap_iter = 100)
```
```
#> $prais_bibby
#> [1] 0.38
#>
#> $average_movement
#> [1] 0.6
#>
#> $wgm
#> [1] 0.39
#>
#> $os_total_top
#> [1] 0.51
#>
#> $os_far_top
#> [1] 0.92
#>
#> $os_total_bottom
#> [1] 0.32
#>
#> $os_far_bottom
#> [1] 0.03
```
# Acknowledgements

We acknowledge contributions from David Sjoquist and Sally Wallace. This package was developed as a research collaboration with the Fiscal Research Center at Georgia State University. 

# References
