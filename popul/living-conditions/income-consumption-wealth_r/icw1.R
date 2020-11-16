############################################################################################################
# Scripts for computing figures and generating graphs in Statistics Explained article
# https://ec.europa.eu/eurostat/statistics-explained/index.php/Interaction_of_household_income,_consumption_and_wealth_-_statistics_on_main_results
# Run on R 64-bits 3.3.1

# Please insert the link to the folder where you want the files to be saved
path_results <- "./MainResults"

library(dplyr)
library(haven)
library(Cairo)
library(eurostat)
library(reshape2)
library(xlsx)

col1 <- rgb(250, 165, 25, maxColorValue = 255)
col1_faded <- rgb(251, 200, 117, maxColorValue = 255)
col2 <- rgb(40, 110, 180, maxColorValue = 255)
col2_faded <- rgb(113, 168, 223, maxColorValue = 255)
col3 <- rgb(240, 99, 34, maxColorValue = 255)
col3_faded <- rgb(246, 162, 123, maxColorValue = 255)
col4 <- rgb(185, 195, 30, maxColorValue = 255)
col5 <- rgb(93, 179, 64, maxColorValue = 255)

year <- 2015

path_data <- "//net1.cec.eu.int/ESTAT/F/1/common/04 Income Consumption Wealth/06 Output/joint_distribution/paper/Statistics_Explained"
setwd(path_data)
countryOrder <- read.csv("country_order.csv")

#################################################################################################################################################
### FIGURE 1 (removed)
#################################################################################################################################################

# indicators_NA <- get_eurostat("nasa_10_ki", time_format = "num")
# saving_rate_NA <- filter(indicators_NA,
#                          na_item == "SRG_S14_S15")
# 
# saving_rate_NA_2015 <- filter(saving_rate_NA,
#                               time == 2015)
# 
# indicators_silc <- get_eurostat("ilc_mdes09", time_format = "num")
# indicators_diff <- filter(indicators_silc,
#                           subjnmon %in% c("EM_D","EM_GD") & hhtyp == "TOTAL" & time == 2015 & incgrp == "TOTAL" & !geo %in% c("EU28","EA19"))
# 
# indicators_diff <- indicators_diff %>%
#   group_by(geo) %>%
#   summarise(prop_diff = sum(values))
# 
# figure1 <- merge(saving_rate_NA_2015, indicators_diff)
# names(figure1)[6] <- "saving_rate"
# 
# plot(figure1$prop_diff, figure1$saving_rate, type = "p", pch = 18, col = col1, bty = "n", xaxt="n",yaxt="n", 
#      xlim = c(0,70), ylim = c(-10,25), xlab = NA, ylab = NA)
# grid(nx = NA, ny = NULL)
# axis(1,pos=0)
# axis(2,pos=0, tick = FALSE, las = 1)
# text(figure1$prop_diff, figure1$saving_rate, labels = figure1$geo, cex = 0.7, pos = 3)
# 
# setwd(path_results)
# write.xlsx(figure1,"DataFiguresSE1.xlsx",sheetName = "Figure 1",append = TRUE)

#################################################################################################################################################
### FIGURE 1
#################################################################################################################################################

indicators_pov <- get_eurostat("icw_pov_01", time_format ="num")
indicators_exp <- filter(indicators_pov,
                         lev_expn == "LOW" & yn_rskpov == "TOTAL" & lev_depr == "TOTAL" & workint == "TOTAL" & time == year)
indicators_inc <- filter(indicators_pov,
                         lev_expn == "TOTAL" & yn_rskpov == "YES_ARP" & lev_depr == "TOTAL" & workint == "TOTAL" & time == year)
names(indicators_exp)[8] <- "prop_expn"
names(indicators_inc)[8] <- "prop_inc"
figure1 <- merge(indicators_exp[,c(6,8)], indicators_inc[,c(6,8)])
figure1 <- figure1[order(figure1$prop_inc),]

