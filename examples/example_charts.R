# Combined DoF theme ggplot2 examples
# Run this script to generate all chart examples

# Load the theme (from parent directory)  
source("../dof_theme.R")

# 1. Basic bar chart
example_bar_chart <- create_dof_example_chart("output/example_bar_chart.png")

# 2. Line chart with smoothing
example_line_chart <- create_dof_line_chart("output/example_line_chart.png")

# 3. Stacked bar chart
example_stacked_chart <- create_dof_stacked_chart("output/example_stacked_bar_chart.png")

# 4. 100% stacked bar chart with labels
example_100_stacked_chart <- create_dof_100_stacked_chart("output/example_100_stacked_bar_chart.png")

# Display summary
output_files <- list.files("output", pattern = "\\.png$", full.names = FALSE)
message("\nGenerated ", length(output_files), " chart examples in output/ folder")