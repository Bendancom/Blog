#!/usr/bin/env python3
from sympy import Matrix

if __name__ == "__main__":
    SI2Gauss = Matrix([
        [1, 0, 0, 0, 0, 3/2, 0],
        [0, 1, 0, 0, 0, 1/2, 0],
        [0, 0, 1, 0, 0, -2, 0],
        [0, 0, 0, 1, 0, 0, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 1/2, 0],
        [0, 0, 0, 0, 0, 0, 1]
    ])
    Gauss2SI = SI2Gauss.inv()
    print("Gauss2SI:",Gauss2SI)
    
    Natural2SI = Matrix([
        [2, 1, -2, 0, 0, 0, 0],
        [1, 0, -1, 0, 0, 0, 0],
        [2, 1, -2, -1, 0, 0, 0],
        [2, 1, -1, 0, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 1]
    ])
    SI2Natural = Natural2SI.inv()
    print("SI2Natural:",SI2Natural)

    Natural2Gauss = Natural2SI * SI2Gauss
    print("Natural2Gauss:",Natural2Gauss)
    
    Gauss2Natural = Gauss2SI * SI2Natural
    print("Gauss2Natural:",Gauss2Natural)
