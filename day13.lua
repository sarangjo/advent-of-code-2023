function get_bitwise(mirrors)
    local s = ''
    for i = 1, 32, 1 do
        if bit32.band(mirrors, bit32.lshift(1, i)) then
            if not s == '' then
                s = s .. ','
            end
            s = s .. i
        end
    end
    return s
end

---
function update_vertical_mirrors(line, mirrors)
    for mirror = 1, string.len(line) do
        --- check if this could be the mirror
        --- no continues in Lua...
        if bit32.band(mirrors, bit32.lshift(1, mirror)) then
            local i = 0
            local still_mirror = true
            while mirror - i >= 1 and mirror + 1 + i <= string.len(line) do
                if not string.sub(line, mirror - i, mirror - i) == string.sub(line, mirror + 1 + i, mirror + 1 + i) then
                    break
                end
            end
            if not still_mirror then
                mirrors = bit32.band(mirrors, bit32.bnot(bit32.lshift(1, mirror)))
            end
        end
    end

    return mirrors
end

function part1(file)
    local f = io.input(file)

    repeat
        local pattern = {}
        local i = 1

        local line = f.read("*l")

        local mirrors = 2 ^ string.len(line) - 1

        print("mirrors", get_bitwise(mirrors))

        while true do
            --- check if this line has vertical mirror
            os.exit()

            line = f.read("*l")

            if line == '' then
                break
            end
        end
    until not s

    for line in io.lines(file) do
        --- We process line by line but also store it in a table so we can check for a potential
        --- horizontal mirror
        lines[#lines + 1] = line
    end

    --- check for horizontal line
end

-- part1("sample13.txt")
print(get_bitwise(7))
