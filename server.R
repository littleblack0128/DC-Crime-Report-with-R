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


shinyServer(function(input, output) {

  color <- colorFactor(topo.colors(7), crime_data$OFFENSE)  
  
  output$map <- renderLeaflet({
      filtered<-crime_data %>%
        filter(OFFENSE %in% input$offense,
               SHIFT %in% input$shift,
               METHOD %in% input$method)
      leaflet(filtered) %>%
        #set view of DC
        setView(lng = -77.03637, lat = 38.89511, zoom = 12)%>%
        addProviderTiles("OpenStreetMap.Mapnik") %>%
        addCircleMarkers(
          lng=~LONGITUDE, # Longitude coordinates
          lat=~LATITUDE, # Latitude coordinates
          clusterOptions = markerClusterOptions(),
          popup=as.character(filtered$BLOCK),
          radius=2,
          fillOpacity=0.5, # Circle Fill Opacity
          color ="purple")%>%
        addLegend(
          "bottomleft", # Legend position
          pal=color, # color palette
          values=~OFFENSE, # legend values
          opacity = 1,
          title="Type of Crime OFFENSE") 
    })
  
    output$plotShift<-renderPlot({
        Shift<-as.data.frame(table(crime_data$SHIFT))
        Shift <-
          Shift %>% 
          arrange(-Freq)
        colnames(Shift) <- c("Time Of Day", "COUNT")
        Shift$`Time Of Day` <- factor(Shift$`Time Of Day`, levels=c('DAY','EVENING','MIDNIGHT'))
        Shift[order(Shift$`Time Of Day`),]
        ggplot(Shift, aes(x=`Time Of Day`,y=COUNT)) +
          geom_bar(stat="identity",alpha = 0.5,color = 'lightblue', fill='lightblue') +
          ggtitle("Number of Crimes by Shift") +
          geom_text(aes(label = Shift$COUNT), size = 4,  hjust = 0.6, color = "black")+
          theme(axis.title=element_text(size=12),
                axis.text.x = element_text(face = 'bold', size=12, angle = 45, hjust = 1))
      })
    
    output$plotMethod<-renderPlot({
      Method<-as.data.frame(table(crime_data$METHOD))
      Method <-
        Method %>% 
        arrange(-Freq)
      colnames(Method) <- c("Type of Methods", "COUNT")
      Method$`Type of Methods` <- factor(Method$`Type of Methods`, levels=c('GUN','KNIFE','OTHERS'))
      Method[order(Method$`Type of Methods`),]
      ggplot(Method, aes(x=`Type of Methods`,y=COUNT)) +
        geom_bar(stat="identity",alpha = 0.5,color = 'lightblue', fill='lightblue') +
        ggtitle("Number of Crimes by Method") +
        geom_text(aes(label = Method$COUNT), size = 4,  hjust = 0.6, color = "black")+
        theme(axis.title=element_text(size=12),
              axis.text.x = element_text(face = 'bold', size=12, angle = 45, hjust = 1)
        )
    })
    
    output$plotWeekday<-renderPlot({
      Weekday<-as.data.frame(table(crime_data$weekd))
      Weekday <-
        Weekday %>% 
        arrange(-Freq)
      colnames(Weekday) <- c("Weekdays", "COUNT")
      Weekday$`Type of Weekday` <- factor(Weekday$`Weekdays`, 
                                  levels=c('Friday','Monday','Saturday','Sunday','Thursday','Tuesday','Wednesday'))
      Weekday[order(Weekday$`Weekdays`),]
      ggplot(Weekday, aes(x=`Weekdays`,y=COUNT)) +
        geom_bar(stat="identity",alpha = 0.5,color = 'lightblue', fill='lightblue') +
        ggtitle("Number of Crimes by Weekday") +
        geom_text(aes(label = Weekday$COUNT), size = 4,  hjust = 0.6, color = "black")+
        theme(axis.title=element_text(size=12),
              axis.text.x = element_text(face = 'bold', size=12, angle = 45, hjust = 1)
        )
    })
    
    output$plotDistrict<-renderPlot({
      District<-as.data.frame(table(crime_data$DISTRICT))
      District <-
        District %>% 
        arrange(-Freq)
      colnames(District) <- c("Districts", "COUNT")
      District$`Districts` <- factor(District$`Districts`, 
                                          levels=c('1','2','3','4','5','6','7'))
      District[order(District$`Districts`),]
      ggplot(District, aes(x=`Districts`,y=COUNT)) +
        geom_bar(stat="identity",alpha = 0.5,color = 'lightblue', fill='lightblue') +
        ggtitle("Number of Crimes by District") +
        geom_text(aes(label = District$COUNT), size = 4,  hjust = 0.6, color = "black")+
        theme(axis.title=element_text(size=12),
              axis.text.x = element_text(face = 'bold', size=12, angle = 45, hjust = 1)
        )
    })
    
    output$table <- renderTable({
      offense<-as.data.frame(table(crime_data$OFFENSE))
      offense <-
        offense %>% 
        arrange(-Freq)
      colnames(offense) <- c("OFFENSE", "COUNT")
      offense
    })
    
    output$data <- DT::renderDataTable ({
      da<-crime_data[
        c("CCN","REPORT_DAT","SHIFT",
          "METHOD","OFFENSE","BLOCK","DISTRICT")]
      datatable(da ,options = list(c(scrollY="200px", scrollX="300px", pageLength = 100)),  filter = 'top')
    })
    
    output$summary<-renderPrint({
      da<-crime_data[
        c("CCN","REPORT_DAT","SHIFT",
          "METHOD","OFFENSE","BLOCK","DISTRICT")]
      summary(da)
    })
  
})




