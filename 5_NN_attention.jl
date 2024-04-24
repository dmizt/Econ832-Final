using Pkg

Pkg.activate("final_env")

#Pkg.add("Chain")
#Pkg.add("DataFramesMeta")
#Pkg.add("MLBase")

# Load packages

using DataFrames
using CSV
using Flux
using Random
using Chain
using DataFramesMeta
using MLBase
using LinearAlgebra
using Parameters: @with_kw



# Load the preprocessed calibration and competition data

train = CSV.read("E:/SFU_MA/SFUComputationalEconomics2024/final/train_set.csv", DataFrame)
test = CSV.read("E:/SFU_MA/SFUComputationalEconomics2024/final/test_set.csv", DataFrame)

column_names = names(train)
println(column_names)


# Data -------------------------------------------------------------------

# Selecting variables for the training data -------------------------------------------------------------------

# Select the relevant variables related to lotteries for the baseline model (id and subjid gets dropped for the DFNN)

train_selected = select(train, :location_rehovot, :gender_female, :age,
                        :shape_b_symm, :shape_b_rskew, :shape_b_lskew,
                        :shape_a_symm, :shape_a_rskew, :shape_a_lskew,
                        :ha, :hb, :p_ha, :p_hb,
                        :lot_num_b, :lot_num_a, :lb, :la, :corr, :amb,
                        :payoff, :apay, :bpay,:rt, :feedback, :forgone, :order, :button_r,  :b)


# Selecting variables for the testing data -------------------------------------------------------------------
test_selected = select(test, :location_rehovot, :gender_female, :age,
                        :shape_b_symm, :shape_b_rskew, :shape_b_lskew,
                        :shape_a_symm, :shape_a_rskew, :shape_a_lskew,
                        :ha, :hb, :p_ha, :p_hb,
                        :lot_num_b, :lot_num_a, :lb, :la, :corr, :amb,
                        :payoff,:apay, :bpay, :rt, :feedback, :forgone, :order, :button_r, :b)


# DNFF -------------------------------------------------------------------

Random.seed!(420)

# Train a DFNN with risk preference variables and demographic variables
# Outcome variable is b

## Feature engineering -------------------------------------------------------------------

# Need to prepare the data for the model
# 1. Separate features from the outcome
# 2. Normalize features (mean 0, sd 1)
# 3. Transpose the matrix of features to have observations as columns

@with_kw mutable struct Args
    lr::Float64 = 0.01
    epochs::Int = 200  # Add this line
end

# Initialize hyperparameter arguments

args = Args(lr=0.01, epochs=150)

# Separate data in X and Y

features = Matrix(train_selected[:, Not(:b)])

outcome = train_selected.b # No need to hot encode the outcome variable since it is binary

# Standardize continuous variables, mean of 0 and sd 1

X = transpose(Flux.normalise(features, dims = 2))

# Transpose the outcome vector

Y = transpose(outcome)

# Data

data = [(X, Y)]



# Model training -------------------------------------------------------------------

# Define your model

model = Flux.Chain(
    Dense(size(X)[1], 128, Flux.relu),
    Dense(128, 64, Flux.relu),
    Dense(64, 32, Flux.relu),
    Dense(32, 1, Flux.sigmoid)
)

# Define loss function based on MSE

loss(X, Y) = Flux.mse(model(X), Y)

# Define optimizer: gradient descent with learning rate `args.lr`

optimiser = Descent(args.lr)

# Train model for `args.epochs` epochs

for epoch in 1:args.epochs
    Flux.train!(loss, Flux.params(model), data, optimiser)
end


# Model evaluation -------------------------------------------------------------------

# Loss

loss(X, Y)

# Predictions

predictions_train = model(X)

# Convert predictions to binary

predictions_train_binary = predictions_train .> 0.5

# Confusion matrix# Convert boolean arrays to integer arrays with class labels starting from 1
Y_int = Int.(Y .> 0.5) .+ 1
predictions_train_binary_int = Int.(predictions_train_binary) .+ 1

# Calculate confusion matrix

confusion_matrix_train = confusmat(2, vec(Y_int), vec(predictions_train_binary_int))

# Accuracy

accuracy_train = sum(diag(confusion_matrix_train)) / sum(confusion_matrix_train)

# Testing the model -------------------------------------------------------------------

# Extract X and Y from calibration_test

features_test = Matrix(test_selected[:, Not(:b)])

outcome_test = test_selected.b

X_test = transpose(Flux.normalise(features_test, dims = 2))

Y_test = transpose(outcome_test)

# Execute the model on the test data

loss(X_test, Y_test)

# Compute the confusion matrix for the test data

predictions_test = model(X_test)

predictions_test_binary = predictions_test .> 0.5

Y_test_int = Int.(Y_test .> 0.5) .+ 1

predictions_test_binary_int = Int.(predictions_test_binary) .+ 1

confusion_matrix_test = confusmat(2, vec(Y_test_int), vec(predictions_test_binary_int))

accuracy_test = sum(diag(confusion_matrix_test)) / sum(confusion_matrix_test)


# Testing the model on the competition data -------------------------------------------------------------------

competition = CSV.read("E:/SFU_MA/SFUComputationalEconomics2024/final/clean_competition.csv", DataFrame)

# Selecting variables for the competition data -------------------------------------------------------------------
competition_selected = select(competition, :location_rehovot, :gender_female, :age,
                        :shape_b_symm, :shape_b_rskew, :shape_b_lskew,
                        :shape_a_symm, :shape_a_rskew, :shape_a_lskew,
                        :ha, :hb, :p_ha, :p_hb,
                        :lot_num_b, :lot_num_a, :lb, :la, :corr, :amb,
                        :payoff, :apay, :bpay,:rt, :feedback, :forgone, :order, :button_r, :b)
                        


# Extract X and Y from competition data
features_competition = Matrix(competition_selected[:, Not(:b)])

outcome_competition = competition_selected.b

# Feature engineering for the competition data

X_competition = transpose(Flux.normalise(features_competition, dims = 2))

Y_competition = transpose(outcome_competition)

# Execute the model on the competition data

# Loss

loss(X_competition, Y_competition)

# Compute the confusion matrix for the competition data

predictions_competition = model(X_competition)

predictions_competition_binary = predictions_competition .> 0.5

Y_competition_int = Int.(Y_competition .> 0.5) .+ 1

predictions_competition_binary_int = Int.(predictions_competition_binary) .+ 1

confusion_matrix_competition = confusmat(2, vec(Y_competition_int), vec(predictions_competition_binary_int))

accuracy_competition = sum(diag(confusion_matrix_competition)) / sum(confusion_matrix_competition)

# Export results -------------------------------------------------------------------

# Export the confusion matrix of the model on the training data

CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/confusion_matrix_train_attention_dfnn.csv", DataFrame(confusion_matrix_train, :auto))

# Export the confusion matrix of the model on the competition data

CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/confusion_matrix_competition_attention_dfnn.csv", DataFrame(confusion_matrix_competition, :auto))

# Export accuracies

accuracies_df = DataFrame(
    data = ["Train", "Test", "Competition"],
    accuracy = [accuracy_train, accuracy_test, accuracy_competition]
)


CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/accuracies_attention_dfnn.csv", accuracies_df)




# Export loss function values

losses_df = DataFrame(
    data = ["Train", "Test", "Competition"],
    loss = [loss(X, Y), loss(X_test, Y_test), loss(X_competition, Y_competition)]
)


CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/losses_attention_dfnn.csv", losses_df)