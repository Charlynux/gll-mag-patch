
(in-package :cl-user)
(require 'utilities)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Dictionaries
;;;

(define-class dictionary name entries next-entry-addr image)
(define-print-method (dictionary name) "#<~A Dictionary>" name)

(defun make-dictionary (name &optional (start-addr 0))
  (make-instance 'dictionary :name name :next-entry-addr start-addr))

(define-class forth-word name address source bytes size)
(define-print-method (forth-word name address size)
  "#<Forth word ~A, address=#x~X, size=~S>"
  name
  (or address :uninstalled)
  (or size :uncompiled))

(define-method (find-entry-by-name (d dictionary entries) name)
  (find name entries :key #'forth-word-name))

(define-method (find-entry-by-address (d dictionary entries) addr)
  (find addr entries :key #'forth-word-address :test #'>=))

(defun make-forth-word (name &key address source bytes size)
  (if (and size bytes (/= size (length bytes)))
    (warn "Size and byte specs do not match."))
  (if (and bytes (null size)) (setf size (length bytes)))
  (make-instance 'forth-word :name name :address address
                 :source source :bytes bytes :size size))

(define-method (fcompile (w forth-word source bytes size) d)
  (setf bytes (compile-forth-words source d))
  (setf size (length bytes))
  w)

(define-method (install (w forth-word name address source bytes size) d)
  (if (find-entry-by-name d name)
    (warn "A word named ~S already exists in ~S." name d))
  (with-slots (entries next-entry-addr) d
    (if (null size)
      (error "~S has not been properly compiled." w))
    (if address
      (if (< address next-entry-addr)
        (error "Can't overwrite existing code."))
      (setf address next-entry-addr))
    (push w entries)
    (setf next-entry-addr address)
    (incf next-entry-addr size)
    t))

(define-method (dump (w forth-word name address source bytes size))
  (format t "~&Dump of forth word ~S:" name)
  (format t "~&~%Source code:")
  (format t "~&~A" source)
  (format t "~&~%Object code:")
  (pprint-bytes bytes address)
  (values))

(define-method (forget (d dictionary entries next-entry-addr) name)
  (let ( (l (member name entries :key #'forth-word-name)) )
    (if (null l)
      (error "~S not found in ~S." name d))
    (setf entries (cdr l))
    (setf next-entry-addr
          (if (null (cdr l))
            0
            (+ (forth-word-address (cadr l)) (forth-word-size (cadr l)))))))

(defvar *the-dictionary* (make-dictionary :default))

(defun lkup (thing &optional (d *the-dictionary*))
  (if (integerp thing)
    (find-entry-by-address d thing)
    (find-entry-by-name d thing)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Parsers
;;;
(defun read-to-delimiter (&optional (stream t)
                                    (delimiters '(#\Space #\Return #\Linefeed)))
  (peek-char t stream nil)
  (with-output-to-string (s)
     (loop
       (let ( (c (read-char stream nil :eof)) )
         (if (or (member c delimiters :test #'eql) (eq c :eof))
           (return s)
           (princ c s))))))

(defun string->forth-word (s &optional (radix 16))
  (receive (n cnt) (parse-integer s :radix radix :junk-allowed t)
    (if (and n (= cnt (length s)))
      n
      (intern (string-upcase s)))))

(defun read-forth-word (&optional (stream t))
  (let ( (w (string->forth-word (read-to-delimiter stream))) )
    (if (neq w '\( )
      w
      (if (eq (read-to-delimiter stream '(#\))) ':eof)
        (error "Unexpected end of file while reading forth comment.")
        (read-forth-word stream)))))

(defun parse-forth (s)
  (with-input-from-string (s s)
    (let ( (result nil) )
      (loop
        (let ( (word (read-forth-word s)) )
          (if (eq word '||)
            (return (nreverse result))
            (push word result)))))))

(defun read-forth-source (filename)
  (with-open-file (f filename)
    (let ( (flag nil) (result '()) )
      (loop
        (let ( (w (read-forth-word f)) )
          (case w
            (|| (return (nreverse result)))
            (\: (push (list '\:) result) (setq flag t))
            (\; (if (null flag)
                  (return (nreverse result))
                  (progn
                    (push w (car result))
                    (setf (car result) (nreverse (car result)))
                    (setq flag nil))))
            (otherwise (if flag (push w (car result))))))))))

(defun read-dictionary (f)
  (let ( (result nil) )
    (loop
      (push (cons (string->forth-word (read-to-delimiter f))
                  (let ( (*read-base* 16)) (- (read f) 2)))
            result)
      (read-line f nil)
      (when (eql (peek-char nil f nil #\Newline) #\Newline)
        (return (sort result #'< :key #'cdr))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  FORTH compiler
;;;

(define-class compiler-state words bytes branch-stack)

(define-method (scan (s compiler-state words))
  (pop words))

(define-method (emit (s compiler-state bytes) &rest new-bytes)
  (dolist (b new-bytes) (push b bytes)))

(define-method (emit16 (s compiler-state) &rest words)
  (dolist (w words) (emit s (logand (ash w -8) #xFF) (logand w #xFF))))

(define-method (mark-branch (s compiler-state bytes branch-stack))
  (push bytes branch-stack))

(define-method (resolve-branch (s compiler-state branch-stack) d)
  (setf (car (pop branch-stack)) d))

(define-method (branch-distance (s compiler-state bytes branch-stack))
  (and branch-stack (- (length bytes) (length (car branch-stack)))))

(defun compile-forth-words (words &optional (d *the-dictionary*))
  (let ( (s (make-compiler-state :words words)) )
    (loop
      (let ( (w (scan s)) )
        (if (null w)
          (return (reverse (compiler-state-bytes s)))
          (receive (cw type) (lookup-forth-word w d)
            (ecase type
              ((:ram :rom) (emit16 s cw))
              (:byte (emit s 0 #x2A cw))
              (:word (emit s 0 #x1F) (emit16 s cw))
              (:system (error "Can't compile system word: ~S" w))
              (:special (compile-special w cw s)))))))))

(defun compile-special (w cw s)
  (case w
    (begin (mark-branch s))
    (do (emit16 s cw)
        (mark-branch s))
    ((end loop +loop)
     (emit16 s cw)
     (let ( (d (branch-distance s)) )
       (cond ( (null d) (error "Unmatched loop end.") )
             ( (> d #xFE) (error "Loop body too large") )
             (t (emit s (logand #xFF (- d)))))))
    (if (emit16 s cw)
        (emit s 'offset)
        (mark-branch s))
    (else (emit16 s cw)
          (emit s 'offset)
          (let ( (d (branch-distance s)) )
            (if (null d) (error "Unmatched ELSE"))
            (resolve-branch s (1+ d)))
          (mark-branch s))
    (then (let ( (d (branch-distance s)) )
            (if (null d) (error "Unmatched THEN"))
            (resolve-branch s (1+ d))))
    (\: (emit16 s cw) (scan s))))

(defvar *special-forth-words* '(if then else begin end do loop +loop \:))

(defun lookup-forth-word (word dictionary)
  (let* ( (entry (find-entry-by-name dictionary word))
          (addr (and entry (forth-word-address entry))) )
    (tcond
     ( (member word *special-forth-words*) (values addr :special) )
     ( addr (values addr (if (>= addr #x4000) :ram :rom) (forth-word-size entry)) )
     ( (not (fixnump word)) (error "Can't find definition of ~S" word) )
     ( (<= 0 word 255) (values word :byte) )
     ( (<= (abs word) #xFFFF) (values (logand word #xFFFF) :word) )
     (t (error "Can't compile ~S" word)))))

(defun compile-forth (s &optional (d *the-dictionary*))
  (if (stringp s) (setq s (parse-forth s)))
  (if (neq (first s) '\:)
    (compile-forth-words s)
    (fcompile (make-forth-word (second s) :source s) d)))

;;;;;;;;;;;;;;;;;;
;;;
;;;  GLL specific stuff
;;;

(defvar *gll-dictionary*)

(require "ram source")
(require "ram image")
(require "rom image")

(defvar *gll-ram-index*)
(defvar *gll-rom-index*)

(with-open-file (f "gll;dictionary")
  (setf *gll-ram-index* (read-dictionary f))
  (unless (= (length *gll-ram-index*) 54)
    (warn "Unexpected number of entries in GLL RAM index."))
  (setf *gll-rom-index* (read-dictionary f))
  (unless (= (length *gll-rom-index*) 229)
    (warn "Unexpected number of entries in GLL ROM index.")))

(defun find-gll-source (word) (find word *gll-source* :key #'second))

(defun build-gll-dictionary ()
  (setq *gll-dictionary* (make-dictionary :gll))
  (walkcdr (fn (w)
             (if (cdr w)
               (install (make-forth-word
                         (caar w)
                         :address (cdar w)
                         :bytes (subseq *gll-rom-image* (cdar w) (cdadr w))
                         :size (- (cdadr w) (cdar w)))
                        *gll-dictionary*)))
           *gll-rom-index*)
  (walkcdr (fn (w)
             (if (cdr w)
               (install (make-forth-word
                         (caar w)
                         :address (cdar w)
                         :source (find-gll-source (caar w))
                         :bytes (subseq *gll-ram-image*
                                        (- (cdar w) #x4000)
                                        (- (cdadr w) #x4000))
                         :size (- (cdadr w) (cdar w)))
                        *gll-dictionary*)))
           *gll-ram-index*)
  (setf *the-dictionary* *gll-dictionary*))

(defun compiler-test ()
  (dolist (w (dictionary-entries *gll-dictionary*))
    (with-slots (name source address bytes) w
      (if source
        (let* ( (test-image (compile-forth-words source))
                (diff (first-difference bytes test-image)) )
          (when diff
            (progn
              (format t "~&~%*** Compiler results for ~S do not match RAM image."
                      name)
              (format t "~&First difference is at #x~X" (+ address diff))
              (pprint-bytes test-image address)
              (format t "~&Should be:")
              (pprint-bytes (nthcdr diff bytes) (+ address diff)))))))))

(defun first-difference (l1 l2)
  (iterate loop ( (l1 l1) (l2 l2) (n 0) )
    (cond ( (and (null l1) (null l2)) nil )
          ( (or (null l1) (null l2) (not (eql (car l1) (car l2)))) n )
          (t (loop (cdr l1) (cdr l2) (1+ n))))))

(defun compile-patch (s &optional (d *the-dictionary*))
  (let ( (w (compile-forth s d)) )
    (with-slots (name size bytes) w
      (let ( (old-w (find-entry-by-name d name)) )
        (when (null old-w)
          (error "Couldn't find old definition of ~S" name))
        (let ( (old-bytes (forth-word-bytes old-w))
               (old-size (forth-word-size old-w))
               (address (forth-word-address old-w)) )
          (setf (forth-word-address w) address)
          (format t "~&Patch for ~S:" name)
          (when (> size old-size)
            (format t "~&***** Patch will overflow original memory slot! ******")
            (format t "~&Patch is ~S bytes long.  ~S bytes available." size old-size))
          (let ( (diff (first-difference bytes old-bytes)) )
            (if (null diff)
              (format t "~&Patch is identical to original code.")
              (pprint-bytes (nthcdr diff bytes) (+ diff address)))))))
    w))

;;;;;;;;;;;;;;;
;;;
;;;  Utilities
;;;
(defun pprint-bytes (bytes &optional (addr 0))
  (iterate loop1 ()
    (format t "~&~4,'0X  " (logand addr #xFFF8))
    (dotimes (i (logand addr 7)) (format t "   "))
    (iterate loop2 ()
      (when bytes
        (format t " ~2,'0X" (pop bytes))
        (incf addr)
        (when (not (zerop (logand addr 7))) (loop2))
        (when bytes (loop1))))))



#|
;;;  SDSPIN patches

;;; uniform sampling, self-modifying hack:
(compile-patch
 ": SDSPIN DUP 15 = IF 1ST-DSPVECTOR TS! THEN DUP 28 = IF
   ADDR-BUFFER DUP @ 20 + DUP 4CF8 > IF DROP 4800 THEN
   DUP ROT 2+ 20 MOVE ADDR-BUFFER ! THEN
   1 430B +! FFFF 7 = IF OPTST 0 430B ! THEN
   DUP 0= IF MAT-LOAD 4FF0 C@ 20 - 2/ CMDPTR +! THEN ;")

;;; uniform sampling
(compile-patch
 ": SDSPIN DUP 15 = IF 1ST-DSPVECTOR TS! THEN DUP 28 = IF
   ADDR-BUFFER DUP @ 20 + DUP 4CF8 > IF DROP 4800 THEN
   DUP ROT 2+ 20 MOVE ADDR-BUFFER ! THEN
   1 46FE +! 46FE @ 0= IF OPTST -7 46FE ! THEN
   DUP 0= IF MAT-LOAD 4FF0 C@ 20 - 2/ CMDPTR +! THEN ;")

;;; uneven sampling (except for 7 and 13 samples per RIM)
(defmacro with-period (period event)
  (if (<= period 1)
    event
    (lisp->forth `(if (= (mod (dup) ,period) ,(1- period)) ,event))))

(defmacro main-event-loop (&body body)
  `(\: SDSPIN DUP #x15 = IF 1ST-DSPVECTOR TS! THEN DUP #x28 = IF
       ADDR-BUFFER DUP @ #x20 + DUP #x4CF8 > IF DROP #x4800 THEN
       DUP ROT 2+ #x20 MOVE ADDR-BUFFER ! THEN
       ,@(mappend #'macroexpand body)
       DUP #x5A = IF MAT-LOAD #x4FF0 C@ #x20 - 2/ CMDPTR +! THEN \;))

(compile-patch (macroexpand '(main-event-loop (with-period 7 (optst)))))
|#