############################################################################################################
# Scripts for computing figures and generating graphs in Statistics Explained article
# http://ec.europa.eu/eurostat/statistics-explained/index.php?title=Interaction_of_household_income,_consumption_and_wealth_-_statistics_on_direct_and_indirect_taxation
# Run on R 64-bits 3.4.1

library(tidyverse)
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

# In National Accounts

vatNA <- get_eurostat("gov_10a_taxag", time = "num")
vatNA <- filter(vatNA,
                sector == "S13" & na_item == "D211" & unit == "MIO_EUR")
vatNA <- rename(vatNA,
                values_vat = values)
cons <- get_eurostat("nasa_10_nf_tr", time = "num")
cons <- filter(cons,
               sector %in% c("S14","S14_S15") & na_item == "P31" & unit == "CP_MEUR" & direct == "PAID")
cons <- dcast(geo+time~sector, data = cons, value.var = "values")

correction_sector <- cons %>%
  filter(!is.na(S14)) %>%
  group_by(time) %>%
  summarise(correction_sector = mean(S14/S14_S15))
cons <- merge(cons, correction_sector, by = "time")

cons <- mutate(cons,
               values_cons = ifelse(is.na(S14), S14_S15*correction_sector, S14))
vatNA <- merge(select(vatNA, geo, time, values_vat), select(cons, geo, time, values_cons))
vatNA <- vatNA %>%
  mutate(vatRate_NA = round(values_vat/(values_cons - values_vat)*100, digits = 2)) %>%
  filter(time == 2010) %>%
  mutate(geo = as.character(geo)) %>%
  filter(nchar(geo) == 2) %>%
  arrange(geo)

# In HBS

list_cty <- c("AT","BE","BG","CY","CZ","DE","DK","EE","EL","ES","FI","FR","HR","HU","IE","IT","LT","LU","LV",
              "MT","PL","PT","RO","SE","SI","SK","UK")

avg_consumption <- get_eurostat("hbs_exp_t111", time_format = "num")
avg_consumption <- filter(avg_consumption, stat == "DMOM" & time == 2010 & geo %in% list_cty & currency == "EUR")
avg_consumption <- mutate(avg_consumption,
                          consumption = values)

str_consumption <- get_eurostat("hbs_str_t211", time_format = "num")
str_consumption <- mutate(str_consumption,
                          coicop = as.character(coicop),
                          coicop = substr(coicop, 3, nchar(coicop)),
                          lv = nchar(coicop) - 1, 
                          share = values/1000)
str_consumption <- filter(str_consumption, geo %in% list_cty & time == 2010 & lv == 2) ## we could take lv == 3 but totals do not add up to 1 - we don't have the full consumption structure at this level of details

consumption <- merge(str_consumption, avg_consumption, by = c("geo", "time"))
consumption <- mutate(consumption,
                      consumption = consumption*share)

rateVat <- get_eurostat("icw_tax_10", time_format = "num")
rateLv2 <- rateVat %>%
  mutate(coicop = substr(as.character(coicop), 3, 5)) %>%
  filter(nchar(coicop) == 3) %>%
  rename(vatRate = values)
consumption <- merge(consumption, rateLv2, by = c("geo","time","coicop"))
consumption <- mutate(consumption,
                      vat = consumption*vatRate/(100 + vatRate))
vatHbs <- consumption %>%
  group_by(geo) %>%
  summarise(vat = sum(vat),
            consumption_pc = sum(consumption))

vatHbs <- mutate(vatHbs,
                 vatRate_hbs = round(vat/(consumption_pc - vat)*100, digits = 2))

figure1 <- merge(vatNA, vatHbs, by = "geo")
figure1 <- arrange(figure1,
                   vatRate_NA)

