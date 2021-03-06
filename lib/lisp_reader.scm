;; -*- Mode: Irken -*-

;; XXX consider rewriting with more experience

;; XXX: for debug info:
;; 1) attach path/line/pos info to each symbol (this should be enough for most debugging)
;; but another approach might be to
;; 2) add a (sexp:pos ...) arm that can be inserted literally anywhere in a sexp,
;;   and ignored by most code.
;;
;; #2 seems much more lispy, and feels cleaner. fingers crossed.
;; also, I think #2 could push pos info into node records pretty easily.
;; [and it should be an optional feature of `read`]

;; ------------------------------

(define hex-map
  (alist/make
   (#\0 0) (#\1 1) (#\2 2) (#\3 3) (#\4 4) (#\5 5) (#\6 6) (#\7 7) (#\8 8) (#\9 9)
   (#\a 10) (#\b 11) (#\c 12) (#\d 13) (#\e 14) (#\f 15)
   (#\A 10) (#\B 11) (#\C 12) (#\D 13) (#\E 14) (#\F 15)
   ))

(define dec-map
  (alist/make
   (#\0 0) (#\1 1) (#\2 2) (#\3 3) (#\4 4) (#\5 5) (#\6 6) (#\7 7) (#\8 8) (#\9 9)
   ))

(define oct-map
  (alist/make
   (#\0 0) (#\1 1) (#\2 2) (#\3 3) (#\4 4) (#\5 5) (#\6 6) (#\7 7)
   ))

(define (reader path read-char)

  (let ((char #\eof) ;; one-character buffer
	(line 1)
	(pos 1))

    (define (read-error0 msg)
      (printf "\nread error: file= " path " line " (int line) ":" (int pos) ".\n")
      (error msg))

    (define (read-error1 msg ob)
      (printf "\nread error: file= " path " line " (int line) ":" (int pos) ".\n")
      (error1 msg ob))

    (define (peek)
      (if (eq? char #\eof)
	  (set! char (read-char))
	  #u)
      char)

    (define (next)
      (let ((result char))
	(if (eq? result #\newline)
	    (begin (set! line (+ line 1))
		   (set! pos 0))
	    (set! pos (+ 1 pos)))
	(set! char (read-char))
	result))

    (define (skip-peek)
      (next)
      (peek)
      )

    (define skip-comment
      #\return  -> #u
      #\newline -> #u
      _         -> (skip-comment (skip-peek))
      )

    (define (skip-whitespace)
      (let loop ((ch (peek)))
	(cond ((eq? ch #\eof) #u)
	      ((eq? ch #\;) (skip-comment (skip-peek)) (loop (peek)))
	      ((whitespace? ch) (loop (skip-peek)))
	      (else #u))))

    ;; very tricky, using a state machine
    (define (read-atom)
      (let ((state 0)
	    (dot-count 0)
	    (ch #\0))
	(let loop ((result '()))
	  (set! ch (peek))
	  (if (eq? ch #\.)
	      (set! dot-count (+ dot-count 1)))
	  (set! state
		(match state with
		  0 -> (cond ((eq? ch #\eof) 4)
			     ((eq? ch #\-) 1)
			     ((digit? ch) 2)
			     ((delim? ch) 7)
			     (else 3))
		  1 -> (cond ((eq? ch #\eof) 5)
			     ((delim? ch) 5)
			     ((digit? ch) 2)
			     (else 3))
		  2 -> (cond ((eq? ch #\eof) 6)
			     ((delim? ch) 6)
			     ((digit? ch) 2)
			     (else 3))
		  3 -> (cond ((eq? ch #\eof) 5)
			     ((delim? ch) 5)
			     (else 3))
		  _ -> (impossible)))
	  (cond ((< state 4) (loop (list:cons (next) result))) ;; non-final
		((= state 4) (read-error1 "unexpected end-of-file" path)) ;; error final
		(else ;; all other finals: 5,6,7
		 ;; single-character - for #\A
		 (if (= state 7) (set! result (list:cons (next) result)))
		 (:atom (list->string (reverse result)) ;; result string
			(= state 6)			;; number?
			(length result)			;; #chars
			dot-count))))))			;; #dots

    (define (dotted-symbol s n)
      ;; handle dots in a symbol
      ;; as a special case, allow all-dots symbols (like '...) through unscathed
      (if (= n (string-length s))
	  (sexp:symbol (string->symbol s))
	  (let loop ((parts (reverse (string-split s #\.))))
	    ;; a.b.c => (get (get a b) c)
	    (match parts with
	      ;; c b a
	      (base)        -> (sexp:symbol (string->symbol base))
	      (attr . rest) -> (sexp:attr (loop rest) (string->symbol attr))
	      ()            -> (impossible)
	      ))))

    (define (read-symbol)
      (match (read-atom) with
	(:atom sym #t _ _) -> (read-error1 "expected symbol" sym)
	(:atom sym #f _ 0) -> (string->symbol sym)
	(:atom sym #f _ _) -> (read-error1 "no dots allowed in constructor names" sym)
	))

    (define (read1)
      (skip-whitespace)
      (let ((ch (peek)))
	(match ch with
	  #\eof -> (read-error1 "unexpected end of file" 0)
	  #\(   -> (sexp:list (read-list))
	  #\{   -> (read-record)
	  #\"   -> (read-string)
	  #\'   -> (begin (next) (sexp (sexp:symbol 'quote) (read)))
	  #\,   -> (begin (next) (sexp (sexp:symbol 'comma) (read)))
	  #\:   -> (begin (next) (sexp:cons 'nil (read-symbol)))
	  #\#   -> (begin
		     (next)
		     (set! ch (peek))
		     (match ch with
		       #\\ -> (begin
				(next) ;; skip backslash
				(match (read-atom) with
				   (:atom atom _ 1 _)      -> (sexp:char (string-ref atom 0))
				   (:atom "newline" _ _ _) -> (sexp:char #\newline)
				   (:atom "space" _ _ _)   -> (sexp:char #\space)
				   (:atom "return" _ _ _)  -> (sexp:char #\return)
				   (:atom "tab" _ _ _)     -> (sexp:char #\tab)
				   (:atom "eof" _ _ _)     -> (sexp:char #\eof)
				   (:atom "nul" _ _ _)     -> (sexp:char #\nul)
				   x                       -> (read-error1 "bad character constant" x)
				   ))
		       ;; Bb
		       #\X -> (begin (next) (sexp:int (read-hex-int)))
		       #\x -> (begin (next) (sexp:int (read-hex-int)))
		       #\O -> (begin (next) (sexp:int (read-oct-int)))
		       #\o -> (begin (next) (sexp:int (read-oct-int)))
                       #\B -> (begin (next) (sexp:int (read-bin-int)))
                       #\b -> (begin (next) (sexp:int (read-bin-int)))
		       #\T -> (begin (next) (sexp:bool #t))
		       #\t -> (begin (next) (sexp:bool #t))
		       #\F -> (begin (next) (sexp:bool #f))
		       #\f -> (begin (next) (sexp:bool #f))
		       #\U -> (begin (next) (sexp:undef))
		       #\u -> (begin (next) (sexp:undef))
		       #\( -> (sexp:vector (read-list))
		       x   -> (read-error1 "syntax error" x)
		       ))
	  #\)   -> (read-error0 "unexpected close-paren")
	  _     -> (match (read-atom) with
		      (:atom chars #t n _) -> (sexp:int (read-int chars n))
		      (:atom chars #f _ 0) -> (sexp:symbol (string->symbol chars))
		      (:atom chars #f _ n) -> (dotted-symbol chars n)
		      )
	  )
	)
      )

    (define (read)
      (let ((result (read1)))
	(skip-whitespace)
	(let loop ((ch (peek)))
	  (match ch with
            ;; ------ postfix/infix extensions -----
	    ;; array-reference syntax
	    #\[ -> (let ((index (read-array-index)))
		     ;; primops take a parameter---------V
		     (set! result (sexp (sexp:symbol '%array-ref) (sexp:bool #f) result index))
                     (skip-whitespace)
                     (loop (peek)))
	    ;; infix colon syntax
	    #\: -> (begin
		     (next)
		     (match result (read) with
                       ;; normal constructor syntax
		       (sexp:symbol dt) (sexp:symbol alt) -> (sexp:cons dt alt)
                       ;; object/method syntax (ob::add arg0 ...)
		       ;; not forcing (sexp:symbol) on <ob> might allow 'builtin method calls'...
		       ;;  ob (sexp:cons 'nil method) -> (sexp:attr (sexp:attr ob 'o) method)
                       ob (sexp:cons 'nil method)
                       -> (sexp (sexp:symbol '%%obref) ob (sexp:symbol method))
		       ;; object : type syntax
		       ob type -> (sexp (sexp:symbol '%typed) ob type)))
		       ;;x y -> (read-error1 "colon syntax" (:pair x y))))
	    ;; infix 'get' syntax (i.e., attribute access)
	    ;; XXX this is disabled because it breaks symbols like '...
	    ;;   so we'll probably need to do the same hack as the python version
	    ;;#\. -> (begin (next) (sexp:attr result (read-symbol)))
	    _   -> result
	    ))))

    (define (read-array-index)
      (next) ;; skip open-left-bracket
      (let ((exp (read)))
	(skip-whitespace)
	(if (eq? (peek) #\])
	    (begin (next) exp)
	    (read-error0 "expected closing ]/} character"))))

    (define (read-hex-digit ch)
      (match (alist/lookup hex-map ch) with
	     (maybe:no) -> (read-error0 "bad hex digit")
	     (maybe:yes num) -> num))

    (define (read-hex-code)
      (let ((n0 (read-hex-digit (next)))
	    (n1 (read-hex-digit (next))))
	(ascii->char (+ (<< n0 4) n1))))

    (define (read-string)
      (next) ;; throw away the opening quote
      (let loop ((ch (peek))
		 (result '()))
	(match ch with
	  #\" -> (begin
		   (next) ;; throw away the close-quote
		   (sexp:string (list->string (reverse result))))
	  #\\ -> (begin
		   ;; ignore this backslash, read the next char
		   (next)
		   (set! ch (next))
		   (match ch with
		     #\x -> (let ((sch (read-hex-code))) (loop (peek) (list:cons sch result)))
		     #\X -> (let ((sch (read-hex-code))) (loop (peek) (list:cons sch result)))
		     #\r -> (loop (peek) (list:cons #\return result))
		     #\n -> (loop (peek) (list:cons #\newline result))
		     #\t -> (loop (peek) (list:cons #\tab result))
		     #\" -> (loop (peek) (list:cons #\" result))
		     #\\ -> (loop (peek) (list:cons #\\ result))
		     _   -> (read-error1 "bad backslash escape in string" result)
		     ))
	  _   -> (loop (skip-peek) (list:cons ch result))
	  )))

    (define (read-list)
      (next) ;; throw away the open paren
      (let loop ((result '()))
	(skip-whitespace)
        (cond ((eq? (peek) #\))
               (next) ;; throw away the close paren
               (reverse result))
              (else
               (loop (list:cons (read) result))))))

    (define (read-record)
      ;; { label=value label=value ...}
      (next)
      (let loop ((result '()))
	(skip-whitespace)
	(let ((p (peek)))
	  (if (eq? p #\})
	      (begin (next) (sexp:record (reverse result)))
	      (let ((name (read-name)))
		(cond ((eq? name '...)
		       (loop (list:cons (field:t name (sexp:bool #f)) result)))
		      (else
		       (skip-whitespace)
		       (if (not (eq? (peek) #\=))
			   (read-error1 "expected '=' in record literal" result)
			   (begin
			     (next)
			     (let ((val (read)))
			       (loop (list:cons (field:t name val) result))))))))
	      ))))

    (define (read-name)
      (let loop ((result '())
		 (ch (peek))
		 (dots #f))
	(cond ((or (field? ch) (eq? ch #\.))
	       (loop (list:cons ch result) (skip-peek) #f))
	      (else
	       (string->symbol (list->string (reverse result)))))))

    (define (read-int s n)
      (let ((neg? (eq? (string-ref s 0) #\-))
	    (start (if neg? 1 0)))
	(let loop ((i start)
		   (r 0))
	  (if (= i n)
	      (if neg? (- 0 r) r)
	      (match (alist/lookup dec-map (string-ref s i)) with
		(maybe:no) -> (read-error1 "bad decimal digit?" s)
		(maybe:yes digit) -> (loop (+ i 1) (+ (* r 10) digit)))
	      ))))

    (define (read-hex-int)
      (let ((neg? (eq? (peek) #\-)))
	(if neg? (begin (next) #u))
	(let loop ((r 0) (ch (peek)))
	  (match (alist/lookup hex-map ch) with
	    (maybe:yes digit) -> (loop (+ (* r 16) digit) (skip-peek))
	    (maybe:no) -> (if neg? (- 0 r) r)))))

    (define (read-oct-int)
      (let ((neg? (eq? (peek) #\-)))
	(if neg? (begin (next) #u))
	(let loop ((r 0) (ch (peek)))
	  (match (alist/lookup oct-map ch) with
	    (maybe:yes digit) -> (loop (+ (* r 8) digit) (skip-peek))
	    (maybe:no) -> (if neg? (- 0 r) r)))))

    (define (read-bin-int)
      (let ((neg? (eq? (peek) #\-)))
        (if neg? (begin (next) #u))
        (let loop ((r 0) (ch (peek)))
          (match ch with
            #\0 -> (loop (<< r 1) (skip-peek))
            #\1 -> (loop (logior (<< r 1) 1) (skip-peek))
            ch  -> (if neg? (- 0 r) r)))))

    (define (read-all)
      (let loop ((result '()))
	(skip-whitespace)
	(if (eq? (peek) #\eof)
	    (reverse result)
            (loop (list:cons (read) result)))
        ))

    (read-all)
    ))

(define (read-string s)
  (reader "<string>" (string-reader s)))

