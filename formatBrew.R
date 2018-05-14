library(readr)

brew <- read_delim("~/Dropbox/2017-2018/ChicagoBreweryProject/breweries.txt", "\t", escape_double = FALSE, col_names = FALSE, trim_ws = TRUE)
colnames(brew) <- c('brewery', 'brewID', 'address', 'city', 'state', 'neighborhood', 'website', 'features')
address <- read_csv("~/Dropbox/2017-2018/ChicagoBreweryProject/GeocodeResults.csv", col_names = FALSE)
colnames(address) <- c('brewID', 'fulladdress', 'matchVal', 'matchType', 'geoAddress', 'coord', 'coord2', 'sth')

brew <- merge(brew, address, by='brewID', all.x=T)
brew[,c(9:12, 15)] <- NULL


brew$inChicago <- ifelse(brew$city == "Chicago", "yes", "no")
brew$latitude <- gsub('-[0-9]*.[0-9]*,','', brew$coord)
brew$longitude <- gsub(',[0-9]*.[0-9]*','', brew$coord)
brew$features <- gsub('TR', 'taproom', brew$features)
brew$hasTapRoom <-ifelse(grepl("taproom", brew$features), "yes", "no")
brew$hasTour <- ifelse(grepl("T", brew$features), "yes", "no")
brew$hasKitchen <- ifelse(grepl("K", brew$features), "yes", "no")

write.csv(brew, "~/Dropbox/2017-2018/ChicagoBreweryProject/breweries_final.csv", quote=T, row.names=F)