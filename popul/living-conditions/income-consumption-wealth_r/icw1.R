############################################################################################################
# Scripts for computing figures and generating graphs in Statistics Explained article
# https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Joint_distribution_of_household_income,_consumption_and_wealth_-_main_indicators
# Run on R 64-bits 4.4.0

# Please insert the link to the folder where you want the files to be saved
path_results <- "./MainResults"
setwd(path_results)

library(dplyr)
library(haven)
library(Cairo)
library(eurostat)
library(reshape2)
library(maditr)
library(devtools)
library(openxlsx)
library(xlsx)
library(restatapi)
library(ggplot2)
library(tidyr)
library(scales)
assign("dmethod","auto",envir=.restatapi_env)


#############################################################################
### Define colors and color palette
#############################################################################
###col1 
col1 <- rgb(38, 68, 167, maxColorValue = 255)
col1_faded <- rgb(156, 193, 250, maxColorValue = 255)
### col2 dark gold
col2 <- rgb(176, 145, 32, maxColorValue = 255)
col2_faded <- rgb(239, 209, 140, maxColorValue = 255)
### col3 Sunset red
col3 <- rgb(224, 64, 64, maxColorValue = 255)
col3_faded <- rgb(255, 163, 163, maxColorValue = 255)


create_fading_palette <- function(color, n) {
  alpha_values <- seq(1, 0.5, length.out = n)
  faded_colors <- alpha(color, alpha_values)
  return(faded_colors)
}

estat_palette <- c(col1, col1_faded, col2, col2_faded, col3, col3_faded)

gold_palette <- create_fading_palette(col2, 10)
blu_palette <- create_fading_palette(col1, 5)


year <- 2020


# Read the CSV file directly from GitHub
countryOrder <- read.csv("https://raw.githubusercontent.com/eurostat/statistics-coded/refs/heads/master/popul/living-conditions/income-consumption-wealth_r/data/country_order.csv") %>% 
  rename(geo=Country)

list_cty <- c("AT","BE","BG", "CY", "CZ", "DE", "DK", "EE", "EL", "ES", "FI", "FR", "HR", "HU", "IE", "LT", "LU", "LV", "MT", "NL", "PL",
              "PT", "RO", "SI" ,"SK", "EU27_2020")


#################################################################################################################################################
### MAIN FIGURE
### Share of households (%) in the bottom quintiles of both income and consumption expenditure distributions, and 
### share of disposable income, consumption expenditure, and net wealth held by these households, 'around 2020'. 
### Source: Eurostat (icw_res_01)
#################################################################################################################################################

indicators_res <- get_eurostat_data("icw_res_01", time_format = "num")
indicators_res <- filter(indicators_res,
                            quant_inc == "QU1" & quant_expn == "QU1" & quant_wlth == "TOTAL" & time == year & geo %in% list_cty)
Main <- dcast(indicators_res, geo+time~indic_il, value.var = "values")

Main <- merge(countryOrder, Main, by = "geo")
Main <- Main[order(Main$HH),]

# Open a PNG device
png("MainFigure.png", width = 1000, height = 800)

MainFigure <- barplot(t(Main[,c(5,7:8)]), beside = TRUE, col = c( col2, col3, col1_faded), main = NA,
                      border = NA, legend.text = c("Dsiposable income", "Consumption expenditure", "Net wealth"),
                      names.arg = Main$geo, cex.names = 0.5, ylab = "% Share", ylim = c(0,20),
                      args.legend = list(x = "topleft", bty = "n", border = NA, cex =1))
# Add points to the barplot
points(x = MainFigure[2,], y = Main$HH, col = col1, pch = 18,cex = 1.5)
legend(x = "topright", legend= "Share of households in the bottom quitile of both income and consumption", col = col1,  pch = 18, bty = "n",cex = 1)

# Close the PNG device
dev.off()

colnames(figure3) <- c("geo","values2015",paste0("values",year))
figure3 <- merge(countryOrder, figure3, by = "geo")
figure3 <- figure3[order(figure3$values2020),]

