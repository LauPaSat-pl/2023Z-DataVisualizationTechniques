# Rozwi�zanie: Zuzanna Pir�g

library(dplyr)

df <- read.csv("house_data.csv")

colnames(df)
dim(df)
apply(df, 2, function(x) sum(is.na(x))) # nie ma warto�ci NA w �adnej kolumnie

# 1. Jaka jest �rednia cena nieruchomo�ci z liczb� �azienek powy�ej mediany i po�o�onych na wsch�d od po�udnika 122W?
df %>% 
  filter(long > -122 & bathrooms > median(bathrooms)) %>% 
  summarise(srednia = mean(price))

# Odp:625499.4

# 2. W kt�rym roku zbudowano najwi�cej nieruchomo�ci?
df %>% 
  group_by(yr_built) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n)) %>% 
  select(yr_built) %>% 
  head(1)

# Odp: 2014

# 3. O ile procent wi�ksza jest mediana ceny budynk�w po�o�onych nad wod� w por�wnaniu z tymi po�o�onymi nie nad wod�?
df %>% 
  filter(waterfront == 1) %>% 
  summarise(mediana = median(price)) -> mediana_woda
df %>% 
  filter(waterfront == 0) %>% 
  summarise(mediana = median(price)) -> mediana_nie_woda
100 *(mediana_woda[1] - mediana_nie_woda[1])/ mediana_nie_woda[1]

# Odp: 211.1111 %

# 4. Jaka jest �rednia powierzchnia wn�trza mieszkania dla najta�szych nieruchomo�ci posiadaj�cych 1 pi�tro (tylko parter) wybudowanych w ka�dym roku?
df %>% 
  filter(floors == 1) %>% 
  group_by(yr_built) %>% 
  filter(price == min(price)) %>% 
  ungroup() %>% 
  summarise(wynik = mean(sqft_living))

# Odp:1030

# 5. Czy jest r�nica w warto�ci pierwszego i trzeciego kwartyla jako�ci wyko�czenia pomieszcze� pomi�dzy nieruchomo�ciami z jedn� i dwoma �azienkami? Je�li tak, to jak r�ni si� Q1, a jak Q3 dla tych typ�w nieruchomo�ci?
#nieruchomosci z jedn� �azienk�
df %>% 
  filter(bathrooms == 1 | bathrooms == 2) %>% 
  select(grade) -> df_grade
df_grade <- df_grade$grade
quantile(df_grade, probs = c(0.25, 0.75))

# Odp: tak, jest r�nica, pierwszy kwartyl wynosi 6 a trzeci wynosi 7

# 6. Jaki jest odst�p mi�dzykwartylowy ceny mieszka� po�o�onych na p�nocy a jaki tych na po�udniu? (P�noc i po�udnie definiujemy jako po�o�enie odpowiednio powy�ej i poni�ej punktu znajduj�cego si� w po�owie mi�dzy najmniejsz� i najwi�ksz� szeroko�ci� geograficzn� w zbiorze danych)
df %>% 
  arrange(lat) %>% 
  select(lat) %>% 
  head(1)-> min
df %>% 
  arrange(-lat) %>% 
  select(lat) %>% 
  head(1)-> max
min + (max - min)/2 -> center_df
center <- center_df[1,1]
center


#mieszkania na p�nocy

polnoc <- df %>% 
  filter(lat > center) %>% 
  select(price)
polnoc <- polnoc$price

polnoc <- quantile(polnoc, prob=c(0.25, 0.75))
wynik_n <- polnoc[2] - polnoc[1]
wynik_n


#mieszkania na po�udnie

poludnie <- df %>% 
  filter(lat < center) %>% 
  select(price)
poludnie <- poludnie$price

poludnie <- quantile(poludnie, prob=c(0.25, 0.75))
wynik_s <- poludnie[2] - poludnie[1]
wynik_s


