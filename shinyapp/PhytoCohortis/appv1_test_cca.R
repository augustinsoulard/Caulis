# Chargement des bibliothèques nécessaires
library(ggplot2)
library(ggrepel)
library(shiny)
library(tidyr)
library(dplyr)
library(DT)        # Pour les tableaux interactifs
library(ape)       # Pour la visualisation de l'arbre de classification
library(data.table) # Pour utiliser dcast()
library(vegan)     # Pour NMDS et analyse de similarité
library(indicspecies) # Pour les espèces indicatrices avec multipatt()

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
                              HTML("Le tableau doit être un csv point-virgule et contenir les colonnes suivantes : releve, espece, strate,abondance_dominance.<br><br>"),
                              
                              uiOutput("select_releves"),
                              numericInput("n_clusters", "Nombre de groupes à identifier:", value = 2, min = 2),
                              actionButton("run", "Lancer l'analyse")
                            ),
                            mainPanel(
                              tabsetPanel(
                                tabPanel("Données brutes (head)", tableOutput("data_head")),
                                tabPanel("Données pivotées", DTOutput("pivoted_data"),downloadButton("download_pivoted", "Télécharger les données pivotées")),
                                tabPanel("Classification", plotOutput("clustering_plot")),
                                tabPanel("Ordination (NMDS)", plotOutput("nmds_plot")),
                                tabPanel("Espèces caractéristiques",
                                         HTML("<p><strong>Définition :</strong> Cette section utilise la fonction <code>multipatt()</code> du package <code>indicspecies</code> pour identifier les espèces les plus représentatives (indicatrices) des groupes de relevés définis par la classification hiérarchique. Elle calcule pour chaque espèce un score combinant sa fidélité (présence fréquente dans un groupe) et sa spécificité (présence exclusive dans ce groupe). Même sans p-value significative, une forte valeur d'indice peut indiquer une affinité marquée avec un groupe.</p>"),
                                         DTOutput("indval_table"),
                                         DTOutput("groupe_releves_table"),
                                         downloadButton("download_indval", "Télécharger les espèces caractéristiques"),
                                         downloadButton("download_groupes", "Télécharger les relevés par groupe")
                                )
                              )
                            )
                          )
                 ),
                 
               tabPanel("Analyse Canonique (CCA)",
                          sidebarLayout(
                            sidebarPanel(
                              h4("Prérequis"),
                              p("L'analyse floristique (1er onglet) doit avoir été lancée pour disposer de la matrice espèces/relevés."),
                              hr(),
                              h4("Données Environnementales"),
                              fileInput("file_env", "2. Charger les données environnementales (CSV)", accept = ".csv"),
                              helpText("Le fichier doit contenir une colonne avec les noms des relevés (identiques au 1er fichier) et des colonnes pour chaque variable environnementale."),
                              uiOutput("select_env_id_col"), # Pour choisir la colonne des relevés
                              uiOutput("select_env_vars"),  # Pour choisir les variables à utiliser
                              actionButton("run_cca", "Lancer la CCA")
                            ),
                            mainPanel(
                              tabsetPanel(
                                tabPanel("Données brutes (head)", tableOutput("data_env_head")),
                                tabPanel("Biplot CCA", plotOutput("cca_plot", height = "600px")),
                                tabPanel("Résumé de l'analyse", verbatimTextOutput("cca_summary")),
                                tabPanel("Test de permutation", verbatimTextOutput("cca_permutest"))
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
server <- function(input, output, session) {
  
  data_input <- reactive({
    req(input$file)
    read.csv(input$file$datapath, stringsAsFactors = FALSE, sep = ";")
  })
  
  output$data_head <- renderTable({
    head(data_input(), 10)
  })
  
  output$select_releves <- renderUI({
    req(data_input())
    releves <- unique(data_input()$releve)
    checkboxGroupInput("selected_releves", "Relevés à inclure:", choices = releves, selected = releves)
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
      filter(releve %in% input$selected_releves) %>%
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
  
  cluster_membership <- reactive({
    mat <- data_pivoted()
    dist_mat <- vegdist(mat, method = "bray")
    clust <- hclust(dist_mat, method = "ward.D2")
    cutree(clust, k = input$n_clusters)
  })
  
  output$clustering_plot <- renderPlot({
    mat <- data_pivoted()
    dist_mat <- vegdist(mat, method = "bray")
    clust <- hclust(dist_mat, method = "ward.D2")
    plot(clust, main = "Classification hiérarchique (Bray-Curtis)", xlab = "", sub = "")
    rect.hclust(clust, k = input$n_clusters, border = 2:6)
  })
  
  output$nmds_plot <- renderPlot({
    mat <- data_pivoted()
    groups <- factor(cluster_membership())
    nmds <- metaMDS(mat, k = 2, trymax = 100, autotransform = FALSE)
    nmds_sites <- as.data.frame(scores(nmds, display = "sites"))
    nmds_sites$label <- rownames(nmds_sites)
    nmds_sites$Groupe <- groups[rownames(nmds_sites)]
    
    stress_val <- round(nmds$stress, 3)
    
    ggplot(nmds_sites, aes(x = NMDS1, y = NMDS2)) +
      geom_point(aes(color = Groupe), size = 3) +
      ggrepel::geom_text_repel(aes(label = label), size = 3, max.overlaps = 100) +
      labs(title = "Ordination NMDS",
           subtitle = paste("Stress:", stress_val),
           x = "NMDS 1", y = "NMDS 2") +
      theme_minimal() +
      coord_equal()
  })
  
  
  output$indval_table <- renderDT({
    mat <- data_pivoted()
    groups <- factor(cluster_membership())
    if (length(unique(groups)) < 2) {
      return(datatable(data.frame(Message = "Moins de 2 groupes détectés")))
    }
    indval_res <- multipatt(mat, groups, func = "IndVal.g", duleg = TRUE, control = how(nperm = 999))
    indval_df <- as.data.frame(indval_res$sign)
    if (nrow(indval_df) == 0) {
      return(datatable(data.frame(Message = "Aucune espèce caractéristique détectée (p > 0.05)")))
    }
    indval_df$Espèce <- rownames(indval_df)
    indval_df <- indval_df %>%
      filter(p.value <= 0.05) %>%
      mutate(Groupe = index) %>%
      select(Espèce, Groupe, stat, p.value)
    colnames(indval_df) <- c("Espèce", "Groupe indicateur", "Indice IndVal", "p-value")
    datatable(indval_df, options = list(pageLength = 10, dom = 'Blfrtip'), filter = 'top')
  })
  
  output$groupe_releves_table <- renderDT({
    clusters <- cluster_membership()
    df_groupes <- data.frame(Releve = names(clusters), Groupe = clusters)
    df_summary <- df_groupes %>% 
      group_by(Groupe) %>% 
      summarise(Relevés = paste(Releve, collapse = ", "))
    datatable(df_summary, options = list(pageLength = 5))
  })
  
  output$download_indval <- downloadHandler(
    filename = function() {
      paste0("especes_caracteristiques_", Sys.Date(), ".csv")
    },
    content = function(file) {
      mat <- data_pivoted()
      groups <- factor(cluster_membership())
      indval_res <- multipatt(mat, groups, func = "IndVal.g", duleg = TRUE, control = how(nperm = 999))
      indval_df <- as.data.frame(indval_res$sign)
      indval_df$Espèce <- rownames(indval_df)
      indval_df <- indval_df %>%
        filter(p.value <= 0.05) %>%
        mutate(Groupe = index) %>%
        select(Espèce, Groupe, stat, p.value)
      colnames(indval_df) <- c("Espèce", "Groupe indicateur", "Indice IndVal", "p-value")
      write.csv2(indval_df, file, row.names = FALSE)
    }
  )
  
  output$download_groupes <- downloadHandler(
    filename = function() {
      paste0("releves_par_groupe_", Sys.Date(), ".csv")
    },
    content = function(file) {
      clusters <- cluster_membership()
      df_groupes <- data.frame(Releve = names(clusters), Groupe = clusters)
      df_summary <- df_groupes %>% 
        group_by(Groupe) %>% 
        summarise(Relevés = paste(Releve, collapse = ", "))
      write.csv2(df_summary, file, row.names = FALSE)
    }
  )
  ################################PARTIE ANALYSE CANONIQUE
  ########################################################
  
  
  # 1. Lecture du fichier de données environnementales
  env_data_input <- reactive({
    req(input$file_env)
    read.csv(input$file_env$datapath, stringsAsFactors = TRUE, sep = ";", row.names = NULL)
  })
  
  # 2. Création de l'UI pour choisir la colonne des relevés
  output$select_env_id_col <- renderUI({
    req(env_data_input())
    selectInput("env_id_col", "Colonne d'identification des relevés:", 
                choices = names(env_data_input()), selected = names(env_data_input())[1])
  })
  
  # 3. Création de l'UI pour choisir les variables à utiliser
  output$select_env_vars <- renderUI({
    req(env_data_input(), input$env_id_col)
    # On propose toutes les colonnes sauf celle qui sert d'identifiant
    var_choices <- setdiff(names(env_data_input()), input$env_id_col)
    checkboxGroupInput("selected_env_vars", "Variables environnementales à inclure:",
                       choices = var_choices, selected = var_choices)
  })
  
  # Aperçu des données environnementales (dynamique)
  output$data_env_head <- renderTable({
    # S'assurer que les données et les sélections sont disponibles
    req(env_data_input(), input$selected_env_vars, input$env_id_col)
    
    # Récupérer les données brutes
    env_df <- env_data_input()
    
    # Définir les colonnes à afficher : l'identifiant + les variables cochées
    cols_to_show <- c(input$env_id_col, input$selected_env_vars)
    
    # Sélectionner uniquement ces colonnes dans le dataframe
    # L'option drop = FALSE garantit que le résultat est toujours un dataframe
    selected_data <- env_df[, cols_to_show, drop = FALSE]
    
    # Afficher les 10 premières lignes des données filtrées
    head(selected_data, 10)
  })

  # 4. Calcul principal de la CCA (déclenché par le bouton)
  cca_results <- eventReactive(input$run_cca, {
    print("Le bouton CCA a été cliqué !")
    browser() # Ce browser devrait maintenant se déclencher

    # On vérifie que les données floristiques (data_pivoted) et environnementales sont prêtes
    req(data_pivoted(), env_data_input(), input$selected_env_vars, input$env_id_col)

    species_mat <- data_pivoted()
    env_df <- env_data_input()

    # Préparation des données environnementales
    # On met la colonne des relevés en tant que noms de ligne
    rownames(env_df) <- env_df[[input$env_id_col]]
    env_df_selected <- env_df[, input$selected_env_vars, drop = FALSE]
    browser()
    # S'assurer que les variables sélectionnées sont numériques
    is_numeric_col <- sapply(env_df_selected, is.numeric)
    if(any(!is_numeric_col)) {
      non_numeric_vars <- names(env_df_selected)[!is_numeric_col]
      showNotification(paste("Attention : les variables suivantes ne sont pas numériques et seront ignorées :",
                             paste(non_numeric_vars, collapse = ", ")), type = "warning")
      env_df_selected <- env_df_selected[, is_numeric_col, drop = FALSE]
    }

    if (ncol(env_df_selected) == 0) {
      showNotification("Aucune variable environnementale numérique valide sélectionnée.", type = "error")
      return(NULL)
    }

    # ÉTAPE CRUCIALE : Synchronisation des deux tableaux
    common_releves <- intersect(rownames(species_mat), rownames(env_df_selected))

    if (length(common_releves) < 2) {
      showNotification("Erreur: Moins de 2 relevés en commun entre les deux fichiers. Vérifiez les noms des relevés.", type = "error")
      return(NULL) # Stoppe l'exécution
    }

    # On filtre et ordonne les deux tableaux pour qu'ils correspondent parfaitement
    species_mat_synced <- species_mat[common_releves, ]
    env_df_synced <- env_df_selected[common_releves, ]

    # Exécution de la CCA
    cca(species_mat_synced ~ ., data = env_df_synced)
  })
  
  # 5. Affichage du graphique Biplot
  output$cca_plot <- renderPlot({
    cca_res <- cca_results()
    req(cca_res)
    
    # Extraction de la variance expliquée pour les titres des axes
    summary_cca <- summary(cca_res)
    cca1_percent <- round(summary_cca$concont$importance[2, 1] * 100, 1)
    cca2_percent <- round(summary_cca$concont$importance[2, 2] * 100, 1)
    axe_x_label <- paste0("CCA1 (", cca1_percent, "%)")
    axe_y_label <- paste0("CCA2 (", cca2_percent, "%)")
    
    # Extraction des scores pour ggplot
    df_sites <- as.data.frame(scores(cca_res, display = "sites"))
    df_env <- as.data.frame(scores(cca_res, display = "bp"))
    df_env$Variable <- rownames(df_env)
    
    # Création du graphique
    ggplot() +
      geom_point(data = df_sites, aes(x = CCA1, y = CCA2), color = "black", size = 3) +
      geom_text_repel(data = df_sites, aes(x = CCA1, y = CCA2, label = rownames(df_sites)), size = 3.5) +
      geom_segment(data = df_env, aes(x = 0, y = 0, xend = CCA1, yend = CCA2),
                   arrow = arrow(length = unit(0.25, "cm")), color = "red") +
      geom_text_repel(data = df_env, aes(x = CCA1, y = CCA2, label = Variable),
                      color = "red", size = 4, fontface = "bold") +
      labs(title = "Analyse Canonique des Correspondances (CCA)",
           x = axe_x_label, y = axe_y_label) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      theme_minimal(base_size = 14) +
      coord_equal()
  })
  
  # 6. Affichage du résumé de l'analyse
  output$cca_summary <- renderPrint({
    req(cca_results())
    summary(cca_results())
  })
  
  # 7. Affichage du test de permutation
  output$cca_permutest <- renderPrint({
    req(cca_results())
    # Utilisation de anova.cca qui est la méthode recommandée
    anova.cca(cca_results(), permutations = 999)
  })
  
  
  
  
  #########################################################
  
  
  
  
  output$especes_par_releve <- renderDT({
    req(data_input())
    df <- data_input()
    colnames(df) <- tolower(colnames(df))
    required_cols <- c("releve", "espece", "strate", "abondance_dominance")
    missing_cols <- setdiff(required_cols, names(df))
    if (length(missing_cols) > 0) {
      return(DT::datatable(data.frame(Erreur = paste("Colonnes manquantes:", paste(missing_cols, collapse=", ")))))
    }
    datatable(
      df %>% dplyr::select(releve, espece, strate, abondance_dominance),
      options = list(pageLength = 10, dom = 'Blfrtip'),
      filter = 'top'
    )
  })
}

shinyApp(ui = ui, server = server)
