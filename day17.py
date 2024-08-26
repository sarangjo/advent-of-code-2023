#!/usr/bin/env python
import math
from queue import PriorityQueue


def main():
    with open("sample17.txt") as f:
        lines = f.readlines()

    # 1. Set of all unvisited nodes
    unvisited = PriorityQueue()
    visited = {}

    for i in range(len(lines)):
        for j in range(len(lines)):
            unvisited.put((0 if i == 0 and j == 0 else math.inf, (i, j)))

    while True:
        cur = unvisited.get()

        if not cur or cur[0] == math.inf:
            break

        # Consider all neighbors
        neighbors = []
        # - U
        if cur[1][0] != 0 and (cur[1][0] - 1, cur[1][1]) not in visited:
            neighbors.append()

        # Mark as visited
        visited[cur[1]] = True




if __name__ == "__main__":
    main()
