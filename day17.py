#!/usr/bin/env python
import math
from typing import Dict, List, Tuple


class Node:
    loc: Tuple[int, int]
    last_dir: str

    def __init__(self, loc: Tuple[int, int], last_dir: str) -> None:
        self.loc = loc
        self.last_dir = last_dir

    @staticmethod
    def from_node(n: 'Node', direction: str) -> None:
        loc = None
        if direction == 'U':
            loc = (n.loc[0] - 1, n.loc[1])
        elif direction == 'R':
            loc = (n.loc[0], n.loc[1] + 1)
        elif direction == 'D':
            loc = (n.loc[0] + 1, n.loc[1])
        else:  # L
            loc = (n.loc[0], n.loc[1] - 1)

        return Node(loc, n.last_dir + direction if n.last_dir == direction else direction)

    def __eq__(self, value: object) -> bool:
        return self.loc == value.loc and self.last_dir == value.last_dir

    def __hash__(self) -> int:
        return hash((self.loc[0], self.loc[1], self.last_dir))

    def __str__(self) -> str:
        return f"({self.loc[0]}, {self.loc[1]}){"" if len(self.last_dir) == 0 else " " + self.last_dir}"


class HeapItem:
    node: Node
    priority: float

    def __init__(self, node: Node, priority: float) -> None:
        self.node = node
        self.priority = priority

    def __str__(self) -> str:
        return f"{self.node}: {self.priority}"

    def __repr__(self) -> str:
        return str(self)

    def cant_go(self) -> str:
        cg = []
        if len(self.node.last_dir) > 0:
            cg.append('U' if self.node.last_dir[-1] == 'D' else 'R' if self.node.last_dir[-1]
                      == 'L' else 'D' if self.node.last_dir[-1] == 'U' else 'L')
        for direction in ['U', 'R', 'D', 'L']:
            if self.node.last_dir[-3:] == direction * 3:
                cg.append(direction)
        return cg


# Let's build our own heap that has efficient operations that we care about: insert, pop, update
class MinHeap:
    # Heap is backed by an array
    _elements: List[HeapItem] = []

    # Index into the array is identified by this dict
    _indexMap: Dict[Node, int] = {}

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
        self._indexMap[self._elements[a].node] = a
        self._indexMap[self._elements[b].node] = b

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
        self._indexMap[item.node] = idx

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
        if len(self._elements) == 0:
            return None
        if len(self._elements) == 1:
            return self._elements.pop()

        ret = self._elements[0]

        # Insert last element into front and bubble down
        new_root = self._elements.pop()
        self._elements[0] = new_root
        del self._indexMap[ret.node]
        self._indexMap[new_root.node] = 0

        # Is the parent larger than the child?
        self._bubble_down(0)

        return ret

    def insert_or_decrease_priority(self, node: Node, p: float):
        if node in self._indexMap:
            idx = self._indexMap[node]
            if p >= self._elements[idx].priority:
                return

            # Reduce priority and bubble up
            self._elements[idx].priority = p
            self._bubble_up(idx)
        else:
            # Insert new node
            self.insert(HeapItem(node, p))


def main():
    with open("sample17.txt") as f:
        lines = f.readlines()

    # Data structures
    unvisited = MinHeap()
    visited: Dict[Node, int] = {}

    # Fill up unvisited with just the start.
    unvisited.insert(HeapItem(Node(loc=(0, 0), last_dir=""), 0))

    while True:
        # Get the smallest priority neighbor
        cur = unvisited.pop()

        if not cur or cur.priority == math.inf:
            break

        # Consider all neighbors
        neighbors: Dict[str, Node] = {d: Node.from_node(cur.node, d) for d in ['U', 'R', 'D', 'L']}
        cg = cur.cant_go()

        # - U
        if cur.node.loc[0] == 0 or neighbors['U'] in visited or 'U' in cg:
            del neighbors['U']
        # - R
        if cur.node.loc[1] == len(lines) - 1 or neighbors['R'] in visited or 'R' in cg:
            del neighbors['R']
        # - D
        if cur.node.loc[0] == len(lines) - 1 or neighbors['D'] in visited or 'D' in cg:
            del neighbors['D']
        # - L
        if cur.node.loc[1] == 0 or neighbors['L'] in visited or 'L' in cg:
            del neighbors['L']

        for d in neighbors:
            # Have we found a better path?
            n = neighbors[d]
            unvisited.insert_or_decrease_priority(n, cur.priority + int(lines[n.loc[0]][n.loc[1]]))

        # Mark as visited
        visited[cur.node] = cur.priority  # , cur.path)

    print(visited[(len(lines) - 1, len(lines) - 1)])


if __name__ == "__main__":
    main()
