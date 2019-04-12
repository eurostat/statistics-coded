# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/scipy-notebook

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    tzdata \
    gfortran \
    default-jdk \
    default-jdk-headless \
    libudunits2-0 \
    libudunits2-dev \
    gnupg \
    python-rpy2 \
    python3-rpy2 \
    libssl-dev \
    libgdal-dev \
    libssh2-1 \
    libssh2-1-dev \
    libgit2-26 \
    libgit2-dev \
    libunwind-dev \
    libzmq3-dev \
    libcairo2-dev \
    libopenblas-base \
    libopenblas-dev \
    gcc \
    build-essential \
    apt-utils \
    software-properties-common

# Add the CRAN repository to apt sources
# RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9 && \
#    gpg -a --export E084DAB9 | apt-key add - && \
#    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
# install R
RUN apt-get update && \
    apt-get install -y \
    r-base \
    r-base-core \
    r-base-dev \
    r-cran-plyr \
    r-cran-rsqlite \
    r-cran-caret \
    r-cran-ggplot2 \
    r-cran-reshape2 \
    r-cran-rcurl \
    r-cran-crayon \
    r-cran-rjson \
    r-cran-jsonlite \
    r-cran-base64enc \
    r-cran-e1071 \
    r-cran-stringr \
    r-cran-stringi \
    r-cran-knitr \
    r-cran-rcpp \
    r-cran-rjava \
    r-cran-randomforest && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "update.packages" >> /tmp/install.R && \
    echo "install.packages('devtools',repos='https://cloud.r-project.org');"  > /tmp/install.R && \
    echo "devtools::install_github('IRkernel/IRkernel');" >> /tmp/install.R && \
    echo "install.packages(c('rJava','rdbnomics','ggrepel','ggraph','ggiraph','ggnetwork','ggTimeSeries','plotrix','tmap','rsdmx','leaflet','shinyjs','TSsdmx','TSdbi','timeSeries','RJDemetra'),repos='https://cloud.r-project.org')" >> /tmp/install.R && \
    echo "devtools::install_github('eurostat/flagr');" >> /tmp/install.R && \
    echo "devtools::install_github('eurostat/restatapi');" >> /tmp/install.R && \
    echo "devtools::install_github('rOpenGov/eurostat');" >> /tmp/install.R && \
    Rscript /tmp/install.R
    

USER $NB_UID

RUN echo "IRkernel::installspec();" > install.R && \
    Rscript install.R
 
# RUN wget https://raw.githubusercontent.com/eurostat/statistics-coded.git/master/popul/young-people-social-inclusion_R.ipynb 
   
# RUN git clone https://github.com/eurostat/statistics-coded.git
