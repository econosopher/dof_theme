# Deconstructor of Fun Theme Examples
# Run all examples and generate outputs

cat("🎮 Deconstructor of Fun Theme Examples\n")
cat("=====================================\n\n")

# Create output directory if it doesn't exist
if (!dir.exists("output")) {
  dir.create("output")
}

# 1. Run ggplot2 chart example
cat("📊 Creating ggplot2 chart example...\n")
tryCatch({
  source("example_chart.R")
  cat("✅ Chart example completed successfully\n\n")
}, error = function(e) {
  cat("❌ Chart example failed:", e$message, "\n\n")
})

# 2. Run GT table example  
cat("📋 Creating GT table example...\n")
tryCatch({
  source("example_table.R")
  cat("✅ Table example completed successfully\n\n")
}, error = function(e) {
  cat("❌ Table example failed:", e$message, "\n\n")
})

# 3. List generated outputs
cat("📁 Generated outputs:\n")
output_files <- list.files("output", full.names = TRUE)
if (length(output_files) > 0) {
  for (file in output_files) {
    cat("  •", basename(file), "\n")
  }
} else {
  cat("  No output files found\n")
}

cat("\n🎉 All examples completed!\n")
cat("View outputs in the examples/output/ folder\n")