using Pkg

Pkg.activate("final_env")

using CSV
using DataFrames
using Flux
using Random

# Load the preprocessed calibration and competition data
calibration_df = CSV.read("E:/SFU_MA/SFUComputationalEconomics2024/final/clean_calibration.csv", DataFrame)

# Test-train split -------------------------------------------------------------------

# Perform a test-train split of the calibration data


# Test-train split of 80-20

Random.seed!(420)

# Shuffle the indices
shuffled_indices = Random.shuffle(1:nrow(calibration_df))

# Determine the number of rows for the training set (80% of total rows)
train_size = round(Int, 0.8 * nrow(calibration_df))

# Split the indices into training and testing sets
train_indices = shuffled_indices[1:train_size]
test_indices = shuffled_indices[train_size+1:end]

# Create the training and testing sets
train_set = calibration_df[train_indices, :]
test_set = calibration_df[test_indices, :]

nrow(train_set)/nrow(calibration_df)

nrow(test_set)/nrow(calibration_df)


# Export training and testing data

CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/train_set.csv", train_set)
CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/test_set.csv", test_set)




# train-test split including new feature




using Pkg

Pkg.activate("final_env")

using CSV
using DataFrames
using Flux
using Random

# Load the preprocessed calibration and competition data
calibration_features_df = CSV.read("E:/SFU_MA/SFUComputationalEconomics2024/final/clean_calibration_features.csv", DataFrame)

# Test-train split -------------------------------------------------------------------

# Perform a test-train split of the calibration data


# Test-train split of 80-20

Random.seed!(420)

# Shuffle the indices
shuffled_indices_f = Random.shuffle(1:nrow(calibration_features_df))

# Determine the number of rows for the training set (80% of total rows)
train_size_f = round(Int, 0.8 * nrow(calibration_features_df))

# Split the indices into training and testing sets
train_indices_f = shuffled_indices_f[1:train_size_f]
test_indices_f = shuffled_indices_f[train_size_f+1:end]

# Create the training and testing sets
train_set_f = calibration_features_df[train_indices_f, :]
test_set_f = calibration_features_df[test_indices_f, :]

nrow(train_set_f)/nrow(calibration_features_df)

nrow(test_set_f)/nrow(calibration_features_df)






# Export training and testing data

CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/train_set_features.csv", train_set_f)
CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/test_set_features.csv", test_set_f)


