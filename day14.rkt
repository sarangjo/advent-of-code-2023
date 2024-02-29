#lang racket

; returns line-number, total-weight, rock-count
(define (process-lines file line-number total-weight rock-count)
    ; scoped definition of the variable line, initialized to the first line
    (let ((line (read-line file 'any)))
        ; implicit base case
        (if (eof-object? line)
            (values 0 0 0)
            ; here we process line by line
            (for ([i (in-naturals)]
                  [c (in-string line)])
                ())
            (displayln line)
            (displayln line-number)
            (process-lines file (+ 1 line-number)))))

(define (part1 filename)
    ; set up rock positions as 0 for each column
    (define rock-positions (make-vector (string-length (call-with-input-file filename
                            (lambda (in)
                            (read-line in)))) 0))
    (display (vector-length rock-positions)))

    ; iterate through each line and accumulate
    (define in (open-input-file filename))
    (for/fold ([total-weight 0]
               [rock-count 0])
              ([line-number (in-naturals)]

               )

        )
    ; better than recursive?

(part1 "sample14.txt")
