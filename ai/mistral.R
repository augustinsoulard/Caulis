# Le chargement du fichier .Renviron et de la librairie reste identique
chemin_renviron <- "G:/Mon Drive/Administratif/hz/.Renviron"
if (!readRenviron(chemin_renviron)) {
  stop("Le fichier .Renviron n'a pas pu être chargé. Vérifiez le chemin : ", chemin_renviron)
}

library(httr2)

# Fonction pour interroger l'API Mistral (version simplifiée)
mistral = function(question,
model = "mistral-large-latest",
temperature = 0.2){

Sys.setenv(MISTRAL_API_KEY = Sys.getenv("R_CODESTRAL_APIKEY"))
  
  api_key <- Sys.getenv("MISTRAL_API_KEY")
  if (api_key == "") {
    stop("La variable d'environnement MISTRAL_API_KEY n'est pas définie ou est vide.")
  }
  
  # Création et exécution de la requête (inchangé)
  req <- request("https://api.mistral.ai/v1/chat/completions") |>
    req_headers(
      "Authorization" = paste("Bearer", api_key),
      "Content-Type" = "application/json"
    ) |>
    req_body_json(
      list(
        model = model,
        messages = list(
          list(role = "user", content = question)
        ),
        temperature = temperature
      )
    )
  
  resp <- tryCatch({
    req_perform(req)
  }, error = function(e) {
    stop("Erreur de connexion ou erreur HTTP : ", e$message)
  })
  
  out <- resp_body_json(resp, simplifyVector = TRUE)
  
  # --- ACCÈS DIRECT ET SIMPLIFIÉ ---
  # On va chercher directement le contenu dans la colonne 'message.content'
  # de la première ligne du data.frame 'choices'. C'est tout !
 return(out$choices)
}
# --- Exemple d'utilisation ---
rep = mistral("Bonjour !")
rep$message$content
