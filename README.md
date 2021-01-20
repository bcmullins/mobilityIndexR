
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mobilityIndexR

<!-- badges: start -->

[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/bcmullins/mobilityIndexR?branch=master&svg=true)](https://ci.appveyor.com/project/bcmullins/mobilityIndexR)
[![CRAN
status](https://www.r-pkg.org/badges/version/mobilityIndexR)](https://CRAN.R-project.org/package=mobilityIndexR)
<!-- badges: end -->

`mobilityIndexR` allows users to both calculate transition matrices
(relative, mixed, and absolute) as well as calculate and compare
mobility indices (*Prais-Bibby*, *Average Movement*, *Weighted Group
Mobility*, and *Origin Specific*).

## Installation

You can install the released version of mobilityIndexR from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("mobilityIndexR")
```

You can install the development version of mobilityIndexR from
[Github](https://github.com) with:

``` r
# install.packages("devtools")
devtools::install_github("bcmullins/mobilityIndexR")
```

# Transition Matrices

Two dimensional transition matrices are a tool for representing mobility
within a group between two points in time with respect to some
observable value such as income of workers or grades of students.
Generally, this approach in some way ranks the observable value at each
point in time and displays a contingency table with aggregated counts or
proportions of each combination of ranks. `mobilityIndexR` offers three
methods of constructing ranks using the `getTMatrix` function: relative,
mixed, and absolute.

As example data, we include three datasets:
`mobilityIndexR::incomeMobility`,
`mobilityIndexR::incomeZeroInfMobility`, and
`mobilityIndexR::gradeMobility`. These datasets each contain 125
records, an “id” column, and observations of some value at ten points in
time, denoted “t0”, …, “t9”. `mobilityIndexR::incomeMobility` simulates
income data over ten years; `mobilityIndexR::incomeZeroInfMobility`
simulates income data over ten years that has an inflated number of
zeros; and `mobilityIndexR::gradeMobility` simulates student grade data
over ten assignments.

``` r
head(incomeMobility)
#>     id cohort    t0       t1       t2       t3       t4       t5        t6
#> 1 1001   2003 39235 39132.26 38988.60 23614.84 23629.59 23981.55  24032.27
#> 2 1002   2001 42533 70862.75 69655.04 70187.41 42896.49 42434.42  42790.18
#> 3 1003   2002 81463 81950.41 49711.08 49542.85 49628.86 82498.21 133827.51
#> 4 1004   2004 34363 33788.56 33744.43 33556.58 33658.70 20477.59  19994.63
#> 5 1005   2000 96627 97232.96 96614.23 95153.38 57226.46 57846.22  57361.49
#> 6 1006   2000 81552 81219.28 80966.39 81258.77 80573.05 79874.92  79569.12
#>          t7        t8        t9       t10
#> 1  39364.19  64585.58  64018.87  63758.16
#> 2  71126.93  71197.74 117711.75 116259.49
#> 3 133013.99 133126.18  80077.67  80559.27
#> 4  19939.64  19850.30  19869.06  31870.81
#> 5  94513.92  95099.74  94393.98  93521.19
#> 6  79847.03  80492.59  80553.66  80703.09
```

## Relative

Types of transition matrices differ by how values are binned into ranks.
With relative transition matrices, values in each of the two specified
columns (`col_x`, `col_y`) are binned into ranks as quantiles. The
number of quantiles is specified in the `num_ranks` argument. Note: if
one value in the data occurs more often than the size of the quantile
ranks, then `getTMatrix` will throw an error.

`getTMatrix` returns a list containing the transition matrix as well as
the bounds used to bin the data into ranks.

``` r
getTMatrix(dat = incomeMobility, col_x = "t0", col_y = "t5", 
           type = "relative", num_ranks = 5, probs = FALSE)
#> $tmatrix
#>    
#>      1  2  3  4  5
#>   1 19  5  1  0  0
#>   2  6 10  6  3  0
#>   3  0  6  8  7  4
#>   4  0  1  3 15  6
#>   5  0  3  7  0 15
#> 
#> $col_x_bounds
#>      0%     20%     40%     60%     80%    100% 
#>   462.0 21543.4 42469.8 64061.6 77888.4 99557.0 
#> 
#> $col_y_bounds
#>          0%         20%         40%         60%         80%        100% 
#>    340.2705  18204.9969  39710.3062  58494.6271  78178.6713 262909.3195
```

The above example produces a \(5 \times 5\) contingency table. Setting
the argument `probs = TRUE`, we obtain a transition matrix with
unconditional probabilities rather than counts.

``` r
getTMatrix(dat = incomeMobility, col_x = "t0", col_y = "t5", 
           type = "relative", num_ranks = 5, probs = TRUE)
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

## Mixed

With mixed transition matrices, values in `col_x` are first binned into
ranks as quantiles, then the bounds for `col_x` are used to bin `col_y`
into ranks. In the example below, observe that `col_x_bounds` and
`col_y_bounds` are equal except for the minimum and maximum values.

``` r
getTMatrix(dat = incomeMobility, col_x = "t0", col_y = "t5", 
           type = "mixed", num_ranks = 5, probs = FALSE)
#> $tmatrix
#>    
#>      1  2  3  4  5
#>   1 21  3  1  0  0
#>   2  8 11  4  2  0
#>   3  1  6 13  1  4
#>   4  0  2  2 15  6
#>   5  1  2  7  0 15
#> 
#> $col_x_bounds
#>      0%     20%     40%     60%     80%    100% 
#>   461.0 21543.4 42469.8 64061.6 77888.4 99558.0 
#> 
#> $col_y_bounds
#>          0%         20%         40%         60%         80%        100% 
#>    339.2705  21543.4000  42469.8000  64061.6000  77888.4000 262910.3195
```

## Absolute

With absolute transition matrices, values in `col_x` and `col_y` are
binned into ranks using user-specified bounds with the `bounds`
argument.

``` r
getTMatrix(dat = gradeMobility, col_x = "t0", col_y = "t5", 
           type = "absolute", probs = FALSE, bounds = c(0, 0.6, 0.7, 0.8, 0.9, 1.0))
#> $tmatrix
#>    
#>      1  2  3  4  5
#>   1 10  3  0  0  0
#>   2  6 13  8  0  0
#>   3  0 12 17  8  3
#>   4  0  3 13 11 13
#>   5  0  0  1  0  4
#> 
#> $col_x_bounds
#> [1] 0.0 0.6 0.7 0.8 0.9 1.0
#> 
#> $col_y_bounds
#> [1] 0.0 0.6 0.7 0.8 0.9 1.0
```

# Mobility Indices

Mobility indices are measures of mobility within a group between two
points in time with respect to some observable value such as income of
workers or grades of students. `mobilityIndexR` calculates indices using
the `getMobilityIndices` function. By default, the `getMobilityIndices`
returns all available indices. Note that `getMobilityIndices` can
additionally return bootstrapped intervals for each of the indices.

``` r
getMobilityIndices(dat = incomeMobility, col_x = "t0", col_y = "t5", 
                   type = "relative", num_ranks = 5)
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

Below is a brief description of the indices. Let \(s(i)\) be the event
that one is in rank \(i\) at the first or starting point in time and
\(e(j)\) be the event that one is in rank \(j\) at the second or ending
point in time. Suppose \(k\) is the largest rank in the data.

The *Prais-Bibby* index (`type = "prais_bibby"`) is the proportion of
records that change ranks, i.e. \(\Sigma_{i = 1}^kPr[s(i) \neq e(i)]\).

The *Average Mobility* index (`type = "average_movement"`) is the
average number of ranks records move.

The *Weighted Group Mobility* index (`type = "wgm"`) is a weighted
version of the proportion of records that change ranks,
i.e. \(k^{-1} \Sigma_{i = 1}^k \frac{Pr[\neg e(i) | s(i)]}{Pr[\neg e(i)]}\).

There are four *Origin Specific* indices (`type = "origin_specific"`):
top, bottom, top far, and bottom far. The top (bottom) index is the
proportion of records that begin in the top (bottom) and end outside of
the top (bottom). The far versions of these indices are the proportions
of records that begin in the top (bottom) and end at least two ranks
away from the top (bottom).

``` r
getMobilityIndices(dat = incomeMobility, col_x = "t0", col_y = "t5", 
                   type = "relative", num_ranks = 5, indices = "wgm")
#> $wgm
#> [1] 0.58
```

A single index or subset of the indices can be returned by passing a
string or vector of strings in the `indices` argument.

# Hypothesis Testing

The function `getHypothesisTest` compares mobility indices across
datasets. The user specifies two datasets (`dat_A`, `dat_B`) as well as
a pair of columns from each dataset as a vector (`cols_A`, `cols_B`).
This function performs a non-parametric one-sided hypothesis test that
the index value for `dat_A` is greater than the index value for `dat_B`.
The parameter `bootstrap_iter` specifies the number of bootstrap
iterations; the default value is `100`.

``` r
getHypothesisTest(dat_A = incomeMobility, dat_B = incomeMobility, 
                  cols_A = c("t0", "t3"), cols_B = c("t5", "t8"),
                  type = "relative", num_ranks = 5, bootstrap_iter = 100)
#> $prais_bibby
#> [1] 0.31
#> 
#> $average_movement
#> [1] 0.52
#> 
#> $wgm
#> [1] 0.33
#> 
#> $os_total_top
#> [1] 0.55
#> 
#> $os_far_top
#> [1] 0.94
#> 
#> $os_total_bottom
#> [1] 0.37
#> 
#> $os_far_bottom
#> [1] 0
```

By default, all available indices are returned. A single index or subset
of the indices can be returned by passing a string or vector of strings
in the `indices` argument.
