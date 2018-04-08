## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
## 00_build_functions.R ; Author: Ben Berger;                               
## Modified from script by Andrew Marder:                              
##
## Defines function to parse JSON columns from trials.csv (from cortellis API) as dataframes in long form. 
## Also used 
##
## Original notes from AM:                                             
## I've written a function called `my_expand` to make working with the 
## trials data a little bit easier. The `get_name`, `assert`, and      
## `json_to_dataframe` functions are helper functions that I used to   
## write the `my_expand` function.                                     
##
## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##

## Load packages 
library(dplyr) 
library(rlang)
library(readr)
library(tidyr)
library(haven)

## ------------------------------------------------------------------------------------------------ ##
##  Define functions
## ------------------------------------------------------------------------------------------------ ##

assert <- stopifnot
get_name <- function(x) as.character(UQE(x))


## Parse a JSON cell as a tibble (data_frame)
json_to_dataframe <- function(s, varname) {
  l <- jsonlite::fromJSON(s)
  assert(class(l) == "list")
  if(length(l) == 1) data <- l[[1]]
  else data <- l
  
  if (class(data) == "data.frame") {
    return(data)
  }
  else {
    data2 <- data.frame(data)
    if(length(names(data)) == 0) names(data2) <- varname
    else names(data2) <- names(data)
    # next few lines are some test code for getting country data
    # if(varname == '~SitesByCountries'){
    #    data2$site_subdivision_code <- data2[['Sites.Site.CountrySubDivision']][['@code']]
    #    data2$site_subdivision_name <- data2[['Sites.Site.CountrySubDivision']][['$']]
    #    data2[['Sites.Site.CountrySubDivision']] <- NULL
    # }
    
    return(data2)
  }
}

#Parse Geographic Data Column: 
json_to_dataframe_geodata <- function(s) {
  l <- jsonlite::fromJSON(s)
  assert(class(l) == "list")
  if(length(l) == 1) data <- l[[1]]
  else data <- l
  
  if(is.null(data[['@country']])) data[['@country']] <- NA
  data <- data[['@country']] %>% as.data.frame
  names(data) <- 'country'
  
  return(data)
}

## Apply json_to_dataframe to each cell of a column
my_expand <- function(df, id, var) {
  id <- enquo(id)
  var <- enquo(var)
  varname <- deparse(substitute(var))
  
  f <- function(row) {
    #print(row[[get_name(id)]])
    assert(class(row) == "list")
    if(varname == '~SitesByCountries') data <- json_to_dataframe_geodata(row[[get_name(var)]])
    else data <- json_to_dataframe(row[[get_name(var)]], varname)
    if(nrow(data) > 0) data[[get_name(id)]] <- row[[get_name(id)]]
    return(data)
  }
  
  df %>%
    select(!!id, !!var) %>%
    filter(!is.na(!!var)) %>%
    rowwise() %>%
    do(f(.)) %>% 
    ungroup
}

