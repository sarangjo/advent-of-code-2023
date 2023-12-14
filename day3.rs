// Hold onto three

// The output is wrapped in a Result to allow matching on errors
// Returns an Iterator to the Reader of the lines of the file.
fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}

fn main() {
    if let Ok(lines) = read_lines("sample3.txt") {
        for line in lines {
            if let Ok(ip) = line {
                println!("{}", ip)
            }
        }
    }

    // println!("Hello, world!")
}
