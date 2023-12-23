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
    // Go one map at a time

    // Skip map title
    i++;

    let line = lines[i];

    // valRanges has the untranslated ranges, newRanges have been translated
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

      let untranslatedRanges = [];

      while (valRanges.length !== 0) {
        const range = valRanges.pop();

        // Okay, how does this range intersect with this line?
        if (range.start < mapLine.srcStart) {
          if (range.start + range.length < mapLine.srcStart) {
            // do nothing
            untranslatedRanges.push(range);
          } else if (range.start + range.length <= mapLine.srcStart + mapLine.length) {
            // split - first section is shrunk, the rest gets mapped
            untranslatedRanges.push({
              start: range.start,
              length: mapLine.srcStart - range.start,
            });

            newRanges.push({
              start: mapLine.dstStart,
              length: range.length - (mapLine.srcStart - range.start),
            } as SeedRange);
          } else {
            // range goes beyond map line - split into three
            // section 1 gets truncated
            untranslatedRanges.push({
              start: range.start,
              length: mapLine.srcStart - range.start,
            });

            // section 2 gets mapped
            newRanges.push({ start: mapLine.dstStart, length: mapLine.length });

            // section 3 gets newly added back to untranslatedRanges
            untranslatedRanges.push({
              start: mapLine.srcStart + mapLine.length,
              length: range.length - mapLine.length - (mapLine.srcStart - range.start),
            });
          }
        } else if (
          range.start > mapLine.srcStart &&
          range.start < mapLine.srcStart + mapLine.length
        ) {
          if (range.start + range.length <= mapLine.srcStart + mapLine.length) {
            // easy - just fully map
            newRanges.push({
              start: mapLine.dstStart + (range.start - mapLine.srcStart),
              length: range.length,
            });
          } else {
            // split up
            newRanges.push({
              start: mapLine.dstStart + (range.start - mapLine.srcStart),
              length: mapLine.srcStart - range.start,
            });

            untranslatedRanges.push({
              start: range.start + range.length,
              length: range.length - (mapLine.srcStart - range.start),
            });
          }
        } else {
          untranslatedRanges.push(range);
        }
      }

      valRanges = untranslatedRanges;

      line = lines[++i];
    }

    // Okay we're all done with map lines - combine valRanges and newRanges
    valRanges.push(...newRanges);

    // Onto next map
    i++;
  }

  return valRanges.reduce((prevMin: undefined | number, cur) => {
    return prevMin === undefined || cur.start < prevMin ? cur.start : prevMin;
  }, undefined);
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

  let min: number | undefined = undefined;
  for (const seedRange of seedRanges) {
    const loc = translateSeedRange(lines, seedRange);
    min = min === undefined || loc < min ? loc : min;
  }

  return min;
}

async function main() {
  const lines = (await fs.readFile("day5.txt")).toString().split("\n");
  const lowest = part2(lines);
  console.log("Lowest location:", lowest);
}

main();
