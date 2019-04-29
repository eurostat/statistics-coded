FROM ubuntu:18.04

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
    r-base \
    gdebi-core \
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
    ipython \
    software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean all
     
RUN pip install jupyter

RUN jupyter notebook --allow-root

RUN echo "update.packages" >> /tmp/install.R && \
    echo "install.packages('devtools',repos='https://cloud.r-project.org');"  > /tmp/install.R && \
    echo "devtools::install_github('IRkernel/IRkernel');" >> /tmp/install.R && \
    echo "install.packages(c('rJava','rdbnomics','ggrepel','ggraph','ggiraph','ggnetwork','ggTimeSeries','plotrix','tmap','rsdmx','leaflet','shinyjs','TSsdmx','TSdbi','timeSeries','RJDemetra'),repos='https://cloud.r-project.org')" >> /tmp/install.R && \
    echo "devtools::install_github('eurostat/restatapi');" >> /tmp/install.R && \
    echo "devtools::install_github('rOpenGov/eurostat');" >> /tmp/install.R && \
    Rscript /tmp/install.R
    

USER $NB_UID

RUN echo "IRkernel::installspec();" > install.R && \
    Rscript install.R
 
# RUN wget https://raw.githubusercontent.com/eurostat/statistics-coded.git/master/popul/young-people-social-inclusion_R.ipynb 
   
# RUN git clone https://github.com/eurostat/statistics-coded.git
