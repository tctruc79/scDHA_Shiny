# 1. Install "scDHA" from CRAN:

pkgs <- c(
    "scDHA",
    "MASS",
    
    "torch",
    "mclust",
    
    "BiocManager",
    
    "flexdashboard",
    "shiny",
    "shinyWidgets",
    "shinyjs",
    
    # install.packages("DT")
    "DT",
    
    # Core
    "tidyverse",
    
    # torch
    "torch"
)

install.packages(pkgs)

# 2. Install other necessary packages ----

BiocManager::install("SingleCellExperiment")

#libtorch can be installed using:
install.packages("torch")
torch::install_torch(reinstall = TRUE)

