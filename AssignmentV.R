#######################################################
########## Assignment V ###############################
#######################################################

# Rate limit is 5000 per day and 5 per second, so we will need to put in a pause-timer

########################################
# 3. Interact with the API - Basics
########################################

# Load the packages needed to interact with APIs using R

library(httr)

# Perform a first GET request, that searches for event venues in Germany (countryCode = "DE"). Extract
# the content from the response object and inspect the resulting list. Describe what you can see.

event_location <- GET(url = "https://app.ticketmaster.com/discovery/v2/venues?apikey=7elxdku9GGG5k8j0Xm8KWdANDgecHMV0&locale=*&countryCode=DE")

event_DE <- jsonlite::fromJSON(content(event_location, as = "text"))
