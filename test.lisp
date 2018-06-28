
(in-package :common-lisp-user)

(defpackage :css-lexer/test
  (:use :babel-stream
        :cl
        :cl-stream
        :css-lexer
        :unistd-stream)
  #.(cl-stream:shadowing-import-from)
  (:export
   #:run
   #:simple-test
   #:test
   #:test-file))

(in-package :css-lexer/test)

(defgeneric test (x))

(defmethod test ((s string))
  (with-stream (css (css-lexer (string-input-stream s)))
    (let ((result))
      (loop
         (multiple-value-bind (token state) (stream-read css)
           (ecase state
             ((nil) (push token result))
             ((:eof) (return))
             ((:non-blocking) (sleep 0.01)))))
      (nreverse result))))

(defmethod test ((path pathname))
  (with-stream (css (css-lexer
                     (babel-input-stream
                      (unistd-stream-open
                       (namestring path) :read t))))
    (let ((result))
      (loop
         (multiple-value-bind (token state) (stream-read css)
           (ecase state
             ((nil) (push token result))
             ((:eof) (return))
             ((:non-blocking) (sleep 0.01)))))
      (nreverse result))))

(defparameter *tests*
  '((""
     eof-token)
    ("body { color: #f00; }"
     ident-token whitespace-token {-token whitespace-token
     ident-token colon-token whitespace-token hash-token semicolon-token
     whitespace-token }-token eof-token)
    ("/* comment */"
     comment-token eof-token)))

(defvar *success*)

(defun compare-result (result expected)
  (loop
     (when (endp result)
       (cond ((endp expected)
              (format t ";  OK~%")
              (incf *success*))
             (t
              (format t ";  FAIL not matched: ~S~%" expected)))
       (return (endp expected)))
     (when (endp expected)
       (format t ";  FAIL unexpected: ~S~%" result)
       (return nil))
     (let ((r (first result))
           (e (first expected)))
       (unless (eq (class-name (class-of r)) e)
         (format t ";  FAIL expected ~S got ~S~%" e r)
         (return)))
     (pop result)
     (pop expected)))

(defun run ()
  (let ((count (length *tests*))
        (i 0)
        (*success* 0))
    (dolist (test *tests*)
      (destructuring-bind (arg &rest expected) test
        (format t "~&; ~A/~A ~S~%" (incf i) count arg)
        (let ((result (test arg)))
          (compare-result result expected))))
    (format t "; Passed tests ~A/~A total~%" *success* count)))

(untrace token-stream::subseq*
         token-stream:make-token)
