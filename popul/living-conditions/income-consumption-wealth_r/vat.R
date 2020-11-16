library(tidyverse)
library(reshape2)

path_data <- "" # folder where you store SILC/HBS data
path_matched <- "" # folder where you store the matched data

load("coicopVAT.RData")
load("VAThist.RData")

for (k in 1:length(list_cty)) {
  
  country <- list_cty[k]
  cat("Computation for", country, "\n")
  
  setwd(paste0(path,"/",country))
  
  load("expHBS.RData")
  
  exp_lv4 <- expHBS$coicop4
  
  load(paste0("silc_hbs_", country, ".RData"))
  year <- unique(hbs_h$HA02)
  
  rateByCoicop <- filter(coicopVAT,
                         Code == country)
  
  hist <- filter(VAThist,
                 Code == country)
  
  VATSelec <- hist[hist$year <= year,]
  VATSelec <- VATSelec %>%
    filter(year == max(year))
  
  VATSelec <- VATSelec[nrow(VATSelec),]
  
  VATSelec <- mutate(VATSelec,
                     RED2 = ifelse(is.na(RED2), RED1, RED2))
  
  VATSelec <- melt(VATSelec, id.vars = "Code", measure.vars = c("STD","SUPER","RED1","RED2"), variable.name = "VAT")
  
  rate <- merge(rateByCoicop, VATSelec, by.x = c("Code","VAT_rate"), by.y = c("Code","VAT"), all.x = TRUE)
  rate <- mutate(rate,
                 value = ifelse(VAT_rate %in% c("EXEMP","ZERO"), 0, value))
  
  rate <- rate[order(rate$CODE_LEVEL4),]
  
  rate <- rate[,c(4,8)]
  names(rate) <- c("coicop", "vatRate")
  
  save(rate, file = "rateByCoicop.RData")
  
  rateStd <- VATSelec[VATSelec$VAT == "STD", "value"]   
  
  exp_lv4 <- merge(exp_lv4, rate, by.x = "coicop_lv4", by.y = "coicop", all.x = TRUE)
  exp_lv4 <- mutate(exp_lv4,
                    vat = EUR_VALUE*vatRate/(100 + vatRate))
  
  vatPaid <- exp_lv4 %>%
    group_by(HA04) %>%
    summarise(vat = sum(vat),
              consumption_lv4 = sum(EUR_VALUE))
  
  cons_tot <- expHBS$coicop0 %>%
    rename(consumption = EUR_VALUE) %>%
    dplyr::select(HA04, consumption)
  
  vatPaid <- merge(vatPaid, cons_tot, by = "HA04")
  vatPaid <- mutate(vatPaid,
                    vat_final = vat + (consumption - consumption_lv4)*rateStd/(100 + rateStd))
  
  vatPaid <- dplyr::select(vatPaid, HA04, vat_final)
  vatPaid <- rename(vatPaid, vat = vat_final)
  
  setwd(paste0(path_matched, "/", country))
  load(paste0("id_matched_data_", country, ".RData"))
  idM <- melt(matched.data.id, id.vars = "HB030", measure.vars = 5:1004, variable.name = "im", value.name = "HA04")
  idM <- mutate(idM,
                im = as.numeric(substr(im, 7, 12)))
  
  vatPaid <- merge(idM, vatPaid)
  vatPaid <- vatPaid[order(vatPaid$HB030, vatPaid$im),]
  
  rm(idM)
  gc()
  
  load(paste0("matchedLong_Eurobase_", country, ".RData"))
  
  matchedDataLong <- merge(matchedDataLong, vatPaid)
  
  save(matchedDataLong, file = paste0("matchedLong_VAT_", country, ".RData"))
  
}