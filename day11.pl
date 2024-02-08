#!/usr/bin/perl

use strict;
use warnings;

my @emptyCols = ();
my @galaxyRows = ();
my @galaxyCols = ();

sub getEmptiesAndGalaxies {
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

getEmptiesAndGalaxies("sample11.txt");

print("galaxy rows ", @galaxyRows, "\n");
print("galaxy cols ", @galaxyCols, "\n");
print("empty rows ", @emptyRows, "\n");
print("empty cols ", @emptyCols, "\n");

# Now we expand and adjust each galaxy as needed

my $rowExpand = 0;
my $colExpand = 0;

my $row = 0;
my $col = 0;

my $curEmptyRowIdx = 0;
my $curEmptyColIdx = 0;

while() {
    # Do we need to bump
}
