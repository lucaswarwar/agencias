Sys.setenv(TZ='UTC') # Local Time Zone

# load libraries --------------------------------------

library(here)         # manage directories
library(ggplot2)      # data viz
library(ggthemes)     # data viz themes
library(hrbrthemes)   # data viz themes
library(sf)           # read and manipulate spatial data
library(data.table)   # fast data wrangling
library(magrittr)     # pipe operator
library(ggmap)        # Google API
library(geobr)        # Brazil's spatial data
library(pbapply)      # progress bar
library(readr)        # rapid data read 
library(tidyr)        # data manipulating
library(stringr)      # strings operations
library(lubridate)    # handle date formats
library(mapview)      # interactive maps
library(RColorBrewer) # color palettes
library(paletteer)    # color palettes
library(extrafont)    # text fonts
library(ggtext)       # text tool for data viz
library(knitr)        # knit documents
library(furrr)        # vectorize in parallel
library(purrr)        # funcional programming
library(forcats)      # handle factors
library(parallel)     # optimize operations
library(future.apply) # more optimization
library(dplyr)        # better than data.table!
library(beepr)        # tells me when work is done
library(patchwork)    # plot composition
library(ggmap)        # geocoding
library(bit64)        # viz large numbers

# Set some options and useful functions --------------------

options(scipen=10000)

`%nin%` = Negate(`%in%`)

`%nlike%` = Negate(`%like%`)

# Use GForce Optimisations in data.table operations
# details > https://jangorecki.gitlab.io/data.cube/library/data.table/html/datatable-optimize.html

options(datatable.optimize=Inf)

# set number of threads used in data.table
data.table::setDTthreads(percent = 100)

rm_accent <- function(str,pattern="all") {
  if(!is.character(str))
    str <- as.character(str)
  pattern <- unique(pattern)
  if(any(pattern=="Ç"))
    pattern[pattern=="Ç"] <- "ç"
  symbols <- c(
    acute = "áéíóúÁÉÍÓÚýÝ",
    grave = "àèìòùÀÈÌÒÙ",
    circunflex = "âêîôûÂÊÎÔÛ",
    tilde = "ãõÃÕñÑ",
    umlaut = "äëïöüÄËÏÖÜÿ",
    cedil = "çÇ"
  )
  nudeSymbols <- c(
    acute = "aeiouAEIOUyY",
    grave = "aeiouAEIOU",
    circunflex = "aeiouAEIOU",
    tilde = "aoAOnN",
    umlaut = "aeiouAEIOUy",
    cedil = "cC"
  )
  accentTypes <- c("´","`","^","~","¨","ç")
  if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern)) # opcao retirar todos
    return(chartr(paste(symbols, collapse=""), paste(nudeSymbols, collapse=""), str))
  for(i in which(accentTypes%in%pattern))
    str <- chartr(symbols[i],nudeSymbols[i], str)
  return(str)
}

options(scipen = 99999)