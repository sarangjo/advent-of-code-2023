#lang racket

; returns line-number, total-weight, rock-count
(define (process-lines file rock-positions line-number total-weight rock-count)
    ; scoped definition of the variable line, initialized to the first line
    (let ((line (read-line file 'any)))
        (if (eof-object? line)
            ; implicit base case
            (values 0 0 0)
            (begin
                ; here we process line by line
                (for ([col (in-naturals)]
                      [c (in-string line)])
                    ; process each character
                    (cond
                        [(= c #\O)
                            ; bump this position, register this rock
                        ]
                        )
                    (printf "Char: ~a\n" c))
                (process-lines file rock-positions (+ 1 line-number) total-weight rock-count)))))

(define (part1 filename)
    ; set up rock positions as 0 for each column
    (define rock-positions (make-vector (string-length (call-with-input-file filename
                (lambda (in)
                (read-line in)))) 0))
    (printf "Vector length: ~a\n" (vector-length rock-positions))

    ; start recursion
    (define in (open-input-file filename))
    (printf "Result: ~a\n" (process-lines in rock-positions 0 0 0))
)

(part1 "sample14.txt")
