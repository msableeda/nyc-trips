library(shiny)


#library(igraph)
library(hash)
#library(lubridate)

green_nyc = read.csv("~/Downloads/tripdata/green_tripdata_2018-01.csv")
taxi_zones = read.csv("~/Downloads/tripdata/taxi+_zone_lookup.csv") 

buildAggregates <- function(nyc) {
    agg <-  hash() # (,1,5)

    # break data down into segments
    for (idx in 1:length(nyc)) 
    {
        i <- nyc[idx,]
        strKey <-paste(i["PULocationID"], i["DOLocationID"], sep = '-')
        if(exists(strKey, agg))
        {
            total_time <- agg[[strKey]][1] + difftime(i[["lpep_dropoff_datetime"]], i[["lpep_pickup_datetime"]])
            total_trips <- agg[[strKey]][2] + 1
            agg[[strKey]] <- c(total_time, total_trips,0)
        }
        else
        {
            total_time <- difftime(i[["lpep_dropoff_datetime"]], i[["lpep_pickup_datetime"]])
            total_trips <- 1
            agg[[strKey]] <- c(total_time, total_trips,0)
        }
    }
    
    # calculate averages
    for (idx in ls(agg))
    {
        #print(toString(idx))
        #print(agg[[idx]])
        #Average time per trip is total_time / total_trips
        avg_trip <- as.double(agg[[idx]][1]) / as.double(agg[[idx]][2])
        agg[[idx]][3] <- avg_trip
    }
    
    print(agg)
    return(agg)
}


agg <- buildAggregates(green_nyc)







# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("NYC Traffic Data"),

    # Sidebar with our parameters and a table with zone info 
    sidebarLayout(
        sidebarPanel(
            selectInput(
                "from_zone",
                "Starting Zone",
                taxi_zones$LocationID,
                97
                ),
            selectInput(
                "to_zone",
                "Ending Zone",
                taxi_zones$LocationID,
                188
            ),
            tableOutput("taxiZones")
        ),

        # Information about your chosen route
        mainPanel(
            h3("greetings"),
            textOutput("tripTime")
        )
    ) 
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    #print(input)
    output$taxiZones <- renderTable(taxi_zones)
    
    trip <- reactive({
        agg[[paste(input$from_zone, input$to_zone, sep = '-')]][3]
    })
    
    output$tripTime <- renderPrint(trip())

    
}

# Run the application 
shinyApp(ui = ui, server = server)
