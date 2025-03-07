
# strona z której jest wykres: https://next.gazeta.pl/next/7,151003,29093054,inflacja-w-strefie-euro-jeszcze-nigdy-nie-byla-tak-wysoka-stopy.html#do_w=163&do_v=484&do_st=RS&do_sid=783&do_a=783&e=RelRecImg10
# nazwa wykresu: Inflation rates(%) measured by HICP

library(dplyr)
library(ggplot2)


country <- c("Belgium",
             "Germany",
             "Estonia",
             "Ireland",
             "Greece",
             "Spain",
             "France",
             "Italy",
             "Cyprus",
             "Latvia",
             "Lithuania",
             "Luxemburg",
             "Malta",
             "Netherlands",
             "Austria",
             "Portugal",
             "Slovenia",
             "Slovakia",
             "Finland")

oct21 <- c(5.4, 4.6, 6.8, 5.1, 2.8, 5.4, 3.2, 3.2, 4.4, 6, 8.2, 5.3, 1.4, 3.7, 3.8, 1.8, 3.5, 4.4, 2.8)
may22 <- c(9.9, 8.7, 20.1, 8.3, 10.5, 8.5, 5.8, 7.3, 8.8, 16.8, 18.5, 9.1, 5.8, 10.2, 7.7, 8.1, 8.7, 11.8, 7.1)
jun22 <- c(10.5, 8.2, 22, 9.6, 11.6, 10, 6.5, 8.5, 9, 19.2, 20.5, 10.3, 6.1, 9.9, 8.7, 9, 10.8, 12.6, 8.1)
jul22 <- c(10.4, 8.5, 23.2, 9.6, 11.3, 10.7, 6.8, 8.4, 10.6, 21.3, 29, 9.3, 6.8, 11.6, 9.4, 9.4, 11.7, 12.8, 8)
aug22 <- c(10.5, 8.8, 25.2, 9, 11.2, 10.5, 6.6, 9.1, 9.6, 21.4, 21.1, 8.6, 7, 13.7, 9.3, 9.3, 11.5, 13.4, 7.9)
sep22 <- c(12.1, 10.9, 24.1, 8.6, 12.1, 9, 6.2, 9.4, 9, 22, 22.5, 8.8, 7.4, 17.1, 10.9, 9.8, 10.6, 13.6, 8.4)
oct22 <- c(13.1, 11.6, 22.4, 9.6, 9.8, 7.3, 7.1, 12.8, 8.6, 21.8, 22, 8.8, 7.5, 16.8, 11.5, 10.6, 10.3, 14.5, 8.3)

monthly_rate <-  c(2.7, 1.1, -1.6, 1.7, -1, 0.1, 1.3, 4, 0.5, 0.9, 1.3, 1.2, -0.6, 1.3, 1.3, 1.1, 0.8, 1.3, 0.7)


df <- data.frame(country, oct21, may22, jun22, jul22, aug22, sep22, oct22)

df_longer <- df %>% 
  pivot_longer(!country, names_to = "date", values_to = "inflation")

df_mothly_rate <- data.frame(country, monthly_rate)

df_monthly_rate_longer <- df_mothly_rate %>% 
  pivot_longer(!country, names_to = "date", values_to = "inflation")



ggplot(df_longer, aes(inflation, country)) +
  geom_col() +
  facet_wrap(~date) + 
  labs(title = "Inflation rates(%) measured by HICP",
       x = "inflation in %")
  

ggplot(df_monthly_rate_longer, aes(inflation, country)) +
  geom_col() +
  facet_wrap(~date) +
  labs(title = "Monthly rate in October 22",
       x = "inflation in %")



#uzasadnienie
#
# Twierdze, ze wykres zaproponowany przeze mnie jest bardziej czytelny,
# poniewaz odbiorca nie jest przytloczony za duza iloscia informacji.
# W dodatku moze latwiej porownac rozne kraje w danych miesiacach,
# nie muszac przy tym orientowac sie w skomplikowanej tabeli.
# 
# 
# 
# 
# 
# 

  