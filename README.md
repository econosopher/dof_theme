# DoF Theme

Custom ggplot2 and GT table themes for the Deconstructor of Fun podcast.

## Project Structure

```
dof_theme/
├── dof_theme.R          # Main ggplot2 theme
├── dof_gt_theme.R       # GT table theme
├── README.md
├── examples/            # Example scripts
│   ├── example_chart.R  # ggplot2 example
│   ├── example_table.R  # GT table example
│   ├── run_all_examples.R # Run all examples
│   └── output/          # Generated outputs
├── Images/              # Brand assets
└── style_guide/         # Official style guide
    ├── colors.png
    ├── font.png
    └── fonts/
        ├── Agrandir.ttf
        ├── Inter_Tight/
        └── Poppins/
```

## Quick Start

### ggplot2 Theme
```r
# Load the theme
source("dof_theme.R")

# Create a basic plot with DoF styling
your_plot + theme_dof()

# Use DoF color palette
your_plot + scale_fill_dof("main")

# Add logo watermark
add_dof_logo(your_plot)

# See example
create_dof_example_chart()
```

### GT Table Theme
```r
# Load the GT theme
source("dof_gt_theme.R")

# Apply DoF styling to a GT table
your_table %>% theme_dof_gt()

# See example
create_dof_example_table()
```

## Official Brand Colors

- **Primary**: #FF66A5 (Galactic Magenta)
- **Secondary**: #0F0D4F (Midnight Indigo)  
- **Accent**: #4F00EB (Pac(Man) Purple)

## Available Functions

### ggplot2 Theme (`dof_theme.R`)
- `theme_dof()` - Custom ggplot2 theme
- `scale_color_dof()` / `scale_fill_dof()` - DoF color scales
- `add_dof_logo()` - Add logo watermark to plots
- `format_dof_*()` - Number formatting functions
- `create_dof_example_chart()` - Example chart

### GT Table Theme (`dof_gt_theme.R`)
- `theme_dof_gt()` - Custom GT table theme
- `style_dof_*()` - Conditional formatting styles
- `create_dof_example_table()` - Example table

## Running Examples

```bash
# Run from the examples folder
cd examples
Rscript run_all_examples.R
```

This will generate outputs in `examples/output/`:
- `dof_example_chart_with_logo.png` - ggplot2 chart
- `dof_example_table.html` - GT table

## Font Hierarchy

The DoF themes use a sophisticated font hierarchy:

- **Titles**: Agrandir Variable (primary brand font)
- **Subtitles**: Inter Tight (clean, readable secondary text)  
- **Body/Axis/Data**: Poppins (UI elements and data display)

### Font Installation

To enable the full font hierarchy:

1. **Install fonts to system** (automatic helper included):
```r
source("dof_theme.R")
install_dof_fonts()  # Installs fonts from style_guide/fonts/ to system
```

2. **Enable fonts in R**:
```r
install.packages("extrafont")
library(extrafont)
font_import()  # Import all system fonts (may take a few minutes)
loadfonts()    # Load fonts for R
```

3. **Restart R** and reload the theme to see the fonts in action.

**Included fonts**:
- `style_guide/fonts/Agrandir.ttf` (Titles)
- `style_guide/fonts/Inter_Tight/` (Subtitles) 
- `style_guide/fonts/Poppins/` (Body/Data)

**Note**: Themes gracefully fallback to system fonts if custom fonts aren't available.