#Please load these packages before running the app
library(shiny)
library(shinythemes)
library(leaflet)
library(rgdal)
library(magrittr)
library(htmltools)
library(shinydashboard)
library(leaflet)
library(dplyr) #data processing
library(data.table)
library(zoo)
library(stringr)
library(ggplot2)
library(flexdashboard)
library(DT)

#set working directory
setwd("/Users/Keroro/Downloads")

#load the data, convert null value to NA
crime_data<-read.csv("Crime_Incidents_in_the_Last_30_Days.csv",
                     stringsAsFactors = FALSE, header = TRUE, 
                     na.strings = c("", " ", "NA"))
na_count <-sapply(crime_data, function(y) sum(length(which(is.na(y)))))
na_count <- data.frame(na_count)
na_count
crime_data<-subset(crime_data,select=-BID)
crime_data<-na.omit(crime_data)
#add a new column that contains report date in regular Y-M-D format
crime_data <- crime_data %>%
  mutate(REPORT_DATE = as.Date(str_split_fixed(crime_data$REPORT_DAT, "T", 2)[,1], format = "%Y-%m-%d")) %>%
  mutate(year_month = zoo::as.yearmon(REPORT_DATE))

#convert date to weekdays
crime_data$weekd<-weekdays(as.Date(crime_data$REPORT_DAT))

#convert three columns to factors
crime_data$SHIFT<-as.factor(crime_data$SHIFT)
crime_data$METHOD<-as.factor(crime_data$METHOD)
crime_data$OFFENSE<-as.factor(crime_data$OFFENSE)


shinyUI(dashboardPage(
  dashboardHeader(title="DC Crime Reports",titleWidth = 200),
  dashboardSidebar(width=150, div(
     sidebarMenu(
      menuItem("Map", tabName = "Map", icon = icon("map"),selected = TRUE),
      menuItem("Charts", tabName = "Charts", icon = icon("bar-chart-o")),
      menuItem("Data Explorer", tabName = "DataExplorer", icon = icon("list-alt"))))),
  dashboardBody(tabItems(
     tabItem(tabName="Map",class="active",
            fluidRow(
              column(width=9,
                     box(width=NULL,solidHeader = TRUE,
                         leafletOutput("map",height = 500))),
              column(width=3,
                     box(width = NULL, status="primary",
                         checkboxGroupInput("offense", "Select Offense:", 
                                            levels(crime_data$OFFENSE),selected=levels(crime_data$OFFENSE))),
                     box(width = NULL, status="primary",  
                         checkboxGroupInput("shift", "Select Shift:",
                                            levels(crime_data$SHIFT),selected=levels(crime_data$SHIFT))),
                     box(width = NULL, status="primary",
                         checkboxGroupInput("method", "Select Method:", 
                                            levels(crime_data$METHOD), selected=levels(crime_data$METHOD))),
                     tags$hr()))),
    tabItem(tabName="Charts",fluidRow(
          tabBox(title="Frequency Plot",
               tabPanel("Shift Frequency",plotOutput("plotShift")),
               tabPanel("Method Frequency",plotOutput("plotMethod")),
               tabPanel("Weekday Frequency",plotOutput("plotWeekday")),
               tabPanel("District Frequency",plotOutput("plotDistrict"))),
          box(title="Offense Frequency Table",
               tableOutput("table")))),
    tabItem(tabName="DataExplorer",
          tabsetPanel(type="tabs",tabPanel("Data",DT::dataTableOutput("data")) ,
                                  tabPanel("Summary", verbatimTextOutput("summary"))))
  ))))