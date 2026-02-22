# Task 2 - Linear Regression

## Table of Contents

- [Overview](#overview)
- [Optimisation Methods](#optimisation-methods)
- [Regularisation Methods](#regularisation-methods)
- [Functions](#functions)
- [Running the Tasks](#running-the-tasks)

## Overview

Linear Regression can be understood geometrically as a regression line that minimizes the square root of the sum of squared distances from the data points to the line. 
Functionally, it aims to minimize a cost or loss function. There are different types of Linear Regression: simple, multiple, and logistic.
For this assignment, the chosen type was the **Multiple Linear Regression** to predict apartment prices in a fictional urban area. 

The regression function is defined as:
$$\space h_θ(x) = θ_0 + θ_1 * x_1 + θ_2 * x_2 + ... + θ_n * x_n + ε$$

Where:
- $$h_θ(x)$$ is the predicted value based on input features $$(x_1, x_2, ..., x_n)$$.
- $$θ_0$$ is the intercept (value of $$h_θ(x)$$ when all features are 0).
- $$θ_1, ..., θ_n$$ are the weights or coefficients of the model.
- $$ε$$ is the prediction error (the difference between predicted and actual value).

These coefficients define how well the model generalises to new, unseen data. The goal is to find θ values that minimise the prediction error.

To measure the performance of the model, a cost function **J(θ)** is defined as follows:

$$
J(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \left( h_{\theta}(x^{(i)}) - y^{(i)} \right)^2
$$

Where:
- $$m$$ is the number of training examples.
- $$x^{(i)}$$ is the input vector for the i-th training example.
- $$y^{(i)}$$ is the actual output for the i-th training example.
- $$h_θ(x^{(i)})$$ is the model's prediction for the i-th input.

The cost function computes the average squared difference between predicted and actual values. Minimising this function improves the accuracy of the model.

## Optimisation Methods

There are two main optimisation algorithms to determine the model coefficients in linear regression:

### 1. Gradient Descent Method

- Gradient Descent is a general iterative optimisation algorithm used to minimise convex functions
- In the context of linear regression, it is applied to minimize the cost function $$\( J(\theta) \)$$
- Since the cost function is convex and has a unique global minimum, any local minimum is also a global minimum
- The method updates the parameters $$\( \theta \)$$ based on the gradient of the cost function and a learning rate $$\( \alpha \in \mathbb{R} \)$$

In MATLAB notation, the gradient vector is:
 ∇J(θ) = [
$$\frac{∂J}{∂θ_1}(\theta)$$
...
$$\frac{∂J}{∂θ_n}(\theta)$$
]'

Where each partial derivative is computed as:  $$\frac{∂J}{∂θ_j} = \frac{1}{m} \sum_{i=1}^{m} \left( h_{\theta}(x^{(i)}) - y^{(i)} \right) * x_j^{(i)}$$

Update rule:  $$θ_j := θ_j - \alpha * \frac{∂J}{∂θ_j}(\theta)$$

### 2. Normal Equation Method

- This is a closed-form solution for computing the coefficients θ directly, without iteration
- It is effective for small datasets only, due to matrix inversion
- To address this, the **Conjugate Gradient Method** is used as an efficient alternative for solving large systems

Fundamental formula: $$θ = (X^{T} * X)^{-1} * X^{T} * Y$$

Where:
- $$X \in \mathbb{R}^{m \times n}$$ is the matrix of feature vectors.
- $$Y \in \mathbb{R}^{m \times 1}$$ is the column vector of actual values.
- $$θ \in \mathbb{R}^{n \times 1}$$ is the column vector of model coefficients.

## Regularisation Methods

In the field of Machine Learning, **regularisation** is a technique used to make a model more generalisable. 
This means it helps the model reduce its variance error when encountering new data after training.

The assignment features two types of regularisation techniques:

### 1. L2 Regularisation (Ridge Regression)

L2 regularisation focuses on finding a regression line that fits the data while introducing a small **bias**. 
This means the line does not perfectly minimise the sum of squared distances between the predicted values and the training data points.

The main idea is to **shrink the model coefficients** $$θ_0, θ_1, \dots, θ_n$$ towards zero. 
This weakens the dependency between the output $$y^{(i)}$$ and certain input features  $$x_1, x_2, \dots, x_n$$, leading to a model that depends less on individual predictors.

The L2 regularised cost function is defined as:

$$
J_{L2}(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \left( h_\theta(x^{(i)}) - y^{(i)} \right)^2 + \lambda \sum_{j=1}^{n} \theta_j^2
$$

Where:
- $$\lambda \sum_{j=1}^{n} \theta_j^2 $$ is the **L2 regularization term**
- $$\lambda \in \mathbb{R}_+ $$ controls the **strength of the regularization**
- $$\lambda$$ is usually selected via **cross-validation**, but will be provided in implementation for this case

This approach helps prevent overfitting by discouraging overly complex models with large coefficients.

### L1 Regularisation (Lasso Regression)

L1 Regularisation is similar in purpose to L2 regularisation, aiming to reduce the complexity of the machine learning model. 
However, Lasso Regression has a distinct effect: some of the model’s coefficients $$θ_0, θ_1, \dots, θ_n$$ can become exactly **zero**.

This means that **certain predictors can be entirely removed** from the model, effectively performing **feature selection**. 
The result is a simpler model that still aims to generalise well to new data.

The L1 regularised cost function is defined as:

$$
J_{L1}(\theta) = \frac{1}{m} \sum_{i=1}^{m} \left( y^{(i)} - h_\theta(x^{(i)}) \right)^2 + \lambda ||\theta||_1
$$

Where:
- $$||\theta||_1 = |\theta_0| + |\theta_1| + \cdots + |\theta_n|$$ is the **L1 norm** of the coefficient vector
- $$\lambda \in \mathbb{R}_+$$ is the **regularisation parameter** that controls the strength of the penalty

L1 regularisation is especially useful when the dataset contains many irrelevant or weak features, as it helps the model focus only on the most important ones.

## Functions

Now that the theoretical background is fully documented, below are the necessary MATLAB functions to perform the tasks:

#### 1. `function [Y, InitialMatrix] = parse_data_set_file(file_path)`

**Purpose**: Receives a relative path to a text file containing dataset entries and returns:
- `Y` – output vector (target values)
- `InitialMatrix` – cell array containing both numerical and string values from the dataset

**Input File Format**:

$$m \space n$$

$$Y_{11} \space x_{11} \space x_{12} \space ... \space x_{1n}$$

$$Y_{21} \space x_{21} \space x_{22} \space ... \space x_{2n}$$

$$...$$

$$Y_{m1} \space x_{m1} \space x_{m2} \space ... \space x_{mn}$$

Where:
- $$m$$ is the number of training examples (rows)
- $$n$$ is the number of predictors (features)
- $$Y_{ij}$$ represents the output value for the i-th example
- $$x_{ij}$$ represents the j-th feature of the i-th example

#### 2. `function [Y, InitialMatrix] = parse_csv_file(file_path)`

**Purpose**: Receives a relative path to the `.csv` file containing dataset entries and returns:
- `Y` – output vector (target values)
- `InitialMatrix` – cell array containing the entire dataset, including both numeric and string values

> **Note:** For details regarding the format of the `.csv` input, check the attached `Example.csv` file.

#### 3. `function [FeatureMatrix] = prepare_for_regression(InitialMatrix)`

**Purpose**: Transforms the initial data matrix (`InitialMatrix`) into a numeric-only matrix suitable for regression tasks.

**Details**:
- Replaces affirmative/negative strings with corresponding numeric values:
  - `'yes'` → `1`
  - `'no'` → `0`
- Encodes strings from the `'furnishing'` category:
  - `'semi-furnished'` → `[1, 0]`
  - `'unfurnished'` → `[0, 1]`
  - `'furnished'` → `[0, 0]`
- Ensures that the resulting matrix (`FeatureMatrix`) contains only numeric data, making it compatible with linear or logistic regression algorithms

#### 4. `function [Error] = linear_regression_cost_function(Theta, Y, FeatureMatrix)`

**Purpose**: Computes the cost function (loss) for a linear regression model based on the previous theoretical formulation.
For simplicity:
  - The error term $$\varepsilon$$ in $$h_\theta(x)$$ is omitted.
  - The intercept term $$\theta_0$$ is assumed to be `0`.

**Inputs**:
- `Theta`: Column vector of coefficients $$\[ \theta_1, \ldots, \theta_n \in \mathbb{R} \]$$.
- `FeatureMatrix`: Matrix containing the predictor values. Each row `i` corresponds to a feature vector $$x^{(i)}$$.
- `Y`: Column vector of actual output values (targets), $$y^{(i)}$$.

**Output**: `Error`: The computed scalar cost for the given parameters and dataset.

#### 5. `function [Theta] = gradient_descent(FeatureMatrix, Y, n, m, alpha, iter)`

**Purpose**: Computes the coefficients $$θ_1, θ_2, ..., θ_n \in \mathbb{R} $$ using **gradient descent** over a number of `iter` steps.  
The intercept term $$θ_0$$ is assumed to be **0**. The function is tested using data from the `.csv` file (parsed earlier).

**Inputs**:
- `FeatureMatrix` – matrix where each row `i` corresponds to the predictor vector $$x^{(i)}$$
- `Y` – column vector of output values $$y^{(i)}$$
- `n` – number of predictors
- `m` – number of examples
- `alpha` – learning rate (α)
- `iter` – number of iterations to perform

**Output**: The column vector θ.

#### 6. `function [Theta] = normal_equation(FeaturesMatrix, Y, tol, iter)`

**Purpose**: Computes the coefficients $$θ_1, θ_2, ..., θ_n \in \mathbb{R}$$ using the **conjugate gradient method** over at most `iter` steps.  
The intercept term $$θ_0$$ is assumed to be **0**. If the system matrix is **not positive definite**, `Theta` will be a zero vector and returned immediately.

**Inputs**:
- `FeaturesMatrix` – matrix containing predictor vectors (each row is a sample $$x^{(i)}$$)
- `Y` – column vector containing actual output values $$y^{(i)}$$
- `tol` – tolerance value for stopping
- `iter` – maximum number of iterations

**Output**: The column vector θ.

#### 7. `function [Error] = lasso_regression_cost_function(Theta, Y, FeMatrix, lambda)`

**Purpose**: Implements the Lasso regression cost function as described in the theoretical section, using two vectors, a matrix, and a scalar input.
Once again, the intercept term $$θ_0$$ is assumed to be **0**.

**Inputs**:
- `Theta` – column vector of coefficients $$θ_1, θ_2, ..., θ_n \in \mathbb{R}$$.
- `FeMatrix` – matrix containing predictor values (each row i represents $$x^{(i)}$$ as described theoretically).
- `Y` – column vector containing actual output values (labels).
- `lambda` – regularisation parameter $$\lambda$$ controlling the strength of the L1 regularisation.

**Output**: `Error`: The computed scalar L1 regularisation cost for the given parameters and dataset.

#### 8. `function [Error] = ridge_regression_cost_function(Theta, Y, FeMatrix, lambda)`

**Purpose**: Implements the Ridge regression cost function as described in the theoretical section, using two vectors, a matrix, and a scalar input.
Once again, the intercept term $$θ_0$$ is assumed to be **0**.

- `Theta` – column vector of coefficients $$θ_1, θ_2, ..., θ_n \in \mathbb{R}$$.
- `FeMatrix` – matrix containing predictor values (each row i represents $$x^{(i)}$$ as described theoretically).
- `Y` – column vector containing actual output values (labels).
- `lambda` – regularisation parameter $$\lambda$$ controlling the strength of the L2 regularisation.

**Output**: `Error`: The computed scalar L2 regularisation cost for the given parameters and dataset.

## Running the Tasks

- Check the `run_all_tasks.m` file and change marked parameters if desired (`.csv` file name, maximum iteration count, etc)
- Ensure that the input files exist at the specified path and are well-formatted
- From the MATLAB/GNU Octave Command Window, enter `run_all_tasks` and inspect the output
