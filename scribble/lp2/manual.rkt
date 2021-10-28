#lang racket/base

(provide (except-out (all-from-out scribble/lp/lang/lang2)
                     lp2:mb)
         (rename-out [mb #%module-begin]))

(require (rename-in scribble/lp/lang/lang2 [#%module-begin lp2:mb])
         syntax/parse/define)

(define-syntax-parse-rule (mb body ...)
  (lp2:mb
    (define title
      ;; Avoid polluting the module-body with require's by using dynamic-require.
      ;;
      ;; But it's odd that we still have to bind title, since we know title will
      ;; be bound by the (require scribble/manual) in the expansion of lp2:mb.
      ;; Perhaps hygiene is in the way? (require scribble/manual) in this module
      ;; doesn't work either, though I suspect the strip-context call of being
      ;; at fault at that point.
      (let ([curryr (dynamic-require 'racket/function 'curryr)]
            [title (dynamic-require 'scribble/manual 'title)])
        (curryr title #:style manual-doc-style)))
    body ...))
