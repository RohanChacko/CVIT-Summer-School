#!/usr/bin/env python3

import matplotlib.pyplot as plt
import cvxpy as cp
import numpy as np
import csv


# Linear regression using CVXPY

file = open('./cvx_lab/problem_2/train.csv', 'r')
csvreader = csv.reader(file)

file = [[float(char) for char in row if 'x' not in char and 'y' not in char]for row in csvreader]
x = []
y = []

for i, row in enumerate(file):
    if i != 0:

        x.append(row[0])
        y.append(row[1])

x = np.array(x)
y_ground = np.array(y)

# Optimization variables.
w = cp.Variable()
b = cp.Variable()

# Constraints
constraints = []

# Objective Function
sum_square = 0
for i in range(len(x)):
    sum_square += ((w*x[i] + b) - y_ground[i])**2

obj = cp.Minimize(sum_square)

# Solver
prob = cp.Problem(obj, constraints)
prob.solve()
print("Opt val", prob.value)
print("x: ", w.value)
print("y: ", b.value)
