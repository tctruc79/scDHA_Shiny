# Installation ----
# 1. Install scDHA package and other requirements----

#Install devtools: 
utils::install.packages('devtools')

#Install the package from GitHub:
devtools::install_github('duct317/scDHA')
#With manual and vignette: 
devtools::install_github('duct317/scDHA', build_manual = T, build_vignettes = T)
#Or from CRAN:
install.packages("scDHA")

#When the package is loaded, it will check for C++ libtorch 
library(scDHA)
#libtorch can be installed using:
torch::install_torch(reinstall = FALSE)

# 2. Install other necessary packages ----

if (!requireNamespace("mclust", quietly = TRUE)) install.packages("mclust")

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("SingleCellExperiment")