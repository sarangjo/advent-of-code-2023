#lang racket

(define (part1 filename)
    ; set up rock positions as 0 for each column
    (define rock-positions (make-vector (string-length (call-with-input-file filename
                (lambda (in)
                (read-line in)))) 0))

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

(define (print-grid grid)
    (for ([row (in-vector grid)])
        (printf "~a\n" row))
    (printf "\n"))

(define (cycle grid)
    (print-grid grid)

    ; Move north
    (for ([j (in-range (vector-length grid))])
        (for/fold ([destination 0]) ([i (in-naturals)] [row (in-vector grid)])
            (cond
                [(char=? (string-ref row j) #\O)
                    (string-set! (vector-ref grid destination) j #\O)
                    (unless (= destination i)
                        (string-set! (vector-ref grid i) j #\.))
                    (add1 destination)]
                [(char=? (string-ref row j) #\#)
                    (add1 i)]
                [else destination])))

    (print-grid grid)

    ; Move west
    (for ([i (in-naturals)] [row (in-vector grid)])
        (for/fold ([destination 0]) ([j (in-naturals)] [cell (in-string row)])
            (cond
                [(char=? cell #\O)
                    (string-set! (vector-ref grid i) destination #\O)
                    (unless (= destination j)
                        (string-set! (vector-ref grid i) j #\.))
                    (add1 destination)]
                [(char=? cell #\#)
                    (add1 j)]
                [else destination])))

    (print-grid grid)

    ; Move south
    (for ([j (in-range (vector-length grid))])
        (for/fold ([destination (sub1 (vector-length grid))]) ([i (in-range (sub1 (vector-length grid)) -1 -1)])
            ; (printf "i ~a j ~a destination ~a\n" i j destination)
            (cond
                [(char=? (string-ref (vector-ref grid i) j) #\O)
                    (string-set! (vector-ref grid destination) j #\O)
                    (unless (= destination i)
                        (string-set! (vector-ref grid i) j #\.))
                    (sub1 destination)]
                [(char=? (string-ref (vector-ref grid i) j) #\#)
                    (sub1 i)]
                [else destination])))

    (print-grid grid)

    ; Move east
    (for ([i (in-naturals)] [row (in-vector grid)])
        (for/fold ([destination (sub1 (vector-length grid))]) ([j (in-range (sub1 (vector-length grid)) -1 -1)])
            (cond
                [(char=? (string-ref row j) #\O)
                    (string-set! (vector-ref grid i) destination #\O)
                    (unless (= destination j)
                        (string-set! (vector-ref grid i) j #\.))
                    (sub1 destination)]
                [(char=? (string-ref row j) #\#)
                    (sub1 j)]
                [else destination])))

    (print-grid grid)

    ; Don't return anything... or return grid maybe?
    (void))

(define (part2 filename)
    ; (printf "part1: ~a\n" (part1 "day14.txt"))
    (define grid (list->vector (file->lines "sample14.txt")))
    (cycle grid))
