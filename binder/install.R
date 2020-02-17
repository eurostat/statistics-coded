install.packages("devtools", dependencies=TRUE, repos="https://cloud.r-project.org")
# install.packages("devtools", dependencies=TRUE, repos="http://cran.rstudio.com/")

# devtools::install_github('IRkernel/IRkernel')
# IRkernel::installspec()

install.packages(c("tidyr", "repr", "dplyr"), repos="https://cloud.r-project.org")
install.packages(c("ggplot2", "data.table", "rjson"), repos="https://cloud.r-project.org")

# Eurostat package restatapi: we get the dev version
devtools::install_github("eurostat/restatapi")
# install.packages("restatapi")

install.packages(c("rsdmx", "RJSDMX","rdbnomics"), repos="https://cloud.r-project.org")

# eurostat packages: many dependencies...
#install.packages(c('eurostat','ggrepel','ggraph','ggiraph','ggnetwork','ggTimeSeries','plotrix','tmap','leaflet','shinyjs'),
#			repos='https://cloud.r-project.org')

install.packages("reticulate") # python support in RMarkdown
