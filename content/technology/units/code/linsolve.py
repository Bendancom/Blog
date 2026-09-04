#!/usr/bin/env python3
from sympy import Matrix, symbols, linsolve

def symbolLinsolve(A: Matrix):
    m,n = A.shape

    vars_list = symbols(f'x1:{n + 1}')
    b = symbols(f'b1:{m + 1}')

    sol = linsolve((A,b), *vars_list)
    return sol
