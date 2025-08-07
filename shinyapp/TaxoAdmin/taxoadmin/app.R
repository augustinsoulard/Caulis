library(shiny)
library(caulisroot) # ta fonction copo() doit être disponible

ui <- fluidPage(
  titlePanel("Taxref + CSV Loader"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("csv_file", "Charger un fichier CSV", accept = c(".csv")),
      selectInput("colonnenom", "Choisir la colonne de nom :", choices = NULL),
      selectInput("colonnecode", "Choisir une colonne de code (falcutatif) :", choices = NULL),
      actionButton("loadtaxref", "Charger Taxref (PostgreSQL)"),
      actionButton("runmatch", "Lancer le matching")
    ),
    mainPanel(
      tableOutput("taxref_table"),
      tableOutput("result_table"),
      verbatimTextOutput("csv_info")
    )
  )
)

server <- function(input, output, session) {
  # --- 1. Lecture du CSV chargé ---
  csv_data <- reactive({
    req(input$csv_file)
    read.csv(input$csv_file$datapath, stringsAsFactors = FALSE,sep=';', encoding = "UTF-8")
  })
  
  # --- 2. Affiche infos sur le CSV chargé ---
  output$csv_info <- renderPrint({
    req(csv_data())
    paste0(
      "Lignes : ", nrow(csv_data()), "\n",
      "Colonnes : ", paste(names(csv_data()), collapse = ", ")
    )
  })
  
  # --- 3. Mise à jour du selectInput pour les colonnes ---
  observeEvent(csv_data(), {
    req(csv_data())
    cols <- names(csv_data())
    updateSelectInput(session, "colonnenom", choices = cols)
    updateSelectInput(session, "colonnecode", choices = c("", cols)) # "" = choix nul
  })
  
  # --- 4. Chargement et affichage d'un extrait de Taxref ---
  observeEvent(input$loadtaxref, {
    con <- copo()
    on.exit(DBI::dbDisconnect(con), add = TRUE)
    df <- DBI::dbGetQuery(con, "SELECT * FROM public.taxrefv18_fr_plantae_ref LIMIT 20")
    output$taxref_table <- renderTable(df)
  })
  
  # --- 5. Utilisation du matching (fonction find_taxaref) ---
  observeEvent(input$runmatch, {
    req(csv_data(), input$colonnenom)
    lb_taxa_entree <- csv_data()[[input$colonnenom]]
    # Colonne code facultative
    if (is.null(input$colonnecode) || input$colonnecode == "" || !(input$colonnecode %in% names(csv_data()))) {
      code_taxa_entree <- NA
    } else {
      code_taxa_entree <- csv_data()[[input$colonnecode]]
    }
    # Appel de la fonction caulisroot::find_taxaref
    result <- find_taxaref(
      lb_taxa_entree = lb_taxa_entree,
      code_taxa_entree = code_taxa_entree,
      ref = "taxref",
      input_ref = "gbif"
    )
    output$result_table <- renderTable(result)
  })
}

shinyApp(ui = ui, server = server)
