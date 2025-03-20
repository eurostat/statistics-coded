############################################################################################################
# Scripts for computing figures and generating graphs in Statistics Explained article
# https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Joint_distribution_of_household_income,_consumption_and_wealth_-_statistics_on_taxation
# Run on R 64-bits 4.4.0

path_results <- "./Taxation"

setwd(path_results)


library(tidyverse)
library(Cairo)
library(eurostat)
library(reshape2)
library(xlsx)
library(restatapi)
library(stringr)
assign("dmethod","auto",envir=.restatapi_env)

col1 <- rgb(250, 165, 25, maxColorValue = 255)
col1_faded <- rgb(251, 200, 117, maxColorValue = 255)
col2 <- rgb(40, 110, 180, maxColorValue = 255)
col2_faded <- rgb(113, 168, 223, maxColorValue = 255)
col3 <- rgb(240, 99, 34, maxColorValue = 255)
col3_faded <- rgb(246, 162, 123, maxColorValue = 255)
col4 <- rgb(185, 195, 30, maxColorValue = 255)
col5 <- rgb(93, 179, 64, maxColorValue = 255)

year <- 2020

# Read the CSV file directly from GitHub
countryOrder <- read.csv("https://raw.githubusercontent.com/eurostat/statistics-coded/refs/heads/master/popul/living-conditions/income-consumption-wealth_r/data/country_order.csv") 


list_cty <- c("AT","BE","BG", "CY", "CZ", "DE", "DK", "EE", "EL", "ES", "FI", "FR", "HR", "HU", "IE", "LT", "LU", "LV", "MT", "NL", "PL",
              "PT", "RO", "SI" ,"SK")

#################################################################################################################################################
### MAP 1 
### Median amount of VAT paid by households as a share of their gross income (%), around 2020.
### Source: Eurostat (icw_tax_01)
#################################################################################################################################################

#vat_rate <- get_eurostat("icw_tax_01", time_format = "num")
vat_rate <- get_eurostat_data("icw_tax_01", time_format = "num")
map1 <- vat_rate %>%
  filter(quantile == "MED" & age == "TOTAL" & time == year) %>%
  rename(vatRate = values) %>%
  arrange(vatRate)

barplot(t(map1[,6]), beside = TRUE, col = col1, main = NA,
        border = NA,
        names.arg = map1$geo, cex.names = 0.5)

setwd(path_results)

write.xlsx(map1,"DataFiguresSE3.xlsx",sheetName = "Map 1",append = TRUE)


#################################################################################################################################################
### FIGURE 1 
### Median VAT paid by households as a percentage of their gross income by income quintile, around 2020.
### ### Source: Eurostat (icw_tax_03)
#################################################################################################################################################

#vat_rate_incQ <- get_eurostat("icw_tax_03", time_format = "num")
vat_rate_incQ <- get_eurostat_data("icw_tax_03", time_format = "num")
vat_rate_incQ <- filter(vat_rate_incQ, quantile == "MED"& time == year)

figure1 <- dcast(vat_rate_incQ, geo~quant_inc, value.var = "values")
figure1 <- merge(figure1, countryOrder, by = "geo")
figure1 <- arrange(figure1, protocol_order)

