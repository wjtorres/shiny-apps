#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(forcats)
library(showtext)

# open showtext
showtext_opts(dpi = 300)
showtext_auto(enable = TRUE)

font_add_google(name = "Lato", family = "lato")


# my theme

# save my colors
darkgrey <- "#2F4F4F"
white <- "#FFFFFF"
grey <- "#DCDCDC"

# create my custom theme
my_theme <-  theme(
    # title
    plot.title = element_text(family = "lato", size = 5, hjust = 0, color = darkgrey),
    
    # axis
    axis.text = element_text(family = "lato", size = 3, color = darkgrey),
    axis.title = element_text(family = "lato", size = 3, color = darkgrey),
    
    # plot background
    plot.background = element_rect(fill = white),
    panel.background = element_rect(fill = white),
    
    # panel grid
    panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                    colour = grey), 
    panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                    colour = grey),
    
    # legend
    legend.title = element_blank(),
    legend.text = element_text(size = 4, color = darkgrey),
    legend.position = "bottom"
    
    )


# Define server logic 
shinyServer(function(input, output) {
    
    # get data in app
    my_data <- readr::read_csv(here::here("astronauts.csv"))
    
    # compute new variables
    
    astronauts <- my_data %>%
        filter(!is.na(mission_title)) %>%
        group_by(name) %>%
        arrange(year_of_mission) %>%
        mutate(year_of_first_mission = first(year_of_mission),
               age_at_mission = year_of_mission - year_of_birth,
               year_and_mission_title = paste(year_of_mission, sep = "-", mission_title)) %>%
        ungroup()
    
    
    # component 1 table
    
    output$astronautTable <- DT::renderDataTable({
        
        astronauts %>%
        select(name, sex, nationality, year_of_first_mission, total_number_of_missions, total_hrs_sum) %>%
        unique() %>%
        arrange(name) %>%
        DT::datatable(rownames = FALSE,
                      colnames = c("Name",
                                   "Sex",
                                   "Nationality",
                                   "Year of First Mission",
                                   "Total Number of Missions",
                                   "Total Duration of All Missions (in Hours)"),
                      filter = "top",
                      options = 
                          list(
                              lengthMenu = list(c(15, 50, 100, 200, 300, -1), c('15', '50', '100', '200', '300', 'All')),
                              pageLength = 15))
    })
    
    # component 2 plots
    
    # astronauts launched plot
    
    output$astroPlot <- renderPlot({
        
        astronauts %>%
            filter(year_of_mission %in% input$dateRange[1]:input$dateRange[2]) %>%
            ggplot(aes(x = year_of_mission, fill = sex)) +
            geom_bar(position = "dodge") +
            
            # axis
            scale_fill_manual(values=c("#4cff4c", "#50B0E8")) +
            scale_x_continuous(breaks = seq(1961, 2019, 3)) +
            
            # labs
            labs(title = "Astronauts Launched Per Year",
                 y = "Numberof Astronauts Launched Per Year",
                 x = "Year"
            ) +
            
            # use my theme
            my_theme
            
    })
    
    
    # year of birth bar plot
    output$agePlot <- renderPlot({

        astronauts_age <- astronauts %>%
            filter(year_of_mission %in% input$dateRange[1]:input$dateRange[2])
        
        astronauts_age %>%
            ggplot(aes(x = age_at_mission)) +
            
            # add a bar plot
            geom_bar(fill = "#50B0E8") +
            
            # add a vertical line at the mean
            geom_vline(
                xintercept = mean(astronauts_age$age_at_mission),
                linetype = "solid",
                color = "#548080",
                size = 1) +
            
            # annotate mean value
            annotate(
                "text",
                x = mean(astronauts_age$age_at_mission) + 3.5,
                y = 100,
                label = paste("Mean age =", round(mean(astronauts_age$age_at_mission), 1)),
                angle = 0,
                color = "#548080",
                size = 1
            ) +
            
            # labs
            labs(title = "Age of Astronauts at Mission",
                 y = "Numberof Astronauts",
                 x = "Age at Mission"
            ) +
            
            # use my theme
            my_theme
        
    })
    
    # nationality plot
    output$nationalityPlot <- renderPlot({
        
        astronauts %>%
            filter(year_of_mission %in% input$dateRange[1]:input$dateRange[2]) %>%
            select(nationality) %>%
            mutate(nationality = fct_lump_min(nationality, min = 10, other_level = "Other")) %>%
            count(nationality) %>%
            ggplot(aes(x = reorder(nationality, n), y = n)) +
            geom_bar(stat = "identity", fill = "#50B0E8") +
            
            # labs
            labs(title = "Nationality",
                 y = "Numberof Astronauts",
                 x = NULL
            ) +
            
            # use my theme
            my_theme +
        
            # flip coord
            coord_flip()
    })
    
    # component 3 plots
    
    # missions
    
    output$missionPlot <- renderPlot({
        astronauts %>%
            filter(year_of_mission %in% input$dateRange2[1]:input$dateRange2[2]) %>%
            ggplot(aes(x = reorder(year_and_mission_title, desc(year_and_mission_title)))) +
            geom_bar(fill = "#50B0E8") +
            geom_text(stat='count', aes(label=..count..), hjust = 0, size = 1, color = "#548080") +

            # axis
            scale_y_continuous(breaks = seq(0, 10, 1)) +
            
            # labs
            labs(title = "Year, Mission Name, and the Number of Astronauts Who Participated in the Mission",
                 y = "Numberof Astronauts",
                 x = NULL
            ) +
    
            # use my theme
            my_theme +
            
            # flip coord
            coord_flip()
            
        
        },
        height = 6000, 
        width = 1500)

})
