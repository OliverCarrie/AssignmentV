#######################################################
########## Assignment V ###############################
#######################################################

# Rate limit is 5000 per day and 5 per second, so we will need to put in a pause-timer

########################################
# 3. Interact with the API - Basics
########################################

# Load the packages needed to interact with APIs using R

if (!require("jsonlite")) install.packages("jsonlite")
if (!require("httr")) install.packages("httr")
if (!require("rlist")) install.packages("rlist")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("naniar")) install.packages("naniar")

library(jsonlite)
library(httr)
library(rlist)
library(tidyverse)
library(naniar)

# Perform a first GET request, that searches for event venues in Germany (countryCode = "DE"). Extract
# the content from the response object and inspect the resulting list. Describe what you can see.

source("C:/Users/olica/OneDrive/Dokumente/Uni Tübingen/WS 21-22/DS400 - Data Science Project Management/Assignments/AssignmentV/API_Keys.R")

APIcontent <- GET(url = "https://app.ticketmaster.com/discovery/v2/venues?",
                  query = list(apikey = API_Key,
                               locale = "*",
                               countryCode = "DE"
                               ))

# Extract the name, the city, the postalCode and address, as well as the url and the longitude and latitude of the venues to a data frame.

## Get the content from the list
event_DE <- jsonlite::fromJSON(content(APIcontent, as = "text"))

## Flatten list to eliminate the nested data
venue_data <- flatten(event_DE)

## Convert data to dataframe
venue_data <- as.data.frame(venue_data$venues)

## Only select necessary columns
venue_data <- select(venue_data, name, city, postalCode, address, url, location)

## Unnest the dataframe further, because we have nested data in the df. Then change the names of the df.
venue_data <- venue_data %>% unnest(c(location, city, address), names_repair = "minimal")
colnames(venue_data) <- c("name", "city", "postalCode", "address", "url", "longitude", "latitude")
venue_data$longitude <- as.double(venue_data$longitude)
venue_data$latitude <- as.double(venue_data$latitude)

# Have a quick look to compare the df with the given data from the assignment
glimpse(venue_data)

##########################################################
# 4. Interacting with the API - advanced
##########################################################


## Check the API documentation under the section Venue Search. How can you request the venues from
## the remaining results pages?

### There is the option in the parameters to select the page that you want to get. In total, there are 629 pages with 12568 elements.
### What does that tell us? We have 628 pages with 20 entries and one page with less entries.

## Write a for loop that iterates through the results pages and performs a GET request for all venues
## in Germany. After each iteration, extract the seven variables name, city, postalCode, address, url,
## longitude, and latitude. Join the information in one large data frame.


### Total results (from website)
n <- 12568

### Entries per page
entries_per_page <- 20

### Number of complete pages
pages <- floor(n/entries_per_page)

### Number of entries on last imcomplete page
remainder <- n - pages*entries_per_page

### Now we create a dataframe

venue_data_long <- tibble(
  name = character(n),
  city = character(n),
  postalCode = character(n),
  address = character(n),
  url = character(n),
  longitude = double(n),
  latitude = double(n)
  )

for (i in 1:pages) {
  search_result <- GET(url = "https://app.ticketmaster.com/discovery/v2/venues?",
                                     query = list(apikey = API_Key,
                                                  locale = "*",
                                                  countryCode = "DE",
                                                  page = i))
  
  search_content <- fromJSON(content(search_result, as = "text"))
  
  search_content <- flatten(search_content)
  
  search_content <- as.data.frame(search_content$venues)
  
  if (exists(search_content$location == TRUE)){
    search_content <- select(search_content, name, city, postalCode, address, url, location)
    
    search_content <- search_content %>% unnest(c(location, city, address), names_repair = "minimal")
    colnames(search_content) <- c("name", "city", "postalCode", "address", "url", "longitude", "latitude")
    search_content$longitude <- as.double(search_content$longitude)
    search_content$latitude <- as.double(search_content$latitude)
    
    venue_data_long[(20*i-19):(20*i),] <- search_content %>%
      select(name, city, postalCode, address, url, longitude, latitude)
    
    Sys.sleep(0.2)    
  }
  else{
    venue_data_long[(20*i-19):(20*i),] <- search_content %>%
      select(name, city, postalCode, address, url, longitude, latitude)
    
    Sys.sleep(0.2)    
  }

}





# Map Of Germany

# Eliminate values that are outside of range


ggplot() +
  geom_polygon(
    aes(x = long, y = lat, group = group), data = map_data("world", region = "Germany"),
    fill = "grey90",color = "black") +
  geom_point(data = venue_data, aes(x = longitude, y = latitude)) +
  theme_void() + coord_quickmap() +
  labs(title = "Event locations across Germany", caption = "Source: ticketmaster.com") +
  theme(title = element_text(size=8, face='bold'),
        plot.caption = element_text(face = "italic"))





#######################################################
########## Latvia #####################################
#######################################################

APIcontent_LV <- GET(url = "https://app.ticketmaster.com/discovery/v2/venues?",
                     query = list(apikey = API_Key,
                                  locale = "*",
                                  countryCode = "LV"))

# Extract the name, the city, the postalCode and address, as well as the url and the longitude and latitude of the venues to a data frame.

## Get the content from the list
event_LV <- jsonlite::fromJSON(content(APIcontent_LV, as = "text"))

## Flatten list to eliminate the nested data
venue_data_LV <- flatten(event_LV)

## Convert data to dataframe
venue_data_LV <- as.data.frame(venue_data_LV$venues)

## Only select necessary columns
venue_data_LV <- select(venue_data_LV, name, city, postalCode, address, url, location)

## Unnest the dataframe further, because we have nested data in the df. Then change the names of the df.
venue_data_LV <- venue_data_LV %>% unnest(c(location, city, address), names_repair = "minimal")
colnames(venue_data_LV) <- c("name", "city", "postalCode", "address", "url", "longitude", "latitude")
venue_data_LV$longitude <- as.double(venue_data_LV$longitude)
venue_data_LV$latitude <- as.double(venue_data_LV$latitude)

# Have a quick look to compare the df with the given data from the assignment
glimpse(venue_data_LV)



# Map Of Latvia

# Two datapoint are located outside of Latvia, I will have to remove them.

venue_data_LV_clean <- filter(venue_data_LV, longitude != 0.00000 )

ggplot() +
  geom_polygon(
    aes(x = long, y = lat, group = group), data = map_data("world", region = "Latvia"),
    fill = "grey90",color = "black") +
  geom_point(data = venue_data_LV_clean, aes(x = longitude, y = latitude)) +
  theme_void() + 
  coord_quickmap() +
  labs(title = "Event locations across Latvia", caption = "Source: ticketmaster.com") +
  theme(title = element_text(size=8, face='bold'),
        plot.caption = element_text(face = "italic"))

