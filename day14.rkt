#lang racket

(define total-weight 0)
(define rock-count 0)

; (define (process-lines file line-number)
;     ; scoped definition of the variable line, initialized to the first line
;     (let ((line (read-line file 'any)))
;         (unless (eof-object? line)
;             ; here we process line by line
;             (for ([i (in-naturals)]
;                   [c (in-string line)])
;                 ())
;             (displayln line)
;             (displayln line-number)
;             (process-lines file (+ 1 line-number)))))

(define (part1 filename)
    ; set up rock positions as 0 for each column
    (define rock-positions (make-vector (string-length (call-with-input-file filename
                            (lambda (in)
                            (read-line in)))) 0))
    (display (vector-length rock-positions)))

(part1 "sample14.txt")
