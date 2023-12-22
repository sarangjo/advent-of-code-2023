import * as fs from "node:fs/promises";

const DST_START = 0;
const SRC_START = 1;
const RANGE_LEN = 2;

function translateSeed(lines: string[], seed: string) {
  let val = +seed;

  let i = 2;
  while (i < lines.length) {
    // console.log("Current val:", val);
    // console.log("Translation:", lines[i]);

    // Skip map title
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

function part1(lines: string[]) {
  // Start with the seeds
  const seedsLine = lines[0];
  const seeds = seedsLine.substring(seedsLine.indexOf(":") + 2).split(" ");

  let bestLoc: number | undefined = undefined;
  for (const seed of seeds) {
    const loc = translateSeed(lines, seed);
    if (bestLoc === undefined || loc < bestLoc) {
      bestLoc = loc;
    }
  }

  return bestLoc;
}

interface MapLine {
  dstStart: number;
  srcStart: number;
  length: number;
}

function translateSeedRange(lines: string[], seedRange: SeedRange) {
  let valRanges = [seedRange];

  let i = 2;
  while (i < lines.length) {
    // Skip map title
    i++;

    let line = lines[i];

    // Go one map at a time
    let newRanges = [];
    while (line.trim().length !== 0) {
      // For each line in map, update our known ranges
      const mapLine = line.split(" ").reduce((acc, cur, idx) => {
        switch (idx) {
          case 0:
            acc.dstStart = +cur;
            break;
          case 1:
            acc.srcStart = +cur;
            break;
          case 2:
            acc.length = +cur;
            break;
        }
        return acc;
      }, {} as MapLine);

      for (const range of valRanges) {
        // Okay, how does this range intersect with this line?
        if (range.start < mapLine.srcStart) {
          if (range.start + range.length < mapLine.srcStart) {
            // do nothing
          } else if (range.start + range.length < mapLine.srcStart + mapLine.length) {
            // split - first section is untouched, the rest gets mapped

            newRanges.push();
          }
        }
      }

      // if (val >= parts[SRC_START] && val < parts[SRC_START] + parts[RANGE_LEN]) {
      //   val = parts[DST_START] + (val - parts[SRC_START]);
      //   done = true;
      // }

      line = lines[++i];
    }

    // Onto next map
    i++;
  }

  return val;
}

interface SeedRange {
  start: number;
  length: number;
}

function part2(lines: string[]) {
  // Now we have a seed range, so we operate on the whole range, effectively
  const seedsLine = lines[0];
  const seedRanges = seedsLine
    .substring(seedsLine.indexOf(":") + 2)
    .split(" ")
    .reduce((acc, cur, idx, arr) => {
      if (idx % 2 == 0) {
        acc.push({ start: +cur, length: +arr[idx + 1] });
      }

      return acc;
    }, [] as SeedRange[]);

  console.log(seedRanges);

  for (const seedRange of seedRanges) {
    const loc = translateSeedRange(lines, seedRange);
  }
}

async function main() {
  const lines = (await fs.readFile("sample5.txt")).toString().split("\n");
  const lowest = part2(lines);
  console.log("Lowest location:", lowest);
}

main();
