library(XLConnect)
library(tidyverse)
library(chron)
library(reshape2)

tempFile <- tempfile()
download.file("https://github.com/eurostat/ICW/blob/master/VAT/data/vat_rates_en.xls", destfile = tempFile)

## alternatively, download the file, directly from the EC website
#download.file("https://ec.europa.eu/taxation_customs/sites/taxation/files/resources/documents/taxation/vat/how_vat_works/rates/vat_rates_en.xls", destfile = tempFile)

reducedVAT <- readWorksheetFromFile(tempFile, sheet = "Reduced VAT rates in Annex III", startRow = 4)

reducedVAT <- reducedVAT %>%
  fill(Col1, .direction = "down") %>%
  fill(Category, .direction = "down")

reducedVAT <- reducedVAT[1:75, ]

rdVAT <- melt(reducedVAT, id.vars = c("Col1","Category"))
rdVAT <- filter(rdVAT,
                !is.na(value))

rdVAT <- rdVAT[!duplicated(paste0(rdVAT$variable, rdVAT$Col1)),]
rdVAT <- mutate(rdVAT,
                value = gsub(",", ".",value))

## current VAT rates

VATrates <- readWorksheetFromFile(tempFile, sheet = "List of VAT rates applied", startRow = 3, startCol = 5)
VATrates <- mutate(VATrates,
                   superRed = as.numeric(gsub(",", ".", Super.reduced.Rate)),
                   std = as.numeric(gsub(",", ".", Standard.Rate)),
                   Reduced.Rate = gsub(",", ".", Reduced.Rate))
completeVector <- function(v,l) {
  if (length(v) < l)
    v <- c(v, rep(NA, l - length(v)))
  return(v)
}
rdRt <- strsplit(VATrates$Reduced.Rate, "/")
lmax <- max(unlist(lapply(rdRt, length)))
completeV <- function(v) {
  completeVector(v, lmax)
}
rdRt <- lapply(rdRt, completeV)

rdRt <- do.call("rbind", rdRt)
VATrates$red1 <- as.numeric(rdRt[,1])
VATrates$red2 <- as.numeric(rdRt[,2])

## determine what is zero rate/super-reduced rate/reduced rate/standard rate

rdVAT <- merge(rdVAT, VATrates[, c(1,6:9)], by.x = "variable", by.y = "Code")

rdVAT <- mutate(rdVAT,
                rate = as.numeric(value),
                VAT_rate = ifelse(substr(value,1,4) == "[ex]", "EXEMP",
                                  ifelse(value == "0", "ZERO",
                                         ifelse(!is.na(rate) & !is.na(superRed) & rate == superRed, "SUPER",
                                                ifelse(!is.na(rate) & !is.na(red1) & rate == red1, "RED1",
                                                       ifelse(!is.na(rate) & !is.na(red2) & rate == red2, "RED2",
                                                              ifelse(!is.na(rate) & rate == std, "STD", "STD")))))))
## history

VAThist <- readWorksheetFromFile("vat_rates_en.xls", sheet = "Evolution of VAT rates", startRow = 4)
country <- readWorksheetFromFile("vat_rates_en.xls", sheet = "List of VAT rates applied", startRow = 3, startCol = 4, endCol = 5, endRow = 31)

# patch for Slovakia
VAThist <- mutate(VAThist,
                  MEMBER.STATES.AND.DATES = ifelse(MEMBER.STATES.AND.DATES == "Slovak Republic", "Slovakia", MEMBER.STATES.AND.DATES))

VAThist$n_ <- 1:nrow(VAThist)
VAThist <- merge(country, VAThist, by.x = "Member.States", by.y = "MEMBER.STATES.AND.DATES", 
                 all.y = TRUE, sort = FALSE)

VAThist <- VAThist[order(VAThist$n_),]
VAThist <- VAThist %>%
  fill(Code)
VAThist <- filter(VAThist,
                  !is.na(STANDARD.RATE))
VAThist <- mutate(VAThist,
                  year = substr(Member.States,1,4), 
                  REDUCED.RATE = gsub(",",".", REDUCED.RATE),
                  std = as.numeric(STANDARD.RATE))
