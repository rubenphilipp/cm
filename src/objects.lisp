;;; **********************************************************************
;;; Copyright (C) 2009 Heinrich Taube, <taube (at) uiuc (dot) edu>
;;;
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the Lisp Lesser Gnu Public License.
;;; See http://www.cliki.net/LLGPL for the text of this agreement.
;;; **********************************************************************

;;; generated by scheme->cltl from objects.scm on 04-Aug-2009 14:11:45

(in-package :cm)

(defmethod copy-object ((obj standard-object))
  (let ((new (make-instance (class-of obj))))
    (fill-object new obj)
    new))

(defmethod fill-object ((new standard-object) (old standard-object))
  (dolist (s (class-slots (class-of old)))
    (let ((n (slot-definition-name s)))
      (when (and (slot-exists-p new n) (slot-boundp old n))
        (setf (slot-value new n) (slot-value old n))))))

(defun save-object (obj file)
  (let ((fp nil))
    (unwind-protect
        (progn (setf fp (open-file file :output))
               (if (consp obj)
                   (dolist (o obj)
                     (write (make-load-form o) :stream fp)
                     (terpri fp))
                   (write (make-load-form obj) :stream fp)))
      (if fp (close-file fp :output)))
    file))

(defparameter *dictionary* (make-hash-table :size 31 :test #'equal))

(progn (defclass container ()
         ((name :initform nil :accessor object-name :initarg :name)))
       (defparameter <container> (find-class 'container))
       (finalize-class <container>)
       (values))

(defmethod print-object ((obj container) port)
  (let ((name (object-name obj)) (*print-case* ':downcase))
    (if name
        (format port "#<~a \"~a\">" (class-name (class-of obj)) name)
        (call-next-method))))

(defmethod initialize-instance :after ((obj container) &rest args)
  args
  (let ((name (object-name obj)))
    (when name
      (unless (stringp name)
        (if (and name (symbolp name))
         (setf name (string-downcase (symbol-name name)))
         (setf name (format nil "~a" name)))
        (setf (object-name obj) name))
      (setf (gethash (string-downcase name) *dictionary*) obj))
    (values)))

(defmethod make-load-form ((obj container))
  `(make-instance
     ,(intern (string-upcase
                (format nil "<~a>" (class-name (class-of obj))))
              :cm)
     ,@(slot-init-forms obj :eval t :omit '(subobjects))
     :subobjects
     ,(cons 'list
            (mapcar #'make-load-form (container-subobjects obj)))))

(defmethod rename-object ((obj container) newname &rest args)
  (let* ((err? (if (null args) t (car args)))
         (str
          (if (stringp newname) newname (format nil "~a" newname)))
         (old (find-object str)))
    (if old
        (if (eq obj old)
            old
            (if err?
                (error "The name ~a already references ~s."
                       newname
                       old)
                nil))
        (progn (remhash (object-name obj) *dictionary*)
               (setf (object-name obj) str)
               (setf (gethash (string-downcase str) *dictionary*)
                     obj)
               obj))))

(defun list-named-objects (&optional type)
  (hash-fold
   (if type
       (lambda (k v p) k (if (typep v type) (cons v p) p))
       (lambda (k v p) k (cons v p)))
   '() *dictionary*))

(defun find-object (string &optional err? class)
  (let* ((name (if (stringp string) string (format nil "~a" string)))
         (type (filename-type name))
         (find nil))
    (if (not type)
        (setf find (gethash (string-downcase name) *dictionary*))
        (let ((name (filename-name name))
              (path (filename-directory name)))
          (hash-fold
           (lambda (k val res)
             k
             res
             (when t
               (let* ((key (object-name val))
                      (typ (filename-type key)))
                 (if typ
                     (let ((nam (filename-name key))
                           (dir (or (filename-directory key) "")))
                       (if (and (string= type typ)
                                (string= name nam)
                                (or (not path) (string= path dir)))
                           (if find
                               (error
                                "More than one file named ~S."
                                string)
                               (setf find val)))))))
             nil)
           nil *dictionary*)))
    (when (and class find)
      (unless (typep find class) (setf find nil)))
    (or find (if err? (error "No object named ~s." string) nil))))

(read-macro-set! #\& (lambda (form) `(find-object ',form t)))

(progn (defclass seq (container)
         ((time :accessor object-time :initarg :time :initform 0)
          (subobjects :initform '() :accessor container-subobjects
           :initarg :subobjects)))
       (defparameter <seq> (find-class 'seq))
       (finalize-class <seq>)
       (values))

(defmethod object-name ((obj standard-object))
  (class-name (class-of obj)))

(defmethod object-time ((obj standard-object)) obj 0)

(defmethod subcontainers ((obj standard-object)) obj '())

(defmethod subcontainers ((obj seq))
  (loop for o in (container-subobjects obj)
        when (typep o <container>) collect o))

(defun map-objects (fn objs &key (start 0) end (step 1) (width 1) at
                    test class key slot slot! arg2 &aux doat indx
                    this)
  (if (not (listp objs)) (setf objs (container-subobjects objs)))
  (if (and slot slot!)
      (error ":slot and slot! are exclusive keywords."))
  (when (or slot slot!)
    (if key
        (error ":slot[!] and :key are exclusive keywords.")
        (setf key
              (if slot!
                  (lambda (x) (slot-value x slot!))
                  (lambda (x) (slot-value x slot))))))
  (when at
    (unless (and (eq start 0) (not end) (eq step 1))
      (error ":at excludes use of :start step and :end"))
    (unless (apply #'< at)
      (error ":at values not in increasing order."))
    (setf doat t)
    (setf start (pop at)))
  (setf indx start)
  (do ((tail (nthcdr start objs) (nthcdr step tail))
       (data nil)
       (done nil)
       (func
        (cond ((not arg2) fn)
              ((eq arg2 ':object) (lambda (x) (funcall fn x this)))
              ((eq arg2 ':position) (lambda (x) (funcall fn x indx)))
              (t (error ":arg2 not :object or :position")))))
      ((or (null tail) done (and end (not (< indx end)))) (values))
    (cond ((> width 1)
           (setf this
                 (loop for i below width
                       for x = (nthcdr i tail)
                       until (null x)
                       collect (car x)))
                 (when (or (not class)
                           (loop for x in this
                                 always (typep x class)))
                           (if key
                               (setf data (mapcar key this))
                               (setf data this))
                           (if (or
                                (not test)
                                (loop for x in data
                                 always (funcall test x)))
                                (if
                                 slot!
                                 (loop for x in (funcall func data)
                                  for y in this
                                  do (setf (slot-value y slot!) x))
                                  (funcall func data)))))
                           (t
                            (setf this (car tail))
                            (when (or (not class) (typep this class))
                              (if
                               key
                               (setf data (funcall key this))
                               (setf data this))
                              (if
                               (or (not test) (funcall test data))
                               (if
                                slot!
                                (setf
                                 (slot-value this slot!)
                                 (funcall func data))
                                (funcall func data))))))
                   (when doat
                     (if (null at)
                         (progn (setf done t) (setf step 0))
                         (progn (setf step (- (pop at) indx)))))
                   (setf indx (+ indx step))))

(defun fold-objects (fn objects acc &rest args)
  (apply #'map-objects
         (lambda (x) (setf acc (funcall fn x acc)))
         objects
         args)
  acc)

(defun subobjects (object &rest args)
  (if (null args)
      (container-subobjects object)
      (let* ((head (list nil)) (tail head))
        (if (member ':slot! args)
            (error "Illegal keyword argument :slot!"))
        (apply #'map-objects
               (lambda (a x)
                 a
                 (rplacd tail (list x))
                 (setf tail (cdr tail)))
               object
               :arg2
               ':object
               args)
        (cdr head))))

(defun list-objects (object &rest args)
  (apply #'map-objects
         (lambda (x i) (format t "~d. ~s~%" i x))
         object
         :arg2
         ':position
         args))

(defmethod insert-object ((sub standard-object) (obj seq))
  (let ((subs (container-subobjects obj)))
    (if (null subs)
        (let ((l (list sub))) (setf (container-subobjects obj) l) l)
        (let ((time (object-time sub)))
          (cond ((< time (object-time (car subs)))
                 (let ((l (cons sub subs)))
                   (setf (container-subobjects obj) l)
                   l))
                (t
                 (do ((top subs) (head (cdr subs) (cdr subs)))
                     ((or (null head)
                          (not (<= (object-time (car head)) time)))
                      (rplacd subs (cons sub head))
                      top)
                   (setf subs head))))))))

(defmethod append-object ((sub standard-object) (obj seq))
  (let ((subs (container-subobjects obj)))
    (cond ((null subs)
           (setf subs (list sub))
           (setf (container-subobjects obj) subs))
          (t (rplacd (last subs) (list sub))))
    subs))

(defmethod remove-object (sub (obj seq))
  (let ((subs (container-subobjects obj)))
    (unless (null subs)
      (if (eq sub (car subs))
          (progn (setf subs (cdr subs))
                 (setf (container-subobjects obj) subs))
          (do ((prev subs) (tail (cdr subs) (cdr tail)))
              ((or (null tail) (eq sub (car tail)))
               (rplacd prev (cddr prev)))
            (setf prev tail))))
    subs))

(defmethod remove-subobjects ((obj seq))
  (setf (container-subobjects obj) (list)))

(progn (defclass event ()
         ((time :accessor object-time :initarg :time)))
       (defparameter <event> (find-class 'event))
       (finalize-class <event>)
       (values))

(defparameter *print-event* t)

(defmethod print-object ((obj event) port)
  (if *print-event*
      (let ((class (class-of obj)) (*print-case* ':downcase))
        (format port "#i(~a" (class-name class))
        (do ((slots (class-slots class) (cdr slots))
             (d nil)
             (s nil)
             (v nil)
             (k nil))
            ((null slots) nil)
          (setf d (car slots))
          (setf s (slot-definition-name d))
          (if (slot-boundp obj s)
              (progn (setf v (slot-value obj s))
                     (setf k (slot-definition-initargs d))
                     (unless (null k)
                       (unless (and
                                (eq *print-event* ':terse)
                                (eq v (slot-definition-initform d)))
                         (format port " ~a ~s" s v))))))
        (format port ")")
        obj)
      (call-next-method)))

(defun i-reader (form)
  (if (consp form)
      `(new ,@form)
      (error "Can't make instance from ~s." form)))

(read-macro-set! #\i #'i-reader)

(read-macro-set! #\I #'i-reader)

(defmacro new (class &body args)
  (let* ((type
          (or (find-class class) (error "No class named ~s." class)))
         (inits (expand-inits type args t nil)))
    `(make-instance (find-class ',class) ,@inits)))

(defun class-name->class-var (sym)
  (let ((str (symbol-name sym)))
    (if (char= (elt str 0) #\<)
        sym
        (intern (string-upcase (concatenate 'string "<" str ">"))
                :cm))))

(defun class-var->class-name (sym)
  (let ((str (symbol-name sym)))
    (if (char= #\< (elt str 0))
        (intern (string-upcase (subseq str 1 (- (length str) 1)))
                :cm)
        (error "Class variable not <~a>" sym))))

(define-list-struct parameter slot (type 'required) time? prefix
 decimals)

(defun parse-parameters (decl)
  (flet ((par (p ty)
           (if (consp p)
               (let* ((nam (pop p)))
                 (if (oddp (length p)) (pop p))
                 (make-parameter :slot nam :type ty :prefix
                  (if (eq ty 'key)
                      (or (getf p ':prefix) (symbol->keyword nam))
                      nil)
                  :decimals (getf p ':decimals)))
               (make-parameter :slot p :type ty :prefix
                (if (eq ty 'key) (symbol->keyword p) nil)))))
    (let ((req '())
          (opt '())
          (rest '())
          (key '())
          (aok '())
          (aux '()))
      aok
      aux
      (multiple-value-setq (req opt rest key aok aux)
        (parse-lambda-list decl))
      (append (mapcar (lambda (p) (par p 'required)) req)
              (mapcar (lambda (p) (par p 'optional)) opt)
              (mapcar (lambda (p) (par p 'rest)) rest)
              (mapcar (lambda (p) (par p 'key)) key)))))

(defun insure-parameters (pars decl supers)
  (flet ((getslotd (slot sups)
           (do ((tail sups (cdr tail)) (isit nil))
               ((or (null tail) isit) isit)
             (setf isit
                   (find-if (lambda (x)
                              (eq slot (slot-definition-name x)))
                            (class-slots (car tail)))))))
    (dolist (p pars)
      (or (let ((s (parameter-slot p)))
            (find-if (lambda (x) (eq s (car x))) decl))
          (getslotd (parameter-slot p) supers)
          (error "No slot definition for parameter ~s."
                 (parameter-slot p))))
    t))

(defparameter *time-slots* '(time start start-time starttime startime begin beg))

(defun find-time-parameter (pars decl supers)
  (flet ((gettimepar (slot sups)
           (do ((tail sups (cdr tail)) (pars nil) (goal nil))
               ((or (null tail) goal) goal)
             (setf pars (class-parameters (car tail)))
             (if pars
                 (let ((test
                        (find-if (lambda
                                  (x)
                                  (eq slot (parameter-slot x)))
                                 pars)))
                   (if (and test (parameter-time? test))
                       (setf goal t)))))))
    (do ((tail pars (cdr tail)) (goal nil) (temp nil))
        ((or (null tail) goal)
         (when goal (parameter-time?-set! goal t))
         t)
      (setf temp (assoc (parameter-slot (car tail)) decl))
      (if (and temp (member 'object-time (cdr temp)))
          (setf goal (car tail))
          (if (member (parameter-slot (car tail)) *time-slots*)
              (setf goal (car tail))
              (if (gettimepar (parameter-slot (car tail)) supers)
                  (setf goal (car tail))))))))

(defmacro defobject (name supers slots &body options)
  (let ((sups
         (mapcar (lambda (x)
                   (or (find-class x)
                       (error "No class named ~s." x)))
                 supers))
        (decl (mapcar (lambda (x) (if (consp x) x (list x))) slots))
        (gvar (intern (string-upcase (format nil "<~a>" name)) :cm))
        (make nil)
        (streams '())
        (pars nil)
        (methods '()))
    (dolist (opt options)
      (unless (consp opt)
        (error "defobject: not an options list: ~s" opt))
      (case (car opt)
        ((:parameters) (setf pars opt))
        ((:event-streams) (setf make t) (setf streams (cdr opt)))
        (t (error "Not a defobject option: ~s." (car opt)))))
    (when pars
      (setf pars (parse-parameters (cdr pars)))
      (insure-parameters pars decl sups)
      (find-time-parameter pars decl sups)
      (if (not make)
          (setf make
                (write-event-streams (mapcar #'find-class supers)))
          (setf make streams))
      (dolist (c make)
        (let ((fn (io-class-definer (find-class c))))
          (when fn
            (push (funcall fn name gvar pars sups decl) methods))))
      (setf methods (reverse methods)))
    (expand-defobject name gvar supers decl pars methods streams)))

(defun process-code-terminates? (code stop)
  (if (null code)
      nil
      (if (consp code)
          (or (process-code-terminates? (car code) stop)
              (process-code-terminates? (cdr code) stop))
          (eq code (car stop)))))

(defun parse-process-clause (forms clauses ops)
  clauses
  ops
  (let ((head forms)
        (oper (pop forms))
        (expr nil)
        (args '())
        (loop '()))
    (when (null forms)
      (loop-error ops head "Missing '" oper "' expression."))
    (setf expr (pop forms))
    (do ((stop nil))
        ((or stop (null forms)))
      (case (car forms)
        ((to)
         (unless (eq oper 'output)
           (loop-error ops head "'~s' is an unknown ~s modifier."
            (car forms) oper))
         (when (null (cdr forms))
           (loop-error ops head "Missing '" oper "' expression."))
         (setf args (append args (list :to (cadr forms))))
         (setf forms (cddr forms)))
        ((at)
         (unless (member oper '(sprout output))
           (loop-error ops head "'" (car forms) "' is an unknown '"
            oper "' modifier."))
         (when (null (cdr forms))
           (loop-error ops head "Missing '" oper "' expression."))
         (setf args (append args (list ':at (cadr forms))))
         (setf forms (cddr forms)))
        ((ahead)
         (unless (eq oper 'output)
           (loop-error ops head "'" (car forms) "' is an unknown '"
            oper "' modifier."))
         (when (null (cdr forms))
           (loop-error ops head "Missing '" oper "' expression."))
         (setf args (append args (list ':ahead (cadr forms))))
         (setf forms (cddr forms)))
        (t (setf stop t))))
    (case oper
      ((output)
       (setf loop
             (if (null args)
                 (list `(,oper ,expr))
                 (list `(,oper ,expr ,@args)))))
      ((wait) (setf loop (list `(wait ,expr))))
      ((sprout)
       (setf loop
             (list `(,oper ,expr
                     ,@(if (null args) (list ':at '(now)) args))))))
    (values (make-loop-clause 'operator oper 'looping loop) forms)))

(defun parse-set-clause (forms clauses ops)
  clauses
  (let ((head forms)
        (oper (pop forms))
        (var nil)
        (=opr nil)
        (expr nil)
        (loop '()))
    (when (null forms)
      (loop-error ops head
       "Variable expected but source code ran out."))
    (setf var (pop forms))
    (unless (and var (symbolp var))
      (loop-error ops head "Found '" var
       "' where variable expected."))
    (when (null forms)
      (loop-error ops head "'=' expected but source code ran out."))
    (setf =opr (pop forms))
    (unless (eq =opr '=)
      (loop-error ops head "Found '" =opr "' where '=' expected."))
    (when (null forms)
      (loop-error ops head "Missing '" oper "' expression."))
    (setf expr (pop forms))
    (setf loop (list `(setf ,var ,expr)))
    (values (make-loop-clause 'operator oper 'looping loop) forms)))

(defun process-while-until (forms clauses ops)
  clauses
  (let ((head forms)
        (oper (pop forms))
        (test nil)
        (stop (process-stop nil)))
    (when (null forms)
      (loop-error ops head "Missing '" oper "' expression."))
    (case oper
      ((until) (setf test (pop forms)))
      ((while) (setf test `(not ,(pop forms)))))
    (values (make-loop-clause 'operator oper 'looping
             (list `(if ,test ,stop)))
            forms)))

(defparameter *each-operators* (list
                                (list 'as #'parse-for 'iter
                                 (list 'from #'parse-numerical-for)
                                 (list 'downfrom #'parse-numerical-for)
                                 (list 'below #'parse-numerical-for)
                                 (list 'to #'parse-numerical-for)
                                 (list 'above #'parse-numerical-for)
                                 (list 'downto #'parse-numerical-for)
                                 (list 'in #'parse-sequence-iteration)
                                 (list 'on #'parse-numerical-for)
                                 (list 'across #'parse-sequence-iteration)
                                 (list '= #'parse-general-iteration))
                                (list 'output #'parse-process-clause 'task 'to 'at 'ahead)
                                (list 'sprout #'parse-process-clause 'task 'at 'ahead)
                                (assoc 'do *loop-operators*)))

(defun parse-each (forms clauses ops)
  clauses
  (let ((save forms)
        (forms (cdr forms))
        (subs '())
        (each nil)
        (loop nil)
        (ends nil))
    (do ()
        ((or (null forms)
             (loop-op? (car forms) (cdr *each-operators*))))
      (if (and (not (eq (car forms) 'as)) (loop-op? (car forms) ops))
          (loop-error *each-operators* forms
           "Expected 'each' action but found '" (car forms)
           "' instead."))
      (push (car forms) subs)
      (setf forms (cdr forms)))
    (when (null subs)
      (loop-error *each-operators* save
       "Missing 'each' stepping clause."))
    (when (null forms)
      (loop-error *each-operators* save
       "Expected 'each' action but source code ran out."))
    (do ((flag t))
        ((or (null forms)
             (and (not flag) (loop-op? (car forms) ops)))
         nil)
      (push (car forms) subs)
      (setf forms (cdr forms))
      (setf flag nil))
    (setf subs (reverse subs))
    (setf each
          (parse-iteration 'each (cons 'as subs) *each-operators*))
    (if (null (loop-end-tests each))
        (loop-error *each-operators* save "No 'each' end test?")
        (setf ends (loop-end-tests each)))
    (unless (null (loop-initially each))
      (loop-error *each-operators* save
       "'each' does not support initializations."))
    (when (null (loop-looping each))
      (loop-error *each-operators* save
       "Expected 'each' action but source code ran out."))
    (setf loop
          (list `(,'do (,@(loop-bindings each))
                  (,(if (null (cdr ends)) (car ends) `(or ,@ends))
                   nil)
                  ,@(loop-looping each) ,@(loop-stepping each))))
    (values (make-loop-clause 'operator 'each 'looping loop) forms)))

(defparameter *process-operators* (append
                                   (mapcar
                                    (lambda (op) (assoc op *loop-operators*))
                                    '(with initially repeat for as do finally when unless if))
                                   (list
                                    (list 'set #'parse-set-clause 'task)
                                    (list 'output #'parse-process-clause 'task 'to 'into)
                                    (list 'sprout #'parse-process-clause 'task 'at 'ahead)
                                    (list 'wait #'parse-process-clause 'task)
                                    (list 'wait-until #'parse-process-clause 'task)
                                    (list 'each #'parse-each 'task)
                                    (list 'while #'process-while-until nil)
                                    (list 'until #'process-while-until nil))))

(defmacro process (&body forms)
  (expand-process forms *process-operators*))

(defmacro defprocess (&body forms) (expand-defprocess forms))

(defun box (op &rest args) (vector op args '()))

(defun box? (x) (and (vectorp x) (> (length x) 2)))

(defun boxfunc (box &rest func)
  (if (null func)
      (elt box 0)
      (progn (setf (elt box 0) (car func)) (car func))))

(defun boxargs (box &rest args)
  (if (null args)
      (elt box 1)
      (progn (setf (elt box 1) (car args)) (car args))))

(defun boxouts (box &rest outs)
  (if (null outs)
      (elt box 2)
      (progn (setf (elt box 2) (car outs)) (car outs))))

(defun box-> (box &rest boxes)
  (dolist (b boxes)
    (unless (box? b) (error "Outbox: ~s not a box." b)))
  (boxouts box boxes)
  (values))

(defun bang! (box &rest args)
  (let ((pmode ':bang!))
    (cond ((null args) nil)
          ((eq (car args) ':bang!) (setf args (cdr args)))
          ((eq (car args) ':send!)
           (setf pmode ':send!)
           (setf args (cdr args)))
          ((eq (car args) ':stop!) (setf pmode ':stop!))
          (t nil))
    (if (eq pmode ':stop!)
        (values)
        (progn (if (not (null args))
                   (if (eq (car args) ':argn)
                       (if (null (cdr args))
                           (setf (elt box 1) (list))
                           (let ((fnargs (elt box 1)))
                             (dopairs
                              (n v (cdr args))
                              (setf (elt fnargs n) v))))
                       (setf (elt box 1) args)))
               (if (eq pmode ':bang!)
                   (let ((res
                          (multiple-value-list
                            (apply (elt box 0) (elt box 1)))))
                     (dolist (o (elt box 2)) (apply #'bang! o res))))
               (values)))))
