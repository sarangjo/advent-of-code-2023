#!/usr/bin/env python
import math
from typing import Dict, List, Tuple


class HeapItem:
    loc: Tuple[int, int]
    priority: float
    path: List[str]

    def __init__(self, loc: Tuple[int, int], priority: float) -> None:
        self.loc = loc
        self.priority = priority
        self.path = []

    def __str__(self) -> str:
        return f"({self.loc[0]}, {self.loc[1]}): {self.priority}{"" if len(self.path) == 0 else "; " + "".join(self.path)}"

    def __repr__(self) -> str:
        return str(self)

    def cant_go(self) -> List[str]:
        cg = []
        if len(self.path) > 0:
            cg.append('U' if self.path[-1] == 'D' else 'R' if self.path[-1]
                      == 'L' else 'D' if self.path[-1] == 'U' else 'L')
        for direction in ['U', 'R', 'D', 'L']:
            if self.path[-3:] == [direction] * 3:
                cg.append(direction)
        return cg


# Let's build our own heap that has efficient operations that we care about: upsert, pop, update
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

    def upsert(self, item: HeapItem):
        """
        Insert, or update if location is already in the heap.
        """
        if item.loc in self._indexMap:
            self.decrease_priority(item.loc, item.priority)
        else:
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

        return True

    def update_path(self, loc: Tuple, cur: HeapItem, next_dir: str):
        self._elements[self._indexMap[loc]].path = cur.path + [next_dir]


def main():
    with open("sample17.txt") as f:
        lines = f.readlines()

    goal = (len(lines) - 1, len(lines) - 1)
    res: None | HeapItem = None

    def h(loc: Tuple[int, int]):
        """
        h(n) is the heuristic guess of the cost from n to the goal
        """
        return goal[0] - loc[0] + goal[1] - loc[1]

    # The openset priority is the fScore
    open_set = MinHeap()
    came_from: Dict[Tuple[int, int], Tuple[int, int]] = {}
    gScore = {}

    # Set up open set (default priority infinity) and gScore (default score infinity). gScore[n] is
    # the cost of cheapest path from start to n
    for i in range(len(lines)):
        for j in range(len(lines)):
            open_set.upsert(HeapItem((i, j), h((0, 0)) if i == 0 and j == 0 else math.inf))
            gScore[(i, j)] = 0 if i == 0 and j == 0 else math.inf

    while True:
        cur = open_set.pop()
        if cur is None:
            break
        if cur == goal:
            res = cur
            break

        # Go through neighbors
        neighbors = []
        cg = cur.cant_go()

        # - U
        if cur.loc[0] != 0 and 'U' not in cg:
            neighbors.append(((cur.loc[0] - 1, cur.loc[1]), 'U'))
        # - R
        if cur.loc[1] != len(lines) - 1 and 'R' not in cg:
            neighbors.append(((cur.loc[0], cur.loc[1] + 1), 'R'))
        # - D
        if cur.loc[0] != len(lines) - 1 and 'D' not in cg:
            neighbors.append(((cur.loc[0] + 1, cur.loc[1]), 'D'))
        # - L
        if cur.loc[1] != 0 and 'L' not in cg:
            neighbors.append(((cur.loc[0], cur.loc[1] - 1), 'L'))

        for n in neighbors:
            # tentative_gScore is the distance from start to the neighbor through current
            tentative_gScore = gScore[cur.loc] + int(lines[n[0][0]][n[0][1]])
            if tentative_gScore < gScore[n[0]]:
                # We have an improvement!
                came_from[n[0]] = cur.loc
                gScore[n[0]] = tentative_gScore

                # Update fScore
                open_set.upsert(HeapItem(n[0], tentative_gScore + h(n[0])))
                open_set.update_path(n[0], cur, n[1])

    # Build paths for each spot to see what's going wrong
    for i in range(len(lines)):
        for j in range(len(lines)):
            cur = (i, j)
            path = f"({i}, {j})"
            while cur in came_from:
                cur = came_from[cur]
                path = f"({cur[0]}, {cur[1]}), " + path

            print(path)

    if res is None:
        print("fail")
    else:
        print("succ")
        print(res)


if __name__ == "__main__":
    main()
