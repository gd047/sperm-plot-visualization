# =============================================================================
# THE SPERM PLOT™ - Interactive Project Timeline Visualization
# =============================================================================
# 
# A novel visualization technique where project trajectories "swim" toward 
# completion, resembling biological swimmers racing toward their destination.
#
# Author: [Your Name]
# License: MIT
# GitHub: https://github.com/gd047/sperm-plot-visualization
#
# Features:
# - Interactive hover with custom positioning
# - Click-to-hide legend functionality  
# - Monotonic project progression tracking
# - Time vs Completion percentage analysis
#
# =============================================================================

# Load required libraries
library(dplyr)
library(plotly)
library(htmlwidgets)

# NOTE: This script requires sample_project_data.csv 
# Generate this file using synthetic_data_generator.R

# =============================================================================
# DATA PREPARATION
# =============================================================================

# Load the raw project data (essential columns only)
# This represents what users need to provide
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

# Process raw data to get full dataset for visualization
project_data <- add_derived_columns(raw_project_data)

# Prepare data for visualization
df_plot <- project_data %>%
  arrange(symv_no, months_ago) %>%
  mutate(
    # Format date for display
    formatted_date = format(snapshot_date, "%Y/%m"),
    
    # Create hover text (currently unused due to custom hover implementation)
    hover_text = paste0(
      "Contract: ", symv_no, "\n",
      "Months ago: ", months_ago, " (", formatted_date, ")\n",
      "% Time elapsed: ", round(pct_time, 1), "%\n",
      "% Completion: ", round(pct_complete, 1), "%"
    ),
    
    # Custom data for hover box (combines months_ago and formatted_date)
    custom_data = paste(months_ago, formatted_date, sep = "|")
  )

# Define color scheme
primary_color <- "#4682b4"  # Steel blue for main elements

# =============================================================================
# CREATE THE SPERM PLOT™
# =============================================================================

