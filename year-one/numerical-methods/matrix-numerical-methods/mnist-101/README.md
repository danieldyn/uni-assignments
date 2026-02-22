# Task 3 - MNIST

## Table of Contents

- [Overview](#overview)
- [Theoretical References](#theoretical-references)
- [Functions](#functions)
- [Running the Tasks](#running-the-tasks)

## Overview

After exploring numerical algorithms and prediction using linear regression in the second task, the final one takes a final step to adapt these algorithms and optimisation methods for other problems, such as **classification**.
The goal is to classify images of handwritten digits (0 to 9) using an appropriate classification model. Since this is a multi-class classification problem, a small neural network is chosen, containing:

- An input layer of 400 neurons (corresponding to the 20×20 pixel values of each image)
- An output layer of 10 neurons (one for each digit class)
- A hidden layer with 25 neurons to increase model complexity and improve classification performance

## Theoretical References

### Logistic Regression

The basic principle behind making predictions using linear regression is that the desired result is a **linear combination** of a set of given parameters (features). 
A similar model can be adapted for **classification** problems with a finite number of classes.

To begin, consider a simple **binary classification** problem. Like linear regression, binary classification uses an input vector of parameters along with a **label** (the target output), which in this case takes values in the set: $$y \in \{0, 1\}$$

However, a key issue arises when applying linear regression to classification: linear regression predicts real-valued outputs (possibly outside the range [0,1]), which are **not appropriate** for a binary decision.

To address this, we need to **introduce a non-linearity** that maps the output of the linear combination into the interval [0, 1]. 
Instead of using the linear hypothesis $$h_θ(x) = θ^T x$$, we use a **modified hypothesis** of the form: 

$$h_θ(x) = \sigma(θ^T x)$$, where $$\sigma : \mathbb{R} \rightarrow [0, 1]$$ is a non-linear **activation function**.
The most commonly used function for this purpose is the **sigmoid function**, defined as:

$$
\sigma : \mathbb{R} \rightarrow [0, 1],\space \sigma(x) = \frac{1}{1 + e^{-x}}
$$

With the new form of our hypothesis, we also need to **redefine the cost function**, since the **mean squared error** used in linear regression is no longer suitable. 
We want an **untrained model** to incur a high penalty if its prediction differs significantly from the true class label.

To better capture the **extreme cases** where prediction and reality diverge, we introduce a new cost function called **cross-entropy loss**, defined for a single example as:

$$
cost^{(i)} = -y^{(i)} \cdot \log(h_θ(x^{(i)})) - (1 - y^{(i)}) \cdot \log(1 - h_θ(x^{(i)}))
$$

For the entire training set, the cost function becomes:

$$
J(θ) = \frac{1}{m} \sum_{i=1}^{m} \left[ -y^{(i)} \cdot \log(h_θ(x^{(i)})) - (1 - y^{(i)}) \cdot \log(1 - h_θ(x^{(i)})) \right]
$$

This form of the cost function is especially effective for binary classification problems because:

- It penalises confident wrong predictions heavily.
- It maps predicted probabilities close to the actual class labels.

To **optimise** this cost function, we can use the same techniques already introduced for linear regression, such as **Gradient Descent** or a modified **Conjugate Gradient method**, resulting in models with strong performance for basic classification tasks.

**Logistic Regression** is a supervised learning technique particularly effective for **simple classification problems**, especially when the number of features is small. However, it comes with some notable limitations:

- **Multiclass limitation**:  
  Classic logistic regression is designed for **binary classification**. Extending it to more than two classes typically requires training a **separate model for each class** (a strategy called **one-vs-all classification**)

- **Scalability issues**:  
  Logistic regression does not scale well to more **complex classification tasks**, such as those encountered in **Computer Vision** (e.g., object detection or image recognition). These problems require more sophisticated classifiers, such as **neural networks** or **deep learning models**, capable of capturing higher-dimensional, non-linear relationships.

### Extending Logistic Regression to Neural Network

Logistic regression can be interpreted as a very simple neural network which consists of the following key components:

- **Neurons (nodes)**:  
  Each node in the network represents a computational unit, also known as a **neuron** or **perceptron**.

- **Connections (edges) with weights**:  
  The links between neurons indicate how much one neuron's output **contributes** to the next layer. Each connection has an associated **weight** that influences the calculation.

- **Activation function**:  
  This introduces **non-linearity** into the model. The most common activation functions are:
  - **Sigmoid**: $$\sigma(x) = \frac{1}{1 + e^{-x}}\space$$  --> the chosen one in this context
  - **ReLU**: $$\max(0, x)$$
  - **Hyperbolic Tangent**: $$\tanh(x)$$

- **Network structure**:  
  The model includes:
  - An **input layer** with multiple input neurons (each corresponding to a feature),
  - A **single output unit**, which represents the predicted class label (binary classification: 0 or 1).

Thus, logistic regression is structurally equivalent to a **single-layer neural network** with a sigmoid output.
This simple design can be **extended** by introducing:

- **Hidden layers** with intermediate neurons,
- An **increased number of output units** to match the number of classes in the classification task.

This leads to a **fully connected neural network** architecture, which consists of **three layers**:
  - **Input layer**: size $$s_1$$
  - **Hidden layer**: size $$s_2$$
  - **Output layer**: size $$s_3 = K$$, where $$K$$ is the number of output classes

In this specific case:

- Input: 400 neurons (corresponding to the 20×20 grayscale image pixels)
- Hidden: 25 neurons
- Output: 10 neurons (for digits 0 through 9)

**Activation values**:
  - For the **input layer**, activations are the actual **input data**: the 400 pixel values.
  - For the **output layer**, activations are the **predictions** (probabilities for each class).
  - For **hidden and output layers**, activations are computed based on the activations from the **previous layer** (fully connected).

**Weights (parameters)** between layers:
  - Between input and hidden layer:  
    $$\Theta^{(1)} \in \mathbb{R}^{s_2 \times (s_1 + 1)}$$
  - Between hidden and output layer:  
    $$\Theta^{(2)} \in \mathbb{R}^{s_3 \times (s_2 + 1)}$$

These matrices store the **learned parameters** (weights) of the network and include an extra column to handle the **bias unit**.

### Forward Propagation in Neural Networks

**Forward propagation** is the procedure by which a neural network computes its predictions for a given input. 
This vectorised process is used both during training and testing phases. It allows neural networks to compute predictions through layered transformations and non-linear activations.

Let:
- $$x^{(i)}$$: input features of training example $$i$$
- $$y^{(i)}$$: true label (class) of example $$i$$

The goal is to compute the activations of neurons in the network, ending with the predicted probabilities for each class.
First, we construct the **activation vector** for the input layer (layer 1), including a **bias unit**:

$$
a^{(1)} = [1;\space x^{(i)}]
$$

Then, we apply the first **linear transformation** using the first weight matrix $$\Theta^{(1)}$$:

$$
z^{(2)} = \Theta^{(1)} \cdot a^{(1)}
$$

After this, the **activation function** (sigmoid, $$\sigma$$) is applied element-wise:

$$
a^{(2)} = \sigma(z^{(2)})
$$

Again, a **bias unit** must be added to the activations:

$$
a^{(2)} = [1;\space a^{(2)}]
$$

The second **linear transformation** is applied:

$$
z^{(3)} = \Theta^{(2)} \cdot a^{(2)}
$$

And the sigmoid activation is applied again:

$$
a^{(3)} = \sigma(z^{(3)})
$$

The final vector $$a^{(3)} \in \mathbb{R}^{10}$$ contains **predicted probabilities** for each of the **10 digit classes** (0 through 9). The **index of the maximum** value indicates the **predicted class** for input $$x^{(i)}$$.

>**Important:** When implementing in MATLAB, index `10` will actually correspond to label `0` to respect indexing rule.

### Backpropagation

Similar to linear and logistic regression, a neural network must **optimise its parameters** by minimising a **cost function**. For classification, the cost function is a generalisation of the **cross-entropy loss** used in logistic regression.

The full cost function is:

$$
J(θ) = \frac{1}{m} \sum_{i=1}^m \sum_{k=1}^K [-y_k^{(i)} \cdot \log(h_θ(x^{(i)})_k) - (1 - y_k^{(i)}) \cdot \log(1 - h_θ(x^{(i)})_k)] \+
$$

$$
\+ \frac{\lambda}{2m} \sum_{j=2}^{s_1 + 1} \sum_{k=1}^{s_2} (\Theta^{(1)}_{k,j})^2 \+
$$

$$
\+ \frac{\lambda}{2m} \sum_{j=2}^{s_2 + 1} \sum_{k=1}^{s_3} (\Theta^{(2)}_{k,j})^2
$$

Where:

- $$\Theta^{(1)} \in \mathbb{R}^{s_2 \times (s_1 + 1)}$$: weight matrix from input to hidden layer  
- $$\Theta^{(2)} \in \mathbb{R}^{s_3 \times (s_2 + 1)}$$: weight matrix from hidden to output layer  
- $$\theta \in \mathbb{R}^{s_2(s_1 + 1) + s_3(s_2 + 1)}$$: unrolled vector of all network parameters  
- $$m$$: number of training examples  
- $$K$$: number of output classes (10 in this case)  
- $$y_k^{(i)}$$: binary indicator (0 or 1) if class label $$k$$ is the correct classification for example $$i$$  
- $$h_\theta(x^{(i)})_k$$: predicted probability for class $$k$$ on input $$x^{(i)}$$

In the above formula:

- The first part of the cost sums the **cross-entropy** loss over all training examples and classes.
- The second part is a **regularisation term** (L2 norm), penalising large weights to prevent overfitting.
- **Bias terms** (corresponding to j = 1) are **not regularised**, just like in linear regression.

This cost function ensures that the neural network is both **accurate** and **generalisable**.

In linear regression, model parameters can be optimized analytically using partial derivatives of the cost function. 
However, for neural networks, deriving an explicit analytical expression for gradients is much more difficult due to the network’s complexity.

To address this, we use the **backpropagation algorithm**, which efficiently computes gradients using the concept of **activation errors**. Bias weights (columns j = 0 ) are **not regularised** and all gradients are accumulated across the entire training set, then averaged. This allows updating the weights using Gradient Descent.

First, Forward Propagation must be performed to calculate predictions based on current parameters. 
Next, we compute the Output Layer error:

$$
\delta^{(3)} = a^{(3)} - y^{(i)}
$$

The, we accumulate gradients for Output Layer parameters:

$$
\Delta^{(2)} = \Delta^{(2)} + \delta^{(3)} \cdot (a^{(2)})^T
$$

In a similar way, the Hidden Layer error is computed:

$$
\delta^{(2)} = (\Theta^{(2)})^T \delta^{(3)} .* \sigma'(z^{(2)})
$$

Where:

- The `.∗` operator denotes element-wise multiplication (Hadamard product)
- We exclude the first component of $$\delta^{(2)}$$, which corresponds to the bias unit.
- The derivative of the activation function is:

$$
\sigma'(x) = \sigma(x) \cdot (1 - \sigma(x))
$$
  

Now, we can also accumulate gradients for Input → Hidden Layer parameters:

$$
\Delta^{(1)} = \Delta^{(1)} + \delta^{(2)} \cdot (a^{(1)})^T
$$

The final gradient (averaged) can be computed using the formula:

$$
\frac{∂J}{∂\Theta} = \frac{1}{m} \Delta
$$

Where the simplified notations are:

- $$\Theta \equiv \Theta^{(l)}_{ij}$$
- $$\Delta \equiv \Delta^{(l)}_{ij}$$

If j > 0, a regularisation is added:

$$
   \frac{∂J}{∂\Theta} = \frac{1}{m} \cdot \Delta + \frac{\lambda}{m} \cdot \Theta
$$

### Parameter Initialisation

In neural networks, initialising the parameters (the elements of the weight matrices) with zero values is not feasible. 
This leads to **symmetry** in the model, making all neurons in the same layer behave identically and rendering the network unable to learn effectively.

Furthermore, zero initialisation causes the gradients to vanish, preventing the network from updating the weights during training — a well-known issue in deep learning called the **Vanishing Gradient Problem**. Parameters should be **randomly initialised** with values in the interval **(−ε, ε)**.

An empirically effective value for **ε** is:

$$
\varepsilon_0 = \sqrt{\frac{6}{L_{prev} + L_{next}}}
$$

## Functions

Now that the theoretical background is fully documented, here are the necessary MATLAB functions:

#### 1. `function [X, y] = load_dataset(path)`

**Purpose**:  
Loads a `.mat` file from the given relative path and returns the dataset:

- `X`: A matrix where each row represents a data example (features).
- `y`: A vector containing the corresponding labels (classes).

#### 2. `function [X_train, y_train, X_test, y_test] = split_dataset(X, y, percent)`

**Purpose**:  
Splits the dataset into training and testing subsets according to the `percent` parameter. It also shuffles the data before splitting it.

**Parameters**:
- `X`, `y`: The full dataset and labels (as returned by `load_dataset`).
- `percent`: A number between 0 and 1, indicating the fraction of data to be used for training.

#### 3. `function [matrix] = initialise_weights(L_prev, L_next)`

**Purpose**:  
Initialises the weight matrix for the transformation between two neural network layers.

**Parameters**:
- `L_prev`: Number of neurons in the previous layer.
- `L_next`: Number of neurons in the next layer.

**Returns**:
- `matrix`: A randomly initialised weight matrix with values from the interval **(−ε, ε)**.

#### 4. `function [J, grad] = cost_function(params, X, y, lambda, input_layer_size, hidden_layer_size, output_layer_size)`

**Purpose**:  
Computes the cost function and gradients for a neural network with one hidden layer, using forward and backward propagation.

**Parameters**:
- `params`: A column vector containing all weights (unrolled from $$\Theta^{(1)} and \Theta^{(2)}$$).
- `X`: Feature matrix for training examples (without labels).
- `y`: Vector of labels corresponding to the examples in `X`.
- `lambda`: Regularisation parameter.
- `input_layer_size`: Number of neurons in the input layer.
- `hidden_layer_size`: Number of neurons in the hidden layer.
- `output_layer_size`: Number of neurons in the output layer (equal to number of classes).

**Returns**:
- `J`: The value of the cost function for the current weights.
- `grad`: A vector of the same size as `params`, containing the unrolled gradients computed via backpropagation.

#### 5. `function [classes] = predict_classes(X, weights, input_layer_size, hidden_layer_size, output_layer_size)`

**Purpose**:  
Predicts the class labels for a given set of test examples using a trained neural network.

**Returns**:
- `classes`: A column vector of predicted class indices for each test example.

## Running the Tasks

- Check the `run_all_tasks.m` file and change marked parameters if desired (input file name, dataset split percentage, etc)
- Ensure that the input file exists at the specified path and is well-formatted (check the included example)
- From the MATLAB/GNU Octave Command Window, enter `run_all_tasks` and inspect the output
