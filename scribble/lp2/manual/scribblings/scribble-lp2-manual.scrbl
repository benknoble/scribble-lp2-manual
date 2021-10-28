#lang scribble/lp2/manual
@require[@for-label[(except-in scribble/lp2/manual #%module-begin)
                    scribble/manual
                    (only-in racket/base #%module-begin)]]

@title{Literate programming in style}
@author{D. Ben Knoble}

@(define scribble/lp/lang/lang2
   @hyperlink["https://github.com/racket/scribble/blob/master/scribble-lib/scribble/lp/lang/lang2.rkt"]{scribble/lp/lang/lang2})

@defmodulelang[scribble/lp2/manual]

The @racketmodname[scribble/lp2] language with @racketmodname[scribble/manual]
style. You must call @racket[title] for the new style to be applied, but really,
what program document doesn't have a title?

@section{About this document}

This document is written in @racketmodname[scribble/lp2/manual] and thus serves as both
test and example for the language. This document also embeds an implementation
of the language, which the main sources use to expose the language.

@itemlist[

    @item{If it renders at all, then it successfully integrates with
    @other-doc['(lib "scribblings/scribble/scribble.scrbl")].}

    @item{If it renders in the style of @racketmodname[scribble/manual], then it
    successfuly applies the style.}

    @item{If it can be run as a racket program and reports @racket[2], then it
    successfully integrates with @racketmodname[scribble/lp2]. See
    @racket[<main-module>].}

]

This @racket[chunk] is the main-module that produces @racket[2] when this code
is run with @code{racket <source>.scrbl}.

@chunk[<main-module>
        (module+ main (+ 1 1))]

@section{Building @racketmodname[scribble/lp2/manual]}

Let's walkthrough how the language is built as an exercise in using the
language.

First, we have to figure out how to apply the @racketmodname[scribble/manual]
style to an existing @racketmodname[scribble/lp2] document. Since @racket[title]
takes @racket[#:style] to control the document's style, we'll use that with
@racket[manual-doc-style] to get what we want:

@codeblock|{
#lang scribble/lp2

@(require scribble/manual)

@title[#:style manual-doc-style]{My program}
}|

@margin-note{Thankfully, @racketmodname[scribble/manual] @racket[provide]s
@racket[manual-doc-style], which we know by looking at
@secref["manual-render-style" #:doc '(lib "scribblings/scribble/scribble.scrbl")].}

This works, but we have to do it for any @racketmodname[scribble/lp2] program we
want to render with style. Let's make a language to fix this.

@subsection{Reader}

All @hash-lang[]s need a reader, so here's ours:

@chunk[<reader>
        (module reader syntax/module-reader
          (code:comment "Name of the expander module")
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

          (code:comment @#,elem{cf. @url{https://github.com/racket/scribble/blob/master/scribble-lib/scribble/lp2.rkt}}))]

We base it on the existing scribble readers, such as that of
@racketmodname[scribble/lp2], but we use our own expander module.

@subsection{Expander}

Next we provide a module implementing the expander:

@chunk[<expander>
        (module expander racket/base
          <expander-provides>
          <expander-impl>)]

The expander needs to provide base bindings for the language, including a
@racket[#%module-begin] syntax. We'll re-use bindings
from @|scribble/lp/lang/lang2|, since that what
@racketmodname[scribble/lp2] uses, but we'll supplement with our own
@racket[#%module-begin]:

@chunk[<expander-provides>
        (provide (except-out (all-from-out scribble/lp/lang/lang2)
                             lp2:mb)
                 (rename-out [mb #%module-begin]))]

Our @racket[#%module-begin] needs to force @racket[title] to use
@racket[manual-doc-style], then invoke @racket[#%module-begin] from
@|scribble/lp/lang/lang2|:

@chunk[<expander-impl>
        (require (rename-in scribble/lp/lang/lang2 [#%module-begin lp2:mb])
                 syntax/parse/define)

        (define-syntax-parse-rule (mb body ...)
          (lp2:mb
            (define title
              (code:comment "Avoid polluting the module-body with require's by using dynamic-require.")
              (code:comment "")
              (code:comment "But it's odd that we still have to bind title, since we know title will")
              (code:comment "be bound by the (require scribble/manual) in the expansion of lp2:mb.")
              (code:comment "Perhaps hygiene is in the way? (require scribble/manual) in this module")
              (code:comment "doesn't work either, though I suspect the strip-context call of being")
              (code:comment "at fault at that point.")
              (let ([curryr (dynamic-require 'racket/function 'curryr)]
                    [title (dynamic-require 'scribble/manual 'title)])
                (curryr title #:style manual-doc-style)))
            body ...))]

@section{Putting it all together}

That's it! The actual implementation uses files that provide exactly this code.
Because this is a literate program, we @italic{could} @racket[require] its
submodules to get a reader or expander. If the actual language implementation
did that, though, there would be a circular dependency! In order to understand
the source of this document, we consult the language definition, which requires
this document to compile, @italic{etc.}, @italic{ad infinitum}. So we won't do
that, though it is a neat trick (@italic{e.g.},
@hyperlink["https://github.com/mbutterick/pollen-tfl"]{pollen-tfl}
implements part of its codebase as a literal program).

Put the code in the following order:

@chunk[<*>
        <reader>
        <expander>
        <main-module>]
