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
- [Installation](#installation)
- [Real-World Applications](#real-world-applications)
- [Why “Sperm Plot”?](#why-sperm-plot)
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
- **Click-to-hide legend** – filter projects interactively.
- **Responsive design** – works on desktop and tablets.
- **Export options** – save as HTML or PNG.

### Static Version (ggplot2)
- **Smooth trajectory interpolation** – publication-ready curves.
- **Variable line thickness** – indicates temporal progression.
- **Anti-collision labels** – clean, readable project names.
- **High-resolution export** – perfect for reports and slides.

## Installation

Ensure you have `R` installed. Then install required packages:

```r
install.packages(c(
  "dplyr", "plotly", "htmlwidgets",
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

project timeline visualization, trajectory plot in R, project progress chart, schedule variance visualization, interactive R charts, ggplot2, plotly, tidyverse, project management analytics.

---

*Made with ❤️ and lots of ☕. If the Sperm Plot helped your project management, consider giving it a ⭐!*  
*“In the swimming pool of project management, not all swimmers finish the race at the same time.”*