barplot(t(figure1[,2:3]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("Low levels of expenditure", "Monetary poverty"),
        names.arg = figure1$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure1,"DataFiguresSE1.xlsx",sheetName = "Figure 1",append = TRUE)

#################################################################################################################################################
### FIGURE 2
#################################################################################################################################################

indicators_asset_pov <- get_eurostat("icw_pov_02", time_format = "num")
indicators_asset_pov <- filter(indicators_asset_pov,
                               yn_rskpov == "YES_ARP" & duration %in% c("M1", "M3","M6","M12") & time == year)
indicators_asset_pov <- mutate(indicators_asset_pov,
                               period = as.numeric(substr(duration,2,4)))
indicators_asset_pov <- indicators_asset_pov[order(indicators_asset_pov$geo, indicators_asset_pov$period),]
figure2 <- dcast(indicators_asset_pov, geo+time~period, value.var = "values")
figure2 <- figure2[order(figure2[,3]),]

barplot(t(figure2[,3:6]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("1 month", "3 months", "6 months", "12 months"),
        names.arg = figure2$geo, cex.names = 0.7,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure2,"DataFiguresSE1.xlsx",sheetName = "Figure 2",append = TRUE)

#################################################################################################################################################
### FIGURE 3
#################################################################################################################################################

indicators_dissav <- get_eurostat("icw_pov_03", time_format = "num")
indicators_dissav <- filter(indicators_dissav,
                  hhtype == "NSAV" & time %in% c(year,2010))
figure3 <- dcast(indicators_dissav, geo~time, value.var = "values")
colnames(figure3) <- c("geo","values2010",paste0("values",year))
figure3 <- figure3[order(figure3$values2015),]

barplot(t(figure3[,2:3]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("2010", "2015"),
        names.arg = figure3$geo, cex.names = 0.5, ylim = c(0,70), cex.axis = 0.7,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure3,"DataFiguresSE1.xlsx",sheetName = "Figure 3",append = TRUE)

#################################################################################################################################################
### FIGURE 4
#################################################################################################################################################

indicators_sr <- get_eurostat("icw_sr_01", time_format = "num")
indicators_agg <- get_eurostat("icw_sr_08", time_format = "num")

indicators_agg <- filter(indicators_agg,
                         age == "TOTAL" & time %in% c(year,2010))
indicators_sr <- filter(indicators_sr,
                        age == "TOTAL" & time %in% c(year,2010))
indicators_agg <- mutate(indicators_agg,
                         sr_agg = 100 - values)
indicators_sr <- mutate(indicators_sr,
                        sr_med = values)
#figure6 <- merge(indicators_sr[,c("geo","sr_med")], indicators_agg[,c("geo","sr_agg")])
#figure6 <- figure6[order(figure6$sr_med),]
figure4 <- dcast(indicators_sr, geo~time, value.var = "sr_med")
colnames(figure4) <- c("geo","sr_med2010",paste0("sr_med",year))
figure4 <- figure4[order(figure4$sr_med2015),]

figure4bis <- dcast(indicators_agg, geo~time, value.var = "sr_agg")
colnames(figure4bis) <- c("geo","sr_agg2010",paste0("sr_agg",year))
figure4bis <- figure4bis[order(figure4bis$sr_agg2015),]

#barplot(t(figure6[,2:3]), beside = TRUE, col = c(col1, col2), main = NA,
#        border = NA, legend.text = c("Median saving rate", "Aggregate saving rate"),
#        names.arg = figure6$geo, cex.names = 0.5, ylim = c(-20,50), cex.axis = 0.7,
#        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

barplot(t(figure4[,2:3]), beside = TRUE, col = c(col1, col2), main = NA,
       border = NA, legend.text = c("Median saving rate 2010", "Median saving rate 2015"),
       names.arg = figure4$geo, cex.names = 0.5, ylim = c(-20,50), cex.axis = 0.7,
       args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))
barplot(t(figure4bis[,2:3]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("Aggregate saving rate 2010", "Aggregate saving rate 2015"),
        names.arg = figure4bis$geo, cex.names = 0.5, ylim = c(-20,50), cex.axis = 0.7,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
#write.xlsx(figure6,"DataFiguresSE1.xlsx",sheetName = "Figure 6",append = TRUE)
write.xlsx(figure4,"DataFiguresSE1.xlsx",sheetName = "Figure 4",append = TRUE)
write.xlsx(figure4bis,"DataFiguresSE1.xlsx",sheetName = "Figure 4 - bis",append = TRUE)

#################################################################################################################################################
### FIGURE 5
#################################################################################################################################################

gini_index <- get_eurostat("icw_sr_05", time_format = "num")
gini_index <- filter(gini_index,
                     time == year)
figure5 <- dcast(gini_index, geo+time~stk_flow, value.var = "values")
figure5 <- figure5[order(figure5[,5]),]

barplot(t(figure5[,3:6]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("Income", "Expenditures", "Savings", "Wealth"),
        names.arg = figure5$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure5,"DataFiguresSE1.xlsx",sheetName = "Figure 5",append = TRUE)

#################################################################################################################################################
### FIGURE 6
#################################################################################################################################################

indicators_inter <- get_eurostat("icw_pov_01", time_format = "num")
figure6 <- filter(indicators_inter,
                  (lev_expn == "LOW" | yn_rskpov == "YES_ARP") & lev_depr == "TOTAL" & workint == "TOTAL" & lev_expn != "TOTAL" & yn_rskpov != "TOTAL" & time == year)

figure6 <- dcast(figure6, geo+time~lev_expn+yn_rskpov, value.var = "values")
figure6 <- mutate(figure6,
                  bar1 = LOW_YES_ARP+LOW_NO_ARP+NLOW_YES_ARP,
                  bar2 = LOW_YES_ARP+NLOW_YES_ARP,
                  bar3 = NLOW_YES_ARP)
figure6 <- figure6[order(figure6$bar1),]

figure6 <- figure6[,c("geo","time","NLOW_YES_ARP","LOW_YES_ARP","LOW_NO_ARP","bar1","bar2","bar3")]

barplot(t(figure6$bar1), col = col3, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        names.arg = figure6$geo, cex.names = 0.5)
barplot(t(figure6$bar2), col = col2, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE)
barplot(t(figure6$bar3), col = c(col1, col2, col3), main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE,
        legend.text = c("Only income-poor", "Income-poor and low levels of expenditure",
                        "Not income-poor, low levels of expenditure"), 
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure6,"DataFiguresSE1.xlsx",sheetName = "Figure 6",append = TRUE)

#################################################################################################################################################
### FIGURE 7
#################################################################################################################################################

indicators_inter <- get_eurostat("icw_pov_04", time_format = "num")
figure7 <- filter(indicators_inter,
                  (lev_expn == "LOW" | hhtype == "NSAV") & age == "TOTAL" & lev_expn != "TOTAL" & hhtype != "TOTAL" & time == year)
figure7 <- dcast(figure7, geo+time~lev_expn+hhtype, value.var = "values")
figure7 <- mutate(figure7,
                  bar1 = LOW_NSAV+LOW_SAV+NLOW_NSAV,
                  bar2 = LOW_NSAV+NLOW_NSAV,
                  bar3 = NLOW_NSAV)

figure7 <- figure7[order(figure7$bar1),]

figure7 <- figure7[,c("geo","time","NLOW_NSAV","LOW_NSAV","LOW_SAV","bar1","bar2","bar3")]

barplot(t(figure7$bar1), col = col3, main = NA,
        border = NA, space = 1.5, ylim = c(0,80),
        names.arg = figure7$geo, cex.names = 0.5)
barplot(t(figure7$bar2), col = col2, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE)
barplot(t(figure7$bar3), col = c(col1, col2, col3), main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE,
        legend.text = c("Dissaving households, no low expenditure", 
                        "Dissaving households with low expenditure",
                        "Saving households with low expenditure"), 
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure7,"DataFiguresSE1.xlsx",sheetName = "Figure 7",append = TRUE)

#################################################################################################################################################
### FIGURE 8
#################################################################################################################################################

#get the PPPs figures
ppp <- get_eurostat("prc_ppp_ind", time_format = "num")
ppp <- filter(ppp,
                  na_item == "PPP_EU28" & ppp_cat == "E011" & time == year)
ppp <- rename(ppp, ppp_values = "values")

#get the exchange rates
exchange_rates <- get_eurostat("ert_bil_eur_a", time_format = "num")
exchange_rates <- filter(exchange_rates,
              currency %in% c("BGN","CZK","DKK","GBP","HRK","HUF","PLN","RON","SEK") & statinfo == "AVG" & time == year)
exchange_rates <- mutate(exchange_rates,country = substr(currency,1,2))
exchange_rates$country[exchange_rates$country=="GB"] <- "UK"
exchange_rates<- rename(exchange_rates, er_values = "values")
exchange_rates<- rename(exchange_rates, geo = "country")

#create the table with PPS
pps <- merge(ppp[,c(3,5)], exchange_rates[,c(6,5)], all=T)
pps <- mutate(pps, er_values = ifelse(is.na(er_values),1,er_values))
pps <- mutate(pps, pps_values = er_values/ppp_values)

#retrieving the values of interest: median consumption by income decile
figure8 <- get_eurostat("icw_sr_06", time_format = "num")
figure8 <- filter(figure8,
              unit == "THS_EUR" & time == year)
figure8 <- merge(figure8[,c(1,2,3,4,5)], pps[,c(1,4)], all=T)
figure8 <- mutate(figure8,values_corr = values*pps_values)

figure8 <- dcast(figure8, geo~quantile, value.var = "values_corr")
figure8 <- merge(figure8, countryOrder, by.x = "geo", by.y = "Country")
figure8 <- arrange(figure8, Protocol_order)
figure8 <- figure8[,c("geo","D1","D2","D3","D4","D5","D6","D7","D8","D9","D10")]

Rsetwd(path_results)
write.xlsx(figure8,"DataFiguresSE1.xlsx",sheetName = "Figure 8",append = TRUE)

#################################################################################################################################################
### FIGURE 9
#################################################################################################################################################

prospensity <- get_eurostat("icw_sr_10", time_format = "num")
figure9 <- filter(prospensity,
                   quantile != "TOTAL" & time == year)
figure9 <- dcast(figure9, geo~quantile, value.var = "values")
figure9 <- merge(figure9, countryOrder, by.x = "geo", by.y = "Country")
figure9 <- arrange(figure9, Protocol_order)

barplot(t(figure9[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), 
        main = NA, ylim = c(0,250),
        border = NA, legend.text = c("1st quintile","2nd quintile","3rd quintile","4th quintile","5th quintile"),
        names.arg = figure9$geo, cex.names = 0.5,
        args.legend = list(x = "topright", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure9,"DataFiguresSE1.xlsx",sheetName = "Figure 9",append = TRUE)

#################################################################################################################################################
### FIGURE 10
#################################################################################################################################################

indicators_sr_age <- get_eurostat("icw_sr_01", time_format = "num")
figure10 <- filter(indicators_sr_age,
                  age != "UNK" & time == year)
figure10 <- dcast(figure10, geo~age, value.var = "values")
figure10 <- merge(figure10, countryOrder, by.x = "geo", by.y = "Country")
figure10 <- arrange(figure10, Protocol_order)
figure10 <- figure10[,c("geo","TOTAL","Y_LT30","Y30-44","Y45-59","Y_GE60","Protocol_order")]

barplot(t(figure10[,c(6,3:5)]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("Less than 30","Between 30 and 44","Between 45 and 60","60 and more"),
        names.arg = figure10$geo, cex.names = 0.5, ylim = c(-60,60),
        args.legend = list(x = "bottomright", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure10,"DataFiguresSE1.xlsx",sheetName = "Figure 10",append = TRUE)

#################################################################################################################################################
### FIGURE 11
#################################################################################################################################################

indicators_sr_hhcomp <- get_eurostat("icw_sr_02", time_format = "num")
figure11 <- filter(indicators_sr_hhcomp,
                   hhcomp != "TOTAL" & time == year)
figure11 <- dcast(figure11, geo~hhcomp, value.var = "values")
figure11 <- merge(figure11, countryOrder, by.x = "geo", by.y = "Country")
figure11 <- arrange(figure11, Protocol_order)
figure11 <- figure11[,c("geo","A1","A2","A_GE3","A1_DCH","A2_DCH","A_GE3_DCH","Protocol_order")]

barplot(t(figure11[,2:7]), beside = TRUE, col = c(col1, col1_faded, col2, col2_faded, col3, col3_faded), 
        main = NA, ylim = c(-60,60),
        border = NA, legend.text = c("One adult","One adult with dependent children","Two adults",
                                     "Two adults with dependent children","Three adults and more","Three adults and more with dependent children"),
        names.arg = figure11$geo, cex.names = 0.5,
        args.legend = list(x = "bottomright", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure11,"DataFiguresSE1.xlsx",sheetName = "Figure 11",append = TRUE)

#################################################################################################################################################
### FIGURE 12
#################################################################################################################################################

indicators_sr_inc <- get_eurostat("icw_sr_03", time_format = "num")
figure12 <- filter(indicators_sr_inc,
                   quantile != "TOTAL" & time == year)
figure12 <- dcast(figure12, geo~quantile, value.var = "values")
figure12 <- merge(figure12, countryOrder, by.x = "geo", by.y = "Country")
figure12 <- arrange(figure12, Protocol_order)

barplot(t(figure12[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), 
        main = NA, ylim = c(-80,80),
        border = NA, legend.text = c("1st quintile","2nd quintile","3rd quintile","4th quintile","5th quintile"),
        names.arg = figure12$geo, cex.names = 0.5,
        args.legend = list(x = "bottomright", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure12,"DataFiguresSE1.xlsx",sheetName = "Figure 12",append = TRUE)