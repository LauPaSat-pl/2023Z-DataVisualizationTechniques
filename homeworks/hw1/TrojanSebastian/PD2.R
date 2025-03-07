library(dplyr)

df <- read.csv("house_data.csv")

colnames(df)
dim(df)
apply(df, 2, function(x) sum(is.na(x))) # nie ma warto�ci NA w �adnej kolumnie

# 1. Jaka jest �rednia cena nieruchomo�ci z liczb� �azienek powy�ej mediany i po�o�onych na wsch�d od po�udnika 122W?
df %>%
  filter(bathrooms> median(bathrooms), long > -122) %>%
  summarise(mean = mean(price))
# Odp:  625499.4 USD

# 2. W kt�rym roku zbudowano najwi�cej nieruchomo�ci?
df %>%
  group_by(yr_built) %>%
  summarise(n = n()) %>%
  arrange(desc(n))

# Odp: W 2014 roku.

# 3. O ile procent wi�ksza jest mediana ceny budynk�w po�o�onych nad wod� w por�wnaniu z tymi po�o�onymi nie nad wod�?
df %>%
  filter(waterfront == 1) %>%
  summarise(mediana = median(price))
#mediana dla waterfront == 1 r�wna 1400000

df %>%
  filter(waterfront == 0) %>%
  summarise(mediana = median(price))
#mediana dla waterfront == 0 r�wna 450000

(1400000*100)/450000-100

# Odp: ~211,11%

#### 4. Jaka jest �rednia powierzchnia wn�trza mieszkania dla najta�szych nieruchomo�ci posiadaj�cych 1 pi�tro (tylko parter) wybudowanych w ka�dym roku?
df %>%
  filter(floors == 1) %>%
  group_by(yr_built) %>%
  slice_min(price) %>%
  ungroup() %>%
  summarise(mean = mean(sqft_living))

# Odp: 1030

# 5. Czy jest r�nica w warto�ci pierwszego i trzeciego kwartyla jako�ci wyko�czenia pomieszcze� pomi�dzy nieruchomo�ciami z jedn� i dwoma �azienkami? Je�li tak, to jak r�ni si� Q1, a jak Q3 dla tych typ�w nieruchomo�ci?
df %>%
  filter(bathrooms == 1) %>%
  summarise(quantile(grade))
#pierwszy kwantyl = 6, trzeci kwantyl = 7

#2 �azienki
df %>%
  filter(bathrooms == 2) %>%
  summarise(quantile(grade))
#pierwszy kwantyl = 7, trzeci kwantyl = 8


# Odp: R�nica mi�dzy Q1 to 1, a mi�dzy Q3 to 1.

# 6. Jaki jest odst�p mi�dzykwartylowy ceny mieszka� po�o�onych na p�nocy a jaki tych na po�udniu? (P�noc i po�udnie definiujemy jako po�o�enie odpowiednio powy�ej i poni�ej punktu znajduj�cego si� w po�owie mi�dzy najmniejsz� i najwi�ksz� szeroko�ci� geograficzn� w zbiorze danych)
punkt_srodkowy <- df %>%
  summarise(max = max(lat), min = min(lat)) %>%
  summarise(polowa = (max+min)/2)
#Punkt �rodkowy = 47.46675

kwantyle_polnoc <- df %>%
  filter(lat>punkt_srodkowy$polowa) %>%
  summarise(kwantyle = quantile(price))

kwantyle_polnoc$kwantyle[4]-kwantyle_polnoc$kwantyle[2]


kwantyle_poludnie <- df %>%
  filter(lat<punkt_srodkowy$polowa) %>%
  summarise(kwantyle = quantile(price))

kwantyle_poludnie$kwantyle[4]-kwantyle_poludnie$kwantyle[2]


# Odp: Odst�p na p�nocy 321000, odst�p na po�udniu 122500

# 7. Jaka liczba �azienek wyst�puje najcz�ciej i najrzadziej w nieruchomo�ciach niepo�o�onych nad wod�, kt�rych powierzchnia wewn�trzna na kondygnacj� nie przekracza 1800 sqft?
df %>%
  filter(waterfront == 0) %>%
  mutate(pow_na_kond = sqft_living/floors) %>%
  filter(pow_na_kond<=1800) %>%
  group_by(bathrooms) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  View

# Odp:Najcz�stsza liczba �azienek to 2.5, a najrzadsza to 4.75

# 8. Znajd� kody pocztowe, w kt�rych znajduje si� ponad 550 nieruchomo�ci. Dla ka�dego z nich podaj odchylenie standardowe powierzchni dzia�ki oraz najpopularniejsz� liczb� �azienek
mode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

df %>%
  group_by(zipcode) %>%
  summarise(ilosc_mieszkan = n(),moda = mode(bathrooms),sd = sd(sqft_lot)) %>%
  filter(ilosc_mieszkan > 550)%>%
  View

# Odp: Odchylenie standardowe dla kod�w pocztowych   98038,      98052,      98103,      98115,     98117,
# to odpowiednio                                     63111.112,  10276.188,  1832.009,   2675.302,  2318.662,
# a najpopularniejsza liczba �azienek to odpowiednio 2.5,        2.5,        1,          1,         1

# 9. Por�wnaj �redni� oraz median� ceny nieruchomo�ci, kt�rych powierzchnia mieszkalna znajduje si� w przedzia�ach (0, 2000], (2000,4000] oraz (4000, +Inf) sqft, nieznajduj�cych si� przy wodzie.
df %>%
  mutate(przedzialy = case_when(sqft_living <= 2000 ~ 1,
                                sqft_living > 4000 ~ 3,
                                 TRUE ~ 2)) %>%
  filter(waterfront == 0) %>%
  group_by(przedzialy) %>%
  summarise(mean = mean(price), median = median(price)) %>%
  View
# Odp: �redenia cen dla odpowiedznich przedia��w to: 385084.3,   645419.0,  1448118.8, 
# a median ceny to odpowiednio:                      359000,     595000,    1262750

# 10. Jaka jest najmniejsza cena za metr kwadratowy nieruchomo�ci? (bierzemy pod uwag� tylko powierzchni� wewn�trz mieszkania)
df %>%
  mutate(cena_za_stope = price/sqft_living/0.09) %>%
  summarise(min = min(cena_za_stope))
# przyjmuj�, �e 1 stopa^2 to 0.09 m^2


# Odp:973.2026 USD
