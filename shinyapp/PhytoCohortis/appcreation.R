# remotes::install_github("ficonsulting/RInno")

trace(RInno:::get_R, edit = TRUE) # if (latest_R_version == R_version)>>>>if (!is.null(latest_R_version) && latest_R_version == R_version)



my_create_app <- function(
    app_name = "myapp",
    app_dir = getwd(),
    app_port = 1984,
    dir_out = "RInno_installer",
    pkgs = c("jsonlite", "shiny", "magrittr"),
    pkgs_path = "bin",
    repo = "https://cran.rstudio.com",
    remotes = "none",
    app_icon = NULL,
    R_version = "4.4.0",
    include_R = TRUE,
    include_Pandoc = FALSE,
    include_Chrome = FALSE,
    include_Rtools = FALSE,
    ...
) {
  # Préparation
  if (!dir.exists(app_dir)) dir.create(app_dir, recursive = TRUE)
  copy_installation(app_dir, overwrite = TRUE)
  
  # Téléchargement R si demandé
  if (include_R) get_R(app_dir, R_version)
  
  # Suite normale
  create_bat(app_name, app_dir)
  create_config(app_name, app_dir, pkgs = pkgs, pkgs_path = pkgs_path,
                remotes = remotes, repo = repo,
                user_browser = "electron")
  
  start_iss(app_name) %>%
    directives_section(include_R, R_version,
                       include_Pandoc, rmarkdown::pandoc_version(),
                       include_Chrome, include_Rtools, "4.0",
                       app_version = "1.0.0") %>%
    setup_section(app_dir, dir_out) %>%
    languages_section() %>%
    tasks_section(desktop_icon = TRUE) %>%
    icons_section(app_dir, app_icon = app_icon) %>%
    files_section(app_name, app_dir, user_browser = "electron") %>%
    run_section() %>%
    code_section(R_version) %>%
    writeLines(file.path(app_dir, paste0(app_name, ".iss")))
  
  check_app(app_dir, pkgs_path)
}


library(RInno)
my_create_app(
  app_name = "PhytoCohortis",
  app_dir = "D:/Github/Caulis/shinyapp/phytocohortis",
  include_R = TRUE,
  R_version = "4.4.0",
  pkgs = c("shiny", "dplyr", "ggplot2","ggrepel","tidyr","DT","ape","data.table","vegan","indicspecies"),
  app_icon = "D:/Github/Caulis/shinyapp/phytocohortis.ico"
)

RInno::create_app(  # ou ta fonction patchée
  app_name = "PhytoCohortis",
  app_dir = "D:/Github/Caulis/shinyapp/phytocohortis",
  include_R = TRUE,
  R_version = "4.4.0",  # ou autre version déjà téléchargée
  pkgs = c("shiny", "dplyr", "ggplot2", "ggrepel", "tidyr", "DT", "ape", "data.table", "vegan", "indicspecies"),
  app_icon = "D:/Github/Caulis/shinyapp/phytocohortis.ico"
)

compile_iss()