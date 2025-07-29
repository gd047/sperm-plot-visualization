# =============================================================================
# THE SPERM PLOT™ - Static Project Timeline Visualization (ggplot2)
# =============================================================================
# 
# A static version of the Sperm Plot using ggplot2 with smooth trajectory 
# rendering and publication-ready aesthetics.
#
# Author: [Your Name]
# License: MIT
# GitHub: https://github.com/gd047/sperm-plot-visualization
#
# Features:
# - Smooth monotonic spline interpolation
# - Variable line thickness based on data recency
# - Anti-collision label positioning
# - Publication-ready styling
# - High-resolution export options
#
# =============================================================================

# Load required libraries
library(tidyverse)
library(scales)
library(ggrepel)

# NOTE: This script requires sample_project_data.csv
# Generate this file using synthetic_data_generator.R

# =============================================================================
# DATA PREPARATION AND SMOOTHING
# =============================================================================

# Load the raw project data (essential columns only)
raw_project_data <- read.csv("sample_project_data.csv", stringsAsFactors = FALSE)
raw_project_data$snapshot_date <- as.Date(raw_project_data$snapshot_date)
raw_project_data$start_date <- as.Date(raw_project_data$start_date)
raw_project_data$end_date <- as.Date(raw_project_data$end_date)

# Function to calculate derived metrics from raw data
add_derived_columns <- function(raw_data) {
  raw_data %>%
    mutate(
      # Calculate time-based metrics
      total_days = as.numeric(end_date - start_date),
      days_passed = as.numeric(snapshot_date - start_date),
      days_passed = pmax(0, days_passed),  # Ensure non-negative
      
      # Calculate percentages  
      pct_time = (days_passed / total_days) * 100,
      pct_complete = (sum_work / cur_symvat) * 100,  # Completion based on work done
      
      # Determine overdue status
      overdue = pct_time > 100
    )
}

# Process raw data to get full dataset
project_data <- add_derived_columns(raw_project_data)

# Calculate upper x-axis break (rounded to nearest 20)
max_time <- max(project_data$pct_time, na.rm = TRUE)
max_break <- ceiling(max_time / 20) * 20

# Create smooth trajectory data with monotonic splines
# This ensures biologically realistic "swimming" curves
df_smooth <- project_data %>%
  group_by(symv_no) %>%
  arrange(pct_time) %>%
  summarise(
    # Store original data points
    x_orig = list(pct_time),
    y_orig = list(pct_complete),
    m_orig = list(months_ago),
    .groups = "drop"
  ) %>%
  mutate(
    # Create dense interpolation points for smooth curves
    xout = map(x_orig, ~ seq(min(.x), max(.x), length.out = 100)),
    
    # Apply monotonic interpolation to maintain realistic trajectories
    df = pmap(
      list(x_orig, y_orig, m_orig, xout),
      function(orig_x, orig_y, orig_m, new_x) {
        
        # Monotonic Hermite spline for completion percentage
        # Ensures projects never "go backwards" in progress
        yfun <- stats::splinefun(orig_x, orig_y, method = "monoH.FC")
        new_y <- yfun(new_x)
        
        # Interpolate months_ago for line thickness variation
        if (length(unique(orig_m)) > 1) {
          new_m <- stats::approx(orig_x, orig_m, xout = new_x, ties = mean)$y
        } else {
          new_m <- rep(orig_m[1], length(new_x))
        }
        
        tibble(
          pct_time = new_x,
          pct_complete = new_y,
          months_ago = new_m
        )
      }
    )
  ) %>%
  select(symv_no, df) %>%
  unnest(df) %>%
  mutate(
    # Calculate line thickness: thicker = more recent data
    thickness = scales::rescale(
      max(project_data$months_ago) - months_ago,
      to = c(0.2, 1.2)  # Range from thin (old) to thick (recent)
    )
  )

# =============================================================================
# COLOR PALETTE GENERATION
# =============================================================================

# Create consistent color schemes for trajectories and labels
contracts <- sort(unique(project_data$symv_no))
line_colors <- hue_pal()(length(contracts))      # Bright colors for trajectories
names(line_colors) <- contracts

label_colors <- colorspace::darken(line_colors, amount = 0.4)  # Darker for labels
names(label_colors) <- contracts

# =============================================================================
# CREATE THE STATIC SPERM PLOT
# =============================================================================

