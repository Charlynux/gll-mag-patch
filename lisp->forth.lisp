
(in-package :cl-user)
(require 'utilities)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  LISP->FORTH - by Erann Gat
;;;

(defun mappend1 (fn mapped-arg &rest unmapped-args)
  (apply #'append (apply #'map1 fn mapped-arg unmapped-args)))

(defvar *forth-synonyms*)
(setq *forth-synonyms* '((print ".")))

(defun lisp->forth (expr &optional env)
  (if (atom expr)
    (atom->forth expr env)
    (case (car expr)
      ( (if)
        (let ( (condition (lisp->forth (second expr) env))
               (true-case (lisp->forth (third expr) env))
               (false-case (lisp->forth (fourth expr) env)) )
          (if false-case
            `(,@condition IF ,@true-case ELSE ,@false-case THEN)
            `(,@condition IF ,@true-case THEN))) )
      ( (until)
        (let ( (condition (lisp->forth (second expr)))
               (body (mappend1 #'lisp->forth (cddr expr) env)) )
          `(BEGIN ,@body ,@condition UNTIL)) )
      ( (while)
        (let ( (condition (lisp->forth (second expr)))
               (body (mappend1 #'lisp->forth (cddr expr) env)) )
          `(BEGIN ,@condition WHILE ,@body REPEAT)) )
      ( (dotimes)
        (let* ( (var (first (second expr)))
                (cnt (lisp->forth (second (second expr))))
                (cnt2 (lisp->forth (third (second expr))))
                (body (mappend1 #'lisp->forth (cddr expr) (cons var (cons nil env)))) )
          (if cnt2
            `(,@cnt2 ,@cnt DO ,@body LOOP)
            `(,@cnt 0 DO ,@body LOOP))) )
      ( (setf)
        (let ( (place (second expr))
               (value (lisp->forth (third expr))) )
          (if (not (symbolp place))
            (error "Can't set ~S" place)
            `(,@value ,place !))) )
      ( (let)
        (let* ( (initforms
                 (mappend1 #'(lambda (initform)
                               (append (lisp->forth (second initform) env) (list '>R)))
                           (second expr)))
                (n (length (second expr)))
                (body (mappend1 #'lisp->forth (cddr expr)
                                (append (reverse (mapcar #'car (second expr))) env))) )
          (append initforms body (list (+ 2 (* n 2)) 'NRDROP))) )
      ( (lambda)
        (append (n-of '>R (length (second expr)))
                (mappend1 #'lisp->forth (cddr expr) (append (second expr) env))
                (list (+ 2 (* (length (second expr)) 2)) 'NRDROP)) )
      ( (define)
        `(":" ,(second expr) ,@(lisp->forth `(lambda ,@(cddr expr))) ";"))
      (otherwise
       (iterate loop ( (args (reverse (cdr expr)))
                       (result (or (cdr (assoc (car expr) *forth-synonyms*))
                                   (list (car expr))))
                       (env env) )
         (if args
           (loop (cdr args)
                 (append (lisp->forth (car args) env) result)
                 env)
           result))))))

(defun atom->forth (expr env)
  (cond ( (null expr) nil )
        ( (fixnump expr) (list expr) )
        ( (numberp expr) (error "Illegal value: ~S" expr) )
        (t
         (let ( (n (position expr env)) )
           (if n
             (list (+ n 2) 'RPICK)
             (list expr '@))))))

#|
(lisp->forth
 '(define rotate (theta bxsc bysc bzsc)
    (let ( (sintheta (sin theta))
           (costheta (cos theta)) )
      (set bxi (- (* bxsc costheta)
                   (* bysc sintheta)))
      (set byi (+ (* bxsc sintheta)
                   (* bysc costheta)))
      (set bzi bzsc))))

; requires infix parser
(lisp->forth
 '(define rotate (theta bxsc bysc bzsc)
    (let ( (sintheta (sin theta))
           (costheta (cos theta)) )
      #{ bxi = bxsc*cos(theta) - bysc*sin(theta) }
      #{ byi = bxsc*sin(theta) + bysc*cos(theta) }
      #{ bzi = bzsc }
      )))

(lisp->forth '#{ xprime = x[i]*k + r[i]/k })
|#