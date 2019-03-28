FROM rocker/r-ver:3.5.2
LABEL maintainer="Erik Ferlanti <eferlanti@tacc.utexas.edu>"

# Install Ubuntu packages
RUN apt-get update && apt-get install -y \
    default-jdk \
    gdebi-core \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libgeos-dev \
    libgit2-dev \
    libglu1-mesa-dev \
    libgsl-dev \
    libmariadbclient-dev \
    libpq-dev \
    libssl-dev \
    libxml2-dev \
    libxt-dev \
    mesa-common-dev \
    pandoc \
    pandoc-citeproc \
    procps \
    sudo \
    vim \
    wget \
    xtail

# Download and install ShinyServer (latest version)
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt) && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment

# Install R packages that are required
RUN R -e "install.packages(c('shiny', 'shinydashboard'), repos='http://cran.rstudio.com/')"
RUN R -e "if (!require('XML',character.only=TRUE)) { install.packages('XML', repos='http://cran.rstudio.com/') }"
RUN R -e "if (!require('dplyr',character.only=TRUE)) { install.packages('dplyr', repos='http://cran.rstudio.com/') }"
RUN R -e "if (!require('ggplot2',character.only=TRUE)) { install.packages('ggplot2', repos='http://cran.rstudio.com/') }"
RUN R -e "if (!require('scales',character.only=TRUE)) { install.packages('scales', repos='http://cran.rstudio.com/') }"
RUN R -e "if (!require('grid',character.only=TRUE)) { install.packages('grid', repos='http://cran.rstudio.com/') }"
RUN R -e "if (!require('reshape2',character.only=TRUE)) { install.packages('reshape2', repos='http://cran.rstudio.com/') }"
RUN R -e "if (!require('RCurl',character.only=TRUE)) { install.packages('RCurl', repos='http://cran.rstudio.com/') }"

# Copy server configuration files
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh

# Copy app and configuration files
COPY /data /srv/shiny-server/data
COPY /www /srv/shiny-server/www
COPY *.R /srv/shiny-server/

# Restore packrat snapshot (required R packages)
WORKDIR /srv/shiny-server

# Make the ShinyApp available at port
EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]
