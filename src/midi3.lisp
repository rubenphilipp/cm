;;; **********************************************************************
;;; Copyright (C) 2009 Heinrich Taube, <taube (at) uiuc (dot) edu>
;;;
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the Lisp Lesser Gnu Public License.
;;; See http://www.cliki.net/LLGPL for the text of this agreement.
;;; **********************************************************************

;;; generated by scheme->cltl from midi3.scm on 04-Aug-2009 14:11:46

(in-package :cm)

(defobject midi-note-on (midi-channel-event)
 ((opcode :initform +ml-note-on-opcode+ :initarg nil)
  (keynum :accessor midi-event-data1)
  (velocity :accessor midi-event-data2 :initform 64))
 (:parameters time channel keynum velocity) (:event-streams))

(defobject midi-note-off (midi-channel-event)
 ((opcode :initform +ml-note-off-opcode+ :initarg nil)
  (keynum :accessor midi-event-data1)
  (velocity :accessor midi-event-data2 :initform 64))
 (:parameters time channel keynum velocity) (:event-streams))

(defobject midi-key-pressure (midi-channel-event)
 ((opcode :initform +ml-key-pressure-opcode+ :initarg nil)
  (keynum :accessor midi-event-data1)
  (pressure :accessor midi-event-data2))
 (:parameters time channel keynum pressure) (:event-streams))

(defobject midi-control-change (midi-channel-event)
 ((opcode :initform +ml-control-change-opcode+ :initarg nil)
  (controller :accessor midi-event-data1)
  (value :accessor midi-event-data2))
 (:parameters time channel controller value) (:event-streams))

(defobject midi-program-change (midi-channel-event)
 ((opcode :initform +ml-program-change-opcode+ :initarg nil)
  (program :accessor midi-event-data1))
 (:parameters time channel program) (:event-streams))

(defobject midi-channel-pressure (midi-channel-event)
 ((opcode :initform +ml-channel-pressure-opcode+ :initarg nil)
  (pressure :accessor midi-event-data1))
 (:parameters time channel pressure) (:event-streams))

(defobject midi-pitch-bend (midi-channel-event)
 ((opcode :initform +ml-pitch-bend-opcode+ :initarg nil)
  (bend :initform 0))
 (:parameters time channel bend) (:event-streams))

(defmethod midi-event-data1 ((obj midi-pitch-bend))
  (multiple-value-bind (ms7b ls7b)
      (floor (+ (midi-pitch-bend-bend obj) 8192) 128)
    ms7b
    ls7b))

(defmethod midi-event-data2 ((obj midi-pitch-bend))
  (multiple-value-bind (ms7b ls7b)
      (floor (+ (midi-pitch-bend-bend obj) 8192) 128)
    ls7b
    ms7b))

(defobject midi-sequence-number (midi-meta-event)
 ((opcode :initform +ml-file-sequence-number-opcode+ :initarg nil)
  (number :accessor midi-event-data1))
 (:parameters time number) (:event-streams))

(defobject midi-text-event (midi-meta-event)
 ((opcode :initform +ml-file-text-event-opcode+ :initarg nil)
  (type :initform +ml-file-text-event-opcode+ :accessor
   midi-event-data1)
  (text :accessor midi-event-data2))
 (:parameters time type text) (:event-streams))

(defobject midi-eot (midi-meta-event)
 ((opcode :initform +ml-file-eot-opcode+ :initarg nil))
 (:parameters time) (:event-streams))

(defobject midi-tempo-change (midi-meta-event)
 ((opcode :initform +ml-file-tempo-change-opcode+ :initarg nil)
  (usecs :accessor midi-event-data1))
 (:parameters time usecs) (:event-streams))

