FROM rocker/verse:4.0.1

# Installing renv (https://rstudio.github.io/renv/articles/docker.html)
ENV RENV_VERSION 0.11.0-6
# (remotes is already included in rocker/verse)
# RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"