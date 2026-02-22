# Task 3 - Recommendations

## Table of Contents

- [Overview](#overview)
- [Theoretical References](#theoretical-references)
- [Functions](#functions)
- [Running the Tasks](#running-the-tasks)

## Overview

The aim here is to implement a basic recommendation system using collaborative filtering and dimensionality reduction techniques. 
In this context, the input matrix represents user ratings or interactions with various items (themes), and the goal is to identify items that are most likely to be of interest to a given user.

## Theoretical References

Collaborative filtering is a widely used approach in recommender systems, where user preferences are predicted based on historical interactions.
Dimensionality reduction, specifically **Singular Value Decomposition (SVD)**, is used to uncover latent factors that capture underlying patterns in the data.
By decomposing the user-item matrix into lower-dimensional representations, the system can capture hidden correlations between items and users while reducing noise from sparse or incomplete data. 

**Cosine similarity** is then applied to the reduced feature vectors to measure the closeness between items. 
This approach allows the recommendation system to suggest items that are similar to those a user has already liked, improving the quality and relevance of recommendations while maintaining computational efficiency.

## Functions

Now that the theoretical background is fully documented, here are the necessary MATLAB functions:

#### 1. `function [mat] = read_mat(path)`

**Purpose**: Reads a CSV file and returns the numeric matrix, ignoring headers.  

**Parameters**:  
- `path` – string path to the CSV file  

**Returns**:  
- `mat` – numeric matrix of values (without row and column headers)  

#### 2. `function [reduced_mat] = preprocess(mat, min_reviews)`

**Purpose**: Filters out rows with fewer than `min_reviews` non-zero elements.  

**Parameters**:  
- `mat` – numeric matrix  
- `min_reviews` – minimum number of non-zero entries to keep a row  

**Returns**:  
- `reduced_mat` – filtered matrix with only rows meeting the threshold  

#### 3. `function [similarity] = cosine_similarity(A, B)`

**Purpose**: Computes the cosine similarity between two vectors.  

**Parameters**:  
- `A` – first vector  
- `B` – second vector  

**Returns**:  
- `similarity` – scalar similarity value (between -1 and 1)  

#### 4. `function [recoms] = recommendations(path, liked_theme, num_recoms, min_reviews, num_features)`

**Purpose**: Recommends the top `num_recoms` themes most similar to the given `liked_theme` using SVD and cosine similarity.  

**Parameters**:  
- `path` – CSV file path  
- `liked_theme` – index of the liked theme  
- `num_recoms` – number of recommendations to return  
- `min_reviews` – minimum number of reviews per theme  
- `num_features` – number of features to use in SVD  

**Returns**:  
- `recoms` – vector of indices of recommended themes  

## Running the Tasks

- Check the `run_all_tasks.m` file and change marked parameters if desired (input file name, base preference ID, etc)
- Ensure that the input file exists at the specified path and is well-formatted
- From the MATLAB/GNU Octave Command Window, enter `run_all_tasks` and inspect the output