create_static_sperm_plot <- function(project_data, smooth_data, 
                                   line_colors, label_colors, 
                                   width = 12, height = 8) {
  
  ggplot() +
    
    # Layer 1: Smooth trajectory "tails" - the swimming paths
    geom_path(
      data = smooth_data,
      aes(
        x = pct_time,
        y = pct_complete,
        group = symv_no,
        linewidth = thickness,           # Variable thickness
        color = symv_no            # Individual project colors
      ),
      lineend = "round"            # Smooth line endings
    ) +
    scale_linewidth_identity(guide = "none") +
    scale_color_manual(
      values = line_colors,
      name = "Contract", 
      guide = "none"               # Hide legend for cleaner look
    ) +
    
    # Layer 2: Current position markers (months_ago = 0)
    geom_point(
      data = filter(project_data, months_ago == 0),
      aes(x = pct_time, y = pct_complete, color = symv_no),
      size = 2
    ) +
    
    # Layer 3: Anti-collision labels at current positions
    geom_text_repel(
      data = filter(project_data, months_ago == 0),
      aes(x = pct_time, y = pct_complete, label = symv_no),
      color = label_colors[filter(project_data, months_ago == 0)$symv_no],
      size = 3,
      max.overlaps = 20,           # Allow aggressive label positioning
      segment.size = 0.2,          # Thin connecting lines
      box.padding = 0.3,           # Label spacing
      point.padding = 0.5          # Distance from points
    ) +
    
    # Reference lines
    geom_vline(
      xintercept = 100, 
      linetype = "dotted", 
      color = "#4682b4", 
      linewidth = 0.7
    ) +  # Project deadline
    
    geom_abline(
      slope = 1, intercept = 0, 
      linetype = "dashed", 
      color = "darkgrey", 
      linewidth = 0.5
    ) +  # Ideal progress line
    
    # Axis configuration
    scale_x_continuous(
      name = "% Time Elapsed",
      limits = c(0, max(project_data$pct_time, 100) * 1.1),
      breaks = seq(0, max_break, by = 20),
      labels = function(x) paste0(x, "%")
    ) +
    
    scale_y_continuous(
      name = "% Project Completion", 
      limits = c(0, 100),
      breaks = seq(0, 100, by = 20),
      labels = function(x) paste0(x, "%")
    ) +
    coord_fixed() +
    # Titles and labels
    labs(
      title = "Project Timeline Swimming Pool",
      subtitle = "Each curve shows the time-progress relationship over the last 12 months.",
      caption = "The Sperm Plot™ - Projects swimming toward completion"
    ) +
    
    # Publication-ready theme
    theme_minimal() +
    theme(
      # Legend styling
      legend.position = "top",
      legend.title = element_text(size = rel(0.9)),
      legend.text = element_text(margin = margin(r = 12, unit = "pt")),
      
      # Text and caption styling  
      plot.caption = element_text(colour = "gray25"),
      plot.title = element_text(size = rel(1.2), face = "bold"),
      plot.subtitle = element_text(size = rel(1.0), color = "gray40"),
      
      # Axis styling
      axis.text.y = element_text(angle = 0, hjust = 1),
      axis.title = element_text(size = rel(1.1)),
      
      # Grid styling for clean presentation
      panel.grid.minor = element_line(
        colour = rgb(244, 252, 253, max = 255), 
        linewidth = 0.5
      ),
      panel.grid.major.x = element_line(
        colour = rgb(234, 242, 243, max = 255), 
        linewidth = 0.5
      ),
      
      # Spacing and margins
      legend.box.margin = margin(0, 0, 0, 0),
      plot.margin = unit(c(5.5, 5.5, 1, 5.5), "pt")
    )
}

# =============================================================================
# USAGE EXAMPLE
# =============================================================================

# Create the static sperm plot
static_sperm_plot <- create_static_sperm_plot(
  project_data = project_data,
  smooth_data = df_smooth,
  line_colors = line_colors,
  label_colors = label_colors
)

# Display the plot
print(static_sperm_plot)

# =============================================================================
# HIGH-RESOLUTION EXPORT OPTIONS
# =============================================================================

# Export as PNG for presentations
export_sperm_plot <- function(plot, filename = "sperm_plot", 
                             width = 12, height = 8, dpi = 300) {
  
  # PNG export
  ggsave(
    filename = paste0(filename, ".png"),
    plot = plot,
    width = width,
    height = height, 
    dpi = dpi,
    bg = "white"
  )
  
  # PDF export for publications
  ggsave(
    filename = paste0(filename, ".pdf"),
    plot = plot,
    width = width,
    height = height,
    device = "pdf"
  )
  
  cat("✓ Plot exported as:", paste0(filename, ".png"), "and", paste0(filename, ".pdf"), "\n")
}

# Uncomment to export
# export_sperm_plot(static_sperm_plot, "sperm_plot_demo")

# =============================================================================
# INTERPRETATION GUIDE (SAME AS INTERACTIVE VERSION)
# =============================================================================
#
# TRAJECTORY PATTERNS:
# 
# 🏊‍♂️ THICK LINES NEAR HEAD: Recent project activity
# 🏊‍♂️ THIN LINES NEAR TAIL: Historical project data
# 🏊‍♂️ UPWARD CURVES: Projects gaining momentum
# 🏊‍♂️ FLAT LINES: Periods of no progress/stalled work
#
# REFERENCE LINES:
# - Dashed diagonal: Ideal progress (time = completion)
# - Dotted vertical: Project deadline (100% time)
# - Area above diagonal: Ahead of schedule  
# - Area below diagonal: Behind schedule
#
# =============================================================================
