#!/usr/bin/env python3

import matplotlib.pyplot as plt
import cvxpy as cp
import numpy as np
import csv
import cv2

# Virtual camera path smoothing

f = open('./cvx_lab/problem_3/chappell_2-p1.txt', 'r')

x = []
for i in f:
    x.append(float(i.split(' ')[0].strip()))

x = np.array(x)

# Optimization variables.
fx = cp.Variable((len(x)))

# Constraints
constraints = []

# Objective Function
sum_square = 0
for i in range(len(x)):
    sum_square += (fx[i] - x[i])**2

obj = cp.Minimize(0.5*sum_square)

# Solver
prob = cp.Problem(obj, constraints)
prob.solve()
print("Opt val", prob.value)
print("x: ", fx.value)

plt.plot(fx.value, x)
plt.show()
