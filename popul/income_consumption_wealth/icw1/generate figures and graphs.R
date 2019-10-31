############################################################################################################
# Scripts for computing figures and generating graphs in Statistics Explained article
# http://ec.europa.eu/eurostat/statistics-explained/index.php?title=Households%27_income,_consumption_and_wealth,_and_how_they_interact_-_statistics_on_main_results
# Run on R 64-bits 3.3.1


library(dplyr)
library(haven)
library(Cairo)
library(eurostat)
library(reshape2)

col1 <- rgb(250, 165, 25, maxColorValue = 255)
col1_faded <- rgb(251, 200, 117, maxColorValue = 255)
col2 <- rgb(40, 110, 180, maxColorValue = 255)
col2_faded <- rgb(113, 168, 223, maxColorValue = 255)
col3 <- rgb(240, 99, 34, maxColorValue = 255)
col3_faded <- rgb(246, 162, 123, maxColorValue = 255)
col4 <- rgb(185, 195, 30, maxColorValue = 255)
col5 <- rgb(93, 179, 64, maxColorValue = 255)

#################################################################################################################################################
### FIGURE 1
#################################################################################################################################################

indicators_NA <- get_eurostat("nasa_10_ki", time_format = "num")
saving_rate_NA <- filter(indicators_NA,
                         na_item == "SRG_S14_S15")

saving_rate_NA_2015 <- filter(saving_rate_NA,
                              time == 2015)

indicators_silc <- get_eurostat("ilc_mdes09", time_format = "num")
indicators_diff <- filter(indicators_silc,
                          subjnmon %in% c("EM_D","EM_GD") & hhtyp == "TOTAL" & time == 2015 & incgrp == "TOTAL" & !geo %in% c("EU28","EA19"))

indicators_diff <- indicators_diff %>%
  group_by(geo) %>%
  summarise(prop_diff = sum(values))

figure1 <- merge(saving_rate_NA_2015, indicators_diff)
names(figure1)[6] <- "saving_rate"

plot(figure1$prop_diff, figure1$saving_rate, type = "p", pch = 18, col = col1, bty = "n", xaxt="n",yaxt="n", 
     xlim = c(0,70), ylim = c(-10,25), xlab = NA, ylab = NA)
grid(nx = NA, ny = NULL)
axis(1,pos=0)
axis(2,pos=0, tick = FALSE, las = 1)
text(figure1$prop_diff, figure1$saving_rate, labels = figure1$geo, cex = 0.7, pos = 3)


#################################################################################################################################################
### FIGURE 2
#################################################################################################################################################

indicators_pov <- get_eurostat("icw_pov_01", time_format ="num")
indicators_exp <- filter(indicators_pov,
                         lev_expn == "LOW" & ind_type == "TOTAL" & lev_depr == "TOTAL" & workint == "TOTAL")
indicators_inc <- filter(indicators_pov,
                         lev_expn == "TOTAL" & ind_type == "ARP" & lev_depr == "TOTAL" & workint == "TOTAL")
names(indicators_exp)[8] <- "prop_expn"
names(indicators_inc)[8] <- "prop_inc"
figure2 <- merge(indicators_exp[,c(6,8)], indicators_inc[,c(6,8)])
figure2 <- figure2[order(figure2$prop_inc),]

