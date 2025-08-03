# Chargement des bibliothèques nécessaires
library(shiny)
library(tidyr)
library(dplyr)
library(DT)        # Pour les tableaux interactifs
library(ape)       # Pour la visualisation de l'arbre de classification
library(data.table) # Pour utiliser dcast()
library(vegan)     # Pour NMDS et analyse de similarité

# Fonction pour convertir les codes Braun-Blanquet en valeurs numériques (ex: '+' = 1, '1' = 2, etc.)
convert_bb <- function(x) {
  bb_codes <- c("+" = 1, "1" = 2, "2" = 3, "3" = 4, "4" = 5, "5" = 6)
  return(as.numeric(bb_codes[as.character(x)]))
}

# Interface utilisateur principale (barre de navigation)
ui <- navbarPage("Application Phytosociologique",
                 
                 # Onglet principal pour l'analyse
                 tabPanel("Analyse",
                          sidebarLayout(
                            sidebarPanel(
                              fileInput("file", "Charger un fichier CSV", accept = ".csv"),
                              actionButton("run", "Lancer l'analyse"),
                                                          ),
                            mainPanel(
                              tabsetPanel(
                                tabPanel("Données brutes (head)", tableOutput("data_head")),
                                tabPanel("Données pivotées", DTOutput("pivoted_data"),downloadButton("download_pivoted", "Télécharger les données pivotées")),
                                tabPanel("Classification", plotOutput("clustering_plot")),
                                tabPanel("Ordination (NMDS)", plotOutput("nmds_plot"))
                              )
                            )
                          )
                 ),
                 
                 # Onglet séparé pour visualiser les espèces par relevé
                 tabPanel("Liste des espèces par relevé",
                          DTOutput("especes_par_releve")
                 )
)

# Partie serveur de l'application
server <- function(input, output) {
  
  # Lecture du fichier CSV avec séparateur ';'
  data_input <- reactive({
    req(input$file)
    read.csv(input$file$datapath, stringsAsFactors = FALSE, sep = ";")
  })
  
  output$data_head <- renderTable({
    head(data_input(), 10)
  })
  
  data_pivoted <- eventReactive(input$run, {
    df <- data_input()
    colnames(df) <- tolower(colnames(df))
    required_cols <- c("releve", "espece", "strate", "abondance_dominance")
    missing_cols <- setdiff(required_cols, names(df))
    if (length(missing_cols) > 0) {
      stop(paste("Colonnes manquantes dans le fichier :", paste(missing_cols, collapse = ", ")))
    }
    df <- df %>%
      mutate(abondance_dominance = trimws(as.character(abondance_dominance))) %>%
      mutate(abondance = convert_bb(abondance_dominance)) %>%
      filter(!is.na(abondance)) %>%
      mutate(espece_strate = paste0(espece, "_", strate))
    df_dt <- as.data.table(df)
    df_pivot <- dcast(
      df_dt,
      releve ~ espece_strate,
      value.var = "abondance",
      fun.aggregate = sum,
      fill = 0
    )
    df_pivot <- as.data.frame(df_pivot)
    rownames(df_pivot) <- df_pivot$releve
    df_pivot <- df_pivot[ , !(names(df_pivot) %in% c("releve"))]
    df_pivot[] <- lapply(df_pivot, as.numeric)
    attr(df_pivot, "releve") <- df_dt[, unique(releve)]
    return(df_pivot)
  })
  
  output$pivoted_data <- renderDT({
    req(data_pivoted())
    datatable(data_pivoted(), options = list(pageLength = 10))
  })
  
  output$download_pivoted <- downloadHandler(
    filename = function() {
      paste0("donnees_pivotees_", Sys.Date(), ".csv")
    },
    content = function(file) {
      df <- data_pivoted()
      releve <- attr(df, "releve")
      df_export <- cbind(releve = releve, df)
      write.csv2(df_export, file, row.names = FALSE)
    }
  )
  
  # Classification hiérarchique
  output$clustering_plot <- renderPlot({
    mat <- data_pivoted()
    dist_mat <- vegdist(mat, method = "bray")
    clust <- hclust(dist_mat, method = "ward.D2")
    plot(clust, main = "Classification hiérarchique (Bray-Curtis)", xlab = "", sub = "")
  })
  
  # Ordination NMDS
  output$nmds_plot <- renderPlot({
    mat <- data_pivoted()
    nmds <- metaMDS(mat, k = 2, trymax = 100, autotransform = FALSE)
    plot(nmds, type = "t", main = "Ordination NMDS")
  })
  
  output$especes_par_releve <- renderDT({
    req(data_input())
    df <- data_input()
    colnames(df) <- tolower(colnames(df))
    required_cols <- c("releve", "espece", "strate", "abondance_dominance")
    missing_cols <- setdiff(required_cols, names(df))
    if (length(missing_cols) > 0) {
      return(DT::datatable(data.frame(Erreur = paste("Colonnes manquantes:", paste(missing_cols, collapse=", ")))))
    }
    datatable(df %>% dplyr::select(releve, espece, strate, abondance_dominance), options = list(pageLength = 10))
  })
}

shinyApp(ui = ui, server = server)
