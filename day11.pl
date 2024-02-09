#!/usr/bin/perl

use strict;
use warnings;

# How much do we need to replace empty rows/cols by?
my $emptyLength = 2;
my @emptyCols = ();
my @galaxyRows = ();
my @galaxyCols = ();

sub getEmptyColsAndGalaxies {
    my $fn = shift;

    my %occupiedCols = ();

    open(FH, '<', $fn);

    # Number of columns in the file
    my $colCount = 0;

    my $row = 0;
    while (<FH>) {
        # Find all galaxies in this row
        my $offset = 0;
        my $col = index($_, '#', $offset);

        # Ignore \n at the end
        $colCount = length($_) - 1;

        # Empty row!
        if ($col == -1) {
            $row += ($emptyLength - 1);
        }

        # Find all galaxies in this row
        while ($col != -1) {
            # Galaxy found; add it
            push(@galaxyRows, $row);
            push(@galaxyCols, $col);

            $occupiedCols{"$col"} = 1;

            $offset = $col + 1;
            $col = index($_, '#', $offset);
        }

        $row++;
    }

    # Convert
    for my $col (0..$colCount) {
        if (!exists($occupiedCols{"$col"})) {
            push(@emptyCols, $col);
        }
    }
}

sub updateGalaxyCols {
    my $colExpand = 0;

    my $curEmptyColIdx = 0;
    my $curSortedColIdx = 0;

    # Sort cols but keep a hold of their original indices so we can rearrange
    my @sortedIndices = sort { $galaxyCols[$a] <=> $galaxyCols[$b] } 0..$#galaxyCols;

    # So now we iterate through galaxyCols via sortedIndices rather than a normal index
    while ($curSortedColIdx < scalar(@sortedIndices) && $curEmptyColIdx < scalar(@emptyCols)) {
        if ($galaxyCols[$sortedIndices[$curSortedColIdx]] < $emptyCols[$curEmptyColIdx]) {
            # No empty col encountered, just update by current expansion rate
            $galaxyCols[$sortedIndices[$curSortedColIdx]] += $colExpand;
            $curSortedColIdx++;
        } else {
            # Empty col, bump colExpand
            $colExpand += ($emptyLength - 1);
            $curEmptyColIdx++;
        }
    }
    # Fencepost
    while ($curSortedColIdx < scalar(@sortedIndices)) {
        # No more empties
        $galaxyCols[$sortedIndices[$curSortedColIdx]] += $colExpand;
        $curSortedColIdx++;
    }
}

sub calculateAllDistances {
    my $sum = 0;
    for my $i (0..$#galaxyRows) {
        for my $j ($i+1..$#galaxyRows) {
            $sum += abs($galaxyRows[$j] - $galaxyRows[$i]) + abs($galaxyCols[$j] - $galaxyCols[$i]);
        }
    }
    return $sum;
}

sub fullSequence {
    # Compute galaxies and empty columns - empty rows are already being taken into account
    getEmptyColsAndGalaxies("sample11.txt");

    # Now we expand and adjust each galaxy as needed
    updateGalaxyCols();

    # Next, find the distance between each pair of galaxies and add them up
    return calculateAllDistances();
}

my $part1 = fullSequence();
print("part 1: $part1\n");

# Reset for part 2
$emptyLength = 1000000;
@emptyCols = ();
@galaxyRows = ();
@galaxyCols = ();

my $part2 = fullSequence();
print("part 2: $part2\n");