(defobject midi-smpte-offset (midi-meta-event)
 ((opcode :initform +ml-file-smpte-offset-opcode+ :initarg nil)
  (offset :initform 'nil :accessor midi-event-data1))
 (:parameters time offset) (:event-streams))

(defobject midi-time-signature (midi-meta-event)
 ((opcode :initform +ml-file-time-signature-opcode+ :initarg nil)
  (numerator :accessor midi-event-data1)
  (denominator :accessor midi-event-data2)
  (clocks :initform 24 :accessor midi-event-data3)
  (32nds :initform 8 :accessor midi-event-data4))
 (:parameters opcode numerator denominator clocks 32nds)
 (:event-streams))

(defobject midi-key-signature (midi-meta-event)
 ((opcode :initform +ml-file-key-signature-opcode+ :initarg nil)
  (key :initform 0 :accessor midi-event-data1)
  (mode :initform 0 :accessor midi-event-data2))
 (:parameters time key mode) (:event-streams))

(defobject midi-sequencer-event (midi-meta-event)
 ((opcode :initform +ml-file-sequencer-event-opcode+ :initarg nil)
  (data :accessor midi-event-data1))
 (:parameters time data) (:event-streams))

(defobject midi-port-event (midi-meta-event)
 ((opcode :initform +ml-file-midi-port-opcode+ :initarg nil)
  (port :accessor midi-event-data1))
 (:parameters time port) (:event-streams))

(defobject midi-chan-event (midi-meta-event)
 ((opcode :initform +ml-file-midi-channel-opcode+ :initarg nil)
  (chan :accessor midi-event-data1))
 (:parameters time chan) (:event-streams))

(defun midi-message->midi-event (m &key data time)
  (let ((ch nil))
    (cond ((midi-channel-message-p m)
           (setf ch (channel-message-channel m))
           (cond ((note-on-p m)
                  (make-instance
                    <midi-note-on>
                    :time
                    time
                    :channel
                    ch
                    :keynum
                    (note-on-key m)
                    :velocity
                    (note-on-velocity m)))
                 ((note-off-p m)
                  (make-instance
                    <midi-note-off>
                    :time
                    time
                    :channel
                    ch
                    :keynum
                    (note-on-key m)
                    :velocity
                    (note-on-velocity m)))
                 ((key-pressure-p m)
                  (make-instance
                    <midi-key-pressure>
                    :time
                    time
                    :channel
                    ch
                    :keynum
                    (key-pressure-key m)
                    :pressure
                    (key-pressure-pressure m)))
                 ((control-change-p m)
                  (make-instance
                    <midi-control-change>
                    :time
                    time
                    :channel
                    ch
                    :controller
                    (control-change-controller m)
                    :value
                    (control-change-value m)))
                 ((program-change-p m)
                  (make-instance
                    <midi-program-change>
                    :time
                    time
                    :channel
                    ch
                    :program
                    (program-change-program m)))
                 ((pitch-bend-p m)
                  (make-instance
                    <midi-pitch-bend>
                    :time
                    time
                    :channel
                    ch
                    :bend
                    (- (+ (pitch-bend-lsb m)
                          (* 128 (pitch-bend-msb m)))
                       8192)))
                 ((channel-pressure-p m)
                  (make-instance
                    <midi-channel-pressure>
                    :time
                    time
                    :channel
                    ch
                    :pressure
                    (channel-pressure-pressure m)))
                 (t (error "Message not supported: ~S." m))))
          ((midi-meta-message-p m)
           (cond ((time-signature-p m)
                  (make-instance
                    <midi-time-signature>
                    :time
                    time
                    :numerator
                    (elt data 1)
                    :denominator
                    (expt 2 (elt data 2))
                    :clocks
                    (elt data 3)
                    :32nds
                    (elt data 4)))
                 ((key-signature-p m)
                  (let ((a (elt data 1)))
                    (make-instance
                      <midi-key-signature>
                      :time
                      time
                      :key
                      (or (and (logtest a 128) (- a 256)) a)
                      :mode
                      (elt data 2))))
                 ((tempo-change-p m)
                  (make-instance
                    <midi-tempo-change>
                    :time
                    time
                    :usecs
                    (+ (ash (elt data 1) 16)
                       (ash (elt data 2) 8)
                       (elt data 3))))
                 ((sequence-number-p m)
                  (make-instance
                    <midi-sequencer-event>
                    :time
                    time
                    :number
                    (+ (ash (elt data 1) 8) (elt data 2))))
                 ((text-meta-event-p m)
                  (make-instance
                    <midi-text-event>
                    :time
                    time
                    :type
                    (meta-message-type m)
                    :text
                    (text-meta-event-data-to-string data)))
                 ((midi-port-p m)
                  (make-instance
                    <midi-port-event>
                    :time
                    time
                    :port
                    (elt data 1)))
                 ((midi-channel-p m)
                  (make-instance
                    <midi-chan-event>
                    :time
                    time
                    :chan
                    (elt data 1)))
                 ((eot-p m) (make-instance <midi-eot> :time time))
                 ((smpte-offset-p m)
                  (make-instance
                    <midi-smpte-offset>
                    :time
                    time
                    :offset
                    (loop for i from 1 to 5 collect (elt data i))))
                  ((sequencer-event-p m)
                   (make-instance
                     <midi-sequencer-event>
                     :time
                     time
                     :data
                     data))
                  (t
                   (error "Shouldnt: message not implemented: ~S."
                          m))))
           ((midi-system-message-p m)
            (let ((type (ldb +enc-lower-status-byte+ m))
                  (size (midimsg-size m))
                  (data '()))
              (cond ((= size 3)
                     (setf data
                           (list (midimsg-data1 m)
                                 (midimsg-data2 m))))
                    ((= size 2) (setf data (list (midimsg-data1 m))))
                    ((sysex-p m)
                     (setf data
                           (loop for i from 1 below (- size 1)
                                 collect (elt data i)))))
                    (make-instance
                      <midi-system-event>
                      :time
                      time
                      :type
                      type
                      :data
                      data)))
            (t (error "message not supported: ~S." m)))))

(defobject midi (event)
 ((keynum :initform 60) (duration :initform 0.5)
  (amplitude :initform 64)
  (channel :initform 0 :accessor midi-channel))
 (:parameters time duration keynum amplitude channel)
 (:event-streams))

(defparameter *midi-skip-drum-channel* ())

(defmacro ensure-microtuning (keyn chan stream)
  `(let ((num nil) (rem nil) (dat nil))
     (cond ((integerp ,keyn)
            (if (not (integerp ,keyn)) (setf ,keyn (round ,keyn))))
           ((and ,keyn (symbolp ,keyn)) (setf ,keyn (keynum ,keyn)))
           ((numberp ,keyn)
            (setf dat (midi-stream-tunedata ,stream))
            (if (null dat)
                (setf ,keyn
                      (if (floatp ,keyn)
                          (round ,keyn)
                          (round ,keyn)))
                (if (eq (car dat) t)
                    (progn (setf num (cadr dat))
                           (let ((int
                                  (if
                                   (floatp ,keyn)
                                   (floor ,keyn)
                                   (floor ,keyn))))
                             (setf rem (- ,keyn int))
                             (setf ,keyn int))
                           (if (and
                                *midi-skip-drum-channel*
                                (= (+ (cadddr dat) num) 8))
                               (incf num))
                           (if (< num (caddr dat))
                               (setf num (+ num 1))
                               (setf num 0))
                           (rplaca (cdr dat) num)
                           (setf ,chan (+ (cadddr dat) num))
                           (midi-write-message
                            (make-pitch-bend ,chan rem
                             (car (cddddr dat)))
                            ,stream 0 nil))
                    (progn (setf num (cadr dat))
                           (let* ((qkey (quantize ,keyn (/ num)))
                                  (int (floor qkey)))
                             (setf rem (- qkey int))
                             (setf ,keyn int))
                           (setf ,chan
                                 (+
                                  (car dat)
                                  (floor (* rem num))))))))
           (t
            (error "midi keynum ~s not key number or note." ,keyn)))))

(defmacro ensure-velocity (ampl keyn)
  `(cond ((integerp ,ampl)
          (if (= ,ampl 0)
              (setf ,keyn -1)
              (if (<= 1 ,ampl 127)
                  nil
                  (error "MIDI: integer amplitude ~s not 0-127 inclusive."
                         ,ampl))))
         ((floatp ,ampl)
          (if (= ,ampl 0.0)
              (setf ,keyn -1)
              (if (<= 0.0 ,ampl 1.0)
                  (setf ,ampl (floor (* ,ampl 127)))
                  (error "MIDI: float amplitude ~s is not 0.0-1.0 inclusive."
                         ,ampl))))
         (t
          (error "MIDI amplitude ~s not integer 0-127 or float 0.0-1.0."
                 ,ampl))))

(defmethod write-event ((obj midi) (mf midi-file) time)
  (let ((beats time)
        (scaler (midi-file-scaler mf))
        (keyn (midi-keynum obj))
        (chan (midi-channel obj))
        (ampl (midi-amplitude obj))
        (last nil))
    (ensure-velocity ampl keyn)
    (ensure-microtuning keyn chan mf)
    (unless (< keyn 0)
      (setf last
            (if (null (%q-head %offs))
                (object-time mf)
                (flush-pending-offs mf beats)))
      (midi-write-message (make-note-on chan keyn ampl) mf
       (if (> beats last) (round (* (- beats last) scaler)) 0) nil)
      (setf (object-time mf) beats)
      (%q-insert
       (%qe-alloc %offs (+ beats (midi-duration obj)) nil
        (make-note-off chan keyn 127) *qentry-message*)
       %offs))
    (values)))

(defmethod write-event ((obj midi-event) (mf midi-file) time)
  (multiple-value-bind (msg data)
      (midi-event->midi-message obj)
    (let ((beats time) (last nil))
      (setf last
            (if (null (%q-head %offs))
                (object-time mf)
                (flush-pending-offs mf beats)))
      (cond ((> beats last)
             (midi-write-message msg mf
              (round (* (- beats last) (midi-file-scaler mf))) data)
             (setf (object-time mf) beats))
            (t (midi-write-message msg mf 0 data)))
      (values))))

(defmethod object->midi (obj)
  (error "No object->midi method defined for ~s." obj))

(defmethod write-event ((obj standard-object) (mf midi-file)
                        scoretime)
  (write-event (object->midi obj) mf scoretime))

(defparameter midi-channel-names (vector
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil
                                  nil))

(defun midi-channel->name (chan) (elt midi-channel-names chan))

(define-list-struct tc ticks scaler offset)

(defmethod import-events ((io midi-file) &key (tracks t) seq
                          meta-exclude channel-exclude
                          (time-format ':beats) tempo exclude-tracks
                          (keynum-format ':keynum) channel-tuning
                          (pitch-bend-width *midi-pitch-bend-width*)
                          (note-off-stack t))
  (let ((results '())
        (notefn nil)
        (result nil)
        (class nil)
        (root nil)
        (tempo-map nil)
        (num-tracks nil))
    (if exclude-tracks
        (if tracks
            (if (eq tracks t)
                (setf tracks nil)
                (error ":tracks and :exclude-tracks are exclusive keywords."))
            (cond ((integerp exclude-tracks)
                   (setf exclude-tracks (list exclude-tracks)))
                  ((consp exclude-tracks))
                  (t
                   (error ":exclude-tracks value '~s' not number, list or ~s."
                          exclude-tracks
                          t))))
        (cond ((eq tracks t))
              ((consp tracks))
              ((integerp tracks) (setf tracks (list tracks)))
              (t
               (error ":tracks value '~s' not number, list or ~s."
                      tracks
                      t))))
    (case time-format
      ((:ticks) t)
      ((:beats) t)
      (t
       (error ":time-format value ~s is not :beats or :ticks."
              time-format)))
    (case keynum-format
      ((:keynum nil) t)
      ((:note) (setf notefn #'note))
      ((:hertz) (setf notefn #'hertz))
      (t
       (error ":keynum-format value '~s' not :keynum, :note or :hertz."
              keynum-format)))
    (unless (member channel-exclude '(t nil))
      (unless (consp channel-exclude)
        (setf channel-exclude (list channel-exclude)))
      (dolist (e channel-exclude)
        (unless (and (integerp e)
                     (<= +ml-note-off-opcode+
                         e
                         +ml-pitch-bend-opcode+))
          (error ":channel-exclude value '~s' not a channel message opcode."
                 e))))
    (unless (member meta-exclude '(t nil))
      (unless (consp meta-exclude)
        (setf meta-exclude (list meta-exclude)))
      (dolist (e meta-exclude)
        (unless (and (integerp e)
                     (or (<= +ml-file-text-event-opcode+
                             e
                             +ml-file-cue-point-opcode+)
                         (<= +ml-file-tempo-change-opcode+
                             e
                             +ml-file-sequencer-event-opcode+)))
          (error ":meta-exclude value '~s' not a meta message opcode."
                 e))))
    (with-open-io (file io :input)
     (cond ((= 1 (midi-file-format file))
            (setf num-tracks (midi-file-tracks file))
            (if tracks
                (if (eq tracks t)
                    (setf tracks
                          (loop for i below num-tracks collect i)))
                    (setf tracks
                          (loop for i below num-tracks
                                unless (member i exclude-tracks)
                                collect i))))
                    (t
                     (setf num-tracks 1)
                     (if (eq tracks t) (setf tracks (list 0)))))
                (cond ((typep seq <seq>))
                      ((or (not seq) (find-class seq))
                       (setf class (or seq <seq>))
                       (setf root
                             (format
                              nil
                              "~a-track"
                              (filename-name
                               (file-output-filename io))))
                       (setf seq nil))
                      (t
                       (setf root (format nil "~s" seq))
                       (setf class <seq>)
                       (setf seq nil)))
                (when (and (eq time-format ':beats) (not tempo))
                  (setf tempo-map (parse-tempo-map file)))
                (dolist (track tracks)
                  (when (consp track)
                    (setf channel-exclude
                          (if (numberp (second track))
                              (list (second track))
                              (second track)))
                    (setf meta-exclude
                          (if (numberp (third track))
                              (list (third track))
                              (third track)))
                    (setf track (first track)))
                  (cond ((<= 0 track (- num-tracks 1))
                         (unless seq
                           (setf seq
                                 (make-instance
                                  class
                                  :name
                                  (format nil "~a-~s" root track))))
                         (setf result
                               (midi-file-import-track
                                file
                                track
                                seq
                                notefn
                                note-off-stack
                                channel-exclude
                                meta-exclude
                                (if
                                 (eq channel-tuning t)
                                 0
                                 channel-tuning)
                                pitch-bend-width))
                         (push result results)
                         (setf seq nil))
                        (t
                         (error "track '~s' out of range. Maximum track is ~s."
                                track
                                (- num-tracks 1)))))
                (setf results (reverse results))
                (cond ((and (eq time-format ':beats)
                            (not tempo)
                            (consp (cdr tempo-map)))
                       (let ((div (midi-file-divisions file)))
                         (dolist (tr results)
                           (apply-tempo-map div tempo-map tr))))
                      ((not (eq time-format :ticks))
                       (let ((div (midi-file-divisions file))
                             (scaler
                              (if
                               tempo
                               (/ 60.0 tempo)
                               (if
                                (consp tempo-map)
                                (* (tc-scaler (car tempo-map)) 1.0)
                                0.5))))
                         (dolist (tr results)
                           (apply-tempo-scaler div scaler tr)))))
                (if (null results)
                    nil
                    (if (null (cdr results))
                        (car results)
                        results)))))

(defun apply-tempo-scaler (divs scaler track)
  (let ((mult (/ scaler divs)))
    (dolist (e (container-subobjects track))
      (setf (object-time e) (* (object-time e) mult))
      (when (typep e <midi>)
        (setf (midi-duration e) (* (midi-duration e) mult))))))

(defun tempo-change->scaler (msg data)
  msg
  (/ (+ (ash (elt data 1) 16) (ash (elt data 2) 8) (elt data 3))
     1000000))

(defun parse-tempo-map (mf)
  (midi-file-set-track mf 0)
  (let ((res (list)) (div (midi-file-divisions mf)))
    (midi-file-map-track
     (lambda (mf)
       (let ((m (midi-file-message mf)))
         (when (tempo-change-p m)
           (push (make-tc :ticks (midi-file-ticks mf) :scaler
                  (tempo-change->scaler m (midi-file-data mf))
                  :offset 0.0)
                 res))))
     mf)
    (setf res (nreverse res))
    (when (or (null res) (not (equal 0 (tc-ticks (car res)))))
      (push (make-tc :ticks 0 :scaler 1/2 :offset 0.0) res))
    (unless (null (cdr res))
      (let ((last (car res)))
        (dolist (this (cdr res))
          (tc-offset-set! this
           (+ (tc-offset last)
              (* (/ (- (tc-ticks this) (tc-ticks last)) div)
                 (tc-scaler last))))
          (setf last this))))
    res))

(defun apply-tempo-map (divs tmap track)
  (let ((data (container-subobjects track))
        (this (pop tmap))
        (flag t))
    (loop while flag
          do (loop while (and (consp data)
                              (or
                               (null tmap)
                               (<
                                (object-time (car data))
                                (tc-ticks (car tmap)))))
                   do (setf (object-time (car data))
                            (+ (tc-offset this)
                               (*
                                (tc-scaler this)
                                (/
                                 (-
                                  (object-time (car data))
                                  (tc-ticks this))
                                 divs))))
                      (when (typep (car data) <midi>)
                        (setf (midi-duration (car data))
                              (*
                               (/ (midi-duration (car data)) divs)
                               (tc-scaler this)
                               1.0)))
                      (setf data (cdr data)))
                   (unless (null tmap) (setf this (pop tmap)))
                   (if (null data) (setf flag nil)))
             track))

(defun midi-file-import-track (file
                               track
                               seq
                               notefn
                               note-off-stack
                               channel-exclude
                               meta-exclude
                               channel-tuning
                               pb-width)
  (let* ((data '())
         (tune
          (if channel-tuning (make-array 16 :initial-element 0) nil))
         (tabl (make-hash-table :size 31 :test #'equal)))
    (flet ((mapper (mf)
             (let* ((b (midi-file-ticks mf))
                    (m (midi-file-message mf))
                    (s (channel-message-opcode m))
                    (n nil))
               (cond ((channel-message-p m)
                      (cond ((and
                              channel-exclude
                              (or
                               (eq channel-exclude t)
                               (member s channel-exclude)))
                             (setf n nil))
                            ((or
                              (= s +ml-note-off-opcode+)
                              (and
                               (= s +ml-note-on-opcode+)
                               (= 0 (channel-message-data2 m))))
                             (let
                              ((on
                                (if
                                 note-off-stack
                                 (let
                                  ((l
                                    (gethash
                                     (channel-note-hash m)
                                     tabl))
                                   (v nil))
                                  (when
                                   (and l (not (null l)))
                                   (setf v (car l))
                                   (setf
                                    (gethash
                                     (channel-note-hash m)
                                     tabl)
                                    (cdr l)))
                                  v)
                                 (let
                                  ((x
                                    (gethash
                                     (channel-note-hash m)
                                     tabl)))
                                  (if
                                   x
                                   (if
                                    (not (null (cdr x)))
                                    (let*
                                     ((tail
                                       (loop with a = x
                                        and b = (cdr x)
                                        until (null (cdr b))
                                        do (setf a b)
                                        (setf b (cdr b))
                                        finally (return a)))
                                       (obj (cadr tail)))
                                      (setf (cdr tail) (list))
                                      obj)
                                     (progn
                                      (setf
                                       (gethash
                                        (channel-note-hash m)
                                        tabl)
                                       (list))
                                      (car x)))
                                    nil)))))
                               (if
                                on
                                (setf
                                 (midi-duration on)
                                 (- b (object-time on)))
                                (format
                                 t
                                 "~%No Note-On for channel ~s keynum ~s."
                                 (channel-message-channel m)
                                 (channel-message-data1 m)))))
                             ((= s +ml-note-on-opcode+)
                              (setf
                               n
                               (make-instance
                                <midi>
                                :time
                                b
                                :keynum
                                (if
                                 notefn
                                 (funcall
                                  notefn
                                  (channel-message-data1 m))
                                 (if
                                  channel-tuning
                                  (+
                                   (channel-message-data1 m)
                                   (elt
                                    tune
                                    (channel-message-channel m)))
                                  (channel-message-data1 m)))
                                :channel
                                (channel-message-channel m)
                                :amplitude
                                (/ (channel-message-data2 m) 127.0)))
                              (let
                               ((v
                                 (gethash
                                  (channel-note-hash m)
                                  tabl)))
                               (if
                                (not v)
                                (setf
                                 (gethash (channel-note-hash m) tabl)
                                 (list n))
                                (setf
                                 (gethash (channel-note-hash m) tabl)
                                 (cons n v)))))
                             ((and
                               channel-tuning
                               (= s +ml-pitch-bend-opcode+))
                              (setf
                               (elt tune (channel-message-channel m))
                               (decimals
                                (rescale
                                 (-
                                  (+
                                   (pitch-bend-lsb m)
                                   (* 128 (pitch-bend-msb m)))
                                  8192)
                                 -8192
                                 8191
                                 (- pb-width)
                                 pb-width)
                                2)))
                             (t
                              (setf
                               n
                               (midi-message->midi-event
                                m
                                :time
                                b)))))
                      ((meta-message-p m)
                       (unless (and
                                meta-exclude
                                (or
                                 (eq meta-exclude t)
                                 (eot-p m)
                                 (member
                                  (ldb +enc-data-1-byte+ m)
                                  meta-exclude)))
                         (setf n
                               (midi-message->midi-event
                                m
                                :time
                                b
                                :data
                                (midi-file-data mf)))))
                      (t
                       (setf n
                             (midi-message->midi-event m :time b))))
                     (when n (push n data)))))
           (midi-file-set-track file track)
           (midi-file-map-track #'mapper file))
      (setf (container-subobjects seq) (nreverse data))
      seq))
