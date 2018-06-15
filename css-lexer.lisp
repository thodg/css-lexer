
(in-package :css-lexer)

(defclass css-lexer (lexer) ())

(defgeneric match-comment (lexer))
(defgeneric match-newline (lexer))
(defgeneric match-whitespace (lexer))
(defgeneric match-hex-digit (lexer))
(defgeneric match-escape (lexer))
(defgeneric whitespace-token (lexer))
(defgeneric match-ws* (lexer))
(defgeneric match-ident-char (lexer))
(defgeneric match-ident-char* (lexer))
(defgeneric ident-token (lexer))
(defgeneric function-token (lexer))
(defgeneric at-keyword-token (lexer))
(defgeneric match-string-char (lexer end-char))
(defgeneric match-string (lexer end-char))
(defgeneric string-token (lexer))
(defgeneric match-non-printable (lexer))
(defgeneric match-url-unquoted-char (lexer))
(defgeneric match-url-unquoted (lexer))
(defgeneric url-token (lexer))
(defgeneric match-digit (lexer))
(defgeneric match-digit+ (lexer))
(defgeneric number-token (lexer))
(defgeneric dimension-token (lexer))
(defgeneric percentage-token (lexer))
(defgeneric unicode-range-token (lexer))
(defgeneric include-match-token (lexer))
(defgeneric dash-match-token (lexer))
(defgeneric prefix-match-token (lexer))
(defgeneric suffix-match-token (lexer))
(defgeneric substring-match-token (lexer))
(defgeneric column-token (lexer))
(defgeneric cdo-token (lexer))
(defgeneric cdc-token (lexer))
(defgeneric consume-token (lexer))

(defclass css-token (token) ())
(defclass printable (token) ())

(defclass identified-token (css-token)
  ((ident :initarg :ident
	  :reader token-ident
	  :type ident-token)))

(defclass comment-token (css-token) ())
(defclass whitespace-token (css-token) ())
(defclass ident-token (printable css-token) ())
(defclass function-token (identified-token) ())
(defclass at-keyword-token (identified-token) ())
(defclass hash-token (printable css-token) ())
(defclass string-token (css-token) ())

(defclass url-token (identified-token)
  ((url :initarg :url
	:reader token-url
	:type token)))

(defclass number-token (printable css-token) ())

(defclass numbered-token (css-token)
  ((number :initarg :number
	   :reader token-number
	   :type number-token)))

(defclass dimension-token (identified-token numbered-token) ())
(defclass percentage-token (numbered-token) ())
(defclass unicode-range-token (css-token) ())
(defclass include-match-token (css-token) ())
(defclass dash-match-token (css-token) ())
(defclass prefix-match-token (css-token) ())
(defclass suffix-match-token (css-token) ())
(defclass substring-match-token (css-token) ())
(defclass column-token (css-token) ())
(defclass cdo-token (css-token) ())
(defclass cdc-token (css-token) ())
(defclass left-paren-token (css-token) ())
(defclass right-paren-token (css-token) ())
(defclass comma-token (css-token) ())
(defclass colon-token (css-token) ())
(defclass semicolon-token (css-token) ())
(defclass [-token (css-token) ())
(defclass ]-token (css-token) ())
(defclass {-token (css-token) ())
(defclass }-token (css-token) ())
(defclass eof-token (css-token) ())
(defclass delim-token (printable css-token) ())

