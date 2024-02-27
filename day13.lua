function update_vertical_mirrors(line, vmirrors)
    for i, mirror in pairs(vmirrors) do
        --- check if this could be the mirror
        local j = 0
        while mirror - j >= 1 and mirror + 1 + j <= string.len(line) do
            if string.sub(line, mirror - j, mirror - j) ~= string.sub(line, mirror + 1 + j, mirror + 1 + j) then
                vmirrors[i] = nil
                break
            end
            j = j + 1
        end
    end
end

function update_horizontal_mirrors(pattern, col, hmirrors)
    for i, mirror in pairs(hmirrors) do
        local j = 0
        while mirror - j >= 1 and mirror + 1 + j <= #pattern do
            if string.sub(pattern[mirror - j], col, col) ~= string.sub(pattern[mirror + 1 + j], col, col) then
                hmirrors[i] = nil
                break
            end
            j = j + 1
        end
    end
end

function mirror_count(mirrors)
    local count = 0
    for _ in pairs(mirrors) do
        count = count + 1
    end
    return count
end

function part1(file)
    -- Set the default file to the provided file path
    io.input(file)
    local score = 0

    repeat
        local pattern = {}
        local line_length = 0

        -- Fencepost to see line length
        local line = io.read("*l")
        line_length = string.len(line)

        -- Set up possible vertical mirrors
        local vmirrors = {}
        for j = 1, line_length - 1, 1 do
            vmirrors[j] = j
        end
        local might_have_vertical_mirror = true

        while line ~= '' and line do
            pattern[#pattern + 1] = line

            if might_have_vertical_mirror then
                update_vertical_mirrors(line, vmirrors)
            end

            -- check if this line has vertical mirror
            if mirror_count(vmirrors) == 0 then
                -- no possible vertical mirror
                might_have_vertical_mirror = false
            end

            line = io.read("*l")
        end

        -- did we find a vertical mirror?
        if might_have_vertical_mirror and mirror_count(vmirrors) == 1 then
            -- found it! there's only one so go into it
            for k in pairs(vmirrors) do
                score = score + k
            end
        else
            -- okay now time for horizontal checking; we have all of the lines loaded so repeat the process
            local hmirrors = {}
            for j = 1, #pattern - 1, 1 do
                hmirrors[j] = j
            end

            for col = 1, line_length, 1 do
                -- check this column
                update_horizontal_mirrors(pattern, col, hmirrors)

                -- we're guaranteed to have a mirror so once we're down to 1 immediately bop out
                if mirror_count(hmirrors) == 1 then
                    for k in pairs(hmirrors) do
                        score = score + (k * 100)
                    end
                    break
                end
            end
        end
    until not line

    print("part 1:", score)
end

part1("day13.txt")

function update_vertical_mirrors_2(line, vmirrors)
    for mirror in pairs(vmirrors) do
        --- check if this could be the mirror
        local j = 0
        while mirror - j >= 1 and mirror + 1 + j <= string.len(line) do
            if string.sub(line, mirror - j, mirror - j) ~= string.sub(line, mirror + 1 + j, mirror + 1 + j) then
                if vmirrors[mirror] == 1 then
                    -- GG to this mirror, needs too many smudges to work
                    vmirrors[mirror] = nil
                    break
                else
                    vmirrors[mirror] = 1
                end
            end
            j = j + 1
        end
    end
end

function update_horizontal_mirrors_2(pattern, col, hmirrors)
    for mirror in pairs(hmirrors) do
        local j = 0
        while mirror - j >= 1 and mirror + 1 + j <= #pattern do
            if string.sub(pattern[mirror - j], col, col) ~= string.sub(pattern[mirror + 1 + j], col, col) then
                if hmirrors[mirror] == 1 then
                    -- bye
                    hmirrors[mirror] = nil
                    break
                else
                    hmirrors[mirror] = 1
                end
            end
            j = j + 1
        end
    end
end

-- Ideas for part 2: instead of solely keeping track of mirrors that work outright, keep track of each with a smudge count. If anything totals to 1 exactly, then that's our winner
function part2(file)
    -- Set the default file to the provided file path
    io.input(file)
    local score = 0

    repeat
        local pattern = {}
        local line_length = 0

        -- Fencepost to see line length
        local line = io.read("*l")
        line_length = string.len(line)

        -- Set up possible vertical mirrors; the value represents the number of smudges that make it
        -- valid
        local vmirrors = {}
        for j = 1, line_length - 1, 1 do
            vmirrors[j] = 0
        end
        local might_have_vertical_mirror = true

        while line ~= '' and line do
            pattern[#pattern + 1] = line

            if might_have_vertical_mirror then
                update_vertical_mirrors_2(line, vmirrors)
            end

            -- check if this line has vertical mirror
            if mirror_count(vmirrors) == 0 then
                -- no possible vertical mirror
                might_have_vertical_mirror = false
            end

            line = io.read("*l")
        end

        -- did we find a vertical mirror with exactly 1 smudge count?
        local found = false
        for k, count in pairs(vmirrors) do
            if count == 1 then
                -- found!
                found = true
                score = score + k
                break
            end
        end

        if not found then
            -- okay now time for horizontal checking; we have all of the lines loaded so repeat the process
            local hmirrors = {}
            for j = 1, #pattern - 1, 1 do
                hmirrors[j] = 0
            end

            for col = 1, line_length, 1 do
                -- check this column
                update_horizontal_mirrors_2(pattern, col, hmirrors)
            end

            -- we must have a smudged; which one though
            for k, count in pairs(hmirrors) do
                if count == 1 then
                    -- found!
                    score = score + 100 * k
                    break
                end
            end
        end

        -- print("running score:", score)
    until not line

    print("part 2:", score)
end

part2("day13.txt")
