# Example usage of DoF GT table theme
# Run this script to see the table theme in action

# Check if gt package is available
if (!require(gt, quietly = TRUE)) {
  cat("GT package not installed. Install with: install.packages('gt')\n")
  cat("Skipping table example.\n")
} else {
  # Load the GT theme (from parent directory)
  source("../dof_gt_theme.R")
  
  # Create and display the example table
  example_table <- create_dof_example_table()
  
  # Display the table
  print(example_table)
  
  # Save the table as PNG to output folder
  gt::gtsave(data = example_table, filename = "output/example_table.png")
  
  cat("Table saved as 'examples/output/example_table.png'\n")
}