package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"unicode"
)

func processLine(line string) int {
	var first, last int
	seenFirst := false
	for _, c := range line {
		if unicode.IsNumber(c) {
			translated := int(c - '0')
			if !seenFirst {
				first = translated
				seenFirst = true
			}
			last = translated
		}
	}
	return first*10 + last
}

func main() {
	// https://adventofcode.com/2023/day/1/input
	file, err := os.Open("day1.txt")
	if err != nil {
		log.Fatal(err)
	}

	scanner := bufio.NewScanner(file)
	sum := 0
	for scanner.Scan() {
		sum += processLine(scanner.Text())
	}

	fmt.Println(sum)
}
