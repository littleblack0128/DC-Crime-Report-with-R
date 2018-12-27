# DC-Crime-Report-with-R

Introduction

How to be less exposed to crime? I investigate this question by using a data set called “Crime Incidents in the Last 30 Days”. It contains 2,691 crime reports with locations and attributes of incidents reported by the District of Columbia Metropolitan Police Department from 11/09/2017 to 12/09/2017. This dataset will help me in exploring this question. Safety is always a primary concern for all. The further analysis will benefit residents in DC and visitors who recently are planning to visit DC.

Workflow Documentation

The dataset can be obtained from http://opendata.dc.gov/datasets/crime-incidents-in-the-last-30-days. With this dataset, I created a shiny app called “Crime Reports Analysis”. Before developing the app, I started with processing the data. The first step was checked if columns contain null value. I dropped the column BID contained 2,233 rows of null value and rows that contain null values. Then I found the report date column, REPORT_DAT, contains not only Y-m-d but also H-m-s. Hence, I created a new column called as REPORT_DATE contained only Y-m-d, and added a new column that contained weekdays of REPORT_DATE for the following analysis. For better layout, I used dashboard page with three tabs, which looked more professional than the default. Next, for the first dashboard tab, I added a crime map by using leaflet. The map interacted with user’s input for offense, shift, and method. If you zoomed in and clicked on the point, you would see the detailed address. The second dashboard tab showed frequency plot and table for shift, method, weekday, district, and offense. The last dashboard tab showed the data with selected columns due to space limitation, and a summary for those columns. Please library packages at the first few rows in the R files before running the app.

Findings

After browsing the shiny application, I found the following findings:
1.	Crime most happened around Columbia Heights.
2.	Crime most happened in Evening, and the following was day time.
3.	Crime happened in DC most used other methods other than gun and knife
4.	Fridays was the dangerous weekday, and the following was Saturday.
5.	Districts 1, 3, and 5 had the most crime reports.
6.	Theft/Other was the most common offense.

Advice

For residents and recent visitors in DC, I advise trying to avoid being around Columbia Heights, districts 1, 3, and 5 at night on Fridays. In addition, please try to store your valuables safe. Lastly, in the worst-case scenario, if a crime happened to you, please remember to report it to the police. I hope you will have a good time in DC. 

Youtube Link
https://www.youtube.com/watch?v=VTUa1dFyfak&feature=youtu.be
