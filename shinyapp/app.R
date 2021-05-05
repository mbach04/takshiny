library(shiny)
library(dplyr)
library(readr)
library(leaflet)
library(shinythemes)
library(plotly)
library(lubridate)

historical_tak = read_csv("/srv/shiny-server/tak/historical_tak_filtered.csv") %>%
    mutate(start=as_datetime(start/1000),
           time = as_datetime(time/1000)) %>%
    mutate(start=as.Date(start))

# historical_tak = read_csv("historical_tak_filtered.csv") %>%
#     mutate(start=as_datetime(start/1000),
#            time = as_datetime(time/1000)) %>%
#     mutate(start=as.Date(start))

# Define UI for application that draws a histogram
ui = fluidPage(theme = shinytheme("darkly"),
                
                # Application title
                titlePanel("Trident Specture 2021 - TAK Analysis"),
                
                    # Show a plot of the generated distribution
                    fluidRow(
                        column(6,
                               sliderInput(
                                   "date",
                                   "Filter Date Range",
                                   min=ymd("2021-04-28"),
                                   max=as.Date(max(historical_tak$start)),
                                   value=as.Date(min(historical_tak$start))
                               ),
                               plotlyOutput("density"),
                               plotlyOutput("ts")),
                        column(6,
                               # pickerInput(
                               #     "type",
                               #     "Filter Type",
                               #     choices=unique(historical_tak$typeDescription),
                               #     selected=unique(historical_tak$typeDescription),
                               #     multiple=T
                               # ),
                               leafletOutput("current_map",
                                             height = 1000))
                    ))

# Define server logic required to draw a histogram
server = function(input, output) {
    
    output$current_map = renderLeaflet({
        map_data = historical_tak %>%
            filter(
                start==input$date[1]
                
            )
        
        leaflet() %>%
            addTiles(urlTemplate = "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png") %>%
            addMarkers(map_data$x,
                       map_data$y,
                       clusterOptions = markerClusterOptions()) %>%
            setView(
                lng = median(map_data$x),
                lat = median(map_data$y),
                zoom = 12
            )
        
    })
    
    output$density = renderPlotly({
        
        historical_tak %>%
            filter(
                start==input$date[1]
                
            ) %>%
            filter(x >= -76.33 & x <= -76.25) %>%
            filter(y >= 36.75 & y <= 37) %>%
            plot_ly() %>%
            add_trace(type = "histogram2dcontour",
                      x =  ~ x,
                      y =  ~ y) %>%
            layout(plot_bgcolor='#222222') %>% 
            layout(paper_bgcolor='#222222',
                   font=list(
                       color="white"
                   ))
        
        
    })
    
    output$ts = renderPlotly({
        
        historical_tak %>%
            filter(
                start==input$date[1]
            ) %>%
            mutate(start=round_date(time,"hour")) %>%
            count(start,typeDescription) %>%
            filter(typeDescription %in% c(
                "unknown air air track",
                "unknown surface sea sea surface track"
            )) %>%
            plot_ly(
                x=~start,
                y=~n,
                type="bar",
                color=~typeDescription
            ) %>%
            layout(plot_bgcolor='#222222') %>% 
            layout(paper_bgcolor='#222222',
                   font=list(
                       color="white"
                   ))
    })
    
}

# Run the application

shinyApp(
    options = list(
        host = "0.0.0.0",
        port = 3838
    ),
    ui = ui, server = server
)
