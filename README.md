# The Sperm Plot™ – Project Timeline Visualization in R

> **Patent pending:** A novel visualization technique for project timeline analysis and progress tracking.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)](https://www.r-project.org/)
[![Made with Love](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red.svg)](https://github.com/gd047/sperm-plot-visualization)

## Table of Contents
- [Overview](#overview)
- [Trajectory Patterns](#trajectory-patterns)
- [Quick Start](#quick-start)
- [Data Requirements](#data-requirements)
- [Key Features](#key-features)
- [Advanced Analytics](#advanced-analytics)
- [Installation](#installation)
- [Real-World Applications](#real-world-applications)
- [Why "Sperm Plot"?](#why-sperm-plot)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [Related Keywords](#related-keywords)

## Overview

The **Sperm Plot™** is an R visualization technique designed for *project timeline analysis* and *trajectory plotting*. Each curve represents a project *swimming upstream* toward completion, similar to how biological swimmers race toward their destination. Some projects race ahead while others struggle to keep pace, providing a clear visual for project progress over time.

This approach combines the power of `ggplot2` and `plotly` to deliver both **interactive** and **publication-ready** charts. It’s ideal for project managers, PMO analysts, and anyone needing to track progress, schedule variance or velocity patterns across multiple projects.

![Interactive project timeline visualization showing trajectories of multiple projects over time](sperm_plot_preview.png)

## Trajectory Patterns

Different trajectory positions tell a story about schedule performance:

- **Above the diagonal:** Projects ahead of schedule – “fast swimmers.”
- **On the diagonal:** Projects on track – ideal progression.
- **Below the diagonal:** Projects behind schedule – “struggling swimmers.”
- **On the x-axis:** Stalled projects – haven’t started or are blocked.
- **Beyond 100 % time:** Overdue projects.

## Quick Start

### 1. Generate Sample Data
```r
source("synthetic_data_generator.R")
# Creates sample_project_data.csv with realistic project timelines
```

### 2. Create Interactive Visualization (Plotly)
```r
source("plotly_sperm_plot_demo.R")
# Interactive project timeline plot with custom hover positioning
```

### 3. Create Static Publication Version (ggplot2)
```r
source("ggplot_sperm_plot_demo.R")
# High-resolution plot suitable for reports and presentations
```

## Data Requirements

The Sperm Plot works with **minimal data**. Your dataset should include:

| Column          | Description                        | Example          |
|-----------------|------------------------------------|------------------|
| `symv_no`       | Project identifier                 | `"PROJ_01"`      |
| `months_ago`    | Time reference (0 = current)       | 0, 1, …, 12      |
| `snapshot_date` | Observation date                   | `"2025-07-26"`   |
| `start_date`    | Project start date                 | `"2024-01-15"`   |
| `end_date`      | Planned project end date           | `"2026-12-31"`   |
| `cur_symvat`    | Total budget (EUR)                 | 5000000          |
| `sum_work`      | Work completed (EUR)               | 2250000          |

**That’s it!** Percentage calculations are derived automatically.

## Key Features

### Interactive Version (Plotly)
- **Custom hover positioning** – solves the tooltip obstruction problem.
- **Trajectory analytics** – displays angle and completion prediction for each snapshot.
- **Dynamic prediction line** – visual projection extending from trajectory start to predicted endpoint.
- **Contract aggregation** – automatically combines parent/child contracts (e.g., "PROJ_01" + "PROJ_01/A").
- **Click-to-hide legend** – filter projects interactively.
- **Responsive design** – works on desktop and tablets.
- **Export options** – save as HTML or PNG.

### Static Version (ggplot2)
- **Smooth trajectory interpolation** – publication-ready curves.
- **Variable line thickness** – indicates temporal progression.
- **Anti-collision labels** – clean, readable project names.
- **High-resolution export** – perfect for reports and slides.

## Advanced Analytics

The Plotly interactive version includes sophisticated analytical features:

### 📊 Trajectory Slope & Angle
Calculates the trajectory angle (in degrees) based on the linear slope between the oldest and most recent snapshots:
- **Positive angles**: Projects making progress toward completion
- **Negative angles**: Projects regressing (rare, but possible)
- **Steep angles**: Rapid progress acceleration
- **Shallow angles**: Slow or stagnant progress

### 🎯 Completion Prediction
Estimates the final completion percentage at the project deadline (100% time) using linear extrapolation:
- **> 100%**: Project will likely exceed targets
- **≈ 100%**: Project on track to complete on time
- **< 100%**: Project will likely fall short without intervention

**Formula**: Based on the trajectory slope from the first to the last snapshot, the prediction extends to 100% time.

### 📈 Dynamic Prediction Line
When hovering over any data point:
- A **dotted gray line** appears showing the projected trajectory
- Extends from the trajectory's **starting point** (oldest snapshot)
- Projects to **100% time** (project deadline)
- The endpoint represents the **predicted completion percentage**

This visual aid helps quickly assess whether current progress rates will lead to successful project completion.

### 🔗 Parent/Child Contract Aggregation
Automatically handles complex contract structures:
- Detects relationships like `"PROJ_01"` (parent) and `"PROJ_01/A"` (child)
- Aggregates budgets and work completed across related contracts
- Inherits start/end dates from parent contracts
- Displays unified trajectories for contract families

**Use case**: When projects have amendments, sub-contracts, or phases tracked separately but need to be analyzed as a whole.

## Installation

Ensure you have `R` installed. Then install required packages:

```r
install.packages(c(
  "dplyr", "stringr", "lubridate", "plotly", "htmlwidgets",
  "tidyverse", "scales", "ggrepel"
))
```

## Real-World Applications

- **Project Portfolio Management** – track multiple projects simultaneously.
- **Executive Dashboards** – visual KPIs for leadership teams.
- **Risk Assessment** – identify struggling projects early.
- **Resource Planning** – understand project velocity patterns.
- **Client Reporting** – professional visualizations for stakeholders.

## Why “Sperm Plot”?

The trajectories genuinely resemble biological swimmers:

- **Head (current position):** where the project is now.
- **Tail (historical data):** the path taken to reach that point.
- **Swimming motion:** progress toward completion.
- **Pool (plot area):** the project timeline environment.

It’s both scientifically accurate and memorably descriptive!

## Contributing

Found a bug or have an improvement idea?

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by real-world project management challenges.
- Built with the amazing R visualization ecosystem.
- Special thanks to the `tidyverse` and `plotly` communities.
- Developed with crucial assistance from AI models.

## Related Keywords

project timeline visualization, trajectory plot in R, project progress chart, schedule variance visualization, interactive R charts, ggplot2, plotly, tidyverse, project management analytics, completion prediction, trajectory analysis, slope calculation, parent-child contract aggregation, project forecasting, progress tracking dashboard.

---

*Made with ❤️ and lots of ☕. If the Sperm Plot helped your project management, consider giving it a ⭐!*  
*“In the swimming pool of project management, not all swimmers finish the race at the same time.”*

