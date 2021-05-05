FROM rocker/shiny:4.0.1

COPY shinyapp/ /srv/shiny-server/tak

#RUN apt install libcurl4-openssl-dev libssldev libxml2-dev -y

RUN Rscript /srv/shiny-server/tak/install_packages.R

USER 1001

EXPOSE 3838

CMD ["Rscript", "/srv/shiny-server/tak/app.R"]

