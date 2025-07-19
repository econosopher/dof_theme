# Deconstructor of Fun ggplot2 Theme
# Custom theme and color palette for DoF podcast

library(ggplot2)
library(png)
library(grid)
library(scales)

# Font setup - DoF font hierarchy
# Primary: Agrandir (titles)
# Secondary: Inter Tight (subtitles, secondary text)  
# Tertiary: Poppins (axis labels, UI elements)
# Fonts are included in style_guide/fonts/ folder

# Install fonts to system if needed
install_dof_fonts <- function() {
  font_paths <- list(
    agrandir = "style_guide/fonts/Agrandir.ttf",
    inter_tight = "style_guide/fonts/Inter_Tight/InterTight-VariableFont_wght.ttf",
    poppins_regular = "style_guide/fonts/Poppins/Poppins-Regular.ttf",
    poppins_bold = "style_guide/fonts/Poppins/Poppins-Bold.ttf"
  )
  
  for (font_name in names(font_paths)) {
    font_path <- font_paths[[font_name]]
    if (file.exists(font_path)) {
      system(paste("cp", shQuote(font_path), "~/Library/Fonts/"))
    }
  }
  
  message("DoF fonts installed to ~/Library/Fonts/")
  message("Run library(extrafont); font_import(); loadfonts() to use in R")
}

# Font hierarchy with fallbacks
dof_font_title <- "sans"      # Agrandir for titles
dof_font_subtitle <- "sans"   # Inter Tight for subtitles
dof_font_body <- "sans"       # Poppins for axis labels/UI

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
    
    # Check for Poppins (body/axis text)
    poppins_fonts <- available_fonts[grepl("Poppins", available_fonts, ignore.case = TRUE)]
    if (length(poppins_fonts) > 0) {
      dof_font_body <- poppins_fonts[1]
    }
  }
}, error = function(e) invisible())

# Backward compatibility
dof_font_family <- dof_font_title

# Define DoF color palette (official brand colors)
dof_colors <- list(
  primary = "#FF66A5",      # Galactic Magenta
  secondary = "#0F0D4F",    # Midnight Indigo
  accent = "#4F00EB",       # Pac(Man) Purple
  white = "#FFFFFF",        # White
  black = "#000000",        # Black
  light_pink = "#FFB3D1",   # Lighter version of Galactic Magenta
  dark_purple = "#0A0835",  # Darker version of Midnight Indigo
  grey_light = "#F5F5F5",
  grey_dark = "#424242"
)

# Create color palette function
dof_palette <- function(type = "main", reverse = FALSE) {
  colors <- switch(type,
    "main" = c(dof_colors$primary, dof_colors$secondary, dof_colors$accent),
    "purple_pink" = c(dof_colors$secondary, dof_colors$primary, dof_colors$light_pink),
    "full" = c(dof_colors$primary, dof_colors$secondary, dof_colors$accent, 
               dof_colors$light_pink, dof_colors$dark_purple)
  )
  
  if (reverse) colors <- rev(colors)
  colors
}

# Custom ggplot2 theme
theme_dof <- function(base_size = 12, logo_alpha = 0.1) {
  theme_minimal(base_size = base_size) +
    theme(
      # Text styling with DoF font hierarchy
      text = element_text(color = dof_colors$secondary, family = dof_font_body),
      plot.title = element_text(
        size = base_size * 1.5,  # Larger like 538
        color = dof_colors$secondary,
        face = "bold",
        family = dof_font_title,  # Agrandir Variable
        hjust = 0,  # Left-aligned like 538
        margin = margin(b = 20)
      ),
      plot.subtitle = element_text(
        size = base_size * 1.1,
        color = dof_colors$grey_dark,
        family = dof_font_subtitle,  # Inter Tight
        hjust = 0,  # Left-aligned like title
        margin = margin(b = 15)
      ),
      
      # Axis styling with Poppins (538-inspired: minimal approach)
      axis.title = element_blank(),  # Remove axis titles like 538
      axis.text = element_text(
        color = dof_colors$grey_dark,
        size = base_size * 0.8,
        family = dof_font_body  # Poppins
      ),
      axis.line = element_blank(),  # Remove axis lines like 538
      axis.ticks = element_blank(),  # Remove axis ticks like 538
      
      # Grid styling (538-inspired: horizontal only, subtle)
      panel.grid.major.x = element_blank(),  # No vertical grid lines
      panel.grid.major.y = element_line(
        color = dof_colors$grey_light, 
        linewidth = 0.3
      ),
      panel.grid.minor = element_blank(),
      
      # Background
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      
      # Legend styling with Poppins (538-inspired positioning)
      legend.title = element_text(
        color = dof_colors$secondary,
        size = base_size * 0.9,
        face = "bold",
        family = dof_font_body  # Poppins
      ),
      legend.text = element_text(
        color = dof_colors$grey_dark,
        size = base_size * 0.8,
        family = dof_font_body  # Poppins
      ),
      legend.position = "bottom",
      legend.direction = "horizontal",  # 538-style horizontal legend
      legend.box = "horizontal",
      legend.margin = margin(t = 15),
      
      # Strip styling for facets with Poppins
      strip.text = element_text(
        color = dof_colors$white,
        face = "bold",
        size = base_size * 0.9,
        family = dof_font_body  # Poppins
      ),
      strip.background = element_rect(
        fill = dof_colors$primary,
        color = NA
      ),
      
      # 538-inspired plot margins for clean spacing
      plot.margin = margin(t = 25, r = 25, b = 25, l = 25)
    )
}

