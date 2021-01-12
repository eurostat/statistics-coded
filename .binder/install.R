# if (!requireNamespace("devtools", quietly = TRUE))
#  install.packages("devtools", repos="https://cloud.r-project.org")
# #  install.packages("devtools", repos="http://cran.rstudio.com/")
# #  install.packages("devtools", dependencies=TRUE, repos=NULL)

# devtools::install_github('IRkernel/IRkernel')
# IRkernel::installspec()

# install through conda conda-forge?
install.packages(c("tidyr", "repr", "dplyr","reshape2"), repos="https://cloud.r-project.org")
install.packages(c("ggplot2","ggforce","plotly","patchwork","kableExtra"),repos="https://cloud.r-project.org")
install.packages(c("restatapi","rjson", "xml2","data.table"), repos="https://cloud.r-project.org")
# install.packages("reticulate", repos="https://cloud.r-project.org") # python support in RMarkdown

# Eurostat package restatapi: we get the dev version
# devtools::install_github("eurostat/restatapi")
install.packages(c("rsdmx", "rdbnomics"), repos="https://cloud.r-project.org")
# install.packages(c("timeSeries", "ggdemetra", "prophet"), repos="https://cloud.r-project.org")

# eurostat packages: many dependencies...
#install.packages(c('eurostat','ggrepel','ggraph','ggiraph','ggnetwork','ggTimeSeries','plotrix','tmap','leaflet','shinyjs'),
#			repos=NULL)
