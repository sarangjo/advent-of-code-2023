import * as fs from "node:fs/promises";

const DST_START = 0;
const SRC_START = 1;
const RANGE_LEN = 2;

function translateSeed(lines: string[], seed: string) {
  let val = +seed;

  let i = 2;
  while (i < lines.length) {
    // console.log("Current val:", val);

    // Skip map title
    // console.log("Translation:", lines[i]);

    i++;

    let line = lines[i];
    let done = false;

    // Go one map at a time
    while (line.trim().length !== 0) {
      if (!done) {
        const parts = line.split(" ").map((x) => +x);

        if (val >= parts[SRC_START] && val < parts[SRC_START] + parts[RANGE_LEN]) {
          val = parts[DST_START] + (val - parts[SRC_START]);
          done = true;
        }
      }
      line = lines[++i];
    }

    // Onto next map
    i++;
  }

  return val;
}

function part1(data: string) {
  const lines = data.split("\n");

  // Start with the seeds
  const seedsLine = lines[0];
  const seeds = seedsLine.substring(seedsLine.indexOf(":") + 2).split(" ");

  let bestLoc: number | undefined = undefined;
  for (let seed of seeds) {
    const loc = translateSeed(lines, seed);
    if (bestLoc === undefined || loc < bestLoc) {
      bestLoc = loc;
    }
  }

  return bestLoc;
}

async function main() {
  const data = await fs.readFile("day5.txt");
  const lowest = part1(data.toString());
  console.log("Lowest location:", lowest);
}

main();
