#!/usr/bin/env python
import math
from queue import PriorityQueue
from typing import Dict, List, Tuple

class HeapItem:
    loc: Tuple[int, int]
    distance: float
    path: List[str]

    def __init__(self, loc: Tuple[int, int], distance: float) -> None:
        self.loc = loc
        self.distance = distance
        self.path = []

    def __str__(self) -> str:
        return f"({self.loc[0]}, {self.loc[1]}): {self.distance}{"" if len(self.path) == 0 else "; " + "".join(self.path)}"

    def __repr__(self) -> str:
        return str(self)

    def cant_go(self) -> str:
        for dir in ['U', 'R', 'D', 'L']:
            if self.path[-3:] == [dir] * 3:
                return dir
        return 'X'


# Let's build our own heap that has efficient operations that we care about: insert, pop, update
class MinHeap:
    # Heap is backed by an array
    _elements: List[HeapItem] = []

    # Index into the array is identified by this dict
    _indexMap: Dict[Tuple, int] = {}

    def _parent(idx: int) -> int:
        return int((idx - 1) / 2)

    def _children(idx: int) -> Tuple[int]:
        return (2*idx + 1, 2*idx + 2)

    def _swap(self, a: int, b: int):
        # Swap idx and parent
        temp = self._elements[a]
        self._elements[a] = self._elements[b]
        self._elements[b] = temp

        # Update indexMap
        self._indexMap[self._elements[a].loc] = a
        self._indexMap[self._elements[b].loc] = b

    def _bubble_up(self, idx: int):
        # Is the child smaller than the parent?
        parent = MinHeap._parent(idx)

        while idx != parent and parent >= 0 and parent < len(self._elements) and self._elements[parent].distance > self._elements[idx].distance:
            # Swap idx and parent
            self._swap(idx, parent)

            idx = parent
            parent = MinHeap._parent(idx)

    def insert(self, item: HeapItem):
        # Add element at the end
        self._elements.append(item)
        idx = len(self._elements) - 1
        self._indexMap[item.loc] = idx

        # Bubble up!
        self._bubble_up(idx)

    def _bubble_down(self, idx: int):
        left, right = MinHeap._children(idx)

        while True:
            # Check children
            smallest = idx

            if left < len(self._elements) and self._elements[left].distance < self._elements[smallest].distance:
                smallest = left
            if right < len(self._elements) and self._elements[right].distance < self._elements[smallest].distance:
                smallest = right

            if smallest == idx:
                break

            self._swap(idx, smallest)

            idx = smallest
            left, right = MinHeap._children(idx)

    def pop(self):
        if len(self._elements) == 0:
            return None
        if len(self._elements) == 1:
            return self._elements.pop()

        ret = self._elements[0]

        # Insert last element into front and bubble down
        new_root = self._elements.pop()
        self._elements[0] = new_root
        del self._indexMap[ret.loc]
        self._indexMap[new_root.loc] = 0

        # Is the parent larger than the child?
        self._bubble_down(0)

        return ret

    def decrease_distance(self, loc: Tuple, p: float) -> bool:
        try:
            idx = self._indexMap[loc]
        except:
            return False

        if p >= self._elements[idx].distance:
            return False

        # Reduce distance and bubble up
        self._elements[idx].distance = p
        self._bubble_up(idx)

        return True

    def update_path(self, loc: Tuple, cur: HeapItem, next_dir: str):
        self._elements[self._indexMap[loc]].path = cur.path + [next_dir]


def main():
    with open("sample17.txt") as f:
        lines = f.readlines()

    # Data structures
    unvisited = MinHeap()
    visited = {}

    # Fill up unvisited with all nodes
    for i in range(len(lines)):
        for j in range(len(lines)):
            unvisited.insert(HeapItem((i, j), 0 if i == 0 and j == 0 else math.inf))

    while True:
        # Get the smallest distance neighbor
        cur = unvisited.pop()

        if not cur or cur.distance == math.inf:
            break

        # Consider all neighbors
        neighbors = []

        # - U
        if cur.loc[0] != 0 and (cur.loc[0] - 1, cur.loc[1]) not in visited and cur.cant_go() != 'U':
            neighbors.append(((cur.loc[0] - 1, cur.loc[1]), 'U'))
        # - R
        if cur.loc[1] != len(lines) - 1 and (cur.loc[0], cur.loc[1] + 1) not in visited and cur.cant_go() != 'R':
            neighbors.append(((cur.loc[0], cur.loc[1] + 1), 'R'))
        # - D
        if cur.loc[0] != len(lines) - 1 and (cur.loc[0] + 1, cur.loc[1]) not in visited and cur.cant_go() != 'D':
            neighbors.append(((cur.loc[0] + 1, cur.loc[1]), 'D'))
        # - L
        if cur.loc[1] != 0 and (cur.loc[0], cur.loc[1] - 1) not in visited and cur.cant_go() != 'L':
            neighbors.append(((cur.loc[0], cur.loc[1] - 1), 'L'))

        for n in neighbors:
            # Have we found a better path?
            if unvisited.decrease_distance(n[0], cur.distance + int(lines[n[0][0]][n[0][1]])):
                unvisited.update_path(n[0], cur, n[1])

        # Mark as visited
        visited[cur.loc] = (cur.distance, cur.path)

    print(visited[(len(lines) - 1, len(lines) - 1)])


if __name__ == "__main__":
    main()
