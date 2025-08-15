# Deconstructor of Fun GT Table Theme
# Custom GT table styling for DoF podcast

library(gt)
library(dplyr)

# Require and source the main DoF theme (fail fast)
# Try to find dof_theme.R in the same directory as this file
.dof_gt_dir <- tryCatch({
  dirname(normalizePath(sys.frame(1)$ofile))
}, error = function(e) {
  # Fallback: check common locations
  if (file.exists("../../dof_theme/dof_theme.R")) {
    normalizePath("../../dof_theme")
  } else {
    getwd()
  }
})

dof_theme_path <- file.path(.dof_gt_dir, "dof_theme.R")
if (file.exists(dof_theme_path)) {
  source(dof_theme_path)
} else if (file.exists("dof_theme.R")) {
  source("dof_theme.R")
} else if (file.exists("../dof_theme.R")) {
  source("../dof_theme.R")
} else {
  stop("dof_theme.R not found. Ensure it exists in the project root.", call. = FALSE)
}

use_web_fonts <- function() {
  "@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&family=Inter+Tight:wght@400;600;700&display=swap');\n"
}

# Embed Agrandir locally so GT exports get the correct title font
embed_agrandir_css <- function() {
  if (!requireNamespace("base64enc", quietly = TRUE)) {
    stop("Required package 'base64enc' is not installed. Install with: install.packages('base64enc')", call. = FALSE)
  }
  paths <- dof_get_font_paths()
  if (is.null(paths$agrandir_regular) || is.na(paths$agrandir_regular) || !file.exists(paths$agrandir_regular)) {
    stop("Agrandir font file not found at style_guide/fonts/Agrandir.ttf", call. = FALSE)
  }
  raw <- readBin(paths$agrandir_regular, what = "raw", n = file.info(paths$agrandir_regular)$size)
  b64 <- base64enc::base64encode(raw)
  paste0("@font-face { font-family: 'Agrandir'; src: url('data:font/ttf;base64,", b64, "') format('truetype'); font-weight: normal; font-style: normal; }\n")
}

# Helper function to find DoF icon path
find_dof_icon_path <- function() {
  search_dirs <- c(
    # New preferred structure
    "assets/brand/icon",
    "../assets/brand/icon",
    # Backward compatibility
    "images/Icon",
    "../images/Icon",
    "Images/Icon",
    "../Images/Icon",
    "images",
    "../images",
    "Images",
    "../Images",
    "assets/images",
    "../assets/images"
  )
  
  for (dir in search_dirs) {
    if (dir.exists(dir)) {
      files <- list.files(dir, pattern = "*Primary*|*primary*", ignore.case = TRUE, full.names = TRUE)
      if (length(files) > 0) {
        return(files[1])
      }
    }
  }
  return("")
}

