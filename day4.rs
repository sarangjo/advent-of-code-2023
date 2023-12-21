use std::collections::HashSet;
use std::fs::File;
use std::io;
use std::io::BufRead;
use std::path::Path;
use std::process;

fn part1_process_line(line: String) -> u32 {
    let mut start = line.find(':').unwrap() + 2;
    let mut winning_numbers = HashSet::new();
    loop {
        if line.chars().nth(start).unwrap() == '|' {
            break;
        }
        let num = &line[start..start + 2].replace(' ', "0");
        winning_numbers.insert(num.parse::<u32>().unwrap());
        start += 3;
    }

    // Now we advance to check our numbers
    let mut win_count: u32 = 0;
    start += 2;
    while start < line.len() {
        let num = &line[start..start + 2].replace(' ', "0");
        if winning_numbers.contains(&num.parse::<u32>().unwrap()) {
            win_count += 1;
        }
        start += 3;
    }

    if win_count > 0 {
        return 2_u32.pow(win_count - 1);
    }
    0
}

fn main() {
    let mut sum = 0;
    let lines = read_lines("./day4.txt").unwrap();
    for l in lines {
        sum += part1_process_line(l.unwrap());
    }
    println!("Sum: {:?}", sum);
}

// From: https://doc.rust-lang.org/rust-by-example/std_misc/file/read_lines.html
// The output is wrapped in a Result to allow matching on errors
// Returns an Iterator to the Reader of the lines of the file.
fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
