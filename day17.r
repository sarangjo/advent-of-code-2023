file_name <- "sample17.txt"
file_content <- readLines(file_name)

grid_dim <- length(file_content)

grid <- matrix(, nrow = grid_dim, ncol = grid_dim)
for (i in seq_along(file_content)) {
    line <- file_content[i]
    line_split <- strsplit(line, "")[[1]]
    line_nums <- as.numeric(line_split)

    grid[i,] <- line_nums
}

cur_pos <- c(1, 1)

move <- function(pos, dir) {
    if (dir == 'R') {
        return(c(pos[1], pos[2] + 1))
    } else if (dir == 'D') {
        return(c(pos[1] + 1, pos[2]))
    } else if (dir == 'L') {
        return(c(pos[1], pos[2] - 1))
    } else { # 'U'
        return(c(pos[1] - 1, pos[2]))
    }
}

get_best_weight <- function(pos, path, same_dir_count, dir) {
    # Base case
    if (pos[1] < 1 || pos[1] > grid_dim || pos[2] < 1 || pos[2] > grid_dim || path[pos[1], pos[2]]) {
        return(-1)
    }

    print("Now at")
    print(pos)

    # Try getting best weight from all possible directions
    possible_directions <- c()
    if (dir == 'X') {
        # Special case for start
        possible_directions <- c(possible_directions, c('R', 'D'))
    } else if (dir == 'R') {
        possible_directions <- c(possible_directions, c('U', 'R', 'D'))
    } else if (dir == 'D') {
        possible_directions <- c(possible_directions, c('R', 'D', 'L'))
    } else if (dir == 'L') {
        possible_directions <- c(possible_directions, c('D', 'L', 'U'))
    } else if (dir == 'U') {
        possible_directions <- c(possible_directions, c('L', 'U', 'R'))
    }

    weight <- -1

    path[pos[1], pos[2]] = TRUE

    for (next_d in possible_directions) {
        if (next_d == dir) {
            same_dir_count <- same_dir_count + 1
        }

        if (same_dir_count >= 4) {
            # Can't go straight more than 3 times
            next
        }

        if (pos[1] == grid_dim && pos[2] == grid_dim) {
            # Reached the destination!
            return(grid[pos[1], pos[2]])
        }

        next_weight <- get_best_weight(move(pos, next_d), path, same_dir_count, next_d)
        if (next_weight < 0) {
            # We went somewhere illegal, abandon
            next
        }

        if (weight < 0 || next_weight < weight) {
            weight <- next_weight
        }
    }

    path[pos[1], pos[2]] = FALSE

    if (weight < 0) {
        return(weight)
    } else {
        return(grid[pos[1], pos[2]] + weight)
    }
}

browser()

path <- matrix(FALSE, nrow = grid_dim, ncol = grid_dim)
weight <- get_best_weight(c(1, 1), path, 0, 'X')

print(weight)

warnings()
