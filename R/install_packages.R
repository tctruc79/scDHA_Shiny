# 1. Install "scDHA" from CRAN:

install.packages("scDHA")
install.packages("MASS")

# Install "torch" for Mac M1
# source("https://raw.githubusercontent.com/mlverse/torch/master/R/install.R")
install.packages("torch")

# 2. Install other necessary packages ----

if (!requireNamespace("mclust", quietly = TRUE)) install.packages("mclust")

if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")

BiocManager::install("SingleCellExperiment")

#libtorch can be installed using:
# torch::install_torch(reinstall = TRUE)

# Sys.setenv(TORCH_INSTALL = 1)