# Function to add DoF logo watermark
add_dof_logo <- function(plot, logo_path = NULL, alpha = 0.15) {
  
  # Auto-detect logo path based on current working directory
  if (is.null(logo_path)) {
    possible_paths <- c(
      "Images/Wordmark/03_Horizontal Layout/Wordmark_Horizontal_Primary Color.png",
      "../Images/Wordmark/03_Horizontal Layout/Wordmark_Horizontal_Primary Color.png"
    )
    
    logo_path <- NULL
    for (path in possible_paths) {
      if (file.exists(path)) {
        logo_path <- path
        break
      }
    }
    
    if (is.null(logo_path)) {
      logo_path <- "Images/Wordmark/03_Horizontal Layout/Wordmark_Horizontal_Primary Color.png"
    }
  }
  
  # Check if logo file exists
  if (!file.exists(logo_path)) {
    warning("Logo file not found. Skipping logo overlay.")
    return(plot)
  }
  
  # Read logo and apply transparency
  logo_img <- readPNG(logo_path)
  
  # Apply alpha to the logo
  if (dim(logo_img)[3] == 4) {
    # Logo already has alpha channel
    logo_img[, , 4] <- logo_img[, , 4] * alpha
  } else {
    # Add alpha channel
    logo_with_alpha <- array(1, dim = c(dim(logo_img)[1], dim(logo_img)[2], 4))
    logo_with_alpha[, , 1:3] <- logo_img
    logo_with_alpha[, , 4] <- alpha
    logo_img <- logo_with_alpha
  }
  
  # Create raster grob with proper aspect ratio
  logo_grob <- rasterGrob(
    logo_img, 
    interpolate = TRUE,
    x = unit(0.95, "npc"),
    y = unit(0.05, "npc"),
    height = unit(0.96, "cm"),
    just = c("right", "bottom")
  )
  
  # Add logo to plot 
  plot +
    annotation_custom(
      logo_grob,
      xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf
    )
}

# Scale functions for consistent DoF colors
scale_color_dof <- function(type = "main", ...) {
  scale_color_manual(values = dof_palette(type), ...)
}

scale_fill_dof <- function(type = "main", ...) {
  scale_fill_manual(values = dof_palette(type), ...)
}

# DoF number formatting functions
format_dof_currency <- function(x, prefix = "$", suffix = "", accuracy = 0.1) {
  dollar(x, prefix = prefix, suffix = suffix, accuracy = accuracy)
}

format_dof_number <- function(x, accuracy = 1, suffix = "") {
  number(x, accuracy = accuracy, suffix = suffix, big.mark = ",")
}

format_dof_percent <- function(x, accuracy = 0.1) {
  percent(x, accuracy = accuracy)
}

format_dof_billions <- function(x, accuracy = 0.1) {
  dollar(x, suffix = "B", scale = 1e-9, accuracy = accuracy)
}

format_dof_millions <- function(x, accuracy = 0.1) {
  dollar(x, suffix = "M", scale = 1e-6, accuracy = accuracy)
}

# Example chart demonstrating the theme
create_dof_example_chart <- function() {
  # Sample gaming industry data
  gaming_data <- data.frame(
    platform = c("Mobile", "Console", "PC", "VR", "Cloud"),
    revenue_billions = c(93.2, 50.4, 36.7, 6.2, 3.7),
    growth_rate = c(7.3, 2.1, -2.8, 31.1, 74.9),
    category = c("Traditional", "Traditional", "Traditional", "Emerging", "Emerging")
  )
  
  # Create the plot
  p <- ggplot(gaming_data, aes(x = reorder(platform, revenue_billions), y = revenue_billions)) +
    geom_col(aes(fill = category), width = 0.7) +
    scale_fill_dof("purple_pink") +
    scale_y_continuous(labels = format_dof_billions, expand = c(0, 0, 0.1, 0)) +
    coord_flip() +
    labs(
      title = "Mobile Gaming Dominates Platform Revenue in 2024",
      subtitle = "Traditional platforms like mobile, console, and PC still drive most revenue,\nwhile emerging tech like VR and cloud gaming remain small",
      x = NULL,  # Remove axis labels for 538-style
      y = NULL,  # Remove axis labels for 538-style  
      fill = "Platform Type",
      caption = "Deconstructor of Fun • Gaming Industry Analysis"
    ) +
    theme_dof(base_size = 12) +
    theme(
      plot.caption = element_text(
        color = dof_colors$grey_dark,
        size = 10,
        hjust = 1,
        family = dof_font_subtitle,  # Inter Tight for captions
        margin = margin(t = 15)
      )
    )
  
  return(p)
}

# Print example usage
cat("DoF Theme Loaded! 🎮\n")
cat("Font hierarchy:\n")
cat("  • Titles:", dof_font_title, "\n")
cat("  • Subtitles:", dof_font_subtitle, "\n") 
cat("  • Body/Axis:", dof_font_body, "\n")
cat("Colors available:", paste(names(dof_colors), collapse = ", "), "\n")
cat("Usage:\n")
cat("  your_plot + theme_dof()\n")
cat("  your_plot + scale_fill_dof('main')\n")
cat("  add_dof_logo(your_plot)\n")
cat("  create_dof_example_chart()\n")
cat("  install_dof_fonts()  # Install fonts to system\n")