# Odp: Na p�nocy odst�p mi�dzykwartylowy: 321000. Na po�udniu odst�p mi�dzykwartylowy: 122500

# 7. Jaka liczba �azienek wyst�puje najcz�ciej i najrzadziej w nieruchomo�ciach niepo�o�onych nad wod�, kt�rych powierzchnia wewn�trzna na kondygnacj� nie przekracza 1800 sqft?
df %>% 
  filter(waterfront == 0) %>% 
  mutate(pow_kondyg = sqft_living/floors) %>% 
  filter(pow_kondyg <= 1800) %>% 
  group_by(bathrooms) %>% 
  summarise(n = n()) %>% 
  arrange(n) -> bathroom_count
head(bathroom_count, 1) #najrzadziej �azienka

bathroom_count %>% 
  arrange(-n) %>% 
  head(1) #najcz�ciej �azienka


# Odp:Najcz�ciej wyst�puje 2.5 �azienek, a najrzadziej 4.75

# 8. Znajd� kody pocztowe, w kt�rych znajduje si� ponad 550 nieruchomo�ci. Dla ka�dego z nich podaj odchylenie standardowe powierzchni dzia�ki oraz najpopularniejsz� liczb� �azienek
df %>% 
  group_by(zipcode) %>% 
  summarise(n = n()) %>% 
  filter(n > 550) %>% 
  select(zipcode) -> kody 
kody_w <- kody[['zipcode']]
kody_w

df %>% 
  filter(zipcode %in% kody_w) %>% 
  group_by(zipcode) %>% 
  summarise(odchylenie = sd(sqft_lot)) -> odchylenie_pow_dzialki
odchylenie_pow_dzialki

df %>% 
  filter(zipcode %in% kody_w) %>% 
  group_by(zipcode, bathrooms) %>% 
  summarise(n = n()) %>% 
  top_n(1, n) %>% 
  select(zipcode, bathrooms)

# Odp:Odchylenie standardowe dla ka�dego zipkodu - 98038: 63111; 98052:10276;  98103:1832;  98115:2675;  98117: 2319
    # Najpopularniejsza liczba �azienek: 98038: 2.5 ; 98052: 2.5 ; 98103: 1 ;  98115:1 ; 98117:1

# 9. Por�wnaj �redni� oraz median� ceny nieruchomo�ci, kt�rych powierzchnia mieszkalna znajduje si� w przedzia�ach (0, 2000], (2000,4000] oraz (4000, +Inf) sqft, nieznajduj�cych si� przy wodzie.
#(0, 2000]
df %>% 
  filter(waterfront == 0) -> df_no_water

df_no_water %>% 
  filter(sqft_living <= 2000) %>% 
  summarise(mediana = median(price),
            srednia = mean(price)) ->df_0_2000
df_0_2000

#(2000, 4000]
df_no_water %>% 
  filter(sqft_living > 2000 & sqft_living <= 4000) %>% 
  summarise(mediana = median(price),
            srednia = mean(price)) ->df_2000_4000
df_2000_4000

df_no_water %>% 
  filter(sqft_living > 4000) %>% 
  summarise(mediana = median(price),
            srednia = mean(price)) ->df_2000_4000
df_2000_4000

# Odp: Najwi�ksza �rendia i mediana znajduje si� dla nieruchomo�ci o powierzchni mieszkalnej wi�Kszej ni� 4000 sqft, nast�pnie dla przedzia�u (2000,4000], a najni�sze ceny dla (0, 2000]
#      W ka�dym z przedzia��w �rednia jest wy�sza od mediany

# 10. Jaka jest najmniejsza cena za metr kwadratowy nieruchomo�ci? (bierzemy pod uwag� tylko powierzchni� wewn�trz mieszkania)

df %>% 
  mutate(metr_kw = price/(sqft_living/10.76)) %>% 
  select(metr_kw) %>% 
  arrange(metr_kw) %>% 
  head(1)

# Odp:942.4494
