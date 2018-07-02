;;
;;  css-lexer  -  CSS lexer
;;
;;  Copyright 2017,2018 Thomas de Grivel <thoxdg@gmail.com>
;;
;;  Permission to use, copy, modify, and distribute this software for any
;;  purpose with or without fee is hereby granted, provided that the above
;;  copyright notice and this permission notice appear in all copies.
;;
;;  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;;  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;;  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
;;  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;;  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;;  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
;;  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;;

(in-package :common-lisp)

(defpackage :css-lexer
  (:use :cl-stream
        :common-lisp
        :matcher-stream
        :token-stream)
  #.(cl-stream:shadowing-import-from)
  (:export
   #:[-token
   #:]-token
   #:at-keyword-token
   #:at-keyword-token
   #:cdc-token
   #:cdc-token
   #:cdo-token
   #:cdo-token
   #:colon-token
   #:column-token
   #:column-token
   #:comma-token
   #:comment-token
   #:consume-token
   #:css-lexer
   #:css-token
   #:dash-match-token
   #:dash-match-token
   #:delim-token
   #:dimension-token
   #:dimension-token
   #:eof-token
   #:function-token
   #:function-token
   #:hash-token
   #:ident-token
   #:ident-token
   #:identified-token
   #:include-match-token
   #:include-match-token
   #:left-paren-token
   #:match-comment
   #:match-digit
   #:match-digit+
   #:match-escape
   #:match-hex-digit
   #:match-ident-char
   #:match-ident-char*
   #:match-newline
   #:match-non-printable
   #:match-string
   #:match-string-char
   #:match-url-unquoted
   #:match-url-unquoted-char
   #:match-whitespace
   #:match-ws*
   #:number-token
   #:number-token
   #:numbered-token
   #:percentage-token
   #:percentage-token
   #:prefix-match-token
   #:prefix-match-token
   #:printable
   #:right-paren-token
   #:semicolon-token
   #:string-token
   #:string-token
   #:substring-match-token
   #:substring-match-token
   #:suffix-match-token
   #:suffix-match-token
   #:token
   #:token-character
   #:token-ident
   #:token-line
   #:token-string
   #:unicode-range-token
   #:unicode-range-token
   #:url-token
   #:url-token
   #:whitespace-token
   #:whitespace-token
   #:{-token
   #:}-token
   ))