barplot(t(figure1[,c("vatRate_NA","vatRate_hbs")]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("National accounts", "HBS"),
        names.arg = figure1$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 2
#################################################################################################################################################

tmpFile <- tempfile()
download.file("https://raw.githubusercontent.com/eurostat/ICW/master/StatisticsExplained3/data/country_order.csv", destfile = tmpFile, method = "auto")
countryOrder <- read.csv(tmpFile)

# income quintiles
avg_consumption_incQ <- get_eurostat("hbs_exp_t133", time_format = "num")
avg_consumption_incQ <- avg_consumption_incQ %>%
  filter(stat == "DMOM" & time == 2010 & geo %in% list_cty & quantile != "TOTAL") %>%
  arrange(geo, quantile) %>%
  rename(consumption = values)

# avg_consumption_incQ <- merge(avg_consumption_incQ, dataHbs, by.x = "geo", by.y = "COUNTRY")
# 
# avg_consumption_incQ <- mutate(avg_consumption_incQ,
#                                consumption = values/(coeff_price*coeff_pps))

str_consumption_incQ <- get_eurostat("hbs_str_t223", time_format = "num")
str_consumption_incQ <- mutate(str_consumption_incQ,
                               coicop = as.character(coicop),
                               coicop = substr(coicop, 3, nchar(coicop)),
                               lv = nchar(coicop) - 1, 
                               share = values/1000)
str_consumption_incQ <- filter(str_consumption_incQ, geo %in% list_cty & time == 2010 & lv == 2)

consumption_incQ <- merge(str_consumption_incQ, avg_consumption_incQ, by = c("geo", "time","quantile"))
consumption_incQ <- mutate(consumption_incQ,
                           consumption = consumption*share)
consumption_incQ <- merge(consumption_incQ, rateLv2, by = c("geo","coicop"))
consumption_incQ <- mutate(consumption_incQ,
                           vat = consumption*vatRate/(100 + vatRate))
vat_incQ <- consumption_incQ %>%
  group_by(geo, quantile) %>%
  summarise(vat = sum(vat),
            consumption_pc = sum(consumption))

vat_incQ <- mutate(vat_incQ,
                   vatRate = round(vat/(consumption_pc - vat)*100, digits = 2))

figure2 <- dcast(vat_incQ, geo~quantile, value.var = "vatRate")
figure2 <- merge(figure2, countryOrder, by.x = "geo", by.y = "Country")
figure2 <- arrange(figure2, Protocol_order)

barplot(t(figure2[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), main = NA,
        border = NA, legend.text = paste0("Q",1:5),
        names.arg = figure2$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 3
#################################################################################################################################################

# household type
avg_consumption_hhtype <- get_eurostat("hbs_exp_t134", time_format = "num")
avg_consumption_hhtype <- avg_consumption_hhtype %>%
  filter(stat == "DMOM" & time == 2010 & geo %in% list_cty & hhtyp != "TOTAL") %>%
  arrange(geo, hhtyp) %>%
  rename(consumption = values)

str_consumption_hhtype <- get_eurostat("hbs_str_t224", time_format = "num")
str_consumption_hhtype <- mutate(str_consumption_hhtype,
                                 coicop = as.character(coicop),
                                 coicop = substr(coicop, 3, nchar(coicop)),
                                 lv = nchar(coicop) - 1, 
                                 share = values/1000)
str_consumption_hhtype <- filter(str_consumption_hhtype, geo %in% list_cty & time == 2010 & lv == 2)

consumption_hhtype <- merge(str_consumption_hhtype, avg_consumption_hhtype, by = c("geo", "time","hhtyp"))
consumption_hhtype <- mutate(consumption_hhtype,
                             consumption = consumption*share)
consumption_hhtype <- merge(consumption_hhtype, rateLv2, by = c("geo","coicop"))
consumption_hhtype <- mutate(consumption_hhtype,
                             vat = consumption*vatRate/(100 + vatRate))
vat_hhtype <- consumption_hhtype %>%
  group_by(geo, hhtyp) %>%
  summarise(vat = sum(vat),
            consumption_pc = sum(consumption))

vat_hhtype <- mutate(vat_hhtype,
                     vatRate = round(vat/(consumption_pc - vat)*100, digits = 2))

figure3 <- dcast(vat_hhtype, geo~hhtyp, value.var = "vatRate")
figure3 <- merge(figure3, countryOrder, by.x = "geo", by.y = "Country")
figure3 <- arrange(figure3, Protocol_order)

barplot(t(figure3[,2:7]), beside = TRUE, col = c(col1, col1_faded, col2, col2_faded,
                                                 col3, col3_faded), main = NA,
        border = NA, legend.text = c("One adult","One adult with dependent children","Two adults",
                                     "Two adults with dependent children","Three adults and more","Three adults and more with dependent children"),
        names.arg = figure3$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 4
#################################################################################################################################################

# age of the reference person
avg_consumption_ageRP <- get_eurostat("hbs_exp_t135", time_format = "num")
avg_consumption_ageRP <- avg_consumption_ageRP %>%
  filter(stat == "DMOM" & time == 2010 & geo %in% list_cty & age != "TOTAL") %>%
  arrange(geo, age) %>%
  rename(consumption = values)
  
str_consumption_ageRP <- get_eurostat("hbs_str_t225", time_format = "num")
str_consumption_ageRP <- mutate(str_consumption_ageRP,
                                coicop = as.character(coicop),
                                coicop = substr(coicop, 3, nchar(coicop)),
                                lv = nchar(coicop) - 1, 
                                share = values/1000)
str_consumption_ageRP <- filter(str_consumption_ageRP, geo %in% list_cty & time == 2010 & lv == 2)

consumption_ageRP <- merge(str_consumption_ageRP, avg_consumption_ageRP, by = c("geo", "time","age"))
consumption_ageRP <- mutate(consumption_ageRP,
                            consumption = consumption*share)
consumption_ageRP <- merge(consumption_ageRP, rateLv2, by = c("geo","coicop"))
consumption_ageRP <- mutate(consumption_ageRP,
                            vat = consumption*vatRate/(100 + vatRate))
vat_ageRP <- consumption_ageRP %>%
  group_by(geo, age) %>%
  summarise(vat = sum(vat),
            consumption_pc = sum(consumption))

vat_ageRP <- mutate(vat_ageRP,
                    vatRate = round(vat/(consumption_pc - vat)*100, digits = 2))

figure4 <- dcast(vat_ageRP, geo~age, value.var = "vatRate")
figure4 <- merge(figure4, countryOrder, by.x = "geo", by.y = "Country")
figure4 <- arrange(figure4, Protocol_order)

barplot(t(figure4[,3:6]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("Less than 30","Between 30 and 44","Between 45 and 60","60 and more"),
        names.arg = figure4$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 5
#################################################################################################################################################

vat_rate <- get_eurostat("icw_tax_01", time_format = "num")
figure5 <- vat_rate %>%
  filter(quantile == "MED" & age == "TOTAL") %>%
  rename(vatRate = values) %>%
  arrange(vatRate)

barplot(t(figure5[,6]), beside = TRUE, col = col1, main = NA,
        border = NA,
        names.arg = figure5$geo, cex.names = 0.5)

#################################################################################################################################################
### FIGURE 6
#################################################################################################################################################

vat_rate_incQ <- get_eurostat("icw_tax_03", time_format = "num")
vat_rate_incQ <- filter(vat_rate_incQ, quantile == "MED" & quant_inc != "TOTAL")

figure6 <- dcast(vat_rate_incQ, geo~quant_inc, value.var = "values")
figure6 <- merge(figure6, countryOrder, by.x = "geo", by.y = "Country")
figure6 <- arrange(figure6, Protocol_order)

barplot(t(figure6[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), main = NA,
        border = NA, legend.text = paste0("Q",1:5),
        names.arg = figure6$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 7
#################################################################################################################################################

vat_rate_hhtyp <- get_eurostat("icw_tax_02", time_format = "num")
vat_rate_hhtyp <- filter(vat_rate_hhtyp, quantile == "MED" & hhcomp != "TOTAL")

figure7 <- dcast(vat_rate_hhtyp, geo~hhcomp, value.var = "values")
figure7 <- merge(figure7, countryOrder, by.x = "geo", by.y = "Country")
figure7 <- arrange(figure7, Protocol_order)

barplot(t(figure7[,2:7]), beside = TRUE, col = c(col1, col1_faded, col2, col2_faded,
                                                 col3, col3_faded), main = NA,
        border = NA, legend.text = c("One adult","One adult with dependent children","Two adults",
                                     "Two adults with dependent children","Three adults and more","Three adults and more with dependent children"),
        names.arg = figure7$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 8
#################################################################################################################################################

vat_rate_ageRP <- get_eurostat("icw_tax_01", time_format = "num")
vat_rate_ageRP <- filter(vat_rate_ageRP, quantile == "MED" & age != "TOTAL")

figure8 <- dcast(vat_rate_ageRP, geo~age, value.var = "values")
figure8 <- merge(figure8, countryOrder, by.x = "geo", by.y = "Country")
figure8 <- arrange(figure8, Protocol_order)

barplot(t(figure8[,2:5]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("Less than 30","Between 30 and 44","Between 45 and 60","60 and more"),
        names.arg = figure8$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 9
#################################################################################################################################################

taxNA <- get_eurostat("gov_10a_taxag", time = "num")
taxNA <- filter(taxNA,
                sector == "S13" & na_item %in% c("D211","D51A","D613","D59A") & unit == "MIO_EUR")
taxNA <- taxNA %>%
  group_by(geo, time) %>%
  summarise(values_tax = sum(values, na.rm = TRUE))

inc <- get_eurostat("nasa_10_nf_tr", time = "num")
inc <- filter(inc,
              sector %in% c("S14","S14_S15") & na_item %in% c("B6G","D5","D613") & unit == "CP_MEUR" & direct == "PAID")
inc <- dcast(geo+time+na_item~sector, data = inc, value.var = "values")

correction_sector <- inc %>%
  filter(!is.na(S14)) %>%
  group_by(time, na_item) %>%
  summarise(correction_sector = mean(S14/S14_S15))
inc <- merge(inc, correction_sector, by = c("time","na_item"))

inc <- mutate(inc,
              values = ifelse(is.na(S14), 
                              ifelse(S14_S15 == 0, 0, S14_S15*correction_sector), S14))
inc <- inc %>%
  group_by(geo, time) %>%
  summarise(values_inc = sum(values))
taxNA <- merge(select(taxNA, geo, time, values_tax), select(inc, geo, time, values_inc))

taxNA <- taxNA %>%
  mutate(tax_rate_na = round(values_tax/(values_inc)*100, digits = 2)) %>%
  mutate(geo = as.character(geo)) %>%
  filter(nchar(geo) == 2) %>%
  arrange(geo)

taxSurvey <- get_eurostat("icw_tax_07", time_format = "num")
taxSurvey <- taxSurvey %>%
  filter(quantile == "MED" & age == "TOTAL") %>%
  select(geo, time, values) %>%
  rename(tax_rate_survey = values)

figure9 <- merge(taxNA, taxSurvey, by = c("geo","time"), all.y = TRUE)
figure9 <- arrange(figure9, tax_rate_survey)

barplot(t(figure9[,c("tax_rate_survey","tax_rate_na")]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("Median", "Aggregate"),
        names.arg = figure9$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 10
#################################################################################################################################################

tax_rate_incQ <- get_eurostat("icw_tax_09", time_format = "num")
tax_rate_incQ <- filter(tax_rate_incQ, quantile == "MED" & quant_inc != "TOTAL")

figure9 <- dcast(tax_rate_incQ, geo~quant_inc, value.var = "values")
figure9 <- merge(figure9, countryOrder, by.x = "geo", by.y = "Country")
figure9 <- arrange(figure9, Protocol_order)

barplot(t(figure9[,2:6]), beside = TRUE, col = c(col1, col2, col3, col4, col5), main = NA,
        border = NA, legend.text = paste0("Q",1:5),
        names.arg = figure9$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 11
#################################################################################################################################################

tax_rate_hhtyp <- get_eurostat("icw_tax_08", time_format = "num")
tax_rate_hhtyp <- filter(tax_rate_hhtyp, quantile == "MED" & hhcomp != "TOTAL")

figure11 <- dcast(tax_rate_hhtyp, geo~hhcomp, value.var = "values")
figure11 <- merge(figure11, countryOrder, by.x = "geo", by.y = "Country")
figure11 <- arrange(figure11, Protocol_order)

barplot(t(figure11[,2:7]), beside = TRUE, col = c(col1, col1_faded, col2, col2_faded,
                                                  col3, col3_faded), main = NA,
        border = NA, legend.text = c("One adult","One adult with dependent children","Two adults",
                                     "Two adults with dependent children","Three adults and more","Three adults and more with dependent children"),
        names.arg = figure11$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))

#################################################################################################################################################
### FIGURE 12
#################################################################################################################################################

tax_rate_ageRP <- get_eurostat("icw_tax_07", time_format = "num")
tax_rate_ageRP <- filter(tax_rate_ageRP, quantile == "MED" & age != "TOTAL")

figure12 <- dcast(tax_rate_ageRP, geo~age, value.var = "values")
figure12 <- merge(figure12, countryOrder, by.x = "geo", by.y = "Country")
figure12 <- arrange(figure12, Protocol_order)

barplot(t(figure12[,2:5]), beside = TRUE, col = c(col1, col2, col3, col4), main = NA,
        border = NA, legend.text = c("Less than 30","Between 30 and 44","Between 45 and 60","60 and more"),
        names.arg = figure12$geo, cex.names = 0.5,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))



