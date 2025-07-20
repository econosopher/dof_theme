# Deconstructor of Fun Theme Examples
# Run all examples and generate outputs

# Create output directory if it doesn't exist
if (!dir.exists("output")) {
  dir.create("output", recursive = TRUE)
}

# Clean up old output files before generating new ones
old_files <- list.files("output", full.names = TRUE)
if (length(old_files) > 0) {
  file.remove(old_files)
}

# Original bar chart
tryCatch({
  source("example_chart.R")
  # Bar chart completed
}, error = function(e) {
  stop("Bar chart example failed: ", e$message)
})

# Line chart
tryCatch({
  source("example_line_chart.R")
  # Line chart completed
}, error = function(e) {
  stop("Line chart example failed: ", e$message)
})

# Stacked bar chart
tryCatch({
  source("example_stacked_bar_chart.R")
  # Stacked bar chart completed
}, error = function(e) {
  stop("Stacked bar chart example failed: ", e$message)
})

# 100% stacked bar chart
tryCatch({
  source("example_100_stacked_bar_chart.R")
  # 100% stacked bar chart completed
}, error = function(e) {
  stop("100% stacked bar chart example failed: ", e$message)
})

# 2. Run GT table example
tryCatch({
  source("example_table.R")
  # Table example completed
}, error = function(e) {
  stop("Table example failed: ", e$message)
})

# Examples completed