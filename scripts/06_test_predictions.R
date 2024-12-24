## This script tests the prediction function.

rm(list = ls())

library(tidyverse)

source("scripts/functions/Prediction.R")

# Read parameters
pars1 <- read_csv("data/parameters/parameters_1_5.csv")
pars2 <- read_csv("data/parameters/parameters_2_0.csv")
pars3 <- read_csv("data/parameters/parameters_3_0.csv")

# Try out the prediction
predict_insulin(glucose = 50, pars = pars1)
predict_insulin(glucose = 50, pars = pars2)
predict_insulin(glucose = 50, pars = pars3)

# Try out hard-coded parameters
predict_insulin(glucose = 50, time = 1.5)
predict_insulin(glucose = 50, time = 2)
predict_insulin(glucose = 50, time = 3)

# Test the target functionality
predict_insulin(glucose = 50, delta = 0)
predict_insulin(glucose = 50, target = 150, start = 150)

predict_insulin(glucose = 50, start = 100, target = 150, time = 2)
