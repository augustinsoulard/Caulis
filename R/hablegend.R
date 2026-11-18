#' @title Partie avant le premier tiret
#' @description Extrait la partie d'une chaîne située avant le premier tiret "-".
#' @param x Chaîne de caractères (code EUNIS par exemple).
#' @return La partie avant le premier tiret, ou "" si NA.
#' @export
left_until_dash <- function(x) {
  if (is.na(x)){return("")} else{
    y = str_sub(x, 1, str_locate(x, "-")[1] - 1)
    return(y)
  }
}

#' @title Partie après le premier tiret
#' @description Extrait la partie d'une chaîne située après le premier tiret "-".
#' @param x Chaîne de caractères (code EUNIS par exemple).
#' @return La partie après le premier tiret, ou "" si NA.
#' @export
right_after_dash <- function(x) {
  if (is.na(x)) return("")
  str_sub(x, str_locate(x, "-")[1] + 1, str_length(x))
}

#' @title Construction de la légende habitat (hablegend)
#' @description Construit la légende hablegend à partir des codes EUNIS 1 et 2 et du libellé habitat.
#' @param hablabel Libellé de l'habitat (habitat remarquables, etc.).
#' @param eunis1 Premier code EUNIS.
#' @param eunis2 Second code EUNIS (optionnel).
#' @return Un data.frame avec les colonnes eunis1, eunis2, hablabel, hablegend.
#' @export
hablegendation <- function(hablabel, eunis1, eunis2){
  HAB = data.frame(
                   eunis1 = as.character(eunis1),
                   eunis2 = as.character(eunis2),
                   hablabel = as.character(hablabel),
                   hablegend = NA_character_
  )
  for(i in 1:nrow(HAB)){
    if(is.na(HAB$eunis1[i])){
      HAB$hablegend[i]  = HAB$hablabel[i]
    } else {
      if(is.na(HAB$eunis2[i])){
        if(is.na(HAB$hablabel[i])){
          HAB$hablegend[i] = HAB$eunis1[i]
        } else{
          HAB$hablegend[i] = paste0(left_until_dash(HAB$eunis1[i]),'-',hablabel[i])
        }

      }else{
        if(is.na(HAB$hablabel[i])){
          HAB$hablegend[i] = paste0(left_until_dash(HAB$eunis1[i]),'x',left_until_dash(HAB$eunis2[i]),'-',
                                    right_after_dash(HAB$eunis1[i]),' x ',right_after_dash(HAB$eunis2[i]))
        } else{
          HAB$hablegend[i] = paste0(left_until_dash(HAB$eunis1[i]),'x',left_until_dash(HAB$eunis2[i]),'-',
                                    HAB$hablabel[i])
        }
      }
    }
  }

  HAB$hablegend = str_replace_all(HAB$hablegend, "<em>|</em>", "")
  return(HAB)
}
