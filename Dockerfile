
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/scipy-notebook
#FROM jupyter/datascience-notebook:87210526f381

MAINTAINER Jupyter Project <jupyter@googlegroups.com>

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    dirmngr \
    gpg-agent \
    software-properties-common 

#RUN sudo apt purge r-base r-recommended r-cran-* &&\
#    sudo apt autoremove &&\
#    sudo apt update
       
RUN add-apt-repository ppa:marutter/c2d4u3.5 &&\
    add-apt-repository ppa:marutter/rrutter3.5 &&\
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/sources.list &&\
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 &&\
    gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | apt-key add - &&\
    apt-get update &&\ 
    apt-get upgrade -y

#RUN apt-get dist-upgrade -y

RUN apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    java-common \
    build-essential \
    libudunits2-0 \
    libudunits2-dev \
    libgdal20 \
    gdal-bin \
    gdal-data \
    libgdal-dev \
    libssl-dev \
    libssh2-1 \
    libssh2-1-dev \
    libgeos-3.6.2 \
    libproj12 \
    proj-bin \
    libproj-dev \
    libpoppler73 \
    poppler-utils \
    libpoppler-dev \
    libgit2-dev \
    gnupg \
    libtool \ 
    libunwind-dev \
    libzmq3-dev \
    libcairo2-dev \
    libopenblas-base \
    libopenblas-dev \
    libexpat1-dev \
    libpq-dev \
    libsqlite3-dev \
    postgis \
    r-base-core \
    r-base-dev \
    r-cran-broom \
    r-cran-codetools \
    r-cran-crosstalk \
    r-cran-desc \
    r-cran-devtools \
    r-cran-dichromat \
    r-cran-dplyr \
    r-cran-eurostat \
    r-cran-ggforce \
    r-cran-ggplot2 \
    r-cran-ggrepel \
    r-cran-ggraph \
    r-cran-htmltools \
    r-cran-htmlwidgets \
    r-cran-leaflet \
    r-cran-mapview \
    r-cran-mgcv \
    r-cran-nlme \
    r-cran-pkgbuild \
    r-cran-pkgload \
    r-cran-pkgkitten \
    r-cran-plyr \
    r-cran-raster \
    r-cran-rcmdcheck \
    r-cran-rcolorbrewer \
    r-cran-rcpp \
    r-cran-readr \
    r-cran-refmanager \
    r-cran-rjdemetra \
    r-cran-rjava \
    r-cran-rjson \
    r-cran-rprojroot \
    r-cran-scales \
    r-cran-sf \
    r-cran-sp \
    r-cran-tmap \
    r-cran-tmaptools \
    r-cran-tidyr \
    r-cran-units \
    r-cran-uuid \
    r-cran-usethis \
    r-cran-viridis \
    r-cran-xml2 \
    gdb \
    valgrind \
    mc \
    gcc && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

 
RUN R CMD javareconf
RUN echo "install.packages(c('restatapi','rdbnomics','TSsdmx','ggiraph','ggnetwork','ggTimeSeries','plotrix','rsdmx','shinyjs','TSdbi','timeSeries','flagr','ggdemetra'),repos='https://cloud.r-project.org')" >> /tmp/install.R && \
#    echo "devtools::install_github('eurostat/restatapi');" >> /tmp/install.R && \
    Rscript /tmp/install.R
    
RUN echo "devtools::install_github('IRkernel/IRkernel');" >> /tmp/install.R && \
    Rscript /tmp/install.R
    
USER $NB_USER

RUN echo "IRkernel::installspec();" > install.R && \
    Rscript install.R




# RUN /bin/bash -c "source activate unidata-workshop && ipython kernel install --user"
# RUN wget https://raw.githubusercontent.com/eurostat/statistics-coded.git/master/popul/young-people-social-inclusion_R.ipynb 
   
# RUN git clone https://github.com/eurostat/statistics-coded.git
