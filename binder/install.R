# install.packages("devtools", dependencies=TRUE, repos=NULL)
# install.packages("devtools", repos="https://cloud.r-project.org")
install.packages("devtools", repos="http://cran.rstudio.com/")

# devtools::install_github('IRkernel/IRkernel')
# IRkernel::installspec()

install.packages(c("tidyr", "repr", "dplyr"), repos="http://cran.rstudio.com/")
install.packages(c("ggplot2", "data.table"), repos="http://cran.rstudio.com/")

# Eurostat package restatapi: we get the dev version
devtools::install_github("eurostat/restatapi")
install.packages("restatapi", repos="http://cran.rstudio.com/")

install.packages(c("rjson", "rsdmx", "RJSDMX","rdbnomics"), repos="http://cran.rstudio.com/")
install.packages(c("timeSeries","ggdemetra"), repos="http://cran.rstudio.com/")

# eurostat packages: many dependencies...
#install.packages(c('eurostat','ggrepel','ggraph','ggiraph','ggnetwork','ggTimeSeries','plotrix','tmap','leaflet','shinyjs'),
#			repos=NULL)

install.packages("reticulate", repos="http://cran.rstudio.com/") # python support in RMarkdown
