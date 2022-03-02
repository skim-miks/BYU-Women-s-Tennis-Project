install.packages("RMySQL")
library(RMySQL)


con <- dbConnect(MySQL(),
                 dbname = "",
                 user = "", 
                 password = "", 
                 host = "")

rs <- dbSendQuery(con, "SELECT * FROM WomensTennisStats;")
womenstennis <- fetch(rs, n=-1)

dbListTables(con)
cnames <- dbListFields(con,"WomensTennisStats")

# combine 2013 data
tennis <- read.csv("tennisPointData2013Pre.csv", header=TRUE)
library(data.table)
tennis$PointID <- NA
orderCols <- c(21,1:20)
tennis <- tennis[,orderCols]
colnames(tennis) <- cnames
womenstennis <- rbind(tennis[4358:7108,],womenstennis)
dbWriteTable(con, name = "WomensTennisStats", overwrite = TRUE, value=womenstennis, row.name=FALSE)
dbDisconnect(con)


womenstennis <- womenstennis[womenstennis$PointResult %in% c("U","F","W"),]
womenstennis <- womenstennis[womenstennis$ShotType %in% c("T","D","S","L","O","V"),]
womenstennis <- womenstennis[womenstennis$Returns %in% c("C","L"),]
womenstennis$Comment <- NULL
womenstennis$PointLength <- NULL
womenstennis$PointID <- NULL
womenstennis$MatchID <- NULL
womenstennis$ErrorPosition <- NULL

womenstennis <- droplevels(womenstennis[womenstennis$ForeBack == "F" | womenstennis$ForeBack == "B",])
womenstennis <- droplevels(womenstennis[womenstennis$CrossLine == "C" | womenstennis$CrossLine == "L",])
womenstennis <- droplevels(womenstennis[womenstennis$ShotType == "T" | womenstennis$ShotType == "V" | womenstennis$ShotType == "O" | womenstennis$ShotType == "S" | womenstennis$ShotType == "L" | womenstennis$ShotType == "D",])

# Points Won by BYU Player
PlayerWinData <- womenstennis[womenstennis$PointWinner == "P",]
# Points Won by Opponent
OpponentWinData <- womenstennis[womenstennis$PointWinner == "O",]


# Unforced Errors model
OpponentWinData$UF <- ifelse(OpponentWinData$PointResult == "U", 1, 0)
OpponentWinData <- na.omit(OpponentWinData)
library(lme4)
summary(glmer(UF ~ ShotType + ForeBack + CrossLine + (1|PlayerID), data = OpponentWinData, family = binomial))

# Winners model
PlayerWinData$W <- ifelse(PlayerWinData$PointResult == "W", 1, 0)
PlayerWinData <- na.omit(PlayerWinData)
summary(glmer(W ~ ShotType + ForeBack + CrossLine + (1|PlayerID), data = PlayerWinData, family = binomial))




