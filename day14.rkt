#lang racket

(require racket/set)

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

    ; (printf "Line count ~a, Total weight ~a, rock count ~a\n" total-lines total-weight total-rock-count)

    ; We're calculating the weight by increasing line numbers 0...n-1; so to calculate actual weight
    ; we subtract from n*rock-count since each rock's weight is (n-w)
    (- (* total-lines total-rock-count) total-weight)
)

(define (print-grid grid)
    (for ([row (in-vector grid)])
        (printf "~a\n" row))
    (printf "\n"))

(define (do-cycle grid)
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

    ; Don't return anything... or return grid maybe?
    (void))

(define (get-rock-locs grid)
    (for*/set ([i (in-range (vector-length grid))]
               [j (in-range (string-length (vector-ref grid i)))]
               #:when (char=? (string-ref (vector-ref grid i) j) #\O))
        (cons i j)))

(define (calculate-load rock-locs row-count)
    (for/fold ([sum 0]) ([p (in-set rock-locs)]) (+ sum (- row-count (car p)))))

(define (part2 filename)
    (define grid (list->vector (file->lines filename)))

    ; set up first cycle
    (do-cycle grid)

    ; we don't have a clean list comprehension approach:
    ; - possible-cycle gets set only inside the inner for loop for the break condition
    (define possible-cycle 0)
    ; - full-rock-locs would be nice to accumulate, but we need to reference this list from inside the loop
    (define full-rock-locs (list (get-rock-locs grid)))

    ; while loop
    (for ([cycle (in-naturals 2)])
        ; body
        (do-cycle grid)
        (define rock-locs (get-rock-locs grid))

        ; (printf "Cycles completed: ~a. Full len ~a\n" cycle (length full-rock-locs))

        ; are we here?
        #:break (
            for/or ([i (in-range (sub1 cycle))])
                ; body
                (if (equal? (list-ref full-rock-locs (- cycle i 2)) rock-locs)
                    (begin (set! possible-cycle (add1 i)) #t)
                    #f))

        (set! full-rock-locs (append full-rock-locs (list rock-locs)))
    )

    ; (printf "possible cycle ~a\n" possible-cycle)

    ; now that we have the cycle, what's the offset into our full-rock-locs that our cycle begins?
    (define offset (- (length full-rock-locs) possible-cycle 1))
    ; cut off the offset from our overall 10^9 target
    (define adjusted-target (- 1000000000 offset))
    ; now, calculate the cycle within our range (in full-rock-locs) that matches our target
    (define match (remainder adjusted-target possible-cycle))
    ; calculate the load for that cycle (sub1 because we start at cycle 2)
    (calculate-load (list-ref full-rock-locs (sub1 (+ offset match))) (vector-length grid)))

; (printf "part1: ~a\n" (part1 "day14.txt"))
(printf "part2: ~a\n" (part2 "day14.txt"))
