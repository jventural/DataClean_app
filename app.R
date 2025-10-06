# Función para instalar y cargar paquetes
install_and_load <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
}

# Lista de paquetes requeridos
required_packages <- c(
  "shiny",
  "shinythemes",
  "shinyWidgets",
  "ThesiStats",
  "tidyverse",
  "readxl",
  "pwr",
  "openxlsx",
  "rlang",
  "DT"
)

# Instalar y cargar todos los paquetes
install_and_load(required_packages)

# =====================================================
# INTERFAZ DE USUARIO (UI)
# =====================================================

ui <- navbarPage(
  title = tags$div(
    style = "display: flex; align-items: center;",
    tags$i(class = "fa fa-broom", style = "margin-right: 8px;"),
    "DataClean Pro"
  ),
  theme = shinytheme("flatly"),
  windowTitle = "DataClean - ThesiStats",
  
  # CSS personalizado para mejorar la apariencia
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
    tags$style(HTML("
      .navbar-brand { font-weight: bold; font-size: 24px !important; }
      .well { background-color: #f8f9fa; border: 1px solid #e9ecef; border-radius: 8px; }
      .panel-heading { background-color: #2c3e50; color: white; border-radius: 6px 6px 0 0; padding: 12px; }
      .btn-primary { background-color: #3498db; border-color: #2980b9; }
      .btn-primary:hover { background-color: #2980b9; border-color: #21618c; }
      .btn-success { background-color: #27ae60; border-color: #229954; }
      .btn-success:hover { background-color: #229954; border-color: #1e8449; }
      .btn-danger { background-color: #e74c3c; border-color: #c0392b; }
      .info-box {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 15px;
        border-radius: 8px;
        margin-bottom: 20px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      }
      .preview-box {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        color: white;
        padding: 10px;
        border-radius: 5px;
        margin-bottom: 10px;
        font-weight: bold;
      }
      .result-box {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        color: white;
        padding: 10px;
        border-radius: 5px;
        margin-bottom: 10px;
        font-weight: bold;
      }
      .step-indicator {
        background-color: #ecf0f1;
        padding: 10px;
        border-radius: 5px;
        margin-bottom: 15px;
        border-left: 4px solid #3498db;
      }
      .success-message {
        background-color: #d4edda;
        color: #155724;
        padding: 10px;
        border-radius: 5px;
        margin-top: 10px;
        border: 1px solid #c3e6cb;
      }
      .help-text {
        color: #7f8c8d;
        font-size: 0.9em;
        font-style: italic;
        margin-top: 5px;
      }
      .scale-config {
        background-color: #f8f9fa;
        border: 2px solid #dee2e6;
        border-radius: 8px;
        padding: 15px;
        margin-bottom: 15px;
      }
      h4 { color: #2c3e50; font-weight: 600; }
      .dataTables_wrapper { margin-top: 20px; }
      .compact { font-size: 12px; }
      .compact th, .compact td { padding: 4px 8px !important; }
      table.dataTable.compact thead th,
      table.dataTable.compact thead td { padding: 4px 8px; }
      table.dataTable.compact tbody th,
      table.dataTable.compact tbody td { padding: 4px 8px; }
    "))
  ),
  
  # ==================== TAB 1: CARGA Y RENOMBRADO ====================
  tabPanel(
    title = tags$span(icon("upload"), "Paso 1: Carga de Datos"),
    fluidRow(
      column(4,
             wellPanel(
               tags$div(class = "step-indicator",
                        tags$h5(icon("info-circle"), "Paso 1: Cargar y Renombrar Columnas")
               ),
               
               fileInput("datafile",
                         label = tags$div(
                           icon("file-excel"), "Seleccionar archivo Excel (.xlsx)"
                         ),
                         accept = c(".xlsx"),
                         buttonLabel = "Explorar...",
                         placeholder = "Ningún archivo seleccionado"),
               
               tags$hr(),
               
               textAreaInput("new_names",
                             label = tags$div(
                               icon("edit"), "Nuevos nombres de columnas",
                               tags$div(class = "help-text", "Separar con comas, uno por línea")
                             ),
                             value = "",
                             placeholder = "Marca_Temporal, Consentimiento, Edad, Sexo, ...",
                             rows = 4),
               
               textInput("columns",
                         label = tags$div(
                           icon("columns"), "Índices de columnas a renombrar",
                           tags$div(class = "help-text", "Usar formato de rango (ej: 1:13)")
                         ),
                         value = "",
                         placeholder = "Ej: 1:12"),
               
               textInput("filter_value",
                         label = tags$div(
                           icon("filter"), "Filtrar por consentimiento",
                           tags$div(class = "help-text", "Valor exacto para filtrar (ej: Si, Sí, Yes)")
                         ),
                         value = "",
                         placeholder = "Ej: Si"),
               
               tags$hr(),
               
               actionButton("apply_step1",
                            label = tags$span(icon("check"), "Aplicar Transformación"),
                            class = "btn-primary btn-block",
                            style = "font-weight: bold;"),
               
               uiOutput("step1_status")
             )
      ),
      
      column(8,
             tags$div(class = "info-box",
                      tags$h4(icon("lightbulb"), "Información"),
                      "Este módulo permite cargar archivos Excel y renombrar columnas específicas. ",
                      "También puedes filtrar las filas según el valor de consentimiento."
             ),
             
             # Opciones de visualización
             conditionalPanel(
               condition = "input.datafile",
               wellPanel(
                 radioButtons("view_mode_step1",
                              label = tags$div(
                                icon("eye"), "Modo de visualización"
                              ),
                              choices = list(
                                "Secuencial (Vista Previa → Resultado)" = "sequential",
                                "Lado a lado (Comparar)" = "sidebyside"
                              ),
                              selected = "sequential",
                              inline = TRUE)
               )
             ),
             
             # PREVISUALIZACIÓN Y RESULTADO: Modo Secuencial
             conditionalPanel(
               condition = "input.view_mode_step1 == 'sequential'",
               uiOutput("ui_preview_raw"),
               uiOutput("ui_result_step1")
             ),
             
             # PREVISUALIZACIÓN Y RESULTADO: Modo Lado a Lado
             conditionalPanel(
               condition = "input.view_mode_step1 == 'sidebyside'",
               fluidRow(
                 column(6, uiOutput("ui_preview_raw_sidebyside")),
                 column(6, uiOutput("ui_result_step1_sidebyside"))
               )
             )
      )
    )
  ),
  
  # ==================== TAB 2: RENOMBRAMIENTO DE ÍTEMS ====================
  tabPanel(
    title = tags$span(icon("tags"), "Paso 2: Renombrar Ítems"),
    fluidRow(
      column(4,
             wellPanel(
               tags$div(class = "step-indicator",
                        tags$h5(icon("info-circle"), "Paso 2: Renombramiento de Ítems")
               ),
               
               tags$h5(icon("layer-group"), "Configuración de Prefijos"),
               
               fluidRow(
                 column(6,
                        textInput("prefix1",
                                  label = "Prefijo 1",
                                  value = "",
                                  placeholder = "Ej: GAD")
                 ),
                 column(6,
                        textInput("n_items1",
                                  label = "N° ítems 1",
                                  value = "",
                                  placeholder = "Ej: 7")
                 )
               ),
               
               fluidRow(
                 column(6,
                        textInput("prefix2",
                                  label = "Prefijo 2",
                                  value = "",
                                  placeholder = "Ej: FOMO")
                 ),
                 column(6,
                        textInput("n_items2",
                                  label = "N° ítems 2",
                                  value = "",
                                  placeholder = "Ej: 11")
                 )
               ),
               
               tags$hr(),
               
               tags$h5(icon("arrows-alt-h"), "Rango de Columnas"),
               
               textInput("inici",
                         label = "Columna de inicio (nombre completo)",
                         value = "",
                         placeholder = "Ej: 1. Se ha sentido nervioso..."),
               
               textInput("final",
                         label = "Columna final (nombre completo)",
                         value = "",
                         placeholder = "Ej: 11. Es importante que entienda..."),
               
               tags$div(class = "help-text",
                        "Especifica el rango de columnas que deseas renombrar usando los prefijos definidos."),
               
               checkboxInput("remove_na",
                             label = tags$span(icon("trash"), "Eliminar filas con NA"),
                             value = TRUE),
               
               tags$hr(),
               
               actionButton("apply_step2",
                            label = tags$span(icon("check"), "Aplicar Renombramiento"),
                            class = "btn-primary btn-block",
                            style = "font-weight: bold;"),
               
               uiOutput("step2_status")
             )
      ),
      
      column(8,
             tags$div(class = "info-box",
                      tags$h4(icon("lightbulb"), "Información"),
                      "Este módulo renombra ítems usando prefijos personalizados. ",
                      "Por ejemplo, puedes convertir ítems largos en GAD1, GAD2, FOMO1, FOMO2, etc."
             ),
             
             # PREVISUALIZACIÓN: Datos del paso 1
             uiOutput("ui_preview_step2"),
             
             # RESULTADO: Ítems renombrados
             uiOutput("ui_result_step2")
      )
    )
  ),
  
  # ==================== TAB 3: VALIDACIÓN ====================
  tabPanel(
    title = tags$span(icon("check-double"), "Paso 3: Validación"),
    fluidRow(
      column(12,
             wellPanel(
               tags$div(class = "step-indicator",
                        tags$h5(icon("info-circle"), "Paso 3: Validación de Categorías Likert")
               ),
               
               tags$div(class = "info-box",
                        tags$h4(icon("lightbulb"), "Información"),
                        "Usa ", tags$code("validation_categoria()"), " para verificar las categorías únicas ",
                        "de tipo Likert en tus datos. Esto te ayuda a identificar las opciones de respuesta ",
                        "antes de configurar el Paso 4."
               ),
               
               fluidRow(
                 column(6,
                        textInput("validate_range1",
                                  label = tags$div(
                                    icon("list"), "Rango de columnas Escala 1",
                                    tags$div(class = "help-text", "Formato: PREFIJO1:PREFIJOX")
                                  ),
                                  value = "",
                                  placeholder = "Ej: GAD1:GAD7")
                 ),
                 column(6,
                        textInput("validate_range2",
                                  label = tags$div(
                                    icon("list"), "Rango de columnas Escala 2",
                                    tags$div(class = "help-text", "Formato: PREFIJO1:PREFIJOX")
                                  ),
                                  value = "",
                                  placeholder = "Ej: FOMO1:FOMO11")
                 )
               ),
               
               tags$hr(),
               
               actionButton("validate_btn",
                            label = tags$span(icon("search"), "Validar Categorías"),
                            class = "btn-primary btn-lg",
                            style = "font-weight: bold;"),
               
               tags$hr(),
               
               uiOutput("validation_results")
             )
      )
    )
  ),
  
  # ==================== TAB 4: PROCESS LIKERT BLOCKS ====================
  tabPanel(
    title = tags$span(icon("sliders-h"), "Paso 4: Escalas Likert"),
    fluidRow(
      column(4,
             wellPanel(
               tags$div(class = "step-indicator",
                        tags$h5(icon("info-circle"), "Paso 4: Process Likert Blocks (Método Actualizado)")
               ),
               
               tags$div(
                 class = "alert alert-info",
                 icon("info-circle"),
                 " Este módulo usa ", tags$code("process_likert_blocks()"),
                 " para procesar múltiples escalas simultáneamente."
               ),
               
               # ESCALA 1
               tags$div(
                 class = "scale-config",
                 tags$h5(icon("star"), "Escala 1", style = "color: #2980b9;"),
                 
                 textInput("scale1_prefix",
                           label = "Prefijo de la escala",
                           value = "",
                           placeholder = "Ej: GAD"),
                 
                 textInput("scale1_n_items",
                           label = "Número de ítems",
                           value = "",
                           placeholder = "Ej: 7"),
                 
                 textAreaInput("scale1_levels",
                               label = "Niveles Likert (separados por coma o por línea)",
                               value = "",
                               placeholder = "Casi todos los días, Más de la mitad de los días, ...",
                               rows = 3),
                 
                 checkboxInput("scale1_start_zero",
                               label = tags$span(icon("zero"), "Iniciar numeración en 0"),
                               value = FALSE)
               ),
               
               # ESCALA 2
               tags$div(
                 class = "scale-config",
                 tags$h5(icon("star"), "Escala 2", style = "color: #d68910;"),
                 
                 textInput("scale2_prefix",
                           label = "Prefijo de la escala",
                           value = "",
                           placeholder = "Ej: FOMO"),
                 
                 textInput("scale2_n_items",
                           label = "Número de ítems",
                           value = "",
                           placeholder = "Ej: 11"),
                 
                 textAreaInput("scale2_levels",
                               label = "Niveles Likert (separados por coma o por línea)",
                               value = "",
                               placeholder = "Extremadamente cierto, Ligeramente cierto, ...",
                               rows = 3),
                 
                 checkboxInput("scale2_start_zero",
                               label = tags$span(icon("zero"), "Iniciar numeración en 0"),
                               value = FALSE)
               ),
               
               # Columnas a eliminar
               tags$hr(),
               
               textInput("cols_to_remove",
                         label = tags$div(
                           icon("trash"), "Columnas a eliminar (opcional)",
                           tags$div(class = "help-text", "Separar por comas")
                         ),
                         value = "",
                         placeholder = "Ej: Marca_Temporal, Consentimiento"),
               
               tags$hr(),
               
               actionButton("apply_step4",
                            label = tags$span(icon("check"), "Aplicar Process Likert Blocks"),
                            class = "btn-success btn-block",
                            style = "font-weight: bold;"),
               
               uiOutput("step4_status")
             )
      ),
      
      column(8,
             tags$div(class = "info-box",
                      tags$h4(icon("lightbulb"), "Información"),
                      "Este módulo utiliza ", tags$code("process_likert_blocks()"), " que procesa múltiples escalas Likert de forma eficiente. ",
                      "Define las especificaciones de cada escala y se aplicarán automáticamente."
             ),
             
             # PREVISUALIZACIÓN: Datos del paso 2
             uiOutput("ui_preview_step4"),
             
             # RESULTADO: Datos finales
             uiOutput("ui_result_step4")
      )
    )
  ),
  
  # ==================== TAB 5: CITAR ====================
  tabPanel(
    title = tags$span(icon("quote-right"), "Citar"),
    fluidRow(
      column(12,
             wellPanel(
               h3(icon("book-open"), "¿Cómo Citar Esta Aplicación?"),
               tags$hr(),
               
               tags$div(
                 style = "background-color: #e3f2fd; padding: 20px; border-radius: 8px; border-left: 5px solid #2196F3;",
                 h4(icon("graduation-cap"), "Formato APA 7ma Edición"),
                 tags$p(
                   style = "font-size: 16px; font-family: 'Times New Roman', serif; line-height: 1.8;",
                   "Ventura-León, J. (2025). DataClean Pro (v2.0) [Shiny app]."
                 ),
                 tags$div(
                   style = "margin-top: 15px;",
                   tags$button(
                     type = "button",
                     class = "btn btn-primary",
                     onclick = "navigator.clipboard.writeText('Ventura-León, J. (2025). DataClean Pro (v2.0) [Shiny app].').then(() => { var btn = this; btn.innerHTML = '<i class=\"fa fa-check\"></i> ¡Copiado!'; btn.classList.remove('btn-primary'); btn.classList.add('btn-success'); setTimeout(function(){ btn.innerHTML = '<i class=\"fa fa-copy\"></i> Copiar Cita'; btn.classList.remove('btn-success'); btn.classList.add('btn-primary'); }, 2000); });",
                     tags$span(icon("copy"), " Copiar Cita")
                   )
                 )
               ),
               
               tags$hr(),
               
               tags$div(
                 style = "background-color: #f5f5f5; padding: 20px; border-radius: 8px;",
                 h4(icon("info-circle"), "Información Adicional"),
                 tags$ul(
                   style = "font-size: 15px; line-height: 2;",
                   tags$li(tags$b("Autor:"), " José Ventura-León"),
                   tags$li(tags$b("Versión:"), " 2.0"),
                   tags$li(tags$b("Año:"), " 2025"),
                   tags$li(tags$b("Tipo:"), " Aplicación Shiny (R)"),
                   tags$li(tags$b("Paquete Base:"), " ThesiStats")
                 )
               ),
               
               tags$hr(),
               
               tags$div(
                 style = "background-color: #fff3cd; padding: 15px; border-radius: 8px; border-left: 5px solid #ffc107;",
                 h5(icon("lightbulb"), "Nota Importante"),
                 tags$p(
                   "Si utilizas esta aplicación en tu investigación o trabajo académico, ",
                   "te agradecemos que la cites adecuadamente. Esto ayuda a reconocer el trabajo ",
                   "y permite que otros investigadores encuentren esta herramienta."
                 )
               ),
               
               tags$hr(),
               
               tags$div(
                 style = "background-color: #d5f4e6; padding: 15px; border-radius: 8px; text-align: center;",
                 h4(icon("heart"), "Desarrollado con", style = "color: #27ae60;"),
                 tags$p(
                   style = "font-size: 18px; margin-top: 10px;",
                   tags$b("ThesiStats"), " | ",
                   tags$b("Shiny"), " | ",
                   tags$b("R")
                 )
               )
             )
      )
    )
  ),
  
  # ==================== TAB 6: AYUDA ====================
  tabPanel(
    title = tags$span(icon("question-circle"), "Ayuda"),
    fluidRow(
      column(12,
             wellPanel(
               h3(icon("book"), "Guía de Uso de DataClean Pro v2.0"),
               tags$hr(),
               
               h4(icon("clipboard-check"), "Flujo de Trabajo Recomendado"),
               tags$ol(
                 tags$li(tags$b("Paso 1:"), "Cargar el archivo Excel y renombrar las columnas principales"),
                 tags$li(tags$b("Paso 2:"), "Renombrar los ítems de las escalas con prefijos personalizados (usa ", tags$code("rename_items2()"), ")"),
                 tags$li(tags$b("Paso 3:"), "Validar las categorías Likert con ", tags$code("validation_categoria()"), " para ver las opciones de respuesta"),
                 tags$li(tags$b("Paso 4:"), "Procesar escalas Likert con ", tags$code("process_likert_blocks()"), " (método actualizado)"),
                 tags$li(tags$b("Descargar:"), "Exportar los datos finales procesados en formato Excel")
               ),
               
               tags$hr(),
               
               h4(icon("tools"), "Funciones de ThesiStats Utilizadas"),
               tags$ul(
                 tags$li(tags$code("rename_columns()"), " - Renombra columnas según índices especificados"),
                 tags$li(tags$code("rename_items2()"), " - Renombra ítems con prefijos personalizados (parámetro ", tags$code("inici"), " en lugar de ", tags$code("inicio"), ")"),
                 tags$li(tags$code("validation_categoria()"), " - Valida categorías Likert antes de procesarlas"),
                 tags$li(tags$code("process_likert_blocks()"), " - ", tags$b("NUEVO:"), " Procesa múltiples bloques Likert simultáneamente usando especificaciones")
               ),
               
               tags$hr(),
               
               h4(icon("code"), "Diferencias con versión anterior"),
               tags$ul(
                 tags$li(tags$b("Método antiguo:"), " detect_expression_Likert() + convert_to_expresions() + remplace_alternative_response()"),
                 tags$li(tags$b("Método nuevo:"), " process_likert_blocks() - Todo en una sola función usando lista de especificaciones"),
                 tags$li(tags$b("Ventajas:"), " Código más limpio, menos propenso a errores, más fácil de mantener")
               ),
               
               tags$hr(),
               
               h4(icon("exclamation-triangle"), "Consejos y Buenas Prácticas"),
               tags$ul(
                 tags$li("En Paso 2, usa ", tags$code("inici"), " no ", tags$code("inicio")),
                 tags$li("SIEMPRE usa el Paso 3 (Validación) antes del Paso 4 para ver las categorías exactas"),
                 tags$li("Los niveles Likert en el Paso 4 deben estar en el orden EXACTO como aparecen en la validación"),
                 tags$li("El parámetro ", tags$code("start_zero"), " define si la numeración comienza en 0 o 1"),
                 tags$li("Puedes eliminar columnas innecesarias al final del Paso 4")
               ),
               
               tags$hr(),
               
               tags$div(
                 style = "background-color: #d5f4e6; padding: 15px; border-radius: 8px;",
                 h4(icon("code"), "Desarrollado con ThesiStats"),
                 p("DataClean Pro v2.0 - Actualizado para usar ", tags$code("process_likert_blocks()"), " y métodos modernos de ThesiStats."),
                 p(tags$b("Versión:"), "2.0 | ", tags$b("Autor:"), "ThesiStats Team | ", tags$b("Fecha:"), "2025")
               )
             )
      )
    )
  )
)

# =====================================================
# SERVIDOR (SERVER)
# =====================================================

server <- function(input, output, session) {
  
  # ==================== REACTIVOS DE DATOS ====================
  
  ## 1. Carga de datos raw ----
  rawData <- reactive({
    req(input$datafile)
    tryCatch({
      read_excel(input$datafile$datapath)
    }, error = function(e) {
      showNotification(paste("Error al cargar archivo:", e$message), type = "error")
      NULL
    })
  })
  
  ## 2. Datos procesados (Step 1) ----
  processedData <- eventReactive(input$apply_step1, {
    req(rawData())
    
    tryCatch({
      # Parsear nombres (permitir saltos de línea o comas)
      new_names_vector <- strsplit(input$new_names, "[,\n]")[[1]] %>%
        trimws() %>%
        .[. != ""]
      
      # Parsear columnas
      columns_vector <- eval(parse(text = input$columns))
      
      # Aplicar rename_columns
      df_new <- ThesiStats::rename_columns(rawData(),
                                           new_names = new_names_vector,
                                           columns = columns_vector)
      
      # Filtrar si hay valor de consentimiento
      if (input$filter_value != "") {
        df_new <- df_new %>% filter(Consentimiento == input$filter_value)
      }
      
      showNotification("✓ Datos cargados y renombrados exitosamente", type = "message", duration = 3)
      df_new
      
    }, error = function(e) {
      showNotification(paste("Error en Paso 1:", e$message), type = "error", duration = 5)
      NULL
    })
  })
  
  ## 3. Datos con ítems renombrados (Step 2) ----
  processedDataRenombrado <- eventReactive(input$apply_step2, {
    req(processedData())
    
    tryCatch({
      df_new <- processedData()
      
      df_new_renombrado <- rename_items2(
        df_new,
        prefix1 = input$prefix1,
        prefix2 = input$prefix2,
        inici = if(input$inici != "") input$inici else NULL,  # Nota: inici no inicio
        final = if(input$final != "") input$final else NULL,
        n_items1 = if(input$n_items1 != "") as.numeric(input$n_items1) else NULL,
        n_items2 = if(input$n_items2 != "") as.numeric(input$n_items2) else NULL
      )
      
      # Eliminar NA si está marcado
      if (input$remove_na) {
        df_new_renombrado <- df_new_renombrado %>% na.omit()
      }
      
      showNotification("✓ Ítems renombrados exitosamente", type = "message", duration = 3)
      df_new_renombrado
      
    }, error = function(e) {
      showNotification(paste("Error en Paso 2:", e$message), type = "error", duration = 5)
      NULL
    })
  })
  
  ## 4. Datos finales con process_likert_blocks (Step 4) ----
  finalData <- eventReactive(input$apply_step4, {
    req(processedDataRenombrado())
    
    tryCatch({
      df_base <- processedDataRenombrado()
      
      # Construir especificaciones para process_likert_blocks
      specs <- list()
      
      # Escala 1
      if (input$scale1_prefix != "" && input$scale1_n_items != "") {
        levels1 <- strsplit(input$scale1_levels, "[,\n]")[[1]] %>%
          trimws() %>%
          .[. != ""]
        
        specs[[1]] <- list(
          prefix = input$scale1_prefix,
          n_items = as.numeric(input$scale1_n_items),
          levels = levels1,
          start_zero = input$scale1_start_zero
        )
      }
      
      # Escala 2
      if (input$scale2_prefix != "" && input$scale2_n_items != "") {
        levels2 <- strsplit(input$scale2_levels, "[,\n]")[[1]] %>%
          trimws() %>%
          .[. != ""]
        
        specs[[length(specs) + 1]] <- list(
          prefix = input$scale2_prefix,
          n_items = as.numeric(input$scale2_n_items),
          levels = levels2,
          start_zero = input$scale2_start_zero
        )
      }
      
      # Aplicar process_likert_blocks
      if (length(specs) > 0) {
        final_df <- process_likert_blocks(df_base, specs)
      } else {
        final_df <- df_base
      }
      
      # Eliminar columnas especificadas
      if (input$cols_to_remove != "") {
        cols_remove <- strsplit(input$cols_to_remove, ",")[[1]] %>%
          trimws() %>%
          .[. != ""]
        
        final_df <- final_df %>% select(-any_of(cols_remove))
      }
      
      showNotification("✓ Process Likert Blocks aplicado exitosamente", type = "message", duration = 3)
      final_df
      
    }, error = function(e) {
      showNotification(paste("Error en Paso 3:", e$message), type = "error", duration = 5)
      NULL
    })
  })
  
  # ==================== VALIDACIÓN ====================
  
  observeEvent(input$validate_btn, {
    req(processedDataRenombrado())
    
    output$validation_results <- renderUI({
      df <- processedDataRenombrado()
      
      results_list <- list()
      
      # Validar Escala 1
      if (input$validate_range1 != "") {
        result1 <- tryCatch({
          cats1 <- validation_categoria(df, !!parse_expr(input$validate_range1))
          list(success = TRUE, categories = cats1, range = input$validate_range1)
        }, error = function(e) {
          list(success = FALSE, error = e$message, range = input$validate_range1)
        })
        results_list[[1]] <- result1
      }
      
      # Validar Escala 2
      if (input$validate_range2 != "") {
        result2 <- tryCatch({
          cats2 <- validation_categoria(df, !!parse_expr(input$validate_range2))
          list(success = TRUE, categories = cats2, range = input$validate_range2)
        }, error = function(e) {
          list(success = FALSE, error = e$message, range = input$validate_range2)
        })
        results_list[[2]] <- result2
      }
      
      # Generar UI con los resultados
      tagList(
        tags$h4(icon("clipboard-check"), "Resultados de Validación"),
        tags$hr(),
        
        lapply(seq_along(results_list), function(i) {
          result <- results_list[[i]]
          
          if (result$success) {
            # Convertir categorías a string separado por comas
            categories_string <- paste(result$categories, collapse = ", ")
            
            wellPanel(
              style = "background-color: #d4edda; border-color: #c3e6cb;",
              tags$h5(
                icon("check-circle", style = "color: #155724;"),
                sprintf(" Escala %d: %s", i, result$range),
                style = "color: #155724;"
              ),
              tags$p(
                tags$b("Categorías únicas encontradas:"),
                sprintf(" %d categorías", length(result$categories))
              ),
              tags$div(
                style = "background-color: white; padding: 15px; border-radius: 5px; border: 1px solid #c3e6cb; font-family: monospace;",
                tags$div(
                  style = "color: #2c3e50; font-size: 14px; line-height: 1.6;",
                  categories_string
                )
              )
            )
          } else {
            wellPanel(
              style = "background-color: #f8d7da; border-color: #f5c6cb;",
              tags$h5(
                icon("exclamation-triangle", style = "color: #721c24;"),
                sprintf(" Escala %d: %s", i, result$range),
                style = "color: #721c24;"
              ),
              tags$p(
                tags$b("Error:"),
                tags$code(result$error)
              )
            )
          }
        })
      )
    })
  })
  
  # ==================== UI DINÁMICOS ====================
  
  # PASO 1: Previsualización de datos raw (Modo Secuencial)
  output$ui_preview_raw <- renderUI({
    req(rawData())
    wellPanel(
      tags$div(class = "preview-box",
               icon("eye"), " VISTA PREVIA: Datos Originales"
      ),
      tags$div(class = "help-text", "Estos son los datos tal como se cargaron del archivo Excel"),
      DTOutput("table_raw")
    )
  })
  
  # PASO 1: Resultado después de transformación (Modo Secuencial)
  output$ui_result_step1 <- renderUI({
    req(processedData())
    wellPanel(
      tags$div(class = "result-box",
               icon("check-circle"), " RESULTADO: Datos Procesados"
      ),
      tags$div(class = "help-text", "Datos después de renombrar columnas y filtrar"),
      DTOutput("table_step1")
    )
  })
  
  # PASO 1: Previsualización de datos raw (Modo Lado a Lado)
  output$ui_preview_raw_sidebyside <- renderUI({
    req(rawData())
    wellPanel(
      tags$div(class = "preview-box",
               icon("eye"), " ANTES: Datos Originales"
      ),
      DTOutput("table_raw_sidebyside")
    )
  })
  
  # PASO 1: Resultado después de transformación (Modo Lado a Lado)
  output$ui_result_step1_sidebyside <- renderUI({
    req(processedData())
    wellPanel(
      tags$div(class = "result-box",
               icon("check-circle"), " DESPUÉS: Datos Procesados"
      ),
      DTOutput("table_step1_sidebyside")
    )
  })
  
  # PASO 2: Previsualización datos del paso 1
  output$ui_preview_step2 <- renderUI({
    req(processedData())
    wellPanel(
      tags$div(class = "preview-box",
               icon("eye"), " VISTA PREVIA: Datos del Paso Anterior"
      ),
      tags$div(class = "help-text", "Datos que vienen del Paso 1"),
      DTOutput("table_prev_step2")
    )
  })
  
  # PASO 2: Resultado después de renombrar ítems
  output$ui_result_step2 <- renderUI({
    req(processedDataRenombrado())
    wellPanel(
      tags$div(class = "result-box",
               icon("check-circle"), " RESULTADO: Ítems Renombrados"
      ),
      tags$div(class = "help-text", "Datos después de renombrar ítems con prefijos"),
      DTOutput("table_step2")
    )
  })
  
  # PASO 4: Previsualización datos del paso 2
  output$ui_preview_step4 <- renderUI({
    req(processedDataRenombrado())
    wellPanel(
      tags$div(class = "preview-box",
               icon("eye"), " VISTA PREVIA: Datos del Paso Anterior"
      ),
      tags$div(class = "help-text", "Datos que vienen del Paso 2"),
      DTOutput("table_prev_step3")
    )
  })
  
  # PASO 4: Resultado final
  output$ui_result_step4 <- renderUI({
    req(finalData())
    wellPanel(
      tags$div(class = "result-box",
               icon("check-circle"), " RESULTADO: Datos Finales Procesados"
      ),
      tags$div(class = "help-text", "Datos finales con escalas Likert procesadas mediante process_likert_blocks()"),
      downloadButton("downloadData",
                     label = tags$span(icon("download"), "Descargar Excel"),
                     class = "btn-success",
                     style = "margin-bottom: 15px; margin-top: 10px;"),
      DTOutput("table_step3")
    )
  })
  
  # ==================== OUTPUTS DE TABLAS ====================
  
  # Tabla raw (datos originales) - Modo Secuencial
  output$table_raw <- renderDT({
    req(rawData())
    datatable(head(rawData(), 2),
              options = list(
                pageLength = 2,
                scrollX = TRUE,
                dom = 'frtip',
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
              ),
              class = 'cell-border stripe hover compact',
              rownames = FALSE)
  })
  
  # Tabla Paso 1 - Resultado - Modo Secuencial
  output$table_step1 <- renderDT({
    req(processedData())
    datatable(head(processedData(), 2),
              options = list(
                pageLength = 2,
                scrollX = TRUE,
                dom = 'frtip',
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
              ),
              class = 'cell-border stripe hover compact',
              rownames = FALSE)
  })
  
  # Tabla raw (datos originales) - Modo Lado a Lado
  output$table_raw_sidebyside <- renderDT({
    req(rawData())
    datatable(head(rawData(), 2),
              options = list(
                pageLength = 2,
                scrollX = TRUE,
                scrollY = "200px",
                paging = FALSE,
                searching = FALSE,
                info = FALSE,
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
              ),
              class = 'cell-border stripe compact',
              rownames = FALSE)
  })
  
  # Tabla Paso 1 - Resultado - Modo Lado a Lado
  output$table_step1_sidebyside <- renderDT({
    req(processedData())
    datatable(head(processedData(), 2),
              options = list(
                pageLength = 2,
                scrollX = TRUE,
                scrollY = "200px",
                paging = FALSE,
                searching = FALSE,
                info = FALSE,
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
              ),
              class = 'cell-border stripe compact',
              rownames = FALSE)
  })
  
  # Tabla Paso 2 - Previsualización
  output$table_prev_step2 <- renderDT({
    req(processedData())
    datatable(head(processedData(), 2),
              options = list(
                pageLength = 2,
                scrollX = TRUE,
                dom = 'frtip',
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
              ),
              class = 'cell-border stripe hover',
              rownames = FALSE)
  })
  
  # Tabla Paso 2 - Resultado
  output$table_step2 <- renderDT({
    req(processedDataRenombrado())
    datatable(head(processedDataRenombrado(), 2),
              options = list(
                pageLength = 2,
                scrollX = TRUE,
                dom = 'frtip',
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
              ),
              class = 'cell-border stripe hover compact',
              rownames = FALSE)
  })
  
  # Tabla Paso 3 - Previsualización
  output$table_prev_step3 <- renderDT({
    req(processedDataRenombrado())
    datatable(head(processedDataRenombrado(), 2),
              options = list(
                pageLength = 2,
                scrollX = TRUE,
                dom = 'frtip',
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
              ),
              class = 'cell-border stripe hover',
              rownames = FALSE)
  })
  
  # Tabla Paso 3 - Resultado final
  output$table_step3 <- renderDT({
    req(finalData())
    datatable(head(finalData(), 2),
              options = list(
                pageLength = 2,
                scrollX = TRUE,
                dom = 'frtip',
                language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
              ),
              class = 'cell-border stripe hover compact',
              rownames = FALSE)
  })
  
  # ==================== MENSAJES DE ESTADO ====================
  
  output$step1_status <- renderUI({
    req(processedData())
    tags$div(class = "success-message",
             icon("check-circle"),
             sprintf(" %d filas × %d columnas procesadas",
                     nrow(processedData()),
                     ncol(processedData()))
    )
  })
  
  output$step2_status <- renderUI({
    req(processedDataRenombrado())
    tags$div(class = "success-message",
             icon("check-circle"),
             sprintf(" %d filas × %d columnas | Ítems renombrados correctamente",
                     nrow(processedDataRenombrado()),
                     ncol(processedDataRenombrado()))
    )
  })
  
  output$step4_status <- renderUI({
    req(finalData())
    tags$div(class = "success-message",
             icon("check-circle"),
             sprintf(" %d filas × %d columnas | Datos finales listos para descargar",
                     nrow(finalData()),
                     ncol(finalData()))
    )
  })
  
  # ==================== DESCARGA DE DATOS ====================
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("Datos_Finales_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      req(finalData())
      tryCatch({
        openxlsx::write.xlsx(finalData(), file)
        showNotification("✓ Archivo descargado exitosamente", type = "message", duration = 3)
      }, error = function(e) {
        showNotification(paste("Error al descargar:", e$message), type = "error")
      })
    }
  )
}

# =====================================================
# EJECUTAR APLICACIÓN
# =====================================================

shinyApp(ui = ui, server = server)
