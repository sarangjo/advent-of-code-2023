function DoHash {
    param ($Word)

    $hash = 0
    foreach ($char in $Word.ToCharArray()) {
        $val = [byte][char]$char
        $hash += $val
        $hash *= 17
        $hash %= 256
    }
    return $hash
}

function Part1 {
    param ($FileName)

    $content = Get-Content $FileName
    $codes = $content.Split(",")

    $total = 0
    foreach ($code in $codes) {
        $total += DoHash $code
    }

    return $total
}

function GetLetterEndIndex {
    param ($Code)

    for ($i = 0; $i -lt $Code.Length; $i++) {
        if ($Code[$i] -eq '=' -or $Code[$i] -eq '-') {
            return $i
        }
    }

    return -1
}

function Part2 {
    param ($FileName)

    $content = Get-Content $FileName
    $codes = $content.Split(",")

    $hashmaps = [System.Collections.Specialized.OrderedDictionary[]]::new(256)

    foreach ($code in $codes) {
        $endIndex = GetLetterEndIndex $code

        $codeword = $code.Substring(0, $endIndex)
        $hash = DoHash $codeword

        if ($code[$endIndex] -eq '=') {
            if ($null -eq $hashmaps[$hash]) {
                $hashmaps[$hash] = [ordered]@{}
            }
            $hashmaps[$hash][$codeword] = [System.Int32]::Parse($code[$endIndex + 1])
        }
        elseif ($null -ne $hashmaps[$hash]) {
            # '-'
            $hashmaps[$hash].Remove($codeword)
        }
    }

    $totalFocalPower = 0

    for ($i = 0; $i -lt $hashmaps.Length; $i++) {
        $hm = $hashmaps[$i]
        if ($hm.Count -gt 0) {
            for ($j = 0; $j -lt $hm.Keys.Count; $j++) {
                $totalFocalPower += ($i + 1) * ($j + 1) * $hm[$hm.Keys[$j]]
            }
        }
    }

    return $totalFocalPower
}

Write-Output "Part 1: $(Part1 day15.txt)"
Write-Output "Part 2: $(Part2 day15.txt)"