barplot(t(figure1[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), main = NA,
        border = NA, legend.text = paste0("Q",1:5),
        names.arg = figure1$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure1,"DataFiguresSE3.xlsx",sheetName = "Figure 1",append = TRUE)


#################################################################################################################################################
### FIGURE 2 
### Median VAT paid by households as a percentage of their gross income by household type, around 2020.
### ### Source: Eurostat (icw_tax_02)
#################################################################################################################################################

#vat_rate_hhtyp <- get_eurostat("icw_tax_02", time_format = "num")
vat_rate_hhtyp <- get_eurostat_data("icw_tax_02", time_format = "num")
vat_rate_hhtyp <- filter(vat_rate_hhtyp, quantile == "MED" & time == year)

figure2 <- dcast(vat_rate_hhtyp, geo~hhcomp, value.var = "values")
figure2 <- merge(figure2, countryOrder, by= "geo")
figure2 <- arrange(figure2, protocol_order)

barplot(t(figure2[,2:7]), beside = TRUE, col = c(col1, col1_faded, col2, col2_faded,
                                                 col3, col3_faded), main = NA,
        border = NA, legend.text = c("One adult","One adult with dependent children","Two adults",
                                     "Two adults with dependent children","Three adults and more","Three adults and more with dependent children"),
        names.arg = figure2$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure2,"DataFiguresSE3.xlsx",sheetName = "Figure 2",append = TRUE)


#################################################################################################################################################
### FIGURE 3 
### Median VAT paid by households as a percentage of their gross income by age of the reference person, around 2020.
### ### Source: Eurostat (icw_tax_01)
#################################################################################################################################################

#vat_rate_ageRP <- get_eurostat("icw_tax_01", time_format = "num")
vat_rate_ageRP <- get_eurostat_data("icw_tax_01", time_format = "num")
vat_rate_ageRP <- filter(vat_rate_ageRP, quantile == "MED" & time == year)

figure3 <- dcast(vat_rate_ageRP, geo~age, value.var = "values")
figure3 <- merge(figure3, countryOrder, by= "geo")
figure3 <- arrange(figure3, protocol_order)

figure3 <- figure3[,c("geo","Y_LT35","Y35-44","Y45-54","Y55-64","Y65-74","Y_GE75","TOTAL","protocol_order","country")]

barplot(t(figure3[,2:7]), beside = TRUE, col = c(col1, col2, col3, col4,col5,col1_faded), main = NA,
        border = NA, legend.text = c("Less than 35","Between 35 and 44","Between 45 and 54","Between 55 and 64",
                                     "Between 65 and 74","75 and more"),
        names.arg = figure3$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure3,"DataFiguresSE3.xlsx",sheetName = "Figure 3",append = TRUE)


#################################################################################################################################################
### MAP 2 
### Median amount of direct taxes paid by households as a share of their gross income (%), around 2020.
### ### Source: Eurostat (icw_tax_04)
#################################################################################################################################################

taxInc <- get_eurostat_data("icw_tax_04", time_format = "num")
map2 <- taxInc %>%
  filter(quantile == "MED" & age == "TOTAL" & time == year) %>%
  select(geo, time, values) %>%
  rename(tax_inc = values) %>%
  arrange(tax_inc)

barplot(t(map2[,3]), beside = TRUE, col = col1, main = NA,
        border = NA,
        names.arg = map2$geo, cex.names = 0.5)

setwd(path_results)
write.xlsx(map2,"DataFiguresSE3.xlsx",sheetName = "Map 2",append = TRUE)

#################################################################################################################################################
### FIGURE 4 
### Median amount of direct taxes paid by households as a percentage of their gross income by income quintile, around 2020.
### ### Source: Eurostat (icw_tax_06)
#################################################################################################################################################

taxQuin <- get_eurostat_data("icw_tax_06", time_format = "num")

figure4 <- taxQuin %>%
  filter(quantile == "MED" & time == year) %>%
  select(geo, time, values, quant_inc)

figure4 <- dcast(figure4, geo~quant_inc, value.var = "values")
figure4 <- arrange(figure4, QU1)

barplot(t(figure4[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), main = NA,
        border = NA, legend.text = paste0("Q",1:5),
        names.arg = figure4$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure4,"DataFiguresSE3.xlsx",sheetName = "Figure 4",append = TRUE)




#################################################################################################################################################
### FIGURE 5  
### Median amount of direct taxes plus VAT paid by households as a percentage of their gross income by income quintile, around 2020.
### Source: Eurostat (icw_tax_09)
#################################################################################################################################################

#tax_rate_incQ <- get_eurostat("icw_tax_09", time_format = "num")
tax_rate_incQ <- get_eurostat_data("icw_tax_09", time_format = "num")
tax_rate_incQ <- filter(tax_rate_incQ, quantile == "MED" & time == year)

figure5 <- dcast(tax_rate_incQ, geo~quant_inc, value.var = "values")
figure5 <- merge(figure5, countryOrder, by= "geo")
figure5 <- arrange(figure5, protocol_order)

barplot(t(figure5[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), main = NA,
        border = NA, legend.text = paste0("Q",1:5),
        names.arg = figure5$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure5,"DataFiguresSE3.xlsx",sheetName = "Figure 5",append = TRUE)

#################################################################################################################################################
### FIGURE 6 
### Median amount of direct taxes plus VAT paid by households as a percentage of their gross income by household type, around 2020.
### ### Source: Eurostat (icw_tax_08)
#################################################################################################################################################

#tax_rate_hhtyp <- get_eurostat("icw_tax_08", time_format = "num")
tax_rate_hhtyp <- get_eurostat_data("icw_tax_08", time_format = "num")
tax_rate_hhtyp <- filter(tax_rate_hhtyp, quantile == "MED"  & time == year)

figure6 <- dcast(tax_rate_hhtyp, geo~hhcomp, value.var = "values")
figure6 <- merge(figure6, countryOrder, by = "geo")
figure6 <- arrange(figure6, protocol_order)

barplot(t(figure6[,2:7]), beside = TRUE, col = c(col1, col1_faded, col2, col2_faded,
                                                 col3, col3_faded), main = NA,
        border = NA, legend.text = c("One adult","One adult with dependent children","Two adults",
                                     "Two adults with dependent children","Three adults and more","Three adults and more with dependent children"),
        names.arg = figure6$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure6,"DataFiguresSE3.xlsx",sheetName = "Figure 6",append = TRUE)

#################################################################################################################################################
### FIGURE 7 
### Median amount of direct taxes plus VAT paid by households as a percentage of their gross income by age of the reference person, around 2020.
### Source: Eurostat (icw_tax_07)
#################################################################################################################################################

#tax_rate_ageRP <- get_eurostat("icw_tax_07", time_format = "num")
tax_rate_ageRP <- get_eurostat_data("icw_tax_07", time_format = "num")
tax_rate_ageRP <- filter(tax_rate_ageRP, quantile == "MED" & time == year)

figure7 <- dcast(tax_rate_ageRP, geo~age, value.var = "values")
figure7 <- merge(figure7, countryOrder, by = "geo")
figure7 <- arrange(figure7, protocol_order)

figure7 <- figure7[,c("geo","Y_LT35","Y35-44","Y45-54","Y55-64","Y65-74","Y_GE75","TOTAL","protocol_order", "country")]

barplot(t(figure7[,2:7]), beside = TRUE, col = c(col1, col2, col3, col4,col5,col1_faded), main = NA,
        border = NA, legend.text = c("Less than 35","Between 35 and 44","Between 45 and 54","Between 55 and 64",
                                     "Between 65 and 74","75 and more"),
        names.arg = figure7$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure7,"DataFiguresSE3.xlsx",sheetName = "Figure 7",append = TRUE)



#################################################################################################################################################
### FIGURE 8 
### Share of VAT in the overall consumption expenditure of households by income quintile, around 2020.
### Source: Eurostat (icw_tax_10, icw_res_02 and hbs_str_t223)
#################################################################################################################################################

# VAT rate from icw_tax_10 table

rateVat <- get_eurostat_data("icw_tax_10", time_format = "num")
rateLv2 <- rateVat %>%
  mutate(coicop = substr(as.character(coicop), 3, 5)) %>%
  filter(nchar(coicop) == 3) %>%
  rename(vatRate = values)


# Average consumption (PPS) by income quintiles from table icw_res_02

res2 <- get_eurostat_data("icw_res_02", time_format = "num")
res <- res2 %>% 
  filter(unit == "PPS" & time == year & geo %in% list_cty & quant_expn == "TOTAL" & quant_wlth == "TOTAL" 
         & indic_il=="EXPN_CONS" & quant_inc %in% c("QU1", "QU2", "QU3", "QU4", "QU5") & statinfo == "AVG") %>% 
  select(quant_inc, unit, geo, time, values) %>% 
  arrange(geo, quant_inc) %>%
  rename(consumption = values, quantile=quant_inc) %>% 
  mutate(quantile = str_replace_all(quantile, c("QU1" = "QUINTILE1", "QU2" = "QUINTILE2", "QU3" = "QUINTILE3", "QU4" = "QUINTILE4", "QU5" = "QUINTILE5")))


# consumption structure from hbs table hbs_str_t223

str_consumption_incQ <- get_eurostat_data("hbs_str_t223", time_format = "num")
str_consumption_incQ <- mutate(str_consumption_incQ,
                               coicop = as.character(coicop),
                               coicop = substr(coicop, 3, nchar(coicop)),
                               lv = nchar(coicop) - 1, 
                               share = values/1000)
str_consumption_incQ <- filter(str_consumption_incQ, geo %in% list_cty & time == year & lv == 2)

## gather the info together

consumption_incQ <- merge(str_consumption_incQ, res, by = c("geo", "time","quantile"))
consumption_incQ <- mutate(consumption_incQ,
                           consumption = consumption*share)
consumption_incQ <- merge(consumption_incQ, rateLv2, by = c("geo","coicop","time"))
consumption_incQ <- mutate(consumption_incQ,
                           vat = consumption*vatRate/(100 + vatRate))
vat_incQ <- consumption_incQ %>%
  group_by(geo, quantile) %>%
  summarise(vat = sum(vat),
            consumption_pc = sum(consumption))

vat_incQ <- mutate(vat_incQ,
                   vatRate = round(vat/(consumption_pc - vat)*100, digits = 2))

figure8 <- dcast(vat_incQ, geo~quantile, value.var = "vatRate")
figure8 <- merge(figure8, countryOrder, by = "geo")
figure8 <- arrange(figure8, protocol_order)

barplot(t(figure8[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), main = NA,
        border = NA, legend.text = paste0("Q",1:5),
        names.arg = figure8$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

setwd(path_results)
write.xlsx(figure8,"DataFiguresSE3.xlsx",sheetName = "Figure 8",append = TRUE)
