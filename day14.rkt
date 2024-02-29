#lang racket

(define (part1 filename)
    ; set up rock positions as 0 for each column
    (define rock-positions (make-vector (string-length (call-with-input-file filename
                (lambda (in)
                (read-line in)))) 0))
    (printf "Vector length: ~a\n" (vector-length rock-positions))

    ; start iteration
    (define in (open-input-file filename))

    (define-values (total-lines total-weight total-rock-count) (
        for/fold (
                ; accumulators
                [line-number 0]
                [total-weight 0]
                [rock-count 0])
                ; top-level iterator
                ([line (in-lines in)]
                 #:break (eof-object? line))
            ; body of for-loop
            (define-values (line-weight line-rock-count) (
                for/fold (
                    ; accumulators
                    [weight 0]
                    [rocks 0])
                    ; inner iterator
                    ([col (in-range (string-length line))])
                    ; return
                    (values
                        ; weight
                        (cond
                            [(char=? (string-ref line col) #\O)
                                (vector-set! rock-positions col (add1 (vector-ref rock-positions col)))
                                (+ weight (sub1 (vector-ref rock-positions col)))]
                            [(char=? (string-ref line col) #\#)
                                (vector-set! rock-positions col (add1 line-number))
                                weight]
                            [else weight])
                        ; rock count
                        (cond [(char=? (string-ref line col) #\O) (add1 rocks)] [else rocks])
                    )
                ))

            ; return
            (values (add1 line-number) (+ line-weight total-weight) (+ line-rock-count rock-count))
    ))

    (printf "Line count ~a, Total weight ~a, rock count ~a\n" total-lines total-weight total-rock-count)

    ; We're calculating the weight by increasing line numbers 0...n-1; so to calculate actual weight
    ; we subtract from n*rock-count since each rock's weight is (n-w)
    (- (* total-lines total-rock-count) total-weight)
)

(printf "part1: ~a\n" (part1 "day14.txt"))
