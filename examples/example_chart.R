# Example usage of DoF theme
# Run this script to see the theme in action

# Load the theme (from parent directory)  
source("dof_theme.R")

# Create the example chart using the new image-based approach
example_chart <- create_dof_example_chart("examples/output/example_chart.png")

# Display the chart (magick image object)
print(example_chart)