setwd(path_results)
write.xlsx(Main,"DataFiguresSE1.xlsx",sheetName = "Main Figure",append = TRUE)


#################################################################################################################################################
### FIGURE 1 
### Share of households (%) with consumption expenditure higher than income 'around 2015' and 'around 2020'.
### Source: Eurostat (icw_pov_03)
#################################################################################################################################################

#indicators_dissav <- get_eurostat("icw_pov_03", time_format = "num")
indicators_dissav <- get_eurostat_data("icw_pov_03", time_format = "num")
indicators_dissav <- filter(indicators_dissav,
                            hhtype == "NSAV" & time %in% c(year,2015) & geo %in% list_cty)
figure1 <- dcast(indicators_dissav, geo~time, value.var = "values")
colnames(figure1) <- c("geo","values2015",paste0("values",year))
figure1 <- merge(countryOrder, figure1, by = "geo")
figure1 <- figure1[order(figure1$values2020),]

# Open a PNG device
png("Figure1.png", width = 1000, height = 800)

barplot(t(figure1[,4:5]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("2015", "2020"),
        names.arg = figure1$geo, cex.names = 0.5, ylim = c(0,70), cex.axis = 0.7,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <-  openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 1")
writeData(wb,"Figure 1", figure1)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE)


#################################################################################################################################################
### FIGURE 2
### Median saving rates (%) of households 'around 2015' and 'around 2020'. 
### Source: Eurostat (icw_sr_03)
#################################################################################################################################################

#indicators_sr <- get_eurostat("icw_sr_01", time_format = "num")
indicators_sr <- get_eurostat_data("icw_sr_01", time_format = "num")


indicators_sr <- filter(indicators_sr,
                        age == "TOTAL" & time %in% c(year,2015) &geo %in% list_cty)

indicators_sr <- mutate(indicators_sr,
                        sr_med = values)

figure2 <- dcast(indicators_sr, geo~time, value.var = "sr_med")
colnames(figure2) <- c("geo","sr_med2015",paste0("sr_med",year))
figure2 <- merge(countryOrder, figure2, by = "geo")
figure2 <- figure2[order(figure2$sr_med2020),]

# Open a PNG device
png("Figure2.png", width = 1000, height = 800)

barplot(t(figure2[,4:5]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("Median saving rate 2015", "Median saving rate 2020"),
        names.arg = figure2$geo, cex.names = 0.5, ylim = c(-20,50), cex.axis = 0.7,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 2")
writeData(wb,"Figure 2", figure2)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )

#################################################################################################################################################
### FIGURE 3
### Gini coefficients for income, expenditures, savings and wealth, ‘around 2020’. 
### Source: Eurostat (icw_sr_05)
#################################################################################################################################################

#gini_index <- get_eurostat("icw_sr_05", time_format = "num")
gini_index <- get_eurostat_data("icw_sr_05", time_format = "num")
gini_index <- filter(gini_index,
                     time == year, geo %in% list_cty)
figure3 <- dcast(gini_index, geo+time~stk_flow, value.var = "values")
figure3 <- merge(countryOrder, figure3, by = "geo")
figure3 <- figure3[order(figure3$SAV),]

# Open a PNG device
png("Figure3.png", width = 1000, height = 800)

barplot(t(figure3[,5:8]), beside = TRUE, col = c(col1, col1_faded, col2, col3), main = NA,
        border = NA, legend.text = c("Income", "Expenditures", "Savings", "Wealth"),
        names.arg = figure3$geo, cex.names = 0.5, ylim=c(0,90),
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 3")
writeData(wb,"Figure 3", figure3)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )


#################################################################################################################################################
### FIGURE 4
### Proportion of the population (%) at-risk-of-poverty (AROP) or having low level of consumption expenditure or both 'around 2020'.
### Source: Eurostat (icw_pov_01)
#################################################################################################################################################

#indicators_inter <- get_eurostat("icw_pov_01", time_format = "num")
indicators_inter <- get_eurostat_data("icw_pov_01", time_format = "num")
figure4 <- filter(indicators_inter,
                  (lev_expn == "LOW" | yn_rskpov == "YES_ARP") & lev_depr == "TOTAL" & workint == "TOTAL" & lev_expn != "TOTAL" & yn_rskpov != "TOTAL" & unit == "PC_POP" & time == year)
figure4 <- filter(figure4, geo %in% list_cty)
figure4 <- dcast(figure4, geo+time~lev_expn+yn_rskpov, value.var = "values")
figure4 <- mutate(figure4,
                  bar1 = LOW_YES_ARP+LOW_NO_ARP+NLOW_YES_ARP,
                  bar2 = LOW_YES_ARP+NLOW_YES_ARP,
                  bar3 = LOW_YES_ARP)
figure4 <- merge(countryOrder, figure4, by = "geo")
figure4 <- figure4[order(figure4$bar1),]

#colnames(figure4) <- c("geo","time","LOW-EXP_but_NO-ARP","LOW-EXP_and_YES-ARP","NLOW-EXP_but_YES-ARP","LOW-EXP_or_YES-ARP","YES-ARP","LOW-EXP_and_YES-ARP")

figure4 <- figure4[,c("geo","time","LOW_YES_ARP","NLOW_YES_ARP","LOW_NO_ARP","bar1","bar2","bar3")]

# Open a PNG device
png("Figure4.png", width = 1000, height = 800)

barplot(t(figure4$bar1), col = col3, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        names.arg = figure4$geo, cex.names = 0.5)
barplot(t(figure4$bar2), col = col2, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE)
barplot(t(figure4$bar3), col = c(col1, col2, col3), main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE,
        legend.text = c("Only at-risk-of-poverty", "At-risk-of-poverty and low levels of expenditure", 
                        "Only low levels of expenditure"), 
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 4")
writeData(wb,"Figure 4", figure4)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )

#################################################################################################################################################
### FIGURE 5
### Intersection between dissaving households and low levels of expenditure 'around 2020'. 
### Source: Eurostat (icw_pov_04).
#################################################################################################################################################

#indicators_inter <- get_eurostat("icw_pov_04", time_format = "num")
indicators_inter <- get_eurostat_data("icw_pov_04", time_format = "num")
figure5 <- filter(indicators_inter,
                  (lev_expn == "LOW" | hhtype == "NSAV") & age == "TOTAL" & lev_expn != "TOTAL" & hhtype != "TOTAL" & time == year)
figure5 <- filter(figure5,geo %in% list_cty)

figure5 <- dcast(figure5, geo+time~lev_expn+hhtype, value.var = "values")
figure5 <- mutate(figure5,
                  bar1 = LOW_NSAV+LOW_SAV+NLOW_NSAV,
                  bar2 = LOW_NSAV+NLOW_NSAV,
                  bar3 = NLOW_NSAV)

figure5 <- figure5[,c("geo","time","NLOW_NSAV","LOW_NSAV","LOW_SAV","bar1","bar2","bar3")]
figure5 <- merge(countryOrder, figure5, by = "geo")
figure5 <- figure5[order(figure5$bar1),]

# Open a PNG device
png("Figure5.png", width = 1000, height = 800)


barplot(t(figure5$bar1), col = col3, main = NA,
        border = NA, space = 1.5, ylim = c(0,80),
        names.arg = figure4$geo, cex.names = 0.5)
barplot(t(figure5$bar2), col = col2, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE)
barplot(t(figure5$bar3), col = c(col1, col2, col3), main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE,
        legend.text = c("Dissaving households, no low expenditure", 
                        "Dissaving households with low expenditure",
                        "Saving households with low expenditure"), 
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 5")
writeData(wb,"Figure 5", figure5)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )
#write.xlsx(figure5,"DataFiguresSE1.xlsx",sheetName = "Figure 5",append = TRUE)

#################################################################################################################################################
### FIGURE 6 - Graph is done in Excel
### Median consumption (1000 purchasing power standard) by income decile, 'around 2020'. 
### Source: Eurostat (icw_sr_06).
#################################################################################################################################################

#figure6 <- get_eurostat("icw_sr_06", time_format = "num")
figure6 <- get_eurostat_data("icw_sr_06", time_format = "num")
figure6 <- filter(figure6,
                  unit == "PPS" & time == year & geo %in% list_cty)
#figure6 <- merge(figure6[,c(1,2,3,4,5)], pps[,c(1,4)], all=T)
figure6 <- mutate(figure6,THS_PPS = values/1000) # Convert PPS in Thousand PPS

figure6 <- dcast(figure6, geo~quant_inc, value.var = "THS_PPS")
figure6 <- merge(figure6, countryOrder, by.x = "geo", by.y = "geo")
figure6 <- arrange(figure6, protocol_order)
figure6 <- figure6[,c("geo","D1","D2","D3","D4","D5","D6","D7","D8","D9","D10")]

# Open a PNG device
png("Figure6.png", width = 1000, height = 800)

barplot(t(figure6[,2:11]), beside = TRUE, col = gold_palette, 
        main = NA, ylim = c(0,70),
        border = NA, legend.text = c("1st decile","2nd decile","3rd decile","4th decile","5th decile","6th decile","7th decile","8th decile","9th decile","10th decile"),
        names.arg = figure6$geo, cex.names = 0.5,
        args.legend = list(x = "topright", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 6")
writeData(wb,"Figure 6", figure6)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )
#write.xlsx(figure6,"DataFiguresSE1.xlsx",sheetName = "Figure 6",append = TRUE)

#################################################################################################################################################
### FIGURE 7
### Aggregate propensity to consume (%) by income quintile, 'around 2020'. 
### Source: Eurostat (icw_sr_10).
#################################################################################################################################################

#propensity <- get_eurostat("icw_sr_10", time_format = "num")
propensity <- get_eurostat_data("icw_sr_10", time_format = "num")
figure7 <- filter(propensity,
                  quant_inc != "TOTAL" & time == year & geo %in% list_cty)
figure7 <- dcast(figure7, geo~quant_inc, value.var = "values")
figure7 <- merge(figure7, countryOrder, by.x = "geo", by.y = "geo")
figure7 <- arrange(figure7, protocol_order)

# Open a PNG device
png("Figure7.png", width = 1000, height = 800)

barplot(t(figure7[,2:6]), beside = TRUE, col = blu_palette, 
        main = NA, ylim = c(0,250),
        border = NA, legend.text = c("1st quintile","2nd quintile","3rd quintile","4th quintile","5th quintile"),
        names.arg = figure7$geo, cex.names = 0.5,
        args.legend = list(x = "topright", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 7")
writeData(wb,"Figure 7", figure7)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )
#write.xlsx(figure7,"DataFiguresSE1.xlsx",sheetName = "Figure 7",append = TRUE)

#################################################################################################################################################
### FIGURE 8
### Median saving rate (%) by age of the household reference person, 'around 2020'. 
### Source: Eurostat (icw_sr_01).
#################################################################################################################################################

#indicators_sr_age <- get_eurostat("icw_sr_01", time_format = "num")
indicators_sr_age <- get_eurostat_data("icw_sr_01", time_format = "num")
figure8 <- filter(indicators_sr_age,
                   age != "UNK" & time == year &geo %in% list_cty)
figure8 <- dcast(figure8, geo~age, value.var = "values")
figure8 <- merge(figure8, countryOrder, by.x = "geo", by.y = "geo")
figure8 <- arrange(figure8, protocol_order)
figure8 <- figure8[,c("geo","TOTAL","Y_LT35","Y35-44","Y45-54","Y55-64","Y65-74","Y_GE75","protocol_order")]

# Open a PNG device
png("Figure8.png", width = 1000, height = 800)

barplot(t(figure8[,c(3:8)]), beside = TRUE, col = estat_palette, main = NA,
        border = NA, legend.text = c("Less than 35","Between 35 and 44","Between 45 and 54","Between 55 and 64",
                                     "Between 65 and 74","75 and more"),
        names.arg = figure8$geo, cex.names = 0.5, ylim = c(-20,80),
        args.legend = list(x = "topright", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 8")
writeData(wb,"Figure 8", figure8)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )
#write.xlsx(figure8,"DataFiguresSE1.xlsx",sheetName = "Figure 8",append = TRUE)

#################################################################################################################################################
### FIGURE 9
### Median saving rate (%) by type of household, 'around 2020'. 
### Source: Eurostat (icw_sr_02).
#################################################################################################################################################

#indicators_sr_hhcomp <- get_eurostat("icw_sr_02", time_format = "num")
indicators_sr_hhcomp <- get_eurostat_data("icw_sr_02", time_format = "num")
figure9 <- filter(indicators_sr_hhcomp,
                   hhcomp != "TOTAL" & time == year & geo %in% list_cty)
figure9 <- dcast(figure9, geo~hhcomp, value.var = "values")
figure9 <- merge(figure9, countryOrder, by.x = "geo", by.y = "geo")
figure9 <- arrange(figure9, protocol_order)
figure9 <- figure9[,c("geo","A1","A2","A_GE3","A1_DCH","A2_DCH","A_GE3_DCH","protocol_order")]

# Open a PNG device
png("Figure9.png", width = 1000, height = 800)

barplot(t(figure9[,2:7]), beside = TRUE, col = estat_palette, 
        main = NA, ylim = c(-40,80),
        border = NA, legend.text = c("One adult","One adult with dependent children","Two adults",
                                     "Two adults with dependent children","Three adults and more","Three adults and more with dependent children"),
        names.arg = figure9$geo, cex.names = 0.5,
        args.legend = list(x = "bottomleft", bty = "n", border = NA, cex = 1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 9")
writeData(wb,"Figure 9", figure9)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )
#write.xlsx(figure9,"DataFiguresSE1.xlsx",sheetName = "Figure 9",append = TRUE)

#################################################################################################################################################
### FIGURE 10
### Median saving rate (%) of households by income quintile, 'around 2020'. 
### Source: Eurostat (icw_sr_03).
#################################################################################################################################################

#indicators_sr_inc <- get_eurostat("icw_sr_03", time_format = "num")
indicators_sr_inc <- get_eurostat_data("icw_sr_03", time_format = "num")
figure10 <- filter(indicators_sr_inc,
                   quant_inc != "TOTAL" & time == year & geo %in% list_cty)
figure10 <- dcast(figure10, geo~quant_inc, value.var = "values")
figure10 <- merge(figure10, countryOrder, by.x = "geo", by.y = "geo")
figure10 <- arrange(figure10, protocol_order)

# Open a PNG device
png("Figure10.png", width = 1000, height = 800)

barplot(t(figure10[,2:6]), beside = TRUE, col = estat_palette, 
        main = NA, ylim = c(-80,100),
        border = NA, legend.text = c("1st quintile","2nd quintile","3rd quintile","4th quintile","5th quintile"),
        names.arg = figure10$geo, cex.names = 0.5,
        args.legend = list(x = "topright", bty = "n", border = NA, cex =1))

# Close the PNG device
dev.off()

setwd(path_results)
wb <- openxlsx::loadWorkbook("DataFiguresSE1.xlsx")
addWorksheet(wb, "Figure 10")
writeData(wb,"Figure 10", figure10)
openxlsx::saveWorkbook(wb,"DataFiguresSE1.xlsx", overwrite=TRUE )
#write.xlsx(figure10,"DataFiguresSE1.xlsx",sheetName = "Figure 10",append = TRUE)