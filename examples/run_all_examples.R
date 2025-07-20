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

# Run all ggplot2 chart examples
tryCatch({
  source("example_charts.R")
  # All charts completed
}, error = function(e) {
  stop("Chart examples failed: ", e$message)
})

# 2. Run GT table example
tryCatch({
  source("example_table.R")
  # Table example completed
}, error = function(e) {
  stop("Table example failed: ", e$message)
})

# Examples completed