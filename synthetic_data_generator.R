# =============================================================================
# SYNTHETIC DATA GENERATOR FOR SPERM PLOT™
# =============================================================================
#
# Generates realistic project timeline data for demonstration purposes.
# Creates monotonic completion trajectories that resemble biological swimmers.
#
# Author: [Your Name]
# License: MIT
# GitHub: https://github.com/gd047/sperm-plot-visualization
#
# =============================================================================

library(dplyr)
library(lubridate)

set.seed(42)  # For reproducible results

generate_sperm_plot_data <- function() {
  
  # Project types based on real-world patterns
  projects <- paste0("PROJ_", sprintf("%02d", 1:20))
  proj_types <- sample(c(rep("ahead", 2), rep("on_track", 2), rep("very_slow", 2), 
                        rep("stalled", 1), rep("behind", 13)))
  
  overdue_projects <- sample(1:20, size = sample(1:2, 1))
  
  all_data <- list()
  
  for (i in 1:20) {
    proj_id <- projects[i]
    proj_type <- proj_types[i]
    
    # Project parameters
    duration_years <- sample(3:10, 1)
    total_days <- duration_years * 365
    
    # Target current completion level
    if (i %in% overdue_projects) {
      target_pct_time <- runif(1, 100, 110)  # Slightly overdue
    } else {
      target_pct_time <- runif(1, 20, 95)    # Normal progress
    }
    
    # Calculate project dates
    current_date <- as.Date("2025-07-26")
    target_days_passed <- (target_pct_time / 100) * total_days
    start_date <- current_date - target_days_passed
    end_date <- start_date + total_days
    
    # Random budget (1M to 100M EUR)
    budget <- round(runif(1, 1000000, 100000000), -3)
    
    # Generate final completion level based on project type
    final_completion <- switch(proj_type,
      "ahead" = pmin(100, target_pct_time * runif(1, 1.2, 1.8)),
      "on_track" = target_pct_time * runif(1, 0.9, 1.1),
      "very_slow" = target_pct_time * runif(1, 0.05, 0.15),
      "stalled" = runif(1, 0, 8),
      "behind" = target_pct_time * runif(1, 0.3, 0.8)
    )
    final_completion <- max(0, min(100, final_completion))
    
    # Create monotonic trajectory by working backwards (13 months: 12→0)
    completions <- numeric(13)
    completions[13] <- final_completion  # months_ago = 0 (most recent)
    
    # Fill backwards to ensure monotonic progression
    for (j in 12:1) {
      if (proj_type == "stalled" && j >= 8) {
        completions[j] <- 0  # Stalled for older periods
      } else {
        # Gradual decrease going back in time
        decrease <- runif(1, 0, 5)  # Max 5% decrease per month
        completions[j] <- max(0, completions[j+1] - decrease)
      }
    }
    
    # Force monotonicity (safety net)
    for (j in 2:13) {
      if (completions[j] < completions[j-1]) {
        completions[j] <- completions[j-1]
      }
    }
    
    # Create data frames for all 13 months
    months_data <- list()
    for (j in 1:13) {
      month_ago <- 13 - j  # 12, 11, 10, ..., 1, 0
      snapshot_date <- current_date - months(month_ago)
      pct_complete <- completions[j]
      sum_work <- round(budget * (pct_complete / 100), -3)
      
      months_data[[j]] <- data.frame(
        symv_no = proj_id,
        months_ago = month_ago,
        snapshot_date = snapshot_date,
        start_date = start_date,
        end_date = end_date,
        cur_symvat = budget,
        sum_work = sum_work,
        stringsAsFactors = FALSE
      )
    }
    
    all_data[[i]] <- do.call(rbind, months_data)
  }
  
  # Combine all project data
  full_data <- do.call(rbind, all_data)
  
  # Create varied project histories (some started more recently)
  short_proj <- sample(projects, 1)   # 5 months of data (0-4)
  medium_proj <- sample(setdiff(projects, short_proj), 1)   # 8 months (0-7)
  partial_proj <- sample(setdiff(projects, c(short_proj, medium_proj)), 1)  # 10 months (0-9)
  
  # Apply truncation to simulate different project start times
  final_data <- full_data %>%
    filter(
      !(symv_no == short_proj & months_ago > 4) &
      !(symv_no == medium_proj & months_ago > 7) &
      !(symv_no == partial_proj & months_ago > 9)
    ) %>%
    arrange(symv_no, desc(months_ago))
  
  return(final_data)
}

# Function to calculate derived metrics from raw data
add_derived_columns <- function(raw_data) {
  raw_data %>%
    mutate(
      total_days = as.numeric(end_date - start_date),
      days_passed = as.numeric(snapshot_date - start_date),
      days_passed = pmax(0, days_passed),
      pct_time = (days_passed / total_days) * 100,
      pct_complete = (sum_work / cur_symvat) * 100,
      overdue = pct_time > 100
    )
}

# =============================================================================
# GENERATE SAMPLE DATA
# =============================================================================

# Generate raw project data
raw_data <- generate_sperm_plot_data()

# Process to get full dataset
synthetic_data <- add_derived_columns(raw_data)

# Export raw data to CSV (what users need to provide)
write.csv(raw_data, "sample_project_data.csv", row.names = FALSE)

# Show summary
cat("✓ Generated", nrow(raw_data), "records for", length(unique(raw_data$symv_no)), "projects\n")
cat("✓ RAW data exported to 'sample_project_data.csv'\n")
cat("  (Contains:", paste(colnames(raw_data), collapse = ", "), ")\n")

# Show project history lengths
history_summary <- raw_data %>%
  group_by(symv_no) %>%
  summarise(months_of_data = n(), .groups = "drop") %>%
  count(months_of_data, name = "projects") 

cat("\nProject history distribution:\n")
print(history_summary)

cat("\nData ready! Use plotly_sperm_plot_demo.R or ggplot_sperm_plot_demo.R to create visualizations.\n")
