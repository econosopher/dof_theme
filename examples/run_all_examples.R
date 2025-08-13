# DoF consolidated examples (charts + table)

message("Running DoF examples...")

if (!dir.exists("output")) dir.create("output", recursive = TRUE)
file.remove(list.files("output", full.names = TRUE))

source("../dof_theme.R")

# Charts
example_bar_chart <- create_dof_example_chart("output/example_bar_chart.png")
example_line_chart <- create_dof_line_chart("output/example_line_chart.png")
example_stacked_chart <- create_dof_stacked_chart("output/example_stacked_bar_chart.png")
example_100_stacked_chart <- create_dof_100_stacked_chart("output/example_100_stacked_bar_chart.png")

# Table
if (!requireNamespace("gt", quietly = TRUE)) {
  stop("Package 'gt' is required for table example. install.packages('gt')")
}
source("../dof_gt_theme.R")
example_table <- create_dof_example_table()
gt::gtsave(data = example_table, filename = "output/example_table.png")

message("Generated ", length(list.files("output", pattern = "\\.png$")), " examples in output/")