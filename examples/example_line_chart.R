# Example line chart with DoF theme
# Run this script to see the line chart theme in action

# Load the theme (from parent directory)  
source("../dof_theme.R")

# Create and display the example line chart
example_line_chart <- create_dof_line_chart("output/example_line_chart.png")

# Display the chart (magick image object)
print(example_line_chart)