barplot(t(figure2[,2:3]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("Low levels of expenditure", "Monetary poverty"),
        names.arg = figure2$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 3
#################################################################################################################################################

indicators_asset_pov <- get_eurostat("icw_pov_02", time_format = "num")
indicators_asset_pov <- filter(indicators_asset_pov,
                               ind_type == "ARP" & duration %in% c("M1", "M3","M6","M12"))
indicators_asset_pov <- mutate(indicators_asset_pov,
                               period = as.numeric(substr(duration,2,4)))
indicators_asset_pov <- indicators_asset_pov[order(indicators_asset_pov$geo, indicators_asset_pov$period),]
figure3 <- dcast(indicators_asset_pov, geo+time~period, value.var = "values")
figure3 <- figure3[order(figure3[,3]),]

barplot(t(figure3[,3:6]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("1 month", "3 months", "6 months", "12 months"),
        names.arg = figure3$geo, cex.names = 0.7,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 4
#################################################################################################################################################

gini_index <- get_eurostat("icw_sr_05", time_format = "num")
figure4 <- dcast(gini_index, geo+time~stk_flow, value.var = "values")
figure4 <- figure4[order(figure4[,5]),]

barplot(t(figure4[,3:6]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("Income", "Expenditures", "Savings", "Wealth"),
        names.arg = figure4$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 5
#################################################################################################################################################

indicators_dissav <- get_eurostat("icw_pov_03", time_format = "num")
figure5 <- filter(indicators_dissav,
                  hhtype == "NSAV")
figure5 <- figure5[order(figure5$values),]

barplot(figure5$values, col = col1, main = NA,
        border = NA, space = 1.5,
        names.arg = figure5$geo, cex.names = 0.5)


#################################################################################################################################################
### FIGURE 6
#################################################################################################################################################

indicators_sr <- get_eurostat("icw_sr_01", time_format = "num")
indicators_agg <- get_eurostat("icw_sr_08", time_format = "num")

indicators_agg <- filter(indicators_agg,
                         age == "TOTAL")
indicators_sr <- filter(indicators_sr,
                        age == "TOTAL")
indicators_agg <- mutate(indicators_agg,
                         sr_agg = 100 - values)
indicators_sr <- mutate(indicators_sr,
                        sr_med = values)
figure6 <- merge(indicators_sr[,c("geo","sr_med")], indicators_agg[,c("geo","sr_agg")])
figure6 <- figure6[order(figure6$sr_med),]

barplot(t(figure6[,2:3]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("Median saving rate", "Aggregate saving rate"),
        names.arg = figure6$geo, cex.names = 0.5, ylim = c(-20,50), cex.axis = 0.7,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 7
#################################################################################################################################################

indicators_inter <- get_eurostat("icw_pov_01", time_format = "num")
figure7 <- filter(indicators_inter,
                  (lev_expn == "LOW" | ind_type == "ARP") & lev_depr == "TOTAL" & workint == "TOTAL" & lev_expn != "TOTAL" & ind_type != "TOTAL")

figure7 <- dcast(figure7, geo+time~lev_expn+ind_type, value.var = "values")
figure7 <- mutate(figure7,
                  bar1 = LOW_ARP+LOW_NARP+NLOW_ARP,
                  bar2 = LOW_ARP+NLOW_ARP,
                  bar3 = NLOW_ARP)
figure7 <- figure7[order(figure7$bar1),]

barplot(t(figure7$bar1), col = col3, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        names.arg = figure7$geo, cex.names = 0.5)
barplot(t(figure7$bar2), col = col2, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE)
barplot(t(figure7$bar3), col = c(col1, col2, col3), main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE,
        legend.text = c("Only income-poor", "Income-poor and low levels of expenditure",
                        "Not income-poor, low levels of expenditure"), 
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 8
#################################################################################################################################################

indicators_inter <- get_eurostat("icw_pov_04", time_format = "num")
figure8 <- filter(indicators_inter,
                  (lev_expn == "LOW" | hhtype == "NSAV") & age == "TOTAL" & lev_expn != "TOTAL" & hhtype != "TOTAL")
figure8 <- dcast(figure8, geo+time~lev_expn+hhtype, value.var = "values")
figure8 <- mutate(figure8,
                  bar1 = LOW_NSAV+LOW_SAV+NLOW_NSAV,
                  bar2 = LOW_NSAV+NLOW_NSAV,
                  bar3 = NLOW_NSAV)

figure8 <- figure8[order(figure8$bar1),]

barplot(t(figure8$bar1), col = col3, main = NA,
        border = NA, space = 1.5, ylim = c(0,80),
        names.arg = figure8$geo, cex.names = 0.5)
barplot(t(figure8$bar2), col = col2, main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE)
barplot(t(figure8$bar3), col = c(col1, col2, col3), main = NA,
        border = NA, space = 1.5, ylim = c(0,40),
        add = TRUE,
        legend.text = c("Dissaving households, no low expenditure", 
                        "Dissaving households with low expenditure",
                        "Saving households with low expenditure"), 
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 9
#################################################################################################################################################

indicators_sr_age <- get_eurostat("icw_sr_01", time_format = "num")
figure9 <- filter(indicators_sr_age,
                  age != "UNK")
figure9 <- dcast(figure9, geo~age, value.var = "values")

barplot(t(figure9[,c(6,3:5)]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("Less than 30","Between 30 and 44","Between 45 and 60","60 and more"),
        names.arg = figure9$geo, cex.names = 0.5, ylim = c(-60,60),
        args.legend = list(x = "bottomright", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 10
#################################################################################################################################################

indicators_sr_hhcomp <- get_eurostat("icw_sr_02", time_format = "num")
figure10 <- filter(indicators_sr_hhcomp,
                   hhcomp != "TOTAL")
figure10 <- dcast(figure10, geo~hhcomp, value.var = "values")

barplot(t(figure10[,2:7]), beside = TRUE, col = c(col1, col1_faded, col2, col2_faded, col3, col3_faded), 
        main = NA, ylim = c(-60,60),
        border = NA, legend.text = c("One adult","One adult with dependent children","Two adults",
                                     "Two adults with dependent children","Three adults and more","Three adults and more with dependent children"),
        names.arg = figure10$geo, cex.names = 0.5,
        args.legend = list(x = "bottomright", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 11
#################################################################################################################################################

indicators_sr_inc <- get_eurostat("icw_sr_03", time_format = "num")
figure11 <- filter(indicators_sr_inc,
                   quantile != "TOTAL")
figure11 <- dcast(figure11, geo~quantile, value.var = "values")

barplot(t(figure11[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), 
        main = NA, ylim = c(-80,80),
        border = NA, legend.text = c("1st quintile","2nd quintile","3rd quintile","4th quintile","5th quintile"),
        names.arg = figure11$geo, cex.names = 0.5,
        args.legend = list(x = "bottomright", bty = "n", border = NA, cex = 0.5))

