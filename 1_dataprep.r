# Load necessary libraries
#install.packages("janitor")
library(tidyverse)
library(dplyr)
library(janitor)


# Read the data
rawcalibaration <- read_csv("E:/SFU_MA/SFUComputationalEconomics2024/final/raw_calibration.csv") %>%
  clean_names()

glimpse(rawcalibaration)

rawcompetition  <- read_csv("E:/SFU_MA/SFUComputationalEconomics2024/final/raw_competition.csv") %>%
  clean_names()

# Data preparation
cleaned_calibration_df <- rawcalibaration %>%
  mutate(id = row_number(),
         subjid = as.character(subj_id),
         location_rehovot = if_else(location == "Rehovot", 1, 0),
         gender_female = if_else(gender == "F", 1, 0),
         set_1 = if_else(set == 1, 1, 0),
         set_2 = if_else(set == 2, 1, 0),
         set_3 = if_else(set == 3, 1, 0),
         set_4 = if_else(set == 4, 1, 0),
         set_5 = if_else(set == 5, 1, 0),
         set_6 = if_else(set == 6, 1, 0),
         experiment_1 = if_else(set %in% c(5,6), 1, 0),
         button_r = if_else(button == "R", 1, 0),
         shape_a_symm = if_else(lot_shape_a == "Symm", 1, 0),
         shape_b_symm = if_else(lot_shape_b == "Symm", 1, 0),
         shape_a_rskew = if_else(lot_shape_a == "R-skew", 1, 0),
         shape_b_rskew = if_else(lot_shape_b == "R-skew", 1, 0),
         shape_a_lskew = if_else(lot_shape_a == "L-skew", 1, 0),
         shape_b_lskew = if_else(lot_shape_b == "L-skew", 1, 0),
         rt = as.integer(replace_na(rt, NA)))

# Data preparation for competition data
competition_df <- rawcompetition %>%
  mutate(id = row_number(),
         subjid = as.character(subj_id),
         location_rehovot = if_else(location == "Rehovot", 1, 0),
         gender_female = if_else(gender == "F", 1, 0),
         experiment_1 = if_else(set %in% c(5,6), 1, 0),
         button_r = if_else(button == "R", 1, 0),
         shape_a_symm = if_else(lot_shape_a == "Symm", 1, 0),
         shape_b_symm = if_else(lot_shape_b == "Symm", 1, 0),
         shape_a_rskew = if_else(lot_shape_a == "R-skew", 1, 0),
         shape_b_rskew = if_else(lot_shape_b == "R-skew", 1, 0),
         shape_a_lskew = if_else(lot_shape_a == "L-skew", 1, 0),
         shape_b_lskew = if_else(lot_shape_b == "L-skew", 1, 0),
         rt = as.integer(replace_na(rt, NA)))


# filter when experiment_1 == 1
calibration_df <- cleaned_calibration_df %>%
  filter(experiment_1 == 1)


# Drop redundant columns
calibration_df <- calibration_df %>%
  select(-subj_id,-location,-gender,-set,-button,-lot_shape_a,-lot_shape_b, -condition)

# drop NA values
calibration_df <- calibration_df %>%
  drop_na()

# Check the cleaned data
glimpse(calibration_df)
glimpse(competition_df)

calibration_df <- calibration_df %>%
    select(id, everything(), b)

# Save the cleaned data
write_csv(calibration_df, "E:/SFU_MA/SFUComputationalEconomics2024/final/clean_calibration.csv")
write_csv(competition_df, "E:/SFU_MA/SFUComputationalEconomics2024/final/clean_competition.csv")
