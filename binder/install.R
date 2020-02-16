#install.packages("devtools",repos="https://cloud.r-project.org")
install.packages("devtools", dependencies=TRUE, repos="http://cran.rstudio.com/"))
# devtools::install_github('IRkernel/IRkernel')
# IRkernel::installspec()

install.packages("reticulate") # python support in RMarkdown

install.packages(c("tidyr", "repr", "dplyr", "data.table"))
install.packages("ggplot2")

# Eurostat package restatapi: we get the dev version
devtools::install_github("eurostat/restatapi")
# install.packages("restatapi")

install.packages(c("rsdmx", "RJSDMX","rdbnomics"))

# eurostat packages: many dependencies...
#install.packages(c('eurostat','ggrepel','ggraph','ggiraph','ggnetwork','ggTimeSeries','plotrix','tmap','leaflet','shinyjs'),
#			repos='https://cloud.r-project.org')
