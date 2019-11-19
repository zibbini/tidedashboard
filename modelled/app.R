library(shiny)
library(leaflet)
library(lubridate)
library(htmltools)
library(dygraphs)
library(dplyr)
library(xts)
library(plyr)

tide_latlon <- readRDS(file = "./Data/tide_latlon.rds")

ui <- fluidPage(
  
  #Title
  titlePanel("Past, present and future tide data for Ireland (Modelled)"),
  
  sidebarPanel(
    #Instruction text 
    tags$div(class = "header", checked = NA,
             tags$b("Instructions to use:"),
             tags$h5("1. Select a station from the map."),
             tags$h5("2. Select your desired date."),
             tags$h5("3. Interact with the reactive plot displayed!"),
             tags$br()),
    #Inputs
    textInput(
      inputId = "station",
      label = "Choose a station",
      value = NULL,
      placeholder = NULL),
    dateInput(
      inputId = "date_day",
      label = "Select a date:",
      min = "2018-01-01",
      max = "2021-01-01"),
    br(),
    
    #Links for further info
    uiOutput("github"),
    hr(),
    uiOutput("am_pm"),
    hr()
  ),
  
  #Interactive map and plot
  mainPanel(
    leafletOutput("stationMap"),
    hr(),
    dygraphOutput("tides"))
)


server <- function(input, output, session) {
  
  #Text for links
  url <- a("GitHub repo", href = "https://github.com/zibbini/tidedashboard/", target = "_blank")
  output$github <- renderUI({
    tagList("For more information on this dashboard, please refer to the following ", url, icon("github"))
  })
  
  #Interactive leaflet map
  output$stationMap <- renderLeaflet({
    leaflet(tide_latlon) %>% addTiles() %>% 
      addMarkers(~unique(longitude), ~unique(latitude), layerId = ~unique(stationID), label = ~htmlEscape(unique(stationID)))
  })
  
  #Reactive inputs
  observeEvent(input$stationMap_marker_click,
               updateTextInput(session, "station",
                               value = unique(tide_latlon$stationID[tide_latlon$stationID %in% input$stationMap_marker_click$id])
               ))
  
  tide <- reactive(readRDS(file = paste0("./Data/",input$station,".rds"))) 
  
  #Reactive dataset corresponding to each dataset chosen
  byMonth <- reactive(tide()[format(as.Date(input$date_day), "%Y-%m")])
  
  #Interative plot
  output$tides <- renderDygraph({ 
    validate(
      need(input$station, "Please select a station from the map above.")
    )
    dygraph(byMonth(), main = paste(input$station, input$date_day), xlab = "Date and time", ylab = "Water level (m)") %>%
      dyOptions(fillGraph = T, fillAlpha = 0.5, colors = "#058FD3") %>%
      dyRangeSelector(c(ymd_hms(paste0(input$date_day, "00:00:00")),ymd_hms(paste0(input$date_day, "23:54:00"))))
  })
  
  #High/low tide results
  byDay <- reactive(byMonth()[format(as.Date(input$date_day), "%Y-%m-%d")])
  
  tide_am <- reactive(window(byDay(), start = paste(input$date_day, "00:00:00"), end = paste(input$date_day, "12:00:00")))
  tide_pm <- reactive(window(byDay(), start = paste(input$date_day, "12:00:00"), end = paste(input$date_day, "24:00:00")))
  
  high_am <- reactive(tide_am()[which.max(tide_am()$Water_Level), ])
  low_am  <- reactive(tide_am()[which.min(tide_am()$Water_Level), ])
  high_pm <- reactive(tide_pm()[which.max(tide_pm()$Water_Level), ])
  low_pm  <- reactive(tide_pm()[which.min(tide_pm()$Water_Level), ])
  
  time_high  <- reactive(ldply(strsplit(as.character(index(high_am())), " ")))
  time_low   <- reactive(ldply(strsplit(as.character(index(low_am())), " ")))
  time_high2 <- reactive(ldply(strsplit(as.character(index(high_pm())), " ")))
  time_low2  <- reactive(ldply(strsplit(as.character(index(low_pm())), " ")))
  
  output$am_pm <- renderUI({
    validate(need(input$station, ""))
    tagList(tags$h3("High and low tide readings:"), 
            tags$h4("Morning high/low tides ", icon("sun")),
            tags$h5(paste(time_high()$V2,"~", high_am()$Water_Level, "m")),
            tags$h5(paste(time_low()$V2,"~", low_am()$Water_Level, "m")),
            tags$h4("Evening high/low tides ", icon("moon")),
            tags$h5(paste(time_high2()$V2,"~", high_pm()$Water_Level, "m")),
            tags$h5(paste(time_low2()$V2,"~", low_pm()$Water_Level, "m"))
    )
    
  })
}

shinyApp(ui, server)


