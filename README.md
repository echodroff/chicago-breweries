# chicago-breweries

1. Obtain raw data from http://thehopreview.com/blog/chicago-brewery-list. This is in cleanBreweries.txt (clean as in it needs to be cleaned)

2. Run brew.py with cleanBreweries.txt as input and breweries.txt and brewAddress.csv as outputs. Yes, there are some redundant lines of code in there, but we all know this is what happens with incremental updates to the code. breweries.txt simply contains a cleaned up version of the full dataset (though it's not final). brewAddress.csv is formatted for the US Census Geocoder.

3. Submit brewAddress.csv to the US Census Geocoder for the geographic coordinates: https://geocoding.geo.census.gov/geocoder/locations/addressbatch?form
This returns GeocodeResults.csv

4. Run formatBrew.R with breweries.txt and GeocodeResults.csv as input to obtain breweries_final.csv (located in the R Shiny app folder called brews)

5. The directory 'brews/' houses the material to run the Shiny app. app.R reads in breweries_final.csv and outputs the app. To run this in R, run shiny::runApp('pathToShinyApp/app.R'). Note that some additional columns are created in the app itself; at some point, the creation of these should be migrated over to formatBrew.R so that they're present in breweries_final.csv. 



