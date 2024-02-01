<?php
function all_zeroes($elems) {
    foreach ($elems as $el) {
        if ($el != 0) {
            return false;
        }
    }
    return true;
}

// Recursive function! Wow!
// $end is true if we're finding the end (part 1), otherwise it's the previous (part 2)
function process_line($elems, $end) {
    if (all_zeroes($elems)) { // Base case
        return 0;
    } else { // Recursive case
        // Compute the new elems to pass in
        $new_elems = array();
        for ($i = 0; $i < count($elems)-1; $i++) {
            $new_elems[] = $elems[$i+1] - $elems[$i];
        }

        // Compute and return result
        $next_lower_elem = process_line($new_elems, $end);

        return $end ? $elems[count($elems) - 1] + $next_lower_elem : $elems[0] - $next_lower_elem;
    }
}

$lines = explode("\n", file_get_contents("day9.txt"));

$sum1 = 0;
$sum2 = 0;
foreach ($lines as $line) {
    $elems = array_map('intval', explode(" ", $line));
    $sum1 += process_line($elems, true);
    $sum2 += process_line($elems, false);
}

echo "Part 1 sum: $sum1\n";
echo "Part 2 sum: $sum2\n";
?>
