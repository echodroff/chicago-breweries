library(shiny)
library(ggplot2)
library(ggmap)
library(shinydashboard)
library(DT)

brews <- read.csv("breweries_final.csv", header=T)
brews$brewplace <- brews$brewery
brews$brewery <- paste("<a href='",brews$website,"' target='_blank'>",brews$brewplace,"</a>", sep='')
brews$address <- brews$address
brews$'city, state' <- paste(brews$city, brews$state, sep=', ')
brews$area <- ifelse(brews$neighborhood %in% c('South Loop', 'Hyde Park', 'Bridgeport', 'Bronzeville', 'Pilsen', 'Douglas Park', 'Beverly', 'Morgan Park', 'Pullman', 'Bedford Park', 'Roseland'), 'South Chicago', ifelse(brews$neighborhood %in% c('West Loop', 'Near West Side', 'West Town', 'Hermosa', 'Wicker Park', 'Logan Square', 'Avondale', 'Irving Park', 'Belmont Cragin', 'Old Irving Park'), 'West Chicago', ifelse(is.na(brews$neighborhood), 'outside Chicago', 'North Chicago')))
 
brews$latitude <- as.numeric(brews$latitude)
brews$longitude <- as.numeric(brews$longitude)

# chicagoMap <- get_map(location = c(lon = -87.65, lat = 41.93), color = "color", source = "google", maptype = "roadmap",zoom = 11)
# chicagolandMap <- get_map(location = c(lon = -87.6, lat = 41.9), color = "color", source = "google", maptype = "roadmap",zoom = 9)
# save(chicagoMap, file = "chicagoMap.RData")
# save(chicagolandMap, file = "chicagolandMap.RData")

load("chicagoMap.RData")
load("chicagolandMap.RData")

# Define UI----
ui <- dashboardPage(

	# App title ----
	dashboardHeader(title = "Chicagoland Breweries"),

	# Sidebar layout with input and output definitions ----
	dashboardSidebar(disable=T),

	# Main panel for displaying outputs ----
	dashboardBody(
 		fluidRow(
 		 
 		# box 1
 		# Output: Plot of the requested variables ----
		box(plotOutput("map", hover=hoverOpts("plot_hover", delay=50, clip=T), height=480), verbatimTextOutput("hover_info", placeholder=T)),
		
		# box 2
		 # Input: Radio button input for Chicago or Chicagoland
		box(radioButtons("regionChoice", "Region", choices = c('Chicago only', 'Chicagoland+'), selected='Chicagoland+'),
		
		# Input: Checkbox for tap rooms, kitchens, tours
		checkboxGroupInput("options", "Options", choices=c('Tap Room', 'Kitchen & Beer', 'Tour')), width=4),
		
		# box 3
		box(dataTableOutput("breweries"))
		)))

# Define server logic to plot various variables ----
server <- function(input, output) {
	
	# get data ----
    subset_data <- reactive({
    if (input$regionChoice=='Chicago only') {
		myData <- subset(brews, city=='Chicago')
    } else {
    	myData <- brews
    }
    
    if ('Tap Room' %in% input$options) {
    	myData <- subset(myData, hasTapRoom=='yes')
    	}
    
    if ('Kitchen' %in% input$options) {
    	myData <- subset(myData, hasKitchen=='yes')
		}
	
	if ('Tour' %in% input$options) {
		myData <- subset(myData, hasTour=='yes')
		}
	row.names(myData) <- 1:nrow(myData)
    return(myData)
    })

    
  # Generate a plot of the requested variables ----
    chooseMap <- reactive({
    if (input$regionChoice=='Chicago only') {
		map <- chicagoMap
    } else {
    	map <- chicagolandMap
    	}
    return(map)
    })
    

  output$map <- renderPlot({
  	ggmap(chooseMap(), extent = "device", ylab = "Latitude", xlab = "Longitude") + geom_point(data=subset_data(), aes(x=longitude, y=latitude, color=area), size=2) + guides(color=F, size=F) + scale_colour_manual(values=c("aquamarine4", "skyblue4", "slateblue","dodgerblue4"))
  })
  	
	output$breweries <- renderDataTable(datatable({ subset_data()[,colnames(brews)%in%c('brewery', 'address', 'city, state')] }, escape = FALSE))
	
	output$hover_info <- renderText({
		if(!is.null(input$plot_hover)) {
			hover=input$plot_hover
			brewName = as.character(brews$brewplace[which.min((brews$latitude-hover$y)^2 + (brews$longitude-hover$x)^2)])
			brewFeats <- subset(brews, brewplace==brewName)$features
			if (is.na(brewFeats)) {
				brewFeats <- '-'
				}
			brewCity <- subset(brews, brewplace==brewName)$city
			if (brewCity=='Chicago') {
				brewNeighborhood <- subset(brews, brewplace==brewName)$neighborhood
				brewCity <- paste(brewCity, brewNeighborhood, sep=' - ')
				}
			paste(brewName, brewCity, brewFeats, sep='\n')
		} else {
		paste('Hover for more info', ' ', ' ', sep='\n') }
    })
    
    }	

# Create Shiny app ----
shinyApp(ui, server)