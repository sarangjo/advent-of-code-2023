---
function update_vertical_mirrors(line, vmirrors)
    for i, mirror in pairs(vmirrors) do
        --- check if this could be the mirror
        local j = 0
        local still_mirror = true
        while mirror - j >= 1 and mirror + 1 + j <= string.len(line) do
            if string.sub(line, mirror - j, mirror - j) ~= string.sub(line, mirror + 1 + j, mirror + 1 + j) then
                still_mirror = false
                break
            end
            j = j + 1
        end
        if not still_mirror then
            vmirrors[i] = nil
        end
    end

    return vmirrors
end

function update_horizontal_mirrors(pattern, col, hmirrors)
    for i, mirror in pairs(hmirrors) do
        local j = 0
        local still_mirror = true
        while mirror - j >= 1 and mirror + 1 + j <= #pattern do
            if string.sub(pattern[mirror - j], col, col) ~= string.sub(pattern[mirror + 1 + j], col, col) then
                still_mirror = false
                break
            end
            j = j + 1
        end
        if not still_mirror then
            hmirrors[i] = nil
        end
    end

    return hmirrors
end

function mirror_count(mirrors)
    local count = 0
    for _ in pairs(mirrors) do
        count = count + 1
    end
    return count
end

function part1(file)
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

        while true do
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

            if line == '' or not line then
                break
            end
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

        print("score:", score)
    until not line
end

part1("sample13.txt")
