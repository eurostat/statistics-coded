############################################################################################################
# Scripts for computing figures and generating graphs in Statistics Explained article
# http://ec.europa.eu/eurostat/statistics-explained/index.php?title=Households%27_income,_consumption_and_wealth,_and_how_they_interact_-_statistics_on_main_results
# Run on R 64-bits 3.3.1


library(dplyr)
library(haven)
library(Cairo)
library(eurostat)
library(reshape2)
library(plot3D)

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

joint_dist <- get_eurostat("icw_sr_07", time_format = "num")
jointDist <- filter(joint_dist, 
                    geo == "BE")
jointDist <- mutate(jointDist,
                    q_inc = as.numeric(substr(quant_inc,2,3)),
                    q_exp = as.numeric(substr(quant_expn,2,3)))
matJointDist <- acast(data = jointDist, q_exp~q_inc, value.var = "values")/10

hist3D(1:10,1:10, matJointDist, xlab = "Income", ylab = "Consumption", 
       border = "grey", space = 0.2)

#################################################################################################################################################
### FIGURE 2
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
figure2 <- merge(indicators_sr[,c("geo","sr_med")], indicators_agg[,c("geo","sr_agg")])
figure2 <- figure2[order(figure2$sr_med),]

barplot(t(figure2[,2:3]), beside = TRUE, col = c(col1, col2), main = NA,
        border = NA, legend.text = c("Median saving rate", "Aggregate saving rate"),
        names.arg = figure2$geo, cex.names = 0.5, ylim = c(-20,50), cex.axis = 0.7,
        args.legend = list(x = "topleft", bty = "n", border = NA, cex = 0.5))


#################################################################################################################################################
### FIGURE 3
#################################################################################################################################################

indicators_sr <- get_eurostat("icw_sr_08", time_format = "num")
sr_na <- get_eurostat("nasa_10_ki", time_format = "num")
sr_agg <- filter(indicators_sr,
                 age == "TOTAL")
sr_na_2010 <- filter(sr_na,
                     time == 2010 & sector == "S14_S15" & na_item == "SRG_S14_S15")

sr_na_2010 <- mutate(sr_na_2010,
                     sr_na = values)
sr_agg <- mutate(sr_agg,
                 sr_agg = 100 - values)
sr <- merge(sr_agg, sr_na_2010, by = "geo")

plot(sr$sr_agg, sr$sr_na, type = "p", pch = 18, col = col1, bty = "n", xaxt="n",yaxt="n", 
     xlim = c(0,50), ylim = c(-5,20), xlab = NA, ylab = NA)
grid(nx = NA, ny = NULL)
axis(1,pos=0)
axis(2,pos=0, tick = FALSE, las = 1)
text(sr$sr_agg, sr$sr_na, labels = sr$geo, cex = 0.7, pos = 3)


### alternative: account for imputed rents

accounts_NA <- get_eurostat("nasa_10_nf_tr", time_format = "num")

# imputed rents (B2G)
b2g_s1415 <- filter(accounts_NA,
                    unit == "CP_MEUR" & na_item == "B2G" & sector == "S14_S15")
b2g_s1415_paid <- filter(b2g_s1415,
                         direct == "PAID")
b2g_s1415_received <- filter(b2g_s1415,
                             direct == "RECV")
b2g_s1415_paid <- mutate(b2g_s1415_paid,
                         b2g_paid = as.numeric(values))
b2g_s1415_received <- mutate(b2g_s1415_received,
                             b2g_received = as.numeric(values))
b2g_s1415_paid <- b2g_s1415_paid[, c("geo","time","sector","unit","b2g_paid")]
b2g_s1415_received <- b2g_s1415_received[, c("geo","time","sector","b2g_received")]
b2n_s1514 <- merge(b2g_s1415_paid, b2g_s1415_received)

# expenditures (P31)
p31_s1415 <- filter(accounts_NA,
                    unit == "CP_MEUR" & na_item == "P31" & sector == "S14_S15")
p31_s1415 <- mutate(p31_s1415,
                    p31 = as.numeric(values))
p31_s1415 <- p31_s1415[, c("geo","time","sector","p31")]

# gross disposable income (B6G)
b6g_s1415 <- filter(accounts_NA,
                    unit == "CP_MEUR" & na_item == "B6G" & sector == "S14_S15" & direct == "RECV")
b6g_s1415 <- mutate(b6g_s1415,
                    b6g = as.numeric(values))
b6g_s1415 <- b6g_s1415[, c("geo","time","sector","b6g")]

# adjustement for the change in net equity of pensions funds
d8_s1415 <- filter(accounts_NA,
                   unit == "CP_MEUR" & na_item == "D8" & sector == "S14_S15")
d8_s1415_paid <- filter(d8_s1415,
                        direct == "PAID")
d8_s1415_received <- filter(d8_s1415,
                            direct == "RECV")
d8_s1415_paid <- mutate(d8_s1415_paid,
                        d8_paid = as.numeric(values))
d8_s1415_received <- mutate(d8_s1415_received,
                            d8_received = as.numeric(values))
d8_s1415_paid <- d8_s1415_paid[, c("geo","time","sector","unit","d8_paid")]
d8_s1415_received <- d8_s1415_received[, c("geo","time","sector","unit","d8_received")]
# merge, assuming missing as 0
d8n_s1415 <- merge(d8_s1415_paid, d8_s1415_received, all = TRUE)
d8n_s1415 <- mutate(d8n_s1415,
                    d8_received = ifelse(is.na(d8_received), 0, d8_received),
                    d8_paid = ifelse(is.na(d8_paid), 0, d8_paid),
                    d8n = d8_received - d8_paid)
d8n_s1415 <- d8n_s1415[, c("geo","time","sector","d8n")]

b8g_s1415 <- merge(p31_s1415, b6g_s1415)
b8g_s1415 <- merge(b8g_s1415, d8n_s1415)
b8g_s1415 <- merge(b8g_s1415, b2g_s1415_received)

b8g_s1415 <- mutate(b8g_s1415,
                    b8g = b6g + d8n - p31,
                    saving_rate_na = round(100*b8g/(b6g + d8n), digits = 1),
                    saving_rate_wo_imprent = round(100*b8g/(b6g + d8n - b2g_received), digits = 1)
)

sr <- merge(sr_agg, b8g_s1415,
            by = c("geo","time"))

plot(sr$sr_agg, sr$saving_rate_wo_imprent, type = "p", pch = 18, col = col1, bty = "n", xaxt="n",yaxt="n", 
     xlim = c(0,50), ylim = c(-5,20), xlab = NA, ylab = NA)
grid(nx = NA, ny = NULL)
axis(1,pos=0)
axis(2,pos=0, tick = FALSE, las = 1)
text(sr$sr_agg, sr$saving_rate_wo_imprent, labels = sr$geo, cex = 0.7, pos = 3)

