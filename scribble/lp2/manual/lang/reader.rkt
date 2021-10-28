#lang s-exp syntax/module-reader
scribble/lp2/manual
#:read read-inside
#:read-syntax read-syntax-inside
#:whole-body-readers? #t
#:language-info (scribble-base-language-info)
#:info (scribble-base-info)

(require scribble/reader
         (only-in scribble/base/reader
                  scribble-base-info
                  scribble-base-language-info))

;; cf. https://github.com/racket/scribble/blob/master/scribble-lib/scribble/lp2.rkt
