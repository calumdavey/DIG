# Primary analysis code
# Calum Davey
# 16 MAR 2022

# Requires clean dataset
# Should be wide: baseline and endline vars in separate
# columns, to allow for ANCOVA analysis

library(dply) # Required library
library(lme4) # Required library

# Define variable names
outcomes <- c() # Names of the outcomes
covars   <- c() # Names of the covers to include in the model
designvars <- c("pair", "district") # Names of the design vars
link_functions <- c() # Link function, for continuous and binary

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