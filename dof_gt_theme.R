# Deconstructor of Fun GT Table Theme
# Custom GT table styling for DoF podcast

library(gt)
library(dplyr)

# Source the main DoF theme for colors
if (file.exists("dof_theme.R")) {
  source("dof_theme.R")
} else {
  # Define colors if main theme not available
  dof_colors <- list(
    primary = "#FF66A5",      # Galactic Magenta
    secondary = "#0F0D4F",    # Midnight Indigo
    accent = "#4F00EB",       # Pac(Man) Purple
    white = "#FFFFFF",
    black = "#000000",
    light_pink = "#FFB3D1",
    dark_purple = "#0A0835",
    grey_light = "#F5F5F5",
    grey_dark = "#424242"
  )
  
  # Font setup - use same hierarchy as main theme
  dof_font_title <- "sans"
  dof_font_subtitle <- "sans"
  dof_font_body <- "sans"
  
  tryCatch({
    if (require(extrafont, quietly = TRUE)) {
      available_fonts <- fonts()
      
      # Check for Agrandir (titles)
      agrandir_fonts <- available_fonts[grepl("Agrandir", available_fonts, ignore.case = TRUE)]
      if (length(agrandir_fonts) > 0) {
        dof_font_title <- agrandir_fonts[1]
      }
      
      # Check for Inter Tight (subtitles)
      inter_fonts <- available_fonts[grepl("Inter.*Tight", available_fonts, ignore.case = TRUE)]
      if (length(inter_fonts) > 0) {
        dof_font_subtitle <- inter_fonts[1]
      } else {
        # Fallback to any Inter variant
        inter_any <- available_fonts[grepl("Inter", available_fonts, ignore.case = TRUE)]
        if (length(inter_any) > 0) {
          dof_font_subtitle <- inter_any[1]
        }
      }
      
      # Check for Poppins (body/data text)
      poppins_fonts <- available_fonts[grepl("Poppins", available_fonts, ignore.case = TRUE)]
      if (length(poppins_fonts) > 0) {
        dof_font_body <- poppins_fonts[1]
      }
    }
  }, error = function(e) invisible())
  
  # Use body font as default for tables
  dof_font_family <- dof_font_body
}

# DoF GT theme function
theme_dof_gt <- function(gt_table, 
                         header_bg = dof_colors$secondary,
                         header_text = dof_colors$white,
                         stripe_color = dof_colors$grey_light,
                         border_color = dof_colors$grey_light,
                         text_color = dof_colors$secondary) {
  
  gt_table %>%
    # Table options
    tab_options(
      # Font settings
      table.font.names = dof_font_family,
      table.font.size = px(12),
      
      # Header styling
      column_labels.background.color = header_bg,
      column_labels.font.weight = "bold",
      column_labels.font.size = px(13),
      
      # Table body
      table.background.color = dof_colors$white,
      data_row.padding = px(8),
      
      # Borders
      table.border.top.style = "solid",
      table.border.top.width = px(2),
      table.border.top.color = header_bg,
      table.border.bottom.style = "solid",
      table.border.bottom.width = px(2),
      table.border.bottom.color = header_bg,
      
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
          font = dof_font_body  # Poppins for headers
        )
      ),
      locations = cells_column_labels(everything())
    ) %>%
    
    # Style table body with Poppins
    tab_style(
      style = list(
        cell_text(
          color = text_color,
          font = dof_font_body  # Poppins for data
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
    
    # Add title and subtitle with font hierarchy
    tab_header(
      title = md("**Gaming Platform Performance 2024**"),
      subtitle = "Revenue, growth, and market share analysis"
    ) %>%
    
    # Style title with Agrandir
    tab_style(
      style = list(
        cell_text(
          font = dof_font_title,  # Agrandir for title
          weight = "bold",
          size = px(18)
        )
      ),
      locations = cells_title("title")
    ) %>%
    
    # Style subtitle with Inter Tight
    tab_style(
      style = list(
        cell_text(
          font = dof_font_subtitle,  # Inter Tight for subtitle
          size = px(14)
        )
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
    
    # Add source note
    tab_source_note(
      source_note = "Deconstructor of Fun • Gaming Industry Analysis 2024"
    ) %>%
    
    # Column groups
    tab_spanner(
      label = "Financial Metrics",
      columns = c(`Revenue (Billions)`, `Growth Rate (%)`, `Market Share (%)`)
    )
  
  return(gt_table)
}

# Print usage information
cat("DoF GT Theme Loaded! 📊\n")
cat("Font hierarchy:\n")
cat("  • Titles:", dof_font_title, "\n")
cat("  • Subtitles:", dof_font_subtitle, "\n")
cat("  • Body/Data:", dof_font_body, "\n")
cat("Usage:\n")
cat("  your_gt_table %>% theme_dof_gt()\n")
cat("  create_dof_example_table()\n")
cat("Styling functions: style_dof_positive(), style_dof_negative(), style_dof_highlight()\n")