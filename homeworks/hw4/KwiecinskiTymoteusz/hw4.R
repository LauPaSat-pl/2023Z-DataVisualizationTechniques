getwd()
library(plotly)
library(dplyr)

setwd("C:\\Users\\tymot\\OneDrive - Politechnika Warszawska\\semestr III\\twd\\hw4")
data <- read.csv("Properties_philly_Kraggle_v2.csv")

# nasz pierwszy wykres b�dzie animowa� �rednie ceny w zale�no�ci od roku 

accumulate_by <- function(dat, var) { # funkcja tworzy kolumne frame, kt�ra �adnie rysuje nam kreski
  var <- lazyeval::f_eval(var, dat)
  lvls <- plotly:::getLevels(var)
  dats <- lapply(seq_along(lvls), function(x) {
    cbind(dat[var %in% lvls[seq(1, x)], ], frame = lvls[[x]])
  })
  dplyr::bind_rows(dats)
}


# funkcja pomaga wykona� podsumowanie - czy�ci nasze dane
convert_string <- function(str, opt) {
  if(opt == "sale_price"){
    str <- substring(str, 2)
  }
  if(opt == "zillow"){
    str <- gsub("\\.", "", str)
    
  }
  str <- gsub(",", ".", str)
  str <- as.numeric(str)*1000
  return(str)
}



prices <- data %>% filter(yearBuilt >= 1900) %>% 
  mutate(Sale.Price.bid.price = convert_string(Sale.Price.bid.price, "sale_price")) %>% 
  mutate(Zillow.Estimate = convert_string(Zillow.Estimate, "zillow")) %>% 
  group_by(yearBuilt) %>% 
  summarize(Sale.Price.bid.price = mean(Sale.Price.bid.price),
            Zillow.Estimate = mean(Zillow.Estimate),
            Opening.Bid = mean(Opening.Bid)) %>% 
  accumulate_by(~yearBuilt)


 fig <- prices %>% 
   plot_ly(type = "scatter", 
          mode = "lines",
          x = ~yearBuilt,
          y = ~Opening.Bid,
          frame = ~frame,
          line = list(simplyfy = F),
          text = "Stawka otwieraj�ca",
          name = "Kwota otwieraj�ca licytacje",
          visible = TRUE) %>% 
   add_trace(type = "scatter", 
             mode = "lines",
             x = ~yearBuilt,
             y = ~Sale.Price.bid.price,
             frame = ~frame,
             line = list(simplyfy = F),
             text = "Stawka zamykaj�ca",
             name = "Kwota zamykaj�ca licytacje",
             visible = TRUE) %>% 
   add_trace(type = "scatter", 
             mode = "lines",
             x = ~yearBuilt,
             y = ~Zillow.Estimate,
             frame = ~frame,
             line = list(simplyfy = F),
             text = "Wska�nik Zillow",
             name = "Szacowana aktualna warto��",
             visible = TRUE) %>% 
   layout(xaxis = list(title = "Rok wybudowania posiad�o�ci",
                   zeroline = FALSE),
          yaxis = list(title = "Kwota w dolarach",
                   zeroline = FALSE),
          title = "Por�wnanie parametr�w posiad�o�ci w zale�no�ci od roku budowy",
          legend = list(title=list(text='<b> Wybrane parametry </b>'))) %>% 
   animation_opts(frame = 100, 
                 transition = 0, 
                 redraw = TRUE
               ) %>% 
  animation_button(x = 1.5, y = 0.5, label = "odtw�rz animacj�") %>%
  animation_slider(hide = TRUE)

 fig
 
 
 saveWidget(fig, "p1.html", selfcontained = F, libdir = "lib")
 # drugi wykres - akumulacyjna animacja liczby dom�w danego typu w latach
 
 

 
 house_types <- data %>% 
   group_by(PropType, yearBuilt) %>% 
   summarize(number  = n()) %>% 
   filter(PropType != "") %>% 
   accumulate_by(~yearBuilt) 
 
 house_types[nrow(house_types) + 1, ] = list("MultiFamily2To4", 0, 1, 0)
 house_types[nrow(house_types) + 1, ] = list("Condominium", 0, 2, 0)
 
 # teraz dodajemy r�cznie k
   
 
 
 fig <- house_types %>% 
   plot_ly( y = ~number,
            x = ~PropType,
            frame = ~frame,
            type = "bar")%>% 
   layout(
     yaxis = list(
       range= c(0, 300),
       title = "liczba wybudowanych dom�W"),
     xaxis = list(
       title = "typ domu"),
     title = "Liczba wybudowanych dom�w ka�dego nie p�niej ni� w danym roku"
   ) %>% 
   animation_opts(frame = 100, 
                  transition = 1, 
                  redraw = FALSE )   %>% 
   animation_button(x = 1.5, y = 0.5, label = "odtw�rz animacj�") %>%
   animation_slider(currentvalue = list(prefix = "rok: "))
   

 fig 
 
 saveWidget(fig, "p2.html", selfcontained = F, libdir = "lib")
 