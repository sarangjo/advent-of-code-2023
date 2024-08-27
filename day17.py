#!/usr/bin/env python
import math
from queue import PriorityQueue
from typing import Dict, List, Tuple

class HeapItem:
    loc: Tuple[int, int]
    priority: float

    def __init__(self, loc: Tuple[int, int], priority: float) -> None:
        self.loc = loc
        self.priority = priority

    def __str__(self) -> str:
        return f"({self.loc[0]}, {self.loc[1]}): {self.priority}"

    def __repr__(self) -> str:
        return str(self)


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

        while idx != parent and parent >= 0 and parent < len(self._elements) and self._elements[parent].priority > self._elements[idx].priority:
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

            if left < len(self._elements) and self._elements[left].priority < self._elements[smallest].priority:
                smallest = left
            if right < len(self._elements) and self._elements[right].priority < self._elements[smallest].priority:
                smallest = right

            if smallest == idx:
                break

            self._swap(idx, smallest)

            idx = smallest
            left, right = MinHeap._children(idx)

    def pop(self):
        ret = self._elements[0]

        # Insert last element into front and bubble down
        new_root = self._elements.pop()
        self._elements[0] = new_root
        del self._indexMap[ret.loc]
        self._indexMap[new_root.loc] = 0

        # Is the parent larger than the child?
        self._bubble_down(0)

        return ret

    def decrease_priority(self, loc: Tuple, p: float) -> bool:
        try:
            idx = self._indexMap[loc]
        except:
            return False

        if p >= self._elements[idx].priority:
            return False

        # Reduce priority and bubble up
        self._elements[idx].priority = p
        self._bubble_up(idx)


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
