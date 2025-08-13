# Deconstructor of Fun ggplot2 Theme
# Custom theme and color palette for DoF podcast

library(ggplot2)
library(grid)
library(scales)

# Strict package requirements (fail fast)
dof_require_packages <- function(pkgs) {
  for (pkg in pkgs) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(paste0("Required package '", pkg, "' is not installed. Install with: install.packages(\"", pkg, "\")"), call. = FALSE)
    }
  }
}

dof_require_packages(c("magick", "showtext", "sysfonts"))

# Font setup - DoF font hierarchy (fail if fonts are missing)
# Primary: Agrandir (titles)
# Secondary: Inter Tight (subtitles, secondary text)
# Tertiary: Poppins (axis labels, UI elements)
# Fonts are included in style_guide/fonts/ folder.

dof_find_existing <- function(candidates) {
  for (p in candidates) {
    if (file.exists(p)) return(normalizePath(p, winslash = "/", mustWork = TRUE))
  }
  NA_character_
}

.dof_font_files <- list(
  agrandir_regular = dof_find_existing(c(
    "style_guide/fonts/Agrandir.ttf",
    "../style_guide/fonts/Agrandir.ttf"
  )),
  inter_tight_regular = dof_find_existing(c(
    "style_guide/fonts/Inter_Tight/static/InterTight-Regular.ttf",
    "../style_guide/fonts/Inter_Tight/static/InterTight-Regular.ttf",
    "style_guide/fonts/Inter_Tight/InterTight-VariableFont_wght.ttf",
    "../style_guide/fonts/Inter_Tight/InterTight-VariableFont_wght.ttf"
  )),
  inter_tight_bold = dof_find_existing(c(
    "style_guide/fonts/Inter_Tight/static/InterTight-Bold.ttf",
    "../style_guide/fonts/Inter_Tight/static/InterTight-Bold.ttf"
  )),
  poppins_regular = dof_find_existing(c(
    "style_guide/fonts/Poppins/Poppins-Regular.ttf",
    "../style_guide/fonts/Poppins/Poppins-Regular.ttf"
  )),
  poppins_bold = dof_find_existing(c(
    "style_guide/fonts/Poppins/Poppins-Bold.ttf",
    "../style_guide/fonts/Poppins/Poppins-Bold.ttf"
  ))
)

dof_verify_font_files <- function() {
  paths <- unlist(.dof_font_files, use.names = TRUE)
  missing_idx <- is.na(paths) | !file.exists(paths)
  if (any(missing_idx)) {
    missing <- names(paths)[missing_idx]
    stop(paste0(
      "Missing required font files: ",
      paste(missing, collapse = ", "),
      ". Ensure fonts are present under 'style_guide/fonts/'."
    ), call. = FALSE)
  }
}

dof_register_fonts <- function() {
  dof_verify_font_files()
  # Register fonts with sysfonts/showtext; these names are used in themes
  sysfonts::font_add(family = "Agrandir", regular = .dof_font_files$agrandir_regular)
  sysfonts::font_add(family = "Inter Tight", regular = .dof_font_files$inter_tight_regular, bold = .dof_font_files$inter_tight_bold)
  sysfonts::font_add(family = "Poppins", regular = .dof_font_files$poppins_regular, bold = .dof_font_files$poppins_bold)
  showtext::showtext_auto(enable = TRUE)
}

# Export font paths for consumers (e.g., GT CSS embedding)
dof_get_font_paths <- function() .dof_font_files

# Register immediately; fail fast on load
dof_register_fonts()

# Font family names (no fallbacks)
dof_font_title <- "Agrandir"
dof_font_subtitle <- "Inter Tight"
dof_font_body <- "Poppins"

# Backward compatibility
dof_font_family <- dof_font_title

# Define DoF color palette (official brand colors)
dof_colors <- list(
  primary = "#DE72FA",      # Galactic Magenta
  secondary = "#0F004F",    # Midnight Indigo (updated)
  accent = "#4F00EB",       # Pac(Man) Purple
  white = "#FFFFFF",        # White
  black = "#000000",        # Black
  light_pink = "#EDB9FC",   # Lighter version of Galactic Magenta
  dark_purple = "#080033",  # Darker version of Midnight Indigo (updated)
  grey_light = "#F5F5F5",
  grey_dark = "#424242"
)