rdRt <- strsplit(VAThist$REDUCED.RATE, "\\| ")
lmax <- max(unlist(lapply(rdRt, length)))
rdRt <- lapply(rdRt, completeV)

rdRt <- do.call("rbind", rdRt)
VAThist <- cbind(VAThist, rdRt)
names(VAThist)[10:15] <- paste0("rdRt", names(VAThist)[10:15])

VAThist <- VAThist[,c(2,8:15)]
VAThist <- mutate(VAThist,
                  rdRt1 = as.character(rdRt1),
                  rdRt2 = as.character(rdRt2),
                  rdRt3 = as.character(rdRt3),
                  rdRt4 = as.character(rdRt4),
                  rdRt5 = as.character(rdRt5),
                  rdRt6 = as.character(rdRt6),
                  rdRt1 = gsub("-",NA,rdRt1),
                  STD = std,
                  SUPER = ifelse(as.numeric(rdRt1) < 5, as.numeric(rdRt1), NA),
                  RED1 = ifelse(is.na(SUPER), as.numeric(rdRt1), as.numeric(rdRt2)),
                  RED2 = ifelse(is.na(SUPER) < 5, as.numeric(rdRt3), as.numeric(rdRt2)))

VAThist <- VAThist[,c(1:2,10:13)]
save(VAThist, file = "VAThist.RData")

year <- 2010

VATSelec <- VAThist[VAThist$year <= year,]
VATSelec <- VATSelec %>%
  group_by(Code) %>%
  filter(year == max(year))

## import correspondence coicop-reduced rate

tempFile <- tempfile()
download.file("https://github.com/eurostat/ICW/blob/master/VAT/data/listCOICOP_withRATE.xls", destfile = tempFile)

lvl1 <- readWorksheetFromFile(tempFile, sheet = "LEVEL1")
lvl2 <- readWorksheetFromFile(tempFile, sheet = "LEVEL2")
lvl3 <- readWorksheetFromFile(tempFile, sheet = "LEVEL3")
lvl4 <- readWorksheetFromFile(tempFile, sheet = "LEVEL4")

names(lvl1) <- paste0(names(lvl1), "_LEVEL1")
names(lvl2) <- paste0(names(lvl2), "_LEVEL2")
names(lvl3) <- paste0(names(lvl3), "_LEVEL3")
names(lvl4) <- paste0(names(lvl4), "_LEVEL4")

lvl4 <- mutate(lvl4,
               CODE_LEVEL1 = substr(CODE_LEVEL4, 1, 2),
               CODE_LEVEL2 = substr(CODE_LEVEL4, 1, 3),
               CODE_LEVEL3 = substr(CODE_LEVEL4, 1, 4))

lvl4 <- merge(lvl4, lvl1)
lvl4 <- merge(lvl4, lvl2)
lvl4 <- merge(lvl4, lvl3)

lvl4 <- mutate(lvl4,
               VAT = ifelse(!is.na(VAT_LEVEL1), VAT_LEVEL1, 
                            ifelse(!is.na(VAT_LEVEL2), VAT_LEVEL2,
                                   ifelse(!is.na(VAT_LEVEL3), VAT_LEVEL3,
                                          ifelse(!is.na(VAT_LEVEL4), VAT_LEVEL4, NA)))))

coicopVAT <- merge(lvl4[,c(5:6,17)], country)
coicopVAT <- merge(coicopVAT, rdVAT[, c(1:3,10)], by.x = c("Code","VAT"), by.y = c("variable","Col1"), all.x = TRUE)

coicopVAT <- coicopVAT[order(coicopVAT$Code, coicopVAT$CODE_LEVEL4),]

coicopVAT <- mutate(coicopVAT,
                    VAT_rate = ifelse(substr(CODE_LEVEL4,1,3) %in% c("041","042","063") | substr(CODE_LEVEL4,1,2) == "10", "EXEMP",
                                      ifelse(is.na(VAT_rate), "STD", VAT_rate)))

save(coicopVAT, file = "coicopVAT.RData")


