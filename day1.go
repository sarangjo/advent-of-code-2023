package main

import (
	"bufio"
	"container/list"
	"fmt"
	"log"
	"os"
	"strings"
	"unicode"
)

// Solution: 55488
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

var digitWords = []string{"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}

const overlapsAllowed = true

// Solution:
// - 55604: no overlaps considered (sevenine = 77, nineight = 99) --> no
// - 55612: overlaps considered (sevenine = 79, nineight = 98) --> no
func processLineBad(line string) int {
	var first, last int
	var translated int
	seenFirst := false
	active := make([]string, 9)
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
			active = make([]string, 9)
			continue
		}
		for i, digit := range digitWords {
			if strings.Index(digit, active[i]+string(c)) == 0 {
				active[i] += string(c)
				if active[i] == digit {
					// Found!
					translated = i + 1
					// Clear out anyone else who might be having ideas about starting early
					if !seenFirst {
						first = translated
						seenFirst = true
					}
					last = translated
					// Thank god no digit starts with the same letter as its last letter
					if overlapsAllowed {
						active[i] = ""
					} else {
						active = make([]string, 9)
						break
					}
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

type Active struct {
	substr string
	digit  int
}

// - 55488: wrong. bad and wrong and bad. lol.
// - 55597: wrong. double letters: eeightabcthreee
// - 55614: success! finally.
// Incredibly overly complicated solution. Problem of thinking bottom-up. Just do the fast approach
// and check each number at each stage. Would have made the solution 5x smaller. Gosh.
func processLine2(line string) int {
	var first, last int
	{
		active := make([]string, 9)
		// Go from front
	lineloop:
		for _, c := range line {
			// numeric
			if unicode.IsNumber(c) {
				first = int(c - '0')
				break
			}
			for i, digit := range digitWords {
				if strings.Index(digit, active[i]+string(c)) == 0 {
					active[i] += string(c)
					if active[i] == digit {
						first = i + 1
						break lineloop
					}
				} else if strings.Index(digit, string(c)) == 0 {
					// handle the case where it's invalid for what we have so far but it can start a new: "tthree"
					active[i] = string(c)
					// not bothering checking because this is single
				} else {
					active[i] = ""
				}
			}
		}
	}
	{
		// We do this whole list approach literally only for "three"
		active := list.New()
		// Go from back
	lineloop2:
		for i := len(line) - 1; i >= 0; i-- {
			c := line[i]

			// numeric
			if '0' <= c && c <= '9' {
				last = int(c - '0')
				break
			}
			var elementsToRemove []*list.Element
			// First see if we can extend active
			for e := active.Front(); e != nil; e = e.Next() {
				a := e.Value.(Active)
				digit := digitWords[a.digit-1]

				// Can we continue extending?
				if strings.LastIndex(digit, string(c)+a.substr) == len(digit)-(len(a.substr)+1) {
					newStr := string(c) + a.substr
					if newStr == digit {
						last = a.digit
						break lineloop2
					}
					// effectively update
					active.PushFront(Active{
						substr: newStr,
						digit:  a.digit,
					})
				}
				elementsToRemove = append(elementsToRemove, e)
			}
			for _, e := range elementsToRemove {
				active.Remove(e)
			}

			// Then just see if we're starting something new
			for i, digit := range digitWords {
				if strings.LastIndex(digit, string(c)) == len(digit)-1 {
					active.PushBack(Active{
						substr: string(c),
						digit:  i + 1,
					})
				}
			}
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
	sum1 := 0
	sum2 := 0

	for scanner.Scan() {
		line := scanner.Text()

		part1Res := processLine(line)
		part2Res := processLine2(line)

		sum1 += part1Res
		sum2 += part2Res
	}

	fmt.Println("Part 1:", sum1)
	fmt.Println("Part 2:", sum2)
}
