# A simple tide viewer

[![license](https://img.shields.io/badge/Licence-GPL--3-blue.svg)](https://github.com/zibbini/tidedashboard/blob/master/LICENSE)

An interactive dashboard built with `shiny`, `leaflet` and `dygraphs` for viewing both historic and modelled tide data in Ireland. Data can be manually subsetted via station and date, using both reactive inputs and a leaflet map. Selected data is then visualised in an interactive dygraphs plot. All data for the published dashboards was sourced from the [Marine Institute](https://www.marine.ie/Home/home) in Ireland. 

## Requirements

If you would like to use this dashboard locally, you will need both [R](https://www.r-project.org) and [RStudio](https://rstudio.com), and all the packages listed below:
* `shiny`
* `leaflet`
* `dygraphs`
* `dplyr`
* `lubridate`
* `readr`
* `xts`
* `htmltools`
* `plyr`

You can install these packages using the following command:

``` r
install.packages(c("shiny","leaflet","dygraphs","dplyr","lubridate","readr","xts","htmltools","plyr"))
```

## View

After cloning/downloading this repo, you can view this app in a local R session using the following:

``` r
shiny::runApp("path/to/tidedashboard/modelled/")
```
for modelled data, and

```r
shiny::runApp("path/to/tidedashboard/non-modelled/")
```
for non-modelled data.

### Online

Dashboards containing both [modelled](https://z-lab.shinyapps.io/tidedashboard-modelled/) and [non-modelled](https://z-lab.shinyapps.io/tide-dashboard/) data have been published at [shinyapps.io](https://www.shinyapps.io/).
