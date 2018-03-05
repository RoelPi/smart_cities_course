library(data.table)
library(lubridate)
setwd('C:/Users/roel/Google Drive/Data Science/MADAS/15_Smart_Cities/Rossi/Lecture_1')

getFiles <- function(pat,folder) {
    files <- list.files(path=folder,pattern=pat)
    for (i in 1:length(files)) {
        print(paste('Reading file',files[i]))
        if (i == 1) {
            dt <- data.table(read.csv(paste0(folder,'/',files[i]),sep=',',header=F,dec='.'))
        } else {
            dt <- rbind(dt,data.table(read.csv(paste0(folder,'/',files[i]),sep=',',header=F,dec='.')))
        }
    }
    dt
}

air_quality <- getFiles('mi_pollution','data/MI_Air_Quality/data')
names(air_quality) <- c('station','timestamp','count')
air_quality <- air_quality[station != 10273]
air_quality <- air_quality[,timestamp := ymd_hm(timestamp)]
air_quality_legend <- read.csv('data/MI_Air_Quality/pollution-legend-mi.csv',sep=',', header=F)
names(air_quality_legend) <- c('station','geo','latitude','longitude','sensor_type','unit','time_format')
air_quality <- merge(air_quality,air_quality_legend,by = 'station',all.x=T)
rm(air_quality_legend)

# How many pollutants are there?
print(paste0('There are ',length(unique(air_quality)), ' pollutants.'))

# How many sensors do we have for each pollutants?
sensors_per_pollutant <- air_quality[,.(sensors = length(unique(station))),by=.(sensor_type)]
ggplot(sensors_per_pollutant, aes(x=sensor_type,y=sensors)) + geom_bar(stat='identity')


# Where are the sensors located?
sensors_per_street <- air_quality[,.(sensors = length(unique(station))),by=.(geo)]
s <- ggplot(sensors_per_street, aes(x=geo,y=sensors)) + geom_bar(stat='identity')

meteo <- getFiles('mi_meteo','data/MI_Weather_Station_Data/data')
names(meteo) <- c('station','timestamp','count')
meteo_legend <- read.csv('data/MI_Weather_Station_Data/mi_meteo_legend.csv',sep=',',header=F)
names(meteo_legend) <- c('station','geo','latitude','longitude','sensor_type','unit')
meteo_legend$station <- as.factor(meteo_legend$station)
meteo <- merge(meteo,meteo_legend,by='station',all.x=T)
rm(meteo_legend)
