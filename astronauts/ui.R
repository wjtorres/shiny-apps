#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)


# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("cosmo"),

    # Application title
    navbarPage("International Astronauts Database",
               tabPanel("Astronauts",
                        h4("There are over 500 astronauts that have traveled to space. Search the astronauts database below for an individual astronaut's name, sex, nationality, year of first mission, total number of missions, and total duration of all their missions. Sort and filter the data by using the column headers."),
                        br(),
                          fluidRow(
                            DT::dataTableOutput("astronautTable")
                          )
                        ),
               
               
               tabPanel("Demographics",
                        h4("The data below shows demographic information for astronauts who participated in the missions. Please note that the data does not represent unique astronauts."),
                        fluidRow(
                          column(width = 12,
                                 align = "center",
                                 sliderInput("dateRange", "Select Mission Year Range:",
                                      min = 1961,
                                      max = 2019,
                                      value = c(1961, 2019),
                                      ticks = FALSE,
                                      sep = ""
                                       ),
                          )
                          ),
                        
                        # Show a plot
                        
                        fluidRow(
                          plotOutput("astroPlot")
                          ),
                        
                        br(),
                        
                        fluidRow(
                          column(width = 6, plotOutput("agePlot")),
                          column(width = 6, plotOutput("nationalityPlot"))
                          
                          )),
               
               
               tabPanel("Chronology of Missions",
                        h4("The data below shows a chronology of astronaut missions. The year and mission title are included, as well as the count of the number of astronauts associated with the mission."),
                        fluidRow(
                          column(width = 12,
                                 align = "center",
                                 sliderInput("dateRange2", "Selection Mission Year Range:",
                                             min = 1961,
                                             max = 2019,
                                             value = c(1961, 2019),
                                             ticks = FALSE,
                                             sep = ""
                                             ),
                        )
                        ),
                        
                        # Show a plot
                        
                        fluidRow(
                          column(width = 12, plotOutput("missionPlot"))
                          ),
               )
    )
)
)