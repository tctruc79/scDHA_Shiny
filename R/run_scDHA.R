# Load libraies ----

# scDHA library
library(scDHA)

# Cores
library(tidyverse)
library(tools)
library(readr)

# Functions to perform scDHA demo ----

# Load data from file
load_data <- function(dsname = NULL, file = NULL) {

    # increasing timeout
    options(timeout = 600)
    
    # Load data from file or package
    if (!is.null(dsname)) {
        
        # load from built-in dataset
        
        data_from_source <- get(dsname)
        
        # Get data matrix and label
        
        if (!is.null(data_from_source)) {
            data <- t(data_from_source[["data"]]) 
            label <- as.character(data_from_source[["label"]])
            cell.stages <- unique(label)
            cell.ids <- colnames(data_from_source[["data"]])
        }
        
    } else if ((!is.null(file)) && (file.exists(file))) {
    
       
        if (file_ext(file) == "rds") {
            
            # load .rds file
            
            data_from_source <- readr::read_rds(file = file)    
        
            # Get data matrix and label
        
            if (!is.null(data_from_source)) {
                data <- t(data_from_source@assays[["data"]]@listData[[1]]) 
                label <- as.character(data_from_source$cell_type1)
                cell.stages <- unique(label)
                cell.ids <- colnames(data_from_source@assays[["data"]]@listData[[1]])
            }
            
        } else if (file_ext(file) == "rda") {
            
            # load .rda file
            data_from_source <- get(load(file))
            
            # Get data matrix and label, same to built-in dataset
            
            if (!is.null(data_from_source)) {
                data <- t(data_from_source[["data"]]) 
                label <- as.character(data_from_source[["label"]])
                cell.stages <- unique(label)
                cell.ids <- colnames(data_from_source[["data"]])
            }
            
        } else if (file_ext(file) == "csv"){
            
            # load .csv file
            # file = "data/csv/camp-brain-fix_imputed.csv"
            data_from_source <- readr::read_csv(file = file)
        
            # Get data matrix 
            
            if (!is.null(data_from_source)) {
                data <- t(data_from_source)
                label <- NULL
                cell.stages <- NULL
                
                col_names <- c(sprintf("Cell_%d", seq(1, ncol(data))))
                colnames(data) <- col_names
                cell.ids <- col_names
                
                data <- t(data)
            }
            
        } else if (file_ext(file) == "tsv"){        
            
            # load .tsv file
            
            data_from_source <- readr::read_tsv(file = file)
            
            # Get data matrix 
            
            if (!is.null(data_from_source)) {
                data <- t(data_from_source)
                label <- NULL
                cell.stages <- NULL
                
                col_names <- c(sprintf("Cell_%d", seq(1, ncol(data))))
                colnames(data) <- col_names
                cell.ids <- col_names
                
                data <- t(data)
            }
        }        
    }
    
       
    # Transform the data
    data <- log2(data + 1)
    
    sc <- list("data" = data, 
               "label" = label,
               "cell.stages" = cell.stages,
               "cell.ids" = cell.ids)
    
    return(sc)
}

# sc <- load_data(dsname = "Goolam")


# SC data after go through scDHA pipeline
scDHA_pipeline <- function(sc) {
 
    # increasing timeout
    options(timeout = 600)
    
    # SC data after go through scDHA pipeline
    result <- scDHA(sc$data, ncores = 32, seed = 1)
    # result <- scDHA(sc$data, seed = 1)
    
    return(result)
}

# scDHA_result <- scDHA_pipeline(sc)


# scDHA function generates clustering result, the input matrix has rows as samples and columns as genes

# cell_segregation <- function(sc, scDHA_result) {
#     
#     # SC data after go through scDHA pipeline
#     result <- sc %>% scDHA_pipeline()     
#     
#     # cell segregation and bind with cell ID    
#     cluster <- bind_cols(sc$cell.ids, scDHA_result$cluster) %>% set_names(c("Cell ID", "Cluster ID"))
#     
#     return(cluster)
# }


