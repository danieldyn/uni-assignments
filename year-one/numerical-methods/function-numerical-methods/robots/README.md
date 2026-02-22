# Task 2 - Robots

## Table of Contents

- [Overview](#overview)
- [Theoretical References](#theoretical-references)
- [Functions](#functions)
- [Running the Tasks](#running-the-tasks)

## Overview

The focus of this task is on **interpolation** applied on the movement of robots. It is a numerical technique used to estimate values of a function at points where no measurements are available,
based on a set of known data points. Given a set of points $$(x_0, y_0), (x_1, y_1), \dots, (x_n, y_n)$$, interpolation constructs a function $$f(x)$$ that passes through all these points.
The main goal is to approximate the underlying behavior of the data, enabling prediction, visualisation, or further analysis.

## Theoretical References

Two common approaches to interpolation are polynomial interpolation and spline interpolation. Polynomial interpolation uses a single high-degree polynomial, typically constructed via a Vandermonde matrix.
The resulting polynomial passes through all data points, but high-degree polynomials can exhibit oscillatory behavior, particularly near the endpoints (Runge's phenomenon).
Functions that implement this approach calculate the coefficients and evaluate the polynomial at arbitrary points.

Cubic spline interpolation provides an alternative that avoids the instability of high-degree polynomials. It constructs piecewise cubic polynomials between consecutive points, ensuring continuity of the function and its first and second derivatives.
This method produces a smooth curve that closely follows the shape of the data. The implementation choice is the **natural cubic spline (C2)**, where the second derivatives at the endpoints are set to zero. 


## Functions

Now that the theoretical background is fully documented, here are the necessary MATLAB functions:

#### 1. `function [x, y] = parse_data(filename)`

**Purpose**: Reads a data file and returns the x and y coordinates.

**Parameters**:
- `filename` – name of the input file (e.g., `'input.txt'`)

**Returns**:
- `x` – vector of x-coordinates
- `y` – vector of y-coordinates

**Input file format**:

$$n$$

$$x_{0} \space x_{1} \space ... \space x_{n}$$

$$y_{0} \space y_{1} \space ... \space y_{n}$$

#### 2. `function coef = spline_c2(x, y)`

**Purpose**: Computes natural cubic spline coefficients for a set of data points.

**Parameters**:
- `x` – vector of x-coordinates
- `y` – vector of y-coordinates

**Returns**:
- `coef` – vector `[a0, b0, c0, d0, ..., an-1, bn-1, cn-1, dn-1]` containing the cubic spline coefficients

#### 3. `function y_interp = P_spline(coef, x, x_interp)`

**Purpose**: Evaluates a cubic spline at specified interpolation points.

**Parameters**:
- `coef` – cubic spline coefficients from `spline_c2`
- `x` – vector of original x-coordinates
- `x_interp` – vector of points where the spline is evaluated

**Returns**:
- `y_interp` – vector of interpolated y-values at `x_interp`

#### 4. `function coef = vandermonde(x, y)`

**Purpose**: Computes the coefficients of the polynomial passing through the given points using a Vandermonde matrix.

**Parameters**:
- `x` – vector of x-coordinates
- `y` – vector of y-coordinates

**Returns**:
- `coef` – vector `[a0, a1, ..., an]` of polynomial coefficients

#### 5. `function y_interp = P_vandermonde(coef, x_interp)`

**Purpose**: Evaluates a polynomial defined by Vandermonde coefficients at given points.

**Parameters**:
- `coef` – polynomial coefficients from `vandermonde`
- `x_interp` – vector of points where the polynomial is evaluated

**Returns**:
- `y_interp` – vector of resulting y-values at `x_interp`

#### 6. `function plot_spline(x, y, nr_points)`

**Purpose**: Plots the cubic spline interpolation along with the original data points.

**Parameters**:
- `x` – vector of x-coordinates
- `y` – vector of y-coordinates
- `nr_points` – number of points for smooth plotting

**Returns**:
- None (displays a figure showing the spline curve and data points)

#### 7. `function plot_vandermonde(x, y, nr_points)`

**Purpose**: Plots the Vandermonde polynomial interpolation along with the original data points.

**Parameters**:
- `x` – vector of x-coordinates
- `y` – vector of y-coordinates
- `nr_points` – number of points for smooth plotting

**Returns**:
- None (displays a figure showing the polynomial curve and data points)

## Running the Tasks

- Check the `run_all_tasks.m` file and change marked parameters if desired (input file name, plotting parameters, etc)
- Ensure that the input file exists at the specified path and is well-formatted
- From the MATLAB/GNU Octave Command Window, enter `run_all_tasks` and inspect the output
