rarete_occurence  <- function(data, col_cd_nom = "cd_nom", col_cd_hab = "cd_hab") {
  library(dplyr)
  
  # Fréquence des espèces
  freqs_especes <- data %>%
    group_by(!!sym(col_cd_nom)) %>%
    summarise(freq_espece = n()) %>%
    mutate(
      score_espece = (1+9*(max(freq_espece)-freq_espece)/(max(freq_espece)-min(freq_espece)))
    )
  
  # Fréquence des habitats
  freqs_habitats <- data %>%
    group_by(!!sym(col_cd_hab)) %>%
    summarise(freq_habitat = n()) %>%
    mutate(
      score_habitat = (3*(max(log(freq_habitat)) - log(freq_habitat)) / (max(log(freq_habitat)) - min(log(freq_habitat))))
    )
  
  # Fusion avec les scores
  data_scored <- data %>%
    left_join(freqs_especes %>% select(!!sym(col_cd_nom), score_espece), by = col_cd_nom) %>%
    left_join(freqs_habitats %>% select(!!sym(col_cd_hab), score_habitat), by = col_cd_hab) %>%
    mutate(score_total = score_espece + score_habitat)
  
  return(data_scored)
}