# Resolve named or raw color values
resolve_dof_color <- function(value, default = dof_colors$primary) {
  if (is.null(value)) return(default)
  # Accept named keys
  if (is.character(value) && length(value) == 1) {
    key <- tolower(value)
    # Common synonyms
    if (key == "purple") key <- "accent"
    if (!is.null(dof_colors[[key]])) return(dof_colors[[key]])
  }
  # Otherwise assume hex or R-named color
  value
}

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

# Helper retained for backwards-compatibility (unused by default)
format_title_538 <- function(title) {
  if (is.null(title) || title == "") return(title)
  toupper(title)
}

# Custom ggplot2 theme with 538-inspired bold, uppercase titles
theme_dof <- function(base_size = 12, border = TRUE, border_color = NULL) {
  
  # Set default border color
  if (is.null(border_color)) border_color <- dof_colors$primary
  
  # Base theme with border
  base_theme <- theme_minimal(base_size = base_size) +
    theme(
      # Text styling with DoF font hierarchy
      text = element_text(color = dof_colors$secondary, family = dof_font_body),
      plot.title = element_text(
        size = base_size * 2.2,  # Much larger for commanding presence (26px at base 12)
        color = dof_colors$secondary,
        face = "bold",
        family = dof_font_title,
        hjust = 0,  # Left-aligned like 538
        margin = margin(l = 0, b = 5, t = 0)  # Reduced margins for tighter spacing
      ),
      plot.title.position = "plot",  # Align with entire plot area
      plot.subtitle = element_text(
        size = base_size * 1.1,
        color = dof_colors$grey_dark,
        family = dof_font_subtitle,
        hjust = 0,  # Left-aligned like title
        margin = margin(l = 0, b = 15)  # Increased bottom margin for more space
      ),
      plot.subtitle.position = "plot",  # Align with entire plot area
      
       # Axis styling with Poppins (538-inspired: minimal approach)
      axis.title = element_blank(),  # Remove axis titles like 538
      axis.text = element_text(
        color = dof_colors$grey_dark,
        size = base_size * 0.8,
        family = dof_font_body
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
      
       # Background with DoF pink border
      plot.background = element_rect(
        fill = "white", 
        color = if (border) border_color else NA,
        linewidth = if (border) 3 else 0
      ),
      panel.background = element_rect(fill = "white", color = NA),
      
      # Legend styling with Poppins (538-inspired positioning)
      legend.title = element_text(
        color = dof_colors$secondary,
        size = base_size * 0.9,
        face = "bold",
        family = dof_font_body
      ),
      legend.text = element_text(
        color = dof_colors$grey_dark,
        size = base_size * 0.8,
        family = dof_font_body
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
        family = dof_font_body
      ),
      strip.background = element_rect(
        fill = dof_colors$primary,
        color = NA
      ),
      
      # Adjusted plot margins to accommodate border and logo strip
      plot.margin = margin(t = 25, r = 25, b = 80, l = 25)
    )
    
  return(base_theme)
}

# DoF Chart Container System - Image-Based Post-Processing
# This creates branded charts using magick for precise image manipulation

# Helper function to detect optimal dimensions based on plot content
detect_optimal_dimensions <- function(plot) {
  # Extract plot data and layers for analysis
  plot_data <- tryCatch({
    if (is_ggplot(plot)) {
      list(
        layers = length(plot$layers),
        facets = !is.null(plot$facet),
        has_legend = !identical(plot$guides$colour, "none") || !identical(plot$guides$fill, "none"),
        coord_type = class(plot$coordinates)[1]
      )
    } else {
      list(layers = 1, facets = FALSE, has_legend = FALSE, coord_type = "CoordCartesian")
    }
  }, error = function(e) {
    list(layers = 1, facets = FALSE, has_legend = FALSE, coord_type = "CoordCartesian")
  })
  
  # Base dimensions
  base_width <- 1200
  base_height <- 800
  
  # Adjust for plot complexity
  if (plot_data$facets) {
    base_width <- base_width * 1.3
    base_height <- base_height * 1.2
  }
  
  if (plot_data$has_legend) {
    base_height <- base_height + 60
  }
  
  if (plot_data$coord_type == "CoordFlip") {
    # Swap dimensions for flipped coordinates
    temp <- base_width
    base_width <- base_height * 1.1
    base_height <- temp * 0.9
  }
  
  return(list(width = round(base_width), height = round(base_height)))
}

# Helper function to calculate adaptive margins based on plot characteristics
calculate_adaptive_margins <- function(plot, width, height, logo_strip, strip_height_px) {
  # Base margins
  base_margin <- 20
  
  # Analyze plot for margin requirements
  plot_info <- tryCatch({
    if (is_ggplot(plot)) {
      list(
        has_title = !is.null(plot$labels$title) && plot$labels$title != "",
        has_subtitle = !is.null(plot$labels$subtitle) && plot$labels$subtitle != "",
        facets = !is.null(plot$facet),
        coord_type = class(plot$coordinates)[1]
      )
    } else {
      list(has_title = FALSE, has_subtitle = FALSE, facets = FALSE, coord_type = "CoordCartesian")
    }
  }, error = function(e) {
    list(has_title = FALSE, has_subtitle = FALSE, facets = FALSE, coord_type = "CoordCartesian")
  })
  
  # Calculate adaptive margins
  top_margin <- 10  # Reduced base top margin
  if (plot_info$has_title) top_margin <- top_margin + 2  # Minimal addition for title
  if (plot_info$has_subtitle) top_margin <- top_margin + 2  # Minimal addition for subtitle
  
  # Adjust for facets
  if (plot_info$facets) {
    top_margin <- top_margin + 15
  }
  
  # Bottom margin depends on logo strip
  bottom_margin <- if (logo_strip) 5 else base_margin
  
  # Side margins scale with width
  side_margin <- max(base_margin, width * 0.02)
  
  return(list(
    top = top_margin,
    right = side_margin,
    bottom = bottom_margin,
    left = side_margin
  ))
}

create_dof_container <- function(plot, 
                                 logo_strip = TRUE,
                                 logo_path = NULL, 
                                 icon_path = NULL,
                                 logo_color = "primary",     # Options: "primary", "secondary", "black", "white"
                                 icon_color = "primary",     # Options: "primary", "secondary", "black", "white"
                                 strip_height_px = 45,       # Thinner logo strip for better proportions
                                 strip_color = NULL,
                                 container_border = TRUE,
                                 border_color = NULL,
                                 border_width = 9,
                                 width = NULL,              # Auto-detect if NULL
                                 height = NULL,             # Auto-detect if NULL
                                  dpi = 150) {               # Higher DPI for better quality
  
  # Validate inputs
  if (!is_ggplot(plot)) {
    stop("Input must be a ggplot object")
  }
  
  # Check magick availability
  if (!requireNamespace("magick", quietly = TRUE)) {
    warning("magick package not available. Install with: install.packages('magick')")
    return(plot)  # Return original plot
  }
  
  # Auto-detect dimensions if not provided
  if (is.null(width) || is.null(height)) {
    # Default responsive dimensions based on plot type and data
    default_dims <- detect_optimal_dimensions(plot)
    if (is.null(width)) width <- default_dims$width
    if (is.null(height)) height <- default_dims$height
  }
  
  # Validate dimensions
  if (width < 300 || height < 200) {
    warning("Dimensions too small, using minimum sizes")
    width <- max(width, 600)
    height <- max(height, 400)
  }
  
  # Set colors (accept named keys like "accent" or hex strings)
  strip_color <- resolve_dof_color(strip_color, default = dof_colors$primary)
  border_color <- resolve_dof_color(border_color, default = dof_colors$primary)
  
  # Adaptive margin system based on plot complexity
  plot_margins <- calculate_adaptive_margins(plot, width, height, logo_strip, strip_height_px)
  
  # Create a clean plot with adaptive margins
  clean_plot <- plot + theme_dof(border = FALSE) +  # No border on ggplot itself
    theme(
      plot.margin = margin(t = plot_margins$top, r = plot_margins$right, 
                          b = plot_margins$bottom, l = plot_margins$left),
      panel.spacing = unit(0, "pt"),                        # No panel spacing
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA)
    )
  
  # Safe file operations with error handling
  temp_plot_file <- tempfile(fileext = ".png")
  
  tryCatch({
    # Calculate chart dimensions (accounting for logo strip if needed)
    chart_height <- if (logo_strip) height - strip_height_px else height
    
    ggsave(temp_plot_file, clean_plot, 
           width = width/100, height = chart_height/100, 
           units = "in", dpi = dpi, bg = "white")
    
    # Validate file was created
    if (!file.exists(temp_plot_file)) {
      stop("Failed to create temporary plot file")
    }
    
    # Load the chart image with validation
    chart_img <- magick::image_read(temp_plot_file)
    
  }, error = function(e) {
    if (file.exists(temp_plot_file)) unlink(temp_plot_file)
    stop(paste("Error creating plot image:", e$message))
  })
  
  # Resize to exact dimensions with validation
  tryCatch({
    chart_img <- magick::image_resize(chart_img, paste0(width, "x", chart_height, "!"))
    
    # Create final canvas with full dimensions
    final_height <- height
    canvas <- magick::image_blank(width, final_height, color = "white")
    
    # Add the chart to the canvas
    canvas <- magick::image_composite(canvas, chart_img, offset = "+0+0")
    
    # Add logo strip if requested
    if (logo_strip) {
      canvas <- add_dof_logo_strip_image(canvas, logo_path, icon_path, strip_color, 
                                         strip_height_px, width, logo_color, icon_color)
    }
    
    # Add border if requested
    if (container_border) {
      canvas <- magick::image_border(canvas, border_color, 
                            paste0(border_width, "x", border_width))
    }
    
  }, error = function(e) {
    warning(paste("Error in image processing:", e$message))
    # Return a basic bordered plot as fallback
    return(plot + theme_dof(border = container_border, border_color = border_color))
  }, finally = {
    # Always clean up temporary file
    if (file.exists(temp_plot_file)) unlink(temp_plot_file)
  })
  
  return(canvas)
}

