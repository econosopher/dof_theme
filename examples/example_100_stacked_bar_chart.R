# Example 100% stacked bar chart with DoF theme
# Run this script to see the 100% stacked bar chart theme in action

# Load the theme (from parent directory)  
source("dof_theme.R")

# Create and display the example 100% stacked bar chart
example_100_stacked_chart <- create_dof_100_stacked_chart("examples/output/example_100_stacked_bar_chart.png")

# Display the chart (magick image object)
print(example_100_stacked_chart)