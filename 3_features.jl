using Pkg

Pkg.activate("final_env")

using DataFrames
using CSV
using DataFramesMeta
using Statistics

# Load the preprocessed calibration and competition data
calibration_df = CSV.read("E:/SFU_MA/SFUComputationalEconomics2024/final/clean_calibration.csv", DataFrame)

column_names = names(calibration_df)
println(column_names)

# create a function to calculate the risk aversion index

function calculate_risk_aversion_index(calibration_df)
    risk_aversion_indices = []
    for row in eachrow(calibration_df)
        # Calculate the expected value
        EV = row.p_ha * row.ha + (1 - row.p_ha) * row.la
        # Calculate the variance
        variance = row.p_ha * (row.ha - EV)^2 + (1 - row.p_ha) * (row.la - EV)^2
        push!(risk_aversion_indices, variance)
    end
    return risk_aversion_indices
end


# Add the new features to the DataFrame
calibration_df.risk_aversion_index = calculate_risk_aversion_index(calibration_df)


using DataFrames

# Define a function to shift the elements in a DataFrame column
function lag_column(df::AbstractDataFrame, column::Symbol)
    return [missing; df[1:end-1, column]]
end

# Define a function to check if the value of b in the current trial equals the value of b in the previous trial
function check_b(df)
    df.b_prev = lag_column(df, :b)
    df.b_same_as_prev = ifelse.(ismissing.(df.b_prev), 0, df.b .== df.b_prev)
    return df
end

# Apply the function to each group of subjid, gameid, and block
grouped_df = groupby(calibration_df, [:subjid, :game_id, :block])
calibration_df = combine(grouped_df, check_b)

# Remove the temporary column b_prev
select!(calibration_df, Not(:b_prev))

mapping = Dict("true" => 1, "false" => 0, "0" => 0)
calibration_df.b_same_as_prev = map(x -> mapping[string(x)], calibration_df.b_same_as_prev)


#Pkg.add("HypothesisTests")
#Pkg.add("StatsBase")
using Statistics
using HypothesisTests
using StatsBase
using Distributions


features = [:location_rehovot, :gender_female, :age,
            :shape_b_symm, :shape_b_rskew, :shape_b_lskew,
            :shape_a_symm, :shape_a_rskew, :shape_a_lskew,
            :ha, :hb, :p_ha, :p_hb,
            :lot_num_b, :lot_num_a, :lb, :la, :corr, :amb,
            :payoff, :apay, :bpay, :rt, :feedback, :forgone, :order, :button_r,
            :risk_aversion_index, :b_same_as_prev ]

for feature in features
    correlation = cor(calibration_df[!, feature], calibration_df.b)
    println("Correlation between $feature and b: $correlation")
end

for feature in features
    # Remove missing values
    feature_values = collect(skipmissing(calibration_df[!, feature]))
    b_values = collect(skipmissing(calibration_df.b))
    
    # Calculate the correlation
    correlation = cor(feature_values, b_values)
    
    # Calculate the p-value
    n = length(feature_values)
    z = 0.5 * log((1 + correlation) / (1 - correlation)) # Fisher transformation
    standard_error = 1 / sqrt(n - 3)
    z_score = z / standard_error
    p = 2 * (1 - cdf(Normal(), abs(z_score))) # Two-tailed p-value
    
    # Print the p-value
    println("P-value for correlation between $feature and b: $p")
end

# location_rehovot: Negative correlation, statistically significant (p < 0.05)
# gender_female: Positive correlation, statistically significant (p < 0.05)
# age: Positive correlation, not statistically significant (p >= 0.05)
# shape_b_symm: Positive correlation, not statistically significant (p >= 0.05)
# shape_b_rskew: Positive correlation, statistically significant (p < 0.05)
# shape_b_lskew: Negative correlation, statistically significant (p < 0.05)
# shape_a_symm: Positive correlation, statistically significant (p < 0.05)
# shape_a_rskew: Negative correlation, statistically significant (p < 0.05)
# shape_a_lskew: Negative correlation, statistically significant (p < 0.05)
# ha: Positive correlation, statistically significant (p < 0.05)
# hb: Positive correlation, statistically significant (p < 0.05)
# p_ha: Negative correlation, statistically significant (p < 0.05)
# p_hb: Negative correlation, statistically significant (p < 0.05)
# lot_num_b: Positive correlation, statistically significant (p < 0.05)
# lot_num_a: Negative correlation, statistically significant (p < 0.05)
# lb: Positive correlation, statistically significant (p < 0.05)
# la: Negative correlation, statistically significant (p < 0.05)
# corr: Negative correlation, statistically significant (p < 0.05)
# amb: Positive correlation, statistically significant (p < 0.05)
# payoff: Negative correlation, statistically significant (p < 0.05)
# apay: Negative correlation, statistically significant (p < 0.05)
# bpay: Positive correlation, statistically significant (p < 0.05)
# rt: Negative correlation, not statistically significant (p >= 0.05)
# feedback: Negative correlation, statistically significant (p < 0.05)
# forgone: Negative correlation, statistically significant (p < 0.05)
# order: Negative correlation, statistically significant (p < 0.05)
# button_r: Positive correlation, statistically significant (p < 0.05)
# risk_aversion_index: Positive correlation, statistically significant (p < 0.05)


# Save the DataFrame with the new features
CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/clean_calibration_features.csv", calibration_df, writeheader=true)


# Add features to the competition data
competition_df = CSV.read("E:/SFU_MA/SFUComputationalEconomics2024/final/clean_competition.csv", DataFrame)



# create a function to calculate the risk aversion index

function calculate_risk_aversion_index(competition_df)
    risk_aversion_indices = []
    for row in eachrow(competition_df)
        # Calculate the expected value
        EV = row.p_ha * row.ha + (1 - row.p_ha) * row.la
        # Calculate the variance
        variance = row.p_ha * (row.ha - EV)^2 + (1 - row.p_ha) * (row.la - EV)^2
        push!(risk_aversion_indices, variance)
    end
    return risk_aversion_indices
end


# Add the new features to the DataFrame
competition_df.risk_aversion_index = calculate_risk_aversion_index(competition_df)


using DataFrames

# Define a function to shift the elements in a DataFrame column
function lag_column(df::AbstractDataFrame, column::Symbol)
    return [missing; df[1:end-1, column]]
end

# Define a function to check if the value of b in the current trial equals the value of b in the previous trial
function check_b(df)
    df.b_prev = lag_column(df, :b)
    df.b_same_as_prev = ifelse.(ismissing.(df.b_prev), 0, df.b .== df.b_prev)
    return df
end

# Apply the function to each group of subjid, gameid, and block
competition_grouped_df = groupby(competition_df, [:subjid, :game_id, :block])
competition_df = combine(competition_grouped_df, check_b)

# Remove the temporary column b_prev
select!(competition_df, Not(:b_prev))

mapping = Dict("true" => 1, "false" => 0, "0" => 0)
competition_df.b_same_as_prev = map(x -> mapping[string(x)], competition_df.b_same_as_prev)


# Save the DataFrame with the new features
CSV.write("E:/SFU_MA/SFUComputationalEconomics2024/final/clean_competition_features.csv", competition_df, writeheader=true)