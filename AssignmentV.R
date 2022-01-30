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

# Perform a first GET request, that searches for event venues in Germany (countryCode = "DE"). Extract
# the content from the response object and inspect the resulting list. Describe what you can see.

APIcontent <- GET(url = "https://app.ticketmaster.com/discovery/v2/venues?apikey=7elxdku9GGG5k8j0Xm8KWdANDgecHMV0&locale=*&countryCode=DE")


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

# Have a quick look to compare the df with the given data from the assignment
glimpse(venue_data)

##########################################################
# 4. Interacting with the API - advanced
##########################################################

## Check the API documentation under the section Venue Search. How can you request the venues from
## the remaining results pages?