# DoF GT theme function
theme_dof_gt <- function(gt_table, 
                         header_bg = dof_colors$secondary,
                         header_text = dof_colors$white,
                         stripe_color = dof_colors$grey_light,
                         border_color = dof_colors$grey_light,
                         text_color = dof_colors$secondary,
                         container_border = TRUE,
                         container_border_color = dof_colors$primary,
                         container_border_width = 3) {
  
  result_table <- gt_table %>%
    # Table options
    tab_options(
      # Font settings - use Poppins for table body (no fallback)
      table.font.names = dof_font_body,
      table.font.size = px(12),
      
      # Reduce heading padding
      heading.padding = px(2),
      heading.border.bottom.style = "none",
      
      # Header styling
      column_labels.background.color = header_bg,
      column_labels.font.weight = "bold",
      column_labels.font.size = px(13),
      
      # Table body
      table.background.color = dof_colors$white,
      data_row.padding = px(8),
      
      # Borders
      table.border.top.style = "solid",
      table.border.top.width = if (container_border) px(container_border_width) else px(2),
      table.border.top.color = if (container_border) container_border_color else header_bg,
      table.border.bottom.style = "solid",
      table.border.bottom.width = if (container_border) px(container_border_width) else px(2),
      table.border.bottom.color = if (container_border) container_border_color else header_bg,
      table.border.left.style = if (container_border) "solid" else "none",
      table.border.left.width = if (container_border) px(container_border_width) else px(0),
      table.border.left.color = if (container_border) container_border_color else "transparent",
      table.border.right.style = if (container_border) "solid" else "none",
      table.border.right.width = if (container_border) px(container_border_width) else px(0),
      table.border.right.color = if (container_border) container_border_color else "transparent",
      
      # Row striping
      row.striping.background_color = stripe_color,
      row.striping.include_table_body = TRUE,
      
      # Source notes
      source_notes.font.size = px(10),
      source_notes.padding = px(4),
      
      # Footnotes
      footnotes.font.size = px(10),
      footnotes.padding = px(4)
    ) %>%
    
    # Style column labels with Poppins
    tab_style(
      style = list(
        cell_text(
          color = header_text,
          weight = "bold",
          font = dof_font_body
        )
      ),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Style table body with Poppins
    tab_style(
      style = list(
        cell_text(
          color = text_color,
          font = dof_font_body
        )
      ),
      locations = cells_body()
    )
}

# DoF GT color functions for conditional formatting
style_dof_positive <- function() {
  list(
    cell_fill(color = dof_colors$light_pink),
    cell_text(color = dof_colors$secondary, weight = "bold")
  )
}

style_dof_negative <- function() {
  list(
    cell_fill(color = dof_colors$dark_purple),
    cell_text(color = dof_colors$white, weight = "bold")
  )
}

style_dof_highlight <- function() {
  list(
    cell_fill(color = dof_colors$primary),
    cell_text(color = dof_colors$white, weight = "bold")
  )
}

# Example DoF GT table
create_dof_example_table <- function() {
  # Check for required packages
  if (!requireNamespace("gt", quietly = TRUE)) {
    stop("Package 'gt' is required. Install with: install.packages('gt')")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required. Install with: install.packages('dplyr')")
  }
  if (!requireNamespace("htmltools", quietly = TRUE)) {
    stop("Package 'htmltools' is required. Install with: install.packages('htmltools')")
  }
  
  # Sample gaming data
  gaming_table_data <- data.frame(
    Platform = c("Mobile", "Console", "PC", "VR", "Cloud Gaming"),
    `Revenue (Billions)` = c(93.2, 50.4, 36.7, 6.2, 3.7),
    `Growth Rate (%)` = c(7.3, 2.1, -2.8, 31.1, 74.9),
    `Market Share (%)` = c(49.0, 26.5, 19.3, 3.3, 1.9),
    Category = c("Traditional", "Traditional", "Traditional", "Emerging", "Emerging"),
    check.names = FALSE
  )
  
  # Create GT table
  gt_table <- gaming_table_data %>%
    gt() %>%
    
    # Apply DoF theme  
    theme_dof_gt() %>%
    
    # Add title and subtitle (538-style bold, uppercase)
    tab_header(
      title = md("**GAMING PLATFORM PERFORMANCE 2024**"),
      subtitle = "Revenue, growth, and market share analysis"
    ) %>%
    
    # Style title with Agrandir (bold, uppercase, left-aligned) - matching charts
    tab_style(
      style = list(
        cell_text(
          font = dof_font_title,
          weight = "normal",
          size = px(18),              # Proportional to table size
          color = dof_colors$secondary,
          align = "left"
        ),
        cell_fill(color = "white")
      ),
      locations = cells_title("title")
    ) %>%
    
    # Style subtitle with Inter Tight (left-aligned) - matching charts
    tab_style(
      style = list(
        cell_text(
          font = dof_font_subtitle,
          size = px(13),               # Match chart subtitle size (base 12 * 1.1)
          color = dof_colors$grey_dark,
          align = "left"
        ),
        cell_fill(color = "white")
      ),
      locations = cells_title("subtitle")
    ) %>%
    
    # Format numbers
    fmt_currency(
      columns = `Revenue (Billions)`,
      currency = "USD",
      scale_by = 1e-9,
      suffixing = TRUE,
      decimals = 1
    ) %>%
    
    fmt_percent(
      columns = c(`Growth Rate (%)`, `Market Share (%)`),
      scale_values = FALSE,
      decimals = 1
    ) %>%
    
    # Conditional formatting
    tab_style(
      style = style_dof_positive(),
      locations = cells_body(
        columns = `Growth Rate (%)`,
        rows = `Growth Rate (%)` > 10
      )
    ) %>%
    
    tab_style(
      style = style_dof_negative(),
      locations = cells_body(
        columns = `Growth Rate (%)`,
        rows = `Growth Rate (%)` < 0
      )
    ) %>%
    
    # Add source note without image for better PNG compatibility
    tab_source_note(
      source_note = "Deconstructor of Fun • Sensor Tower Data"
    )
    
  # CSS to use web fonts (Inter/Poppins) and embed Agrandir locally
  base_css <- paste0(embed_agrandir_css(), use_web_fonts(),
  "
    .gt_title {
      font-family: 'Agrandir' !important;
      padding-bottom: 2px !important;
      margin-bottom: 0px !important;
    }
    .gt_subtitle {
      font-family: 'Inter Tight', 'Inter', sans-serif !important;
      padding-top: 0px !important;
      margin-top: 0px !important;
    }
    .gt_heading {
      padding-bottom: 5px !important;
    }
    .gt_col_heading, .gt_column_spanner {
      font-family: 'Poppins', 'Helvetica Neue', 'Arial', sans-serif !important;
    }
    .gt_sourcenote, .gt_row {
      font-family: 'Poppins', 'Helvetica Neue', 'Arial', sans-serif !important;
    }
    table, .gt_table {
      font-family: 'Poppins', 'Helvetica Neue', 'Arial', sans-serif !important;
    }
    .gt_sourcenote {
      color: #0F004F !important;
      font-weight: 500 !important;
      text-align: right !important;
    }
  ")
  
  gt_table <- gt_table %>%
    opt_css(css = base_css) %>%
    
    # Column groups
    tab_spanner(
      label = "Financial Metrics",
      columns = c(`Revenue (Billions)`, `Growth Rate (%)`, `Market Share (%)`)
    )
  
  # Return the gt table
  return(gt_table)
}

# Print usage information
invisible(TRUE)