create_sperm_plot <- function(data, width = 1130, height = 750) {
  
  # Main plot with trajectory lines and points
  p <- data %>%
    plot_ly(
      x = ~pct_time,
      y = ~pct_complete,
      split = ~symv_no,                    # Creates separate traces per project
      customdata = ~custom_data,           # Data for custom hover functionality
      type = 'scatter',
      mode = 'lines+markers',
      
      # Line styling - creates the "swimmer" trajectories
      line = list(shape = 'spline', width = 2, color = 'grey80'),
      
      # Marker styling - colored by timeline age
      marker = list(
        size = 8,
        color = ~months_ago,               # Color represents data age
        colorscale = list(
          c(0, 'rgba(70,130,180,1)'),     # Recent data: steel blue
          c(1, 'rgba(200,200,200,0.2)')   # Older data: light grey
        ),
        cmin = 0,
        cmax = max(data$months_ago, na.rm = TRUE),
        showscale = FALSE,                 # Hide color scale legend
        opacity = 0.6
      ),
      
      # Disable default hover - we'll implement custom hover
      hoverinfo = 'none'
    ) %>%
    
    # Add project labels at current position (months_ago = 0)
    add_trace(
      data = filter(data, months_ago == 0),
      x = ~pct_time,
      y = ~pct_complete,
      type = 'scatter',
      mode = 'text',
      text = ~symv_no,
      textfont = list(color = primary_color, size = 12),
      textposition = 'top center',
      showlegend = FALSE,                  # Don't show in legend
      hoverinfo = 'skip'                   # Skip hover for text labels
    ) %>%
    
    # Configure layout and reference lines
    layout(
      # Add reference lines
      shapes = list(
        # Vertical line at 100% time (project deadline)
        list(
          type = "line",
          x0 = 100, x1 = 100,
          y0 = 0, y1 = 100,
          line = list(dash = 'dash', color = primary_color)
        ),
        # Diagonal line (ideal progress: completion = time elapsed)
        list(
          type = "line", 
          x0 = 0, x1 = 100,
          y0 = 0, y1 = 100,
          line = list(dash = 'dot', color = 'darkgrey', width = 1)
        )
      ),
      
      # X-axis configuration
      xaxis = list(
        title = "% Time Elapsed",
        range = c(0, max(data$pct_time, 100, na.rm = TRUE) * 1.1),
        tickmode = 'array',
        tickvals = seq(0, ceiling(max(data$pct_time, 100)/20)*20, by = 20),
        ticktext = paste0(seq(0, ceiling(max(data$pct_time, 100)/20)*20, by = 20), "%"),
        ticklen = 5,
        tickpad = 2
      ),
      
      # Y-axis configuration  
      yaxis = list(
        scaleanchor = "x",                 # Maintain aspect ratio
        scaleratio = 1,                    # 1:1 ratio for proper visualization
        title = "% Project Completion",
        range = c(0, 100),
        tickmode = 'array',
        tickvals = seq(0, 100, by = 20),
        ticktext = paste0(seq(0, 100, by = 20), "%")
      ),
      
      # Legend configuration
      legend = list(title = list(text = "Contract")),
      
      # Margin settings for optimal spacing
      margin = list(l = 40, r = 20, t = 80, b = 40),
      
      # Custom hover information box (positioned in top-left)
      annotations = list(
        list(
          x = 0.1, y = 0.90,
          xref = "paper", yref = "paper",
          text = "Hover over points for details",
          showarrow = FALSE,
          xanchor = "left", yanchor = "top",
          bordercolor = "gray", borderwidth = 1,
          bgcolor = "rgba(255,255,255,0.9)",
          font = list(size = 11)
        )
      ),
      
      # Set plot dimensions
      width = width,
      height = height
    ) %>%
    
    # =================================================================
    # CUSTOM HOVER IMPLEMENTATION
    # =================================================================
    # This solves the common issue where hover tooltips obscure
    # subsequent data points in upward-trending trajectories
    #
    htmlwidgets::onRender("
      function(el, x) {
        
        // Event listener for hover events
        el.on('plotly_hover', function(eventData) {
          
          // Extract information from the hovered point
          var point = eventData.points[0];
          
          // Parse custom data (months_ago|formatted_date)
          var customParts = point.customdata.split('|');
          var monthsAgo = customParts[0];
          var formattedDate = customParts[1];
          
          // Build information text
          var infoText = 'Contract: ' + point.data.name + '<br>' +
                        'Months ago: ' + monthsAgo + ' (' + formattedDate + ')<br>' +
                        '% Time: ' + point.x.toFixed(1) + '%<br>' +
                        '% Completion: ' + point.y.toFixed(1) + '%';
          
          // Update the annotation box with hover information
          Plotly.relayout(el, 'annotations[0].text', infoText);
        });
        
        // Event listener for unhover events  
        el.on('plotly_unhover', function() {
          // Reset to default text
          Plotly.relayout(el, 'annotations[0].text', 'Hover over points for details');
        });
      }
    ")
  
  return(p)
}

# =============================================================================
# USAGE EXAMPLE
# =============================================================================

# Create the interactive sperm plot
sperm_plot <- create_sperm_plot(df_plot)

# Display the plot
sperm_plot

# =============================================================================
# INTERPRETATION GUIDE
# =============================================================================
#
# TRAJECTORY PATTERNS:
# 
# 🏊‍♂️ SWIMMERS ABOVE DIAGONAL: Projects ahead of schedule
#    - Completion percentage > Time elapsed percentage  
#    - "Fast swimmers" racing toward the finish
#
# 🏊‍♂️ SWIMMERS ON DIAGONAL: Projects on schedule
#    - Completion ≈ Time elapsed
#    - Ideal project progression
#
# 🏊‍♂️ SWIMMERS BELOW DIAGONAL: Projects behind schedule  
#    - Completion < Time elapsed
#    - "Slower swimmers" struggling to keep pace
#
# 🏊‍♂️ SWIMMERS ON X-AXIS: Stalled projects
#    - Near 0% completion despite time passing
#    - Projects that haven't started or are blocked
#
# REFERENCE LINES:
# - Dotted diagonal: Ideal progress line (completion = time)
# - Dashed vertical at 100%: Project deadline
# - Projects beyond 100% time are overdue
#
# INTERACTIVE FEATURES:
# - Hover: Custom positioned information box (solves UX issue)
# - Legend: Click to hide/show individual project trajectories
# - Zoom: Mouse wheel or selection box for detailed analysis
#
# =============================================================================

# Optional: Export static version
# Uncomment to save as PNG
# library(webshot)
# htmlwidgets::saveWidget(sperm_plot, "sperm_plot.html")
# webshot("sperm_plot.html", "sperm_plot.png", width = 1130, height = 750)
