package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"
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

var digitWords = []string{"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}

func processLine2(line string) int {
	var first, last int
	var translated int
	seenFirst := false
	active := make([]string, 10)
	for _, c := range line {
		// As we process each letter, we either:
		// - complete a number
		// - update possible numbers
		if unicode.IsNumber(c) {
			translated = int(c - '0')
			if !seenFirst {
				first = translated
				seenFirst = true
			}
			last = translated
			continue
		}
		for i, digit := range digitWords {
			if strings.Index(digit, active[i]+string(c)) == 0 {
				active[i] += string(c)
				if active[i] == digit {
					// Found!
					translated = i
					// Clear out anyone else who might be having ideas about starting early
					if !seenFirst {
						first = translated
						seenFirst = true
					}
					last = translated
					// Thank god no digit starts with the same letter as its last letter
					active[i] = ""
				}
			} else {
				active[i] = ""
			}
		}
		// Creating a common section to save either the numeric values or the text-based values; they
		// both jump here
		// save:
		// 	if saving {
		// 		// active = make([]string, 10)
		// 		if !seenFirst {
		// 			first = translated
		// 			seenFirst = true
		// 		}
		// 		last = translated
		// 		saving = false
		// 	}
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
	idx := 0
	for scanner.Scan() {
		lineRes := processLine2(scanner.Text())
		fmt.Println("lineRes", lineRes)
		sum += lineRes
		// if idx > 15 {
		// 	break
		// }
		idx++
	}

	fmt.Println(sum)
}
