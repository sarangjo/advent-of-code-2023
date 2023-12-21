use std::collections::HashSet;
use std::collections::VecDeque;
use std::convert::TryInto;
use std::fs::File;
use std::io;
use std::io::BufRead;

fn part1_get_win_count(line: String) -> u32 {
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

    win_count
}

#[allow(dead_code)]
fn part1(lines: io::Lines<io::BufReader<File>>) -> u32 {
    let mut sum = 0;
    for l in lines {
        let win_count = part1_get_win_count(l.unwrap());
        if win_count > 0 {
            sum += 2_u32.pow(win_count - 1);
        }
    }
    return sum;
}

fn part2(lines: io::Lines<io::BufReader<File>>) -> u32 {
    let mut card_count = 0;

    let mut card_counts = VecDeque::from([]);

    for l in lines {
        // How many copies do we have? This is represented by the front of the card_counts
        let mut copies = 1;
        if card_counts.len() > 0 {
            copies += card_counts.pop_front().unwrap();
        }
        card_count += copies;

        // Based on how many copies we have, we have to multiplicatively update the next N cards
        // println!("We have {} copies of card {}", copies, i + 1);

        // Now how does this card impact the next elements?
        let win_count = part1_get_win_count(l.unwrap());
        let len = card_counts.len().try_into().unwrap();

        // println!("Card {} has a win_count {}", i + 1, win_count);

        // Allocate up front to make faster
        if win_count > len {
            card_counts.resize(win_count.try_into().unwrap(), 0);
            // win_count = len;
        }

        // So at this point, the next win_count lines need to get a +1 **for each copy of the current card**
        for i in 0..win_count {
            card_counts[i.try_into().unwrap()] += copies;
        }

        // println!(
        //     "After processing card {}, card_counts: {:?}",
        //     i + 1,
        //     card_counts
        // );

        // println!("-------------------\n\n");
    }

    return card_count;
}

fn main() {
    let file = File::open("./day4.txt").unwrap();
    let lines = io::BufReader::new(file).lines();
    let sum = part2(lines);
    println!("Sum: {:?}", sum);
}
