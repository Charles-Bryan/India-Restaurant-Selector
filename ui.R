#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
require(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("India's Restaurant Selector"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            h3("Minimum Order Price for Delivery (in Rupees)"),
            sliderInput("minOrder",
                        "Minimum Delivery Range:",
                        min = 0,
                        max = 500,
                        value = c(0, 500)),
            
            h3("Average Order Price (in Rupees)"),
            sliderInput("avgCost",
                        "Average Cost Range:",
                        min = 0,
                        max = 1200,
                        value = c(0, 1200)),
            
            h3("City Selection"),
            checkboxInput("checkHyderabad", "Hyderabad", value = TRUE),
            checkboxInput("checkMumbai", "Mumbai", value = TRUE),
            checkboxInput("checkPune", "Pune", value = TRUE),
            checkboxInput("checkNoida", "Noida", value = TRUE),
            checkboxInput("checkMajestic", "Majestic", value = TRUE),
            checkboxInput("checkKolkata", "Kolkata", value = TRUE),
            
            h3("Cuisines of Interest"),
            checkboxInput("checkNorthIndian", "North Indian", value = TRUE),
            checkboxInput("checkChinese", "Chinese", value = TRUE),
            checkboxInput("checkFastFood", "Fast Food", value = TRUE),
            checkboxInput("checkBeverages", "Beverages", value = TRUE),
            checkboxInput("checkDesserts", "Desserts", value = TRUE)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotlyOutput("distPlot")
        )
    )
))
