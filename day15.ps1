function Part1 {
    param ($FileName)

    $content = Get-Content $FileName
    $codes = $content.Split(",")

    $total = 0
    foreach ($code in $codes) {
        $hash = 0
        foreach ($char in $code.ToCharArray()) {
            $val = [byte][char]$char
            $hash += $val
            $hash *= 17
            $hash %= 256
        }
        $total += $hash
    }

    return $total
}

Write-Output "Part 1: $(Part1 day15.txt)"
