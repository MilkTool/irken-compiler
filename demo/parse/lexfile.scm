;; -*- Mode: Irken -*-

(require "lib/basis.scm")
(require "lib/dfa/lexicon.scm")
(require "lib/parse/lexer.scm")

(if (< sys.argc 3)
    (begin (printf "\nLex a file, given a lexicon.\n\n")
           (printf "Usage: " sys.argv[0] " <lexicon.sg> <input-file>\n")
           (printf "    example: $ " sys.argv[0] " sexp-lex.sg sexp-lex.sg\n"))
    (let ((lexpath sys.argv[1])
          (lexfile (file/open-read lexpath))
          ;; read the parser spec as an s-expression
          (exp (reader lexpath (lambda () (file/read-char lexfile))))
          (lexicon (sexp->lexicon (car exp)))
          ;; convert the lexicon to a dfa
          (dfa0 (lexicon->dfa lexicon))
          ((labels dfa1) dfa0)
          ;; build a lexer from the dfa
          (lexer (dfa->lexer dfa0))
          ;; lex the given file
          (spath sys.argv[2])
          (sfile (file/open-read spath))
          (gen0 (file-char-generator sfile))
          (gen1 (make-lex-generator lexer gen0)))
      (for tok gen1
        (printf (sym tok.kind) " " (string tok.val) "\n"))
      ))
