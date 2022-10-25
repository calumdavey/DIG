# Primary analysis code
# Calum Davey
# Created 16 MAR 2022
# Modified 18 OCT 2022

# Requires clean dataset
# Should be wide: baseline and endline vars in separate
# columns, to allow for ANCOVA analysis

# Load libraries
    library(lme4)
    library(data.table)

# Save as data.table
# Reshape the model wide: outcome with baseline covars

# Names of variables
    outcomes <- c() # Names of the outcomes
    covars   <- c() # Names of the covers to include in the model

# Functions
# =========

# Function to return summary statistics
summary_cells <- function (var, data = d) {
    # if binary, return n/N and %
    # if continuous, return the mean and SD
    if (length(unique(data[, ..var])) <= 2) {

    } else {

    }
}

# Function to return the effect estimates
effects <- function (var, data = d) {
    # Fit a model
    model <- lmer()
    # Format the result
}

# Plots
# =====

# Plot 1: Histogram of primary outcome by arm
# -------------------------------------------

# Tables
# ======

# Table 1: baseline balance
# -------------------------

# Table 2: effects of the intervention at endline
# -----------------------------------------------


# Define list to save the results
results <- list()

# Perform the analysis
for (Y in outcomes) { # Loop over the multiple outcomes
    model <- glmer(as.formula(
        paste0(Y, " ~ DIG + + (1|village) + ",
        paste(c(covars, designvars), collapse = " + "))),
    data = data,
    link = link_functions[which(Y %in% outcomes)])
    results[[which(Y %in% outcomes)]] <- model
}

# Summarise the results
lapply(results, summary) %>% bind_rows()