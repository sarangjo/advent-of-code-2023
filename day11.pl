#!/usr/bin/perl

use strict;
use warnings;

my @emptyCols = ();
my @galaxyRows = ();
my @galaxyCols = ();

sub getEmptyColsAndGalaxies {
    my $fn = shift;

    my %occupiedCols = ();

    open(FH, '<', $fn);

    my $colCount = 0;

    my $row = 0;
    while (<FH>) {
        # Find all galaxies in this row
        my $offset = 0;
        my $col = index($_, '#', $offset);

        # Ignore \n at the end
        $colCount = length($_) - 1;

        if ($col == -1) {
            $row++;
        }

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

    my $col = 0;
    while ($col < $colCount) {
        if (!exists($occupiedCols{"$col"})) {
            push(@emptyCols, $col);
        }

        $col++;
    }
}

sub updateGalaxyCols {
    my $colExpand = 0;

    my $curEmptyColIdx = 0;
    my $curSortedColIdx = 0;

    # Sort cols but keep a hold of their original indices so we can rearrange
    my @sortedIndices = sort { $galaxyCols[$a] <=> $galaxyCols[$b] } 0..$#galaxyCols;

    print("sorted indices ", @sortedIndices, "\n");

    # So now we iterate through galaxyCols via sortedIndices rather than a normal index
    while ($curSortedColIdx < scalar(@sortedIndices) && $curEmptyColIdx < scalar(@emptyCols)) {
        if ($galaxyCols[$sortedIndices[$curSortedColIdx]] < $emptyCols[$curEmptyColIdx]) {
            # No empty col encountered, just update by current expansion rate
            $galaxyCols[$sortedIndices[$curSortedColIdx]] += $colExpand;
            $curSortedColIdx++;
        } else {
            # Empty col, bump colExpand
            $colExpand++;
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
}

# Compute galaxies and empty columns - empty rows are already being taken into account
getEmptyColsAndGalaxies("sample11.txt");

print("galaxy rows ", @galaxyRows, "\n");
print("galaxy cols ", @galaxyCols, "\n");
print("empty cols ", @emptyCols, "\n");

# Now we expand and adjust each galaxy as needed
updateGalaxyCols();

print("galaxy cols ", @galaxyCols, "\n");

# Next, find the distance between each pair of galaxies and add them up
calculateAllDistances();