(defmethod comment-token ((lx lexer))
  (push-token lx)
  (if (match lx "/*")
      (progn (match-until lx "*/")
	     (make-token lx 'comment-token))
      (discard-token lx)))

(let ((rn (coerce '(#\Return #\Newline) 'string)))
  (defmethod match-newline ((lx lexer))
    (or (match lx #\Newline)
        (match lx rn)
        (match lx #\Return)
        (match lx #\Linefeed))))

(defmethod match-whitespace ((lx lexer))
  (or (match lx #\Space)
      (match lx #\Tab)
      (match-newline lx)))

(defmethod match-hex-digit ((lx lexer))
  (let ((c (the fixnum (lexer-match-char lx 0))))
    (when (or (<= (char-code #\0) c (char-code #\9))
	      (<= (char-code #\a) c (char-code #\f))
	      (<= (char-code #\A) c (char-code #\F)))
      (incf (the fixnum (lexer-match-start lx))))))
       
(defmethod match-escape ((lx lexer))
  (match-sequence lx
    (and (match lx #\\)
	 (or (when (match-times lx #'match-hex-digit 1 6)
	       (match-whitespace lx)
	       (lexer-match-start lx))
	     (when (not (match-newline lx))
	       (lexer-match-start lx))))))

(defmethod whitespace-token ((lx lexer))
  (push-token lx)
  (if (match-times lx #'match-whitespace 1 nil)
      (make-token lx 'whitespace-token)
      (discard-token lx)))

(defmethod match-ws* ((lx lexer))
  (match-option lx #'whitespace-token))

(defmethod match-ident-char ((lx lexer))
  (or (match-escape lx)
      (let ((c (the character (lexer-match-char lx 0))))
	(when (or (char<= #\a c #\z)
		  (char<= #\A c #\Z)
		  (char<= #\0 c #\9)
		  (char=  #\_ c)
		  (char=  #\- c)
		  (<  #x007F (char-code c)))
	  (incf (the fixnum (lexer-match-start lx)))))))

(defmethod match-ident-char* ((lx lexer))
  (match-times lx #'match-ident-char 0 nil))

(defmethod ident-token ((lx lexer))
  (match-sequence lx
    (push-token lx)
    (match lx #\-)
    (cond ((or (match-escape lx)
	       (let ((c (the character (lexer-match-char lx 0))))
		 (when (or (char<= #\a c #\z)
			   (char<= #\A c #\Z)
			   (char=  #\_ c)
			   (<  #x007F (char-code c)))
		   (incf (the fixnum (lexer-match-start lx))))))
	   (match-ident-char* lx)
	   (make-token lx 'ident-token))
	  (t
	   (discard-token lx)))))

(defmethod function-token ((lx lexer))
  (match-sequence lx
    (push-token lx)
    (let ((ident (ident-token lx)))
      (if (and ident (match lx #\())
	  (make-token lx 'function-token :ident ident)
	  (discard-token lx)))))

(defmethod at-keyword-token ((lx lexer))
  (match-sequence lx
    (push-token lx)
    (if (match lx #\@)
	(let ((ident (ident-token lx)))
	  (if ident
	      (make-token lx 'at-keyword-token :ident ident)
	      (discard-token lx)))
	(discard-token lx))))

(defmethod hash-token ((lx lexer))
  (match-sequence lx
    (push-token lx)
    (if (match lx #\#)
	(and (match-ident-char* lx)
	     (make-token lx 'hash-token))
	(discard-token lx))))

(defgeneric string-token-string (string-token))

(defmethod string-token-string ((s string-token))
  (let ((string (token-string s)))
    (declare (type (vector character) string))
    (subseq string 1 (1- (length string)))))

(defmethod match-string-char ((lx lexer) (end-char character))
  (or (match-sequence lx
	(and (match lx #\\)
	     (match-newline lx)))
      (match-escape lx)
      (match-not lx (lambda (lx)
                      (or (match lx end-char)
                          (match lx #\\)
                          (match-newline lx))))))

(defmethod match-string ((lx lexer) (end-char character))
  (match-sequence lx
    (and (match lx end-char)
         (match-times lx (lambda (lx) (match-string-char lx end-char)) 0 nil)
         (match lx end-char))))

(defmethod string-token ((lx lexer))
  (push-token lx)
  (if (or (match-string lx #\")
	  (match-string lx #\'))
      (make-token lx 'string-token)))

(defmethod match-non-printable ((lx lexer))
  (let ((c (the fixnum (lexer-match-char lx 0))))
    (when (or (<= #x0000 c #x0008)
	      (=  #x000B c)
	      (<= #x000E c #x001F)
	      (=  #x007F c))
      (incf (the fixnum (lexer-match-start lx))))))

(defmethod match-url-unquoted-char ((lx lexer))
  (or (match-escape lx)
      (match-not lx
	(or (match lx #\")
	    (match lx #\')
	    (match lx #\()
	    (match lx #\))
	    (match lx #\\)
	    (match-whitespace lx)
	    (match-non-printable lx)))))

(defmethod match-url-unquoted ((lx lexer))
  (push-token lx)
  (if (match-times lx #'match-url-unquoted-char 1 nil)
      (make-token lx 'token)
      (discard-token lx)))

(defmethod url-token ((lx lexer))
  (push-token lx)
  (or (match-sequence lx
	(let ((ident (ident-token lx)))
	  (and (string= "url" (the (vector character)
                                   (token-string ident)))
	       (match lx #\()
	       (match-ws* lx)
	       (let ((url (or (string-token lx)
			      (match-url-unquoted lx))))
		 (match-ws* lx)
		 (when (match lx #\))
		   (make-token lx 'url-token :ident ident :url url))))))
      (discard-token lx)))

(defmethod match-digit ((lx lexer))
  (let ((c (the character (lexer-match-char lx 0))))
    (when (char<= #\0 c #\9)
      (incf (the fixnum (lexer-match-start lx))))))

(defmethod match-digit+ ((lx lexer))
  (match-times lx #'match-digit 1 nil))

(defmethod number-token ((lx lexer))
  (push-token lx)
  (if (match-sequence lx
	(and (or (match lx #\-)
		 (match lx #\+)
		 t)
	     (or (match-sequence lx
		   (and (match lx #\.)
			(match-digit+ lx)))
		 (match-sequence lx
		   (match-digit+ lx)
		   (match lx #\.)
		   (match-digit+ lx))
		 (match-digit+ lx))
	     (or (match-sequence lx
		   (and (or (match lx #\E)
			    (match lx #\e))
			(or (match lx #\-)
			    (match lx #\+)
			    t)
			(match-digit+ lx)))
		 (lexer-match-start lx))))
      (make-token lx 'number-token)
      (discard-token lx)))

(defmethod dimension-token ((lx lexer))
  (push-token lx)
  (or (match-sequence lx
	(let ((number (number-token lx)))
	  (when number
	    (let ((ident (ident-token lx)))
	      (when ident
		(make-token lx 'dimension-token
			    :number number
			    :ident ident))))))
      (discard-token lx)))

(defmethod percentage-token ((lx lexer))
  (push-token lx)
  (or (match-sequence lx
	(let ((number (number-token lx)))
	  (when number
	    (when (match lx #\%)
	      (make-token lx 'percentage-token
			  :number number)))))
      (discard-token lx)))

(defmethod unicode-range-token ((lx lexer))
  (push-token lx)
  (or (match-sequence lx
	(and (or (match lx #\u)
		 (match lx #\U))
	     (match lx #\+)
	     (or (match-sequence lx
		   (and (match-times lx #'match-hex-digit 1 6)
			(match lx #\-)
			(match-times lx #'match-hex-digit 1 6)))
		 (match-sequence lx
		   (let ((start (the fixnum (lexer-match-start lx))))
		     (and (match-times lx #'match-hex-digit 0 5)
			  (let ((digits (- (the fixnum
                                                (lexer-match-start lx))
                                           start)))
                            (declare (type fixnum digits))
			    (match-times lx (lambda (lx) (match lx #\?))
					 1 (the fixnum (- 6 digits)))))))
		 (match-times lx #'match-hex-digit 1 6))
	     (make-token lx 'unicode-range-token)))
      (discard-token lx)))

(defmethod include-match-token ((lx lexer))
  (push-token lx)
  (if (match lx "~=")
      (make-token lx 'include-match-token)
      (discard-token lx)))

(defmethod dash-match-token ((lx lexer))
  (push-token lx)
  (if (match lx "|=")
      (make-token lx 'dash-match-token)
      (discard-token lx)))

(defmethod prefix-match-token ((lx lexer))
  (push-token lx)
  (if (match lx "^=")
      (make-token lx 'prefix-match-token)
      (discard-token lx)))

(defmethod suffix-match-token ((lx lexer))
  (push-token lx)
  (if (match lx "$=")
      (make-token lx 'suffix-match-token)
      (discard-token lx)))

(defmethod substring-match-token ((lx lexer))
  (push-token lx)
  (if (match lx "*=")
      (make-token lx 'substring-match-token)
      (discard-token lx)))

(defmethod column-token ((lx lexer))
  (push-token lx)
  (if (match lx "||")
      (make-token lx 'column-token)
      (discard-token lx)))

(defmethod cdo-token ((lx lexer))
  (push-token lx)
  (if (match lx "<!--")
      (make-token lx 'cdo-token)
      (discard-token lx)))

(defmethod cdc-token ((lx lexer))
  (push-token lx)
  (if (match lx "-->")
      (make-token lx 'cdc-token)
      (discard-token lx)))

(defmethod left-paren-token ((lx lexer))
  (push-token lx)
  (if (match lx #\()
      (make-token lx 'left-paren-token)
      (discard-token lx)))

(defmethod right-paren-token ((lx lexer))
  (push-token lx)
  (if (match lx #\))
      (make-token lx 'right-paren-token)
      (discard-token lx)))

(defmethod comma-token ((lx lexer))
  (push-token lx)
  (if (match lx #\,)
      (make-token lx 'comma-token)
      (discard-token lx)))

(defmethod colon-token ((lx lexer))
  (push-token lx)
  (if (match lx #\:)
      (make-token lx 'colon-token)
      (discard-token lx)))

(defmethod semicolon-token ((lx lexer))
  (push-token lx)
  (if (match lx #\;)
      (make-token lx 'semicolon-token)
      (discard-token lx)))

(defmethod [-token ((lx lexer))
  (push-token lx)
  (if (match lx #\[)
      (make-token lx '[-token)
      (discard-token lx)))

(defmethod ]-token ((lx lexer))
  (push-token lx)
  (if (match lx #\])
      (make-token lx ']-token)
      (discard-token lx)))

(defmethod {-token ((lx lexer))
  (push-token lx)
  (if (match lx #\{)
      (make-token lx '{-token)
      (discard-token lx)))

(defmethod }-token ((lx lexer))
  (push-token lx)
  (if (match lx #\})
      (make-token lx '}-token)
      (discard-token lx)))

(defmethod eof-token ((lx lexer))
  (push-token lx)
  (cond ((and (lexer-input-ended lx)
              (= (lexer-match-start lx)
                 (fill-pointer (lexer-buffer lx))))
         (setf (lexer-eof-p lx) t)
         (make-token lx 'eof-token))
        (t
         (discard-token lx))))

(defmethod delim-token ((lx lexer))
  (push-token lx)
  (lexer-input-n lx 1)
  (incf (the fixnum (lexer-match-start lx)))
  (make-token lx 'delim-token))

;;  CSS lexer

(defmethod stream-element-type ((lx css-lexer))
  'css-token)

(defmethod lexer-token ((lx css-lexer))
  (or (eof-token lx)
      (whitespace-token lx)
      (string-token lx)
      (hash-token lx)
      (suffix-match-token lx)
      (left-paren-token lx)
      (right-paren-token lx)
      (substring-match-token lx)
      (number-token lx)
      (comma-token lx)
      (cdc-token lx)
      (comment-token lx)
      (colon-token lx)
      (semicolon-token lx)
      (cdo-token lx)
      (at-keyword-token lx)
      ([-token lx)
      (]-token lx)
      (prefix-match-token lx)
      ({-token lx)
      (}-token lx)
      (unicode-range-token lx)
      (ident-token lx)
      (dash-match-token lx)
      (include-match-token lx)
      (delim-token lx)
      (error "no matching css token")))

(defun css-lexer (stream)
  (assert (eq 'character (stream-element-type stream)))
  (make-instance 'css-lexer :stream stream))

;;  print-object

(defmethod print-object ((object identified-token) stream)
  (declare (type cl:stream stream))
  (print-unreadable-object (object stream :type t)
    (format stream "~S" (token-ident object))))

(defmethod print-object ((object numbered-token) stream)
  (declare (type cl:stream stream))
  (print-unreadable-object (object stream :type t)
    (format stream "~S" (token-number object))))

(defmethod print-object ((object printable) stream)
  (declare (type cl:stream stream))
  (print-unreadable-object (object stream :type t)
    (format stream "~S" (token-string object))))

(defmethod print-object ((object string-token) stream)
  (declare (type cl:stream stream))
  (print-unreadable-object (object stream :type t)
    (format stream "~S" (string-token-string object))))

(defmethod print-object ((object token) stream)
  (declare (type cl:stream stream))
  (print-unreadable-object (object stream :type t)))
