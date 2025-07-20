# Example stacked bar chart with DoF theme
# Run this script to see the stacked bar chart theme in action

# Load the theme (from parent directory)  
source("../dof_theme.R")

# Create and display the example stacked bar chart
example_stacked_chart <- create_dof_stacked_chart("output/example_stacked_bar_chart.png")

# Display the chart (magick image object)
print(example_stacked_chart)