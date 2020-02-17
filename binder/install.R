install.packages("devtools", dependencies=TRUE, repos=NULL)
# install.packages("devtools", dependencies=TRUE, repos="https://cloud.r-project.org")
# install.packages("devtools", dependencies=TRUE, repos="http://cran.rstudio.com/")

# devtools::install_github('IRkernel/IRkernel')
# IRkernel::installspec()

install.packages(c("tidyr", "repr", "dplyr"), dependencies=TRUE, repos=NULL)
install.packages(c("ggplot2", "data.table"), repos=NULL)

# Eurostat package restatapi: we get the dev version
devtools::install_github("eurostat/restatapi")
install.packages("restatapi", dependencies=TRUE, repos=NULL)

install.packages(c("rjson", "rsdmx", "RJSDMX","rdbnomics"), repos=NULL)

# eurostat packages: many dependencies...
#install.packages(c('eurostat','ggrepel','ggraph','ggiraph','ggnetwork','ggTimeSeries','plotrix','tmap','leaflet','shinyjs'),
#			repos=NULL)

install.packages("reticulate", repos=NULL) # python support in RMarkdown