# Image-based logo strip creation using magick with robust error handling
add_dof_logo_strip_image <- function(canvas, logo_path = NULL, icon_path = NULL, 
                                    strip_color = NULL, strip_height_px = 45, 
                                    canvas_width = 1200, logo_color = "primary", 
                                    icon_color = "primary") {
  
  # Validate inputs
  if (!requireNamespace("magick", quietly = TRUE)) {
    warning("magick package not available. Returning original canvas.")
    return(canvas)
  }
  
  # Set default strip color
  if (is.null(strip_color)) {
    strip_color <- dof_colors$primary
  }
  
  # Robust logo path detection with color-specific patterns
  find_asset_path <- function(asset_type = "logo", color = "primary") {
    # Convert color names to match file naming convention
    color_map <- list(
      "primary" = "Primary Color",
      "secondary" = "Secondary Color", 
      "black" = "Black",
      "white" = "White"
    )
    
    file_color <- color_map[[tolower(color)]]
    if (is.null(file_color)) file_color <- "Primary Color"  # fallback
    
    if (asset_type == "logo") {
      search_patterns <- c(
        paste0("*", file_color, "*"),
        paste0("*Horizontal*", file_color, "*"),
        "*Horizontal*", 
        "*horizontal*",
        "wordmark*horizontal*", 
        "logo*horizontal*",
        "logo*"
      )
      search_dirs <- c(
        # New preferred structure
        "assets/brand/wordmark/horizontal",
        "../assets/brand/wordmark/horizontal",
        "assets/brand/wordmark",
        "../assets/brand/wordmark",
        # Backward compatibility with previous layouts
        "images/Wordmark/03_Horizontal Layout",
        "../images/Wordmark/03_Horizontal Layout", 
        "Images/Wordmark/03_Horizontal Layout",
        "../Images/Wordmark/03_Horizontal Layout",
        "images/Wordmark",
        "../images/Wordmark",
        "Images/Wordmark",
        "../Images/Wordmark", 
        "images",
        "../images",
        "Images",
        "../Images",
        "assets/images",
        "../assets/images"
      )
    } else {
      search_patterns <- c(
        paste0("*", file_color, "*"),
        "*Primary*",
        "*primary*",
        "icon*primary*",
        "icon*"
      )
      search_dirs <- c(
        # New preferred structure
        "assets/brand/icon",
        "../assets/brand/icon",
        # Backward compatibility with previous layouts
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
    }
    
    for (dir in search_dirs) {
      if (dir.exists(dir)) {
        for (pattern in search_patterns) {
          files <- list.files(dir, pattern = pattern, ignore.case = TRUE, full.names = TRUE)
          if (length(files) > 0) {
            return(files[1])  # Return first match
          }
        }
      }
    }
    return(NULL)
  }
  
  # Auto-detect logo path with color-specific fallbacks
  if (is.null(logo_path)) {
    logo_path <- find_asset_path("logo", logo_color)
  }
  
  # Auto-detect icon path with color-specific fallbacks  
  if (is.null(icon_path)) {
    icon_path <- find_asset_path("icon", icon_color)
  }
  
  # Create background strip
  strip_bg <- magick::image_blank(canvas_width, strip_height_px, color = strip_color)
  
  # Calculate positioning - much simpler with pixel coordinates!
  icon_margin <- 15        # 15px from left edge (moved closer to edge)
  logo_margin <- 15        # 15px from right edge (moved closer to edge)
  icon_size <- 36          # Icon height in pixels (smaller for better proportions)
  logo_height <- 26        # Logo height in pixels (smaller for better proportions)
  
  # Add icon on the left if available
  if (file.exists(icon_path)) {
    icon_img <- magick::image_read(icon_path)
    
    # Resize icon to desired height while maintaining aspect ratio
    icon_info <- magick::image_info(icon_img)
    icon_aspect <- icon_info$width / icon_info$height
    icon_width <- round(icon_size * icon_aspect)
    icon_img <- magick::image_resize(icon_img, paste0(icon_width, "x", icon_size, "!"))
    
    # Get actual dimensions after resize for precise centering
    resized_icon_info <- magick::image_info(icon_img)
    actual_icon_height <- resized_icon_info$height
    
    # Calculate vertical center position using actual image height
    icon_y <- round((strip_height_px - actual_icon_height) / 2)
    
    # Add 3px downward adjustment to better center visually
    icon_y <- icon_y + 3
    
    # Ensure minimum offset to prevent clipping
    icon_y <- max(icon_y, 1)
    
    # Composite icon onto strip
    strip_bg <- magick::image_composite(strip_bg, icon_img, 
                               offset = paste0("+", icon_margin, "+", icon_y))
  }
  
  # Add logo on the right if available
  if (file.exists(logo_path)) {
    logo_img <- magick::image_read(logo_path)
    
    # Resize logo to desired height while maintaining aspect ratio
    logo_info <- magick::image_info(logo_img)
    logo_aspect <- logo_info$width / logo_info$height
    logo_width <- round(logo_height * logo_aspect)
    logo_img <- magick::image_resize(logo_img, paste0(logo_width, "x", logo_height, "!"))
    
    # Get actual dimensions after resize for precise centering
    resized_logo_info <- magick::image_info(logo_img)
    actual_logo_height <- resized_logo_info$height
    actual_logo_width <- resized_logo_info$width
    
    # Calculate positions (right-aligned and vertically centered using actual dimensions)
    logo_x <- canvas_width - actual_logo_width - logo_margin
    logo_y <- round((strip_height_px - actual_logo_height) / 2)
    
    # Add 3px downward adjustment to better center visually
    logo_y <- logo_y + 3
    
    # Ensure minimum offset to prevent clipping
    logo_y <- max(logo_y, 1)
    logo_x <- max(logo_x, 0)
    
    # Composite logo onto strip
    strip_bg <- magick::image_composite(strip_bg, logo_img, 
                               offset = paste0("+", logo_x, "+", logo_y))
  } else {
    warning("Logo file not found.")
  }
  
  # Get canvas dimensions
  canvas_info <- magick::image_info(canvas)
  canvas_height <- canvas_info$height
  
  # Calculate position for logo strip (bottom of canvas)
  strip_y <- canvas_height - strip_height_px
  
  # Composite the logo strip onto the bottom of the canvas
  result <- magick::image_composite(canvas, strip_bg, 
                           offset = paste0("+0+", strip_y))
  
  return(result)
}

# Backward compatibility function - now uses image-based approach
add_dof_logo_strip <- function(plot, logo_path = NULL, strip_height = 0.075, 
                               strip_color = NULL, width = 1200, height = 800) {
  # Convert strip_height proportion to pixels
  strip_height_px <- round(height * strip_height)
  
  create_dof_container(
    plot = plot,
    logo_strip = TRUE,
    logo_path = logo_path,
    strip_height_px = strip_height_px,
    strip_color = strip_color,
    width = width,
    height = height
  )
}

# Scale functions for consistent DoF colors
scale_color_dof <- function(type = "main", ...) {
  scale_color_manual(values = dof_palette(type), ...)
}

scale_fill_dof <- function(type = "main", ...) {
  scale_fill_manual(values = dof_palette(type), ...)
}

# Use scales package label_dollar and label_number for smart formatting
# The scales package already handles K/M/B formatting automatically

# For backwards compatibility, map old function names to scales functions
format_dof_currency <- label_dollar()
format_dof_number <- label_number(big.mark = ",")
format_dof_percent <- label_percent(accuracy = 0.1)
format_dof_billions <- label_dollar(suffix = "B", scale = 1e-9, accuracy = 0.1)
format_dof_millions <- label_dollar(suffix = "M", scale = 1e-6, accuracy = 0.1)

# Custom formatter for small values (ARPDAU, etc) with 2 decimal places
format_dof_smart_currency <- function(x) {
  # Use label_dollar with custom logic for small values
  ifelse(abs(x) < 100 & abs(x) > 0,
         dollar(x, accuracy = 0.01),  # 2 decimals for small values
         label_dollar(accuracy = NULL, scale_cut = cut_short_scale())(x))  # Auto K/M/B
}

# For non-currency numbers
format_dof_smart_number <- label_number(accuracy = NULL, scale_cut = cut_short_scale())

# Example chart demonstrating the theme
create_dof_example_chart <- function(save_path = NULL) {
  # Sample gaming industry data
  gaming_data <- data.frame(
    platform = c("Mobile", "Console", "PC", "VR", "Cloud"),
    revenue_billions = c(93.2, 50.4, 36.7, 6.2, 3.7),
    growth_rate = c(7.3, 2.1, -2.8, 31.1, 74.9),
    category = c("Traditional", "Traditional", "Traditional", "Emerging", "Emerging")
  )
  
  # Calculate average for reference line
  avg_revenue <- mean(gaming_data$revenue_billions)
  
  # Calculate dynamic position for average text with scalable logic
  # For horizontal bar charts (coord_flip), positioning needs special handling
  max_revenue <- max(gaming_data$revenue_billions)
  min_revenue <- min(gaming_data$revenue_billions)
  
  # Position text horizontally: slightly to the right of the average line
  text_y_position <- avg_revenue + (max_revenue * 0.025)  # 2.5% offset (half of previous)
  
  # Position text vertically: find a gap in the data to avoid overlap
  # Sort platforms by revenue to find the best gap
  sorted_revenues <- sort(gaming_data$revenue_billions, decreasing = TRUE)
  
  # Find which platforms are closest to the average
  platform_positions <- seq_along(gaming_data$platform)
  revenues_ordered <- gaming_data$revenue_billions[order(gaming_data$revenue_billions, decreasing = TRUE)]
  
  # Place text at a position that avoids overlap with bars
  # Using 0.7 positions the text above the highest bar (30% up from top)
  text_x_position <- 0.7
  
  # Create the plot with new border and logo strip
  p <- ggplot(gaming_data, aes(x = reorder(platform, revenue_billions), y = revenue_billions)) +
    geom_col(aes(fill = category), width = 0.7) +
    geom_hline(yintercept = avg_revenue, linetype = "solid", 
               color = dof_colors$secondary, linewidth = 1.2, alpha = 0.9) +
    annotate("text", y = text_y_position, x = text_x_position,
             label = paste0("Avg: $", round(avg_revenue, 1), "B"),
             color = dof_colors$secondary, size = 3.5, family = dof_font_body,
             hjust = 0, vjust = 0.5, fontface = "bold") +
    scale_fill_dof("purple_pink") +
    scale_y_continuous(labels = format_dof_billions, expand = c(0, 0, 0.1, 0)) +
    coord_flip() +
    labs(
      title = "MOBILE GAMING DOMINATES PLATFORM REVENUE IN 2024",
      subtitle = "Traditional platforms like mobile, console, and PC still drive most revenue,\nwhile emerging tech like VR and cloud gaming remain small",
      x = NULL,  # Remove axis labels for 538-style
      y = NULL,  # Remove axis labels for 538-style  
      fill = "Platform Type",
      caption = "Deconstructor of Fun • Sensor Tower Data"
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
  
  # Create the image-based container with logo strip
  result_image <- create_dof_container(p, width = 1200, height = 800)
  
  # Save if path provided
  if (!is.null(save_path)) {
    image_write(result_image, save_path)
    cat("Chart with border and logo strip saved as '", save_path, "'\n", sep = "")
  }
  
  return(result_image)
}

# Line chart example with reference line
create_dof_line_chart <- function(save_path = NULL) {
  # Generate sample daily revenue data for popular games over 30 days
  set.seed(42)  # For reproducible data
  dates <- seq(from = Sys.Date() - 29, to = Sys.Date(), by = "day")
  
  # Create realistic daily revenue data for different games
  games_data <- expand.grid(
    date = dates,
    game = c("Fortnite", "Roblox", "Genshin Impact", "PUBG Mobile", "Candy Crush")
  )
  
  # Generate revenue with different patterns for each game
  games_data$daily_revenue <- sapply(1:nrow(games_data), function(i) {
    game <- games_data$game[i]
    day_num <- as.numeric(games_data$date[i] - min(games_data$date)) + 1
    
    base_revenue <- switch(as.character(game),
      "Fortnite" = 850000,
      "Roblox" = 720000, 
      "Genshin Impact" = 950000,
      "PUBG Mobile" = 680000,
      "Candy Crush" = 520000
    )
    
    # Add trend and seasonality
    trend <- base_revenue * (1 + (day_num - 15) * 0.01)
    seasonality <- sin(day_num * 2 * pi / 7) * base_revenue * 0.1  # Weekly pattern
    noise <- rnorm(1, 0, base_revenue * 0.05)
    
    max(trend + seasonality + noise, 0)
  })
  
  # Calculate overall average for reference line
  overall_avg <- mean(games_data$daily_revenue)
  
  # Create the line plot
  p <- ggplot(games_data, aes(x = date, y = daily_revenue, color = game)) +
    geom_smooth(method = "loess", se = FALSE, linewidth = 1.2, alpha = 0.8) +
    geom_point(size = 2, alpha = 0.5) +  # Increased transparency
    geom_hline(yintercept = overall_avg, linetype = "solid", 
               color = dof_colors$secondary, linewidth = 1.2, alpha = 0.9) +  # Made line more prominent
    annotate("text", x = max(games_data$date), y = overall_avg,
             label = paste0("Avg: ", format_dof_smart_currency(overall_avg)),
             color = dof_colors$secondary, size = 3.5, family = dof_font_body,
             hjust = 1.1, vjust = -0.5, fontface = "bold") +  # Made text bold and larger
    scale_color_dof("full") +
    scale_y_continuous(labels = format_dof_smart_currency, expand = c(0, 0, 0.05, 0)) +
    scale_x_date(date_labels = "%b %d", date_breaks = "1 week") +
    labs(
      title = "DAILY MOBILE GAME REVENUE TRENDS OVER 30 DAYS",
      subtitle = "Fortnite and Genshin Impact lead in daily revenue generation,\\nwith clear weekly patterns visible across all titles",
      x = NULL,
      y = NULL,
      color = "Game Title",
      caption = "Deconstructor of Fun • Sensor Tower Data"
    ) +
    theme_dof(base_size = 12) +
    theme(
      plot.caption = element_text(
        color = dof_colors$grey_dark,
        size = 10,
        hjust = 1,
        family = dof_font_subtitle,
        margin = margin(t = 15)
      ),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  # Create the image-based container with logo strip
  result_image <- create_dof_container(p, width = 1200, height = 800)
  
  # Save if path provided
  if (!is.null(save_path)) {
    image_write(result_image, save_path)
    cat("Line chart with border and logo strip saved as '", save_path, "'\\n", sep = "")
  }
  
  return(result_image)
}

# Stacked bar chart example
create_dof_stacked_chart <- function(save_path = NULL) {
  # Generate sample data for different game genres by platform
  stacked_data <- data.frame(
    platform = rep(c("Mobile", "Console", "PC", "VR"), each = 4),
    genre = rep(c("Action", "Strategy", "RPG", "Casual"), 4),
    revenue_millions = c(
      # Mobile
      12500, 8200, 15300, 9800,
      # Console  
      8900, 3200, 11200, 2100,
      # PC
      7800, 5900, 9200, 1800,
      # VR
      420, 180, 680, 290
    )
  )
  
  # Calculate totals for each platform
  platform_totals <- aggregate(revenue_millions ~ platform, stacked_data, sum)
  
  # Create the stacked bar plot
  p <- ggplot(stacked_data, aes(x = platform, y = revenue_millions, fill = genre)) +
    geom_col(width = 0.7, alpha = 0.9) +
    # Add labels inside each segment
    geom_text(aes(label = paste0("$", round(revenue_millions/1000, 1), "B")), 
              position = position_stack(vjust = 0.5),
              color = "white",
              size = 3.5,
              fontface = "bold",
              family = dof_font_body) +
    # Add total labels on top of each bar
    geom_text(data = platform_totals, 
              aes(x = platform, y = revenue_millions, label = paste0("$", round(revenue_millions/1000, 1), "B")),
              inherit.aes = FALSE,
              vjust = -0.5,
              color = dof_colors$secondary,
              size = 4,
              fontface = "bold",
              family = dof_font_body) +
    scale_fill_dof("full") +
    scale_y_continuous(labels = function(x) paste0("$", round(x/1000, 1), "B"), 
                       expand = c(0, 0, 0.1, 0)) +
    labs(
      title = "GAMING REVENUE BY PLATFORM AND GENRE IN 2024",
      subtitle = "Mobile gaming dominates across all genres, with RPG and Action\\ngames generating the highest revenue per platform",
      x = NULL,
      y = NULL,
      fill = "Game Genre",
      caption = "Deconstructor of Fun • Sensor Tower Data"
    ) +
    theme_dof(base_size = 12) +
    theme(
      plot.caption = element_text(
        color = dof_colors$grey_dark,
        size = 10,
        hjust = 1,
        family = dof_font_subtitle,
        margin = margin(t = 15)
      ),
      # Remove y-axis text since we have labels
      axis.text.y = element_blank(),
      panel.grid.major.y = element_blank()
    )
  
  # Create the image-based container with logo strip
  result_image <- create_dof_container(p, width = 1200, height = 800)
  
  # Save if path provided
  if (!is.null(save_path)) {
    image_write(result_image, save_path)
    cat("Stacked bar chart with border and logo strip saved as '", save_path, "'\\n", sep = "")
  }
  
  return(result_image)
}

# 100% stacked bar chart example
create_dof_100_stacked_chart <- function(save_path = NULL) {
  # Generate sample data for monetization models by platform
  monetization_data <- data.frame(
    platform = rep(c("Mobile", "Console", "PC", "VR"), each = 4),
    model = rep(c("Free-to-Play", "Premium", "Subscription", "Ad-Supported"), 4),
    percentage = c(
      # Mobile
      65, 15, 12, 8,
      # Console
      25, 55, 15, 5,
      # PC  
      35, 40, 20, 5,
      # VR
      30, 60, 8, 2
    )
  )
  
  # Create the 100% stacked bar plot
  p <- ggplot(monetization_data, aes(x = platform, y = percentage, fill = model)) +
    geom_col(width = 0.7, alpha = 0.9, position = "fill") +
    geom_text(aes(label = paste0(percentage, "%")), 
              position = position_fill(vjust = 0.5),
              color = "white",
              size = 3.5,
              fontface = "bold",
              family = dof_font_body) +
    scale_fill_dof("full") +
    scale_y_continuous(labels = percent_format(), expand = c(0, 0, 0.02, 0)) +
    labs(
      title = "MONETIZATION MODEL DISTRIBUTION BY PLATFORM 2024",
      subtitle = "Free-to-play dominates mobile while premium sales lead console gaming,\\nsubscription models gaining traction across all platforms",
      x = NULL,
      y = NULL,
      fill = "Monetization Model",
      caption = "Deconstructor of Fun • Sensor Tower Data"
    ) +
    theme_dof(base_size = 12) +
    theme(
      plot.caption = element_text(
        color = dof_colors$grey_dark,
        size = 10,
        hjust = 1,
        family = dof_font_subtitle,
        margin = margin(t = 15)
      )
    )
  
  # Create the image-based container with logo strip
  result_image <- create_dof_container(p, width = 1200, height = 800)
  
  # Save if path provided
  if (!is.null(save_path)) {
    image_write(result_image, save_path)
    cat("100% stacked bar chart with border and logo strip saved as '", save_path, "'\\n", sep = "")
  }
  
  return(result_image)
}

# Theme loaded successfully - no output messages