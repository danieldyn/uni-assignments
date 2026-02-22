# Task 1 - Markov

## Table of Contents

- [Overview](#overview)
- [Theoretical References](#theoretical-references)
- [Functions](#functions)
- [Running the Tasks](#running-the-tasks)

## Overview

The problem focuses on navigating a robot through a labyrinth, starting from a given position. The goal is to determine the probability that the robot 
will reach a **winning exit**, given that at each step it selects one of the available directions (up, down, left, right — no diagonal moves allowed). 
The robot avoids revisiting previously visited cells.

There are two types of exits in the labyrinth:

- **Winning exits** (marked green): Located on the **top and bottom** edges of the labyrinth. Reaching one of these exits means the
  robot has successfully "escaped" with a winning probability of **1**.
- **Losing exits** (marked red): Found on the **left and right** edges. Reaching one of these ends in a loss, with a probability of **0**.

Walls may exist between adjacent cells, blocking movement between them. For example, moving directly from cell (1, 1) to (1, 2) might not be possible due to such walls.
The idea is to model the problem probabilistically and then apply heuristic methods (e.g., greedy algorithms based on computed probabilities) to guide the 
robot more efficiently toward a winning exit.

## Theoretical References

To model the given scenario, **Markov chains** are used—probabilistic models particularly valuable in fields such as economics, dynamic system reliability and 
artificial intelligence algorithms. One notable application of Markov chains is the **Google PageRank algorithm**.

In a Markov chain, the system is represented as a **directed graph**, where:
- **Nodes (states)** correspond to possible positions or conditions of the system.
- **Edges (transitions)** indicate non-zero probabilities of moving from one state to another.
- For any state, the sum of all outgoing transition probabilities is **1**.

In this problem:
- Each **labyrinth cell** corresponds to a **unique state** in the Markov chain.
- Two additional special states are introduced:
  - **WIN state**: The robot has reached a winning exit. It is an absorbing state (no further transitions).
  - **LOSE state**: The robot exits through a losing side. Also an absorbing state.

Thus, the labyrinth becomes a probabilistic model:
- **States** represent positions in the maze.
- **Transitions** represent possible valid moves with equal probabilities.
- The **Markov chain** is stored as a **weighted directed graph**, with weights corresponding to movement probabilities.

This abstraction allows us to analyse the robot's behavior using probability theory and efficiently calculate its chances of winning or losing.
Below are the most important features of this way of modelling the problem.

### Adjacency Matrix for a Directed Graph

The **adjacency matrix** of a directed graph, similar to that of an undirected graph, is defined as:

$$
A = (A_{ij})_{i,j \in \{1, ..., n\}} \in \{0, 1\}^{n \times n}
$$

Where:

- $$\( A_{ij} = 1 \)$$, if there is a **transition** from state \( i \) to state \( j \),
- $$\( A_{ij} = 0 \)$$, otherwise.

In the context of the labyrinth:

- The submatrix \( A(1:n, 1:n) \) is **symmetric**,
- This symmetry exists because **walls are bidirectional** — if a transition from state \( i \) to state \( j \) is possible, then the reverse transition is also possible.

This matrix structure models **bidirectional movement** between adjacent, non-blocked cells in the maze.

### Link Matrix (Transition Probability Matrix)

The **link matrix** is a more powerful representation than the adjacency matrix. While structurally similar, the key difference lies in the meaning of the values it contains.

In a **link matrix**, each element represents the **transition probability** from one state to another in the Markov chain.
Using the notation $$p_{ij}$$, the matrix is defined as:

- $$L_{ij} = p_{ij}$$, if 0 < $$p_{ij}$$ ≤ 1
- $$L_{ij} = 0$$, otherwise

Notice that \( L \) is a **row-stochastic matrix**: the sum of each row equals 1.

### Reformulating the Problem as a Linear System

In addition to graph-based representations, the Markov chain describing the robot’s movement in a labyrinth can be reformulated as a **system of linear equations**.

Let $$p ∈ ℝ^{m·n}$$ be a vector of winning probabilities for each cell in the labyrinth, where `m` and `n` are the maze's dimensions. 
Each entry $$p_i$$ represents the probability that the robot, starting from state `i`, eventually reaches a winning exit.

For example, suppose the robot in state 1 can:
- Move to state 4 with a probability of 1/2, and
- Move to the WIN state (where the game is won) with a probability of 1/2.

Then the equation becomes:

$$p_1 = (1/2) * p_4 + (1/2) * p_{WIN} = (1/2) * p_4 + 1/2$$

Writing similar equations for all states results in a linear system, where the influence of WIN and LOSE states is encoded in the right-hand side. 

This system takes the form: `p = G·p + c`

- `G` is a matrix capturing transition probabilities between non-terminal states
- `c` is a vector containing contributions from terminal states (e.g., WIN with probability 1)
- `p` is the unknown vector we want to solve for

This form is particularly suitable for **iterative methods** such as the **Jacobi method**. The iteration step is defined as:

$$x_{k+1} = G·x_k + c$$

This iterative scheme efficiently computes the probability of reaching a winning exit from any given state, especially in large labyrinths.

### Heuristic Search

The distribution of probabilities within the Markov chain supports an intuitive observation: **states closer to the WIN state tend to have higher winning probabilities**, 
while those nearer to the LOSE state have lower ones. This insight motivates the use of a **heuristic search algorithm** to guide the robot from its starting position toward a winning exit.

A heuristic algorithm is not guaranteed to always find the optimal solution (e.g., the shortest path), but it has the advantage of being significantly faster than exhaustive search methods. In the context of navigating a labyrinth, this trade-off between accuracy and performance is often acceptable, especially for large labyrinths.

A simple **greedy algorithm** can be employed, guided by the precomputed winning probabilities:

- Starting from the initial position, the robot evaluates its unvisited neighboring cells.
- It **chooses the neighbor with the highest winning probability**, moving towards more promising regions of the maze.
- This strategy is implemented on top of a **Depth-First Search (DFS)** framework to manage backtracking in case of dead ends.

While not always optimal, this approach typically yields good paths quickly and benefits directly from the probabilistic analysis previously computed using the Markov model.

### Maze Input Encoding: Cohen-Sutherland-Inspired Wall Representation

To process the maze as input data efficiently, a **condensed binary encoding** of each cell is required. Inspired by the **Cohen-Sutherland algorithm** (originally used in computer graphics), a compact representation is adopted for the maze structure.

### Labyrinth Representation

A very efficient way of representing the maze is using the **Cohen-Sutherland encoding**. The labyrinth is stored as an `m × n` matrix, 
where each entry is a **4-bit integer** representing the presence of walls around that cell. Each bit encodes whether movement in a certain direction is blocked by a wall:

- **Bit b3 (value 8)**: Wall to the **North** of the cell
- **Bit b2 (value 4)**: Wall to the **South** of the cell
- **Bit b1 (value 2)**: Wall to the **East** of the cell
- **Bit b0 (value 1)**: Wall to the **West** of the cell

Each cell value can be interpreted in binary form as  $$\left(b_{3}b_{2}b_{1}b_{0}\right)_{(2)}$$, where:
- A bit set to **1** indicates that direction is **blocked by a wall**
- A bit set to **0** means movement in that direction is **allowed**

This encoding facilitates efficient parsing and use of the maze in algorithms by compactly describing connectivity and movement constraints between adjacent cells.

## Functions

Now that the theoretical background is fully documented, here are the necessary MATLAB functions:

#### 1. `function [Labyrinth] = parse_labyrinth(file_path)`

**Purpose**: Reads a text file containing the encoded labyrinth and returns the matrix of encodings.

**Input file format**: 

$$m \space n$$

$$l_{11} \space l_{12} \space ... \space l_{1n}$$

$$l_{21} \space l_{22} \space ... \space l_{2n}$$

$$...$$

$$l_{m1} \space l_{m2} \space ... \space l_{mn}$$


#### 2. `function [Adj] = get_adjacency_matrix(Labyrinth)`

**Purpose**: Receives the matrix of encodings and returns the **adjacency matrix** of the associated directed graph (Markov chain).

#### 3. `function [Link] = get_link_matrix(Labyrinth)`

**Purpose**: Receives the maze encoding matrix and returns the **link matrix** – containing the **transition probabilities** between states.

#### 4. `function [G, c] = get_Jacobi_parameters(Link)`

**Purpose**: Receives the link matrix and returns:
- `G` – iteration matrix for Jacobi method
- `c` – constant vector for Jacobi method

#### 5. `function [x, err, steps] = perform_iterative(G, c, x0, tol, max_steps)`

**Purpose**: Uses the **Jacobi iterative method** to solve the linear system approximately.

**Parameters**:
- `x0` – initial guess vector
- `tol` – relative error tolerance (convergence threshold)
- `max_steps` – maximum allowed iterations

**Returns**:
- `x` – approximated solution
- `err` – final relative error
- `steps` – number of iterations performed

#### 6. `function [path] = heuristic_greedy(start_position, probabilities, Adj)`

**Purpose**: Uses a **greedy search algorithm** to find a valid path to the WIN state.

**Parameters**:
- `start_position` – index of starting cell (in range `[1, m*n]`)
- `probabilities` – extended vector of win/loss probabilities (includes WIN and LOSE)
- `Adj` – adjacency matrix of the Markov chain

**Returns**:
- `path` – a valid path as a vector of linear indices

#### 7. `function [decoded_path] = decode_path(path, lines, cols)`

**Purpose**: Converts the linear index path into a list of (row, column) coordinates.

**Parameters**:
- `path` – vector of linear indices representing the path
- `lines`, `cols` – maze dimensions

**Returns**:
- `decoded_path` – a matrix with two columns: `[row, column]` for each step in the path

## Running the Tasks

- Check the `run_all_tasks.m` file and change marked parameters if desired (input file name, Jacobi tolerance, etc)
- Ensure that the input file exists at the specified path and is well-formatted
- From the MATLAB/GNU Octave Command Window, enter `run_all_tasks` and inspect the output