cell_segregation <- function(sc, scDHA_result) {

    # cell segregation and bind with cell ID    
    cluster <- bind_cols(sc$cell.ids, scDHA_result$cluster) %>% set_names(c("Cell ID", "Cluster ID"))
    
    return(cluster)
}

# cluster <- cell_segregation(sc, scDHA_result)

# Generate 2D representation, the input is the output from scDHA function
gen_2d_rep <- function(scDHA_result) {
 
    # increasing timeout
    options(timeout = 600)
    
    result <- scDHA.vis(scDHA_result, ncores = 16, seed = 1)
     
    return(result)
}

# rep2d <- gen_2d_rep(scDHA_result)


# Plot the representation of the dataset, different colors represent different cell types

visual_2d <- function(result, sc) {
    
    # increasing timeout
    options(timeout = 600)
    
    plot(result$pred, col=factor(sc$label), xlab = "scDHA1", ylab = "scDHA2")
    
}

# visual_2d(rep2d)

# Generate pseudo-time for each cell, the input is the output from scDHA function

pseudo_time <- function(scDHA_result) {
    
    # increasing timeout
    options(timeout = 600)
    
    #  Perform Pseudo-time inference
    result <- scDHA.pt(scDHA_result, start.point = 1, seed = 1)
    
    return(result)
}


# Calculate R-squared value representing correlation between inferred pseudo-time and cell stage order
cal_r2 <- function (sc, result) {
    
    r2 <- round(cor(result$pt, as.numeric(factor(sc$label, levels = sc$cell.stages)))^2, digits = 2)
    
    return(r2)
}


# Plot pseudo-temporal ordering of cells in dataset

pseudo_plot <- function(sc, result, r2) {
 
    plot(result$pt, factor(sc$label, levels = sc$cell.stages), xlab= "Pseudo Time", ylab = "Cell Stages", xaxt="n", yaxt="n")
    axis(2, at = 1:length(sc$cell.stages), labels=sc$cell.stages, las = 2)
    text(x = 5, y = 5, labels = paste0("R2 = ", r2))
}


# Cell Classification

# Predict the labels of cells in testing set, the input matrices have rows as samples and columns as genes

cell_classification <- function(train.x, train.y, test.x) {
    
    prediction <- scDHA.class(train = train.x, train.label = train.y, test = test.x, seed = 1)

    return(prediction)
}

# Calculate accuracy of the predictions

cal_accuracy <- function(test.y, prediction) {
    
    accuracy <- round(sum(test.y == prediction)/length(test.y), 2)
    
    return(accuracy)
}

# test the code

# set.seed(1)
# 
# idx <- sample.int(nrow(sc$data), size = round(nrow(sc$data)*0.75))
# 
# train.x <- sc$data[idx, ]
# train.y <- sc$label[idx]
# test.x  <- sc$data[-idx, ]
# test.y  <- sc$label[-idx]
# test.cell.ids <- sc$cell.ids[-idx] 
# 
# # Predict the labels of cells in testing set, the input matrices have rows as samples and columns as genes
# 
# prediction <- cell_classification (train.x, train.y, test.x) 
# 
# # Calculate accuracy
# accuracy <<- cal_accuracy (test.y, prediction)
# 
# pre_result <- bind_cols(test.cell.ids, prediction, test.y) %>% set_names(c("Cell ID", "Predicted Label", "True Label")) %>%
#     mutate(`Accurate` = case_when(
#     `Predicted Label` == `True Label` ~ 'TRUE',
#     TRUE ~ 'FALSE'
#     ))



# Convert .csv to .tsv

csv_to_tsv <-  function(file1, file2) {

    data <- readr::read_csv(file1)

    readr::write_tsv(data, file2)
}




# test convert

#csv_to_tsv("data/csv/goolam_imputed.csv", "data/tsv/google_imputed.tsv")

# data1 <- readr::read_tsv("data/tsv/google_imputed.tsv")



# Load rda file
# file <- "data/rda/Goolam.rda"

# file.exists("canteen_clean.rda")
# filename <- file.choose("Goolam")
# Goolam <- readRDS(filename)

