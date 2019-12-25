#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

require(tidyverse)      # Dataframe package
require(readxl)         # Read in provided data from xlsx files
library(shiny)
require(plotly)

# Prep Functions
remove_char <- function(dataset, bad_char, given_col){
    remove_terms <- paste("[",bad_char,"]")
    dataset[[given_col]] <- str_replace(dataset[[given_col]], bad_char, "")
    return(dataset)
}

encode_cuisines <- function(dataset, given_column, split_text, unique_terms, N, keep = FALSE){
    named_column <- enquo(given_column)
    output <- dataset %>% mutate(!!named_column := strsplit(Cuisines, split = split_text))
    for (element in unique_terms$Terms[1:N]){
        new_name = paste("Cuisine: ", element)
        output <- output %>% mutate(!!new_name := 0)
        for (index in 1:nrow(output)){
            output[index,][new_name] <- element %in% output[index,][given_column][[1]][[1]]
        }
    }
    if (keep){
        output <- select(output, -c(!!named_column))
    }
    else{
        output <- select(output, -c(!!named_column, Cuisines))
    }
    
    return(output)
}
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    data_train_base <- read_excel("./data/starting_data.xlsx")
    
    data_train_base <- data_train_base %>%
        mutate_at(vars(contains("Cuisine:")),as.numeric) %>%
        filter(`Cuisine:  North Indian` + `Cuisine:  Chinese` + `Cuisine:  Fast Food` + `Cuisine:  Beverages` + `Cuisine:  Desserts` >0)
    
    output_levels <- c("10 minutes","20 minutes", "30 minutes", "45 minutes", "65 minutes", "80 minutes", "120 minutes")
    data_train_base$Delivery_Time <- factor(data_train_base$Delivery_Time, levels = output_levels)    
    
    df_cities <- reactive({
        df <- data_train_base
        
        if(!input$checkHyderabad){
            df <- df %>% filter(!grepl("Hyderabad", Location))
            }
        if(!input$checkMumbai){
            df <- df %>% filter(!grepl("Mumbai", Location))
        }
        if(!input$checkPune){
            df <- df %>% filter(!grepl("Pune", Location))
        }
        if(!input$checkNoida){
            df <- df %>% filter(!grepl("Noida", Location))
        }
        if(!input$checkKolkata){
            df <- df %>% filter(!grepl("Kolkata", Location))
        }
        if(!input$checkMajestic){
            df <- df %>% filter(!grepl("Majestic", Location))
        }
        df
    })
    
    df_foods <- reactive({
        df <- df_cities()
        
        foods <- vector()
        if(input$checkNorthIndian){foods <- c(foods,"Cuisine:  North Indian")}
        if(input$checkChinese){foods <- c(foods,"Cuisine:  Chinese")}
        if(input$checkFastFood){foods <- c(foods,"Cuisine:  Fast Food")}
        if(input$checkBeverages){foods <- c(foods,"Cuisine:  Beverages")}
        if(input$checkDesserts){foods <- c(foods,"Cuisine:  Desserts")}
        
        
        df %>% filter_at(vars(foods), any_vars(. > 0))
    })
    
    df_min_order <- reactive ({
        df <- df_foods()
        
        minOrder_lower <- input$minOrder[1]
        minOrder_upper <- input$minOrder[2]
        
        df %>% 
            filter(Minimum_Order >= minOrder_lower) %>%
            filter(Minimum_Order <= minOrder_upper)
    })
    
    df_avg_cost <- reactive ({
        df <- df_min_order()
        
        avgCost_lower <- input$avgCost[1]
        avgCost_upper <- input$avgCost[2]
        
        df %>% 
            filter(Average_Cost >= avgCost_lower) %>%
            filter(Average_Cost <= avgCost_upper)
    })
    
    
    output$distPlot <- renderPlotly({

        # draw the histogram with the specified number of bins
        # g <- ggplot(data_train, aes(x=Votes, y=Rating)) +
        #     geom_point(aes(color=Delivery_Time))
        data <- df_avg_cost()
        
        p <- data %>%
            plot_ly(type = "scatter", mode = "markers", 
                    x = ~Votes, y= ~Rating, color= ~Delivery_Time,
                    text = ~paste("<b>Restaurant:</b> ", Restaurant,
                                  "<br><b>Rating:</b> ", Rating,
                                  "<br><b>Location:</b> ", Location),
                    hovertemplate = paste(
                        "%{text}",
                        "<extra></extra>"
                    ))

        p <- layout(p, xaxis = list(range = c(0, 8000)), yaxis = list(range = c(0, 5)))
        p
    })

})
