# Example usage of DoF theme
# Run this script to see the theme in action

# Load the theme (from parent directory)
source("../dof_theme.R")

# Create and display the example chart
example_plot <- create_dof_example_chart()

# Display the plot
print(example_plot)

# Add logo version with watermark
logo_plot <- add_dof_logo(example_plot, alpha = 0.12)
print(logo_plot)

# Save the plot with logo watermark to output folder
ggsave("output/dof_example_chart_with_logo.png", logo_plot, width = 10, height = 6, dpi = 300, bg = "white")

cat("Chart with logo watermark saved as 'output/dof_example_chart_with_logo.png'\n")