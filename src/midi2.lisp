;;; **********************************************************************
;;; Copyright (C) 2009 Heinrich Taube, <taube (at) uiuc (dot) edu>
;;;
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the Lisp Lesser Gnu Public License.
;;; See http://www.cliki.net/LLGPL for the text of this agreement.
;;; **********************************************************************

;;; generated by scheme->cltl from midi2.scm on 04-Aug-2009 14:11:46

(in-package :cm)

(defparameter *midi-pitch-bend-width* 2)

(defparameter *midi-channel-map* (let*
                                  ((l (list nil)) (h l))
                                  (do
                                   ((p 0 (+ p 1)))
                                   ((= p 8)
                                    (apply #'vector (cdr l)))
                                   (do
                                    ((c 0 (+ c 1)))
                                    ((= c 16) nil)
                                    (rplacd h (list (list p c)))
                                    (setf h (cdr h))))))

(defun logical-channel (chan map)
  (if (vectorp map) (elt map chan) (elt map chan)))

(defparameter %midituningtypes (quote
                                ((t
                                  :note
                                  note
                                  :note-by-note
                                  note-by-note)
                                 (1
                                  :12-note
                                  12-note
                                  :12-tone
                                  12-tone)
                                 (2
                                  24
                                  :24-note
                                  24-note
                                  :24-tone
                                  24-tone)
                                 (3
                                  36
                                  :36-note
                                  36-note
                                  :36-tone
                                  36-tone)
                                 (4
                                  48
                                  :48-note
                                  48-note
                                  :48-tone
                                  48-tone)
                                 (5
                                  60
                                  :60-note
                                  60-note
                                  :60-tone
                                  60-tone)
                                 (6
                                  72
                                  :72-note
                                  72-note
                                  :72-tone
                                  72-tone)
                                 (7
                                  84
                                  :84-note
                                  84-note
                                  :84-tone
                                  84-tone)
                                 (8
                                  96
                                  :96-note
                                  96-note
                                  :96-tone
                                  96-tone)
                                 (9
                                  108
                                  :108-note
                                  108-note
                                  :108-tone
                                  108-note)
                                 (10
                                  120
                                  :120-note
                                  120-note
                                  :120-tone
                                  120-tone)
                                 (11
                                  132
                                  :132-note
                                  132-note
                                  :132-tone
                                  132-tone)
                                 (12
                                  144
                                  :144-note
                                  144-note
                                  :144-tone
                                  144-tone)
                                 (13
                                  156
                                  :156-note
                                  156-note
                                  :156-tone
                                  156-tone)
                                 (14
                                  :168-note
                                  168-note
                                  :168-tone
                                  168-tone)
                                 (15
                                  :180-note
                                  180-note
                                  :180-tone
                                  180-tone)
                                 (16
                                  :180-note
                                  180-note
                                  :180-tone
                                  180-tone))))

(progn (defclass midi-stream-mixin ()
         ((channel-map :initform *midi-channel-map* :initarg
           :channel-map :accessor midi-stream-channel-map)
          (bend-width :accessor midi-stream-bend-width :initarg
           :pitch-bend-width :initform *midi-pitch-bend-width*)
          (channel-tuning :initarg :channel-tuning :initarg
           :microtuning :initform nil :accessor
           midi-stream-channel-tuning)
          (tunedata :initform '() :accessor midi-stream-tunedata
           :initarg :tuning-channels)))
       (defparameter <midi-stream-mixin> (find-class
                                          'midi-stream-mixin))
       (finalize-class <midi-stream-mixin>)
       (values))

(defparameter *midi-file-default-tempo* 60)

(progn (defclass midi-file (event-file midi-stream-mixin)
         ((elt-type :initform :byte :initarg :elt-type :accessor
           file-elt-type)
          (keysig :initform nil :initarg :keysig :accessor
           midi-file-keysig)
          (timesig :initform nil :initarg :timesig :accessor
           midi-file-timesig)
          (tempo :initform *midi-file-default-tempo* :initarg :tempo
           :accessor midi-file-tempo)
          (scaler :initform 1 :accessor midi-file-scaler)
          (status :initform 0 :accessor midi-file-status)
          (size :initform 0 :accessor midi-file-size)
          (tracks :initform 1 :accessor midi-file-tracks)
          (track :initform -1 :initarg :track :accessor
           midi-file-track)
          (tracklen :initform 0 :accessor midi-file-tracklen)
          (divisions :initform 480 :initarg :divisions :accessor
           midi-file-divisions)
          (resolution :initform nil :initarg :resolution :accessor
           midi-file-resolution)
          (format :initform
                  0
                  :initarg
                  :format
                  :accessor
                  midi-file-format)
          (ticks :initform nil :accessor midi-file-ticks)
          (delta :initform nil :accessor midi-file-delta)
          (message :initform nil :accessor midi-file-message)
          (data :initform '() :accessor midi-file-data))
         #+metaclasses
         (:metaclass io-class))
       (defparameter <midi-file> (find-class 'midi-file))
       (finalize-class <midi-file>)
       (setf (io-class-file-types <midi-file>) '("*.midi" "*.mid"))
       (values))

(defun set-midi-output-hook! (fn)
  (unless (or (not fn) (functionp fn))
    (error "Not a midi hook: ~s" fn))
  (setf (io-class-output-hook <midi-file>) fn)
  (values))

(defparameter *midi-player* (let ((os (os-name)))
                             (cond
                              ((member os '(darwin osx macos macosx))
                               (cond
                                ((probe-file
                                  "/usr/local/bin/timidity")
                                 "/usr/local/bin/timidity")
                                ((probe-file "/usr/local/bin/qtplay")
                                 "/usr/local/bin/qtplay")
                                (t "open")))
                              ((member os '(unix linux cygwin))
                               "timidity")
                              ((member os '(win32 windows))
                               (let
                                ((mp
                                  "/Program Files/Windows Media Player/mplayer2.exe"))
                                (if (probe-file mp) mp nil)))
                              (t nil))))

(defun play-midi-file (file &rest args)
  (if (getf args ':play t)
      (if *midi-player*
          (let* ((cmd *midi-player*)
                 (tyo (getf args ':verbose))
                 (wai (getf args ':wait)))
            (setf cmd (concatenate 'string *midi-player* " " file))
            (if tyo (format t "~%; ~a" cmd))
            (shell cmd :wait wai :output nil)
            file)
          nil)
      nil))

(set-midi-output-hook! #'play-midi-file)

(defparameter +midi-file-header-length+ 14)

(defparameter +miditrack-header-length+ 8)

(defparameter +mthd+ 1297377380)

(defparameter +mtrk+ 1297379947)

(defun read-bytes (fp n)
  (do ((s 0) (i 0 (+ i 1)))
      ((>= i n) s)
    (setf s (+ (ash s 8) (read-byte fp)))))

(defun write-bytes (fp byts n)
  (do ((pos (* (- n 1) 8) (- pos 8)))
      ((< pos 0) (values))
    (write-byte (ash (logand byts (ash 255 pos)) (- pos)) fp)))

(defun read-variable-quantity (fp)
  (let* ((b (read-byte fp)) (n (logand b 127)))
    (do ()
        ((not (logtest 128 b)) n)
      (setf b (read-byte fp))
      (setf n (+ (ash n 7) (logand b 127))))))

(defun write-variable-quantity (n fp)
  (when (>= n 2097152)
    (write-byte (logior (logand (ash n -21) 127) 128) fp))
  (when (>= n 16384)
    (write-byte (logior (logand (ash n -14) 127) 128) fp))
  (when (>= n 128)
    (write-byte (logior (logand (ash n -7) 127) 128) fp))
  (write-byte (logand n 127) fp)
  (values))

(defun variable-quantity-length (n)
  (let ((l 1))
    (if (>= n 2097152) (setf l (+ 1 l)))
    (if (>= n 16384) (setf l (+ 1 l)))
    (if (>= n 128) (setf l (+ 1 l)))
    l))

(defun midi-file-read-header (mf)
  (let* ((fp (io-open mf)) (bytes (read-bytes fp 4)))
    (unless (= bytes +mthd+)
      (error "Expected midi-file header mark but got ~s instead."
             bytes))
    (read-bytes fp 4)
    (values (read-bytes fp 2) (read-bytes fp 2) (read-bytes fp 2))))

(defun midi-file-write-header (mf
                               fmat
                               tracks
                               division
                               &rest
                               resolution)
  (let ((fp (io-open mf)))
    (write-bytes fp +mthd+ 4)
    (write-bytes fp 6 4)
    (write-bytes fp fmat 2)
    (write-bytes fp tracks 2)
    (if (null resolution)
        (write-bytes fp division 2)
        (progn (write-bytes fp (+ (- division) 256) 1)
               (write-bytes fp (car resolution) 1)))
    (values)))

(defun midi-file-read-track-header (mf)
  (let* ((fp (io-open mf)) (byts (read-bytes fp 4)))
    (unless (= byts +mtrk+)
      (error "Expected midi-file track mark but got ~s instead."
             byts))
    (read-bytes fp 4)))

(defun midi-file-write-track-header (mf len)
  (let ((fp (io-open mf)))
    (write-bytes fp +mtrk+ 4)
    (write-bytes fp len 4)
    (values)))

(defun midi-file-read-message (mf)
  (let ((fp (io-open mf)) (ticks 0) (byte 0) (size 0) (raw 0))
    (setf ticks (read-variable-quantity fp))
    (setf (midi-file-delta mf) ticks)
    (setf (midi-file-data mf) nil)
    (when (> ticks 0)
      (setf (midi-file-ticks mf) (+ (midi-file-ticks mf) ticks)))
    (setf byte (read-byte fp))
    (cond ((< byte 240)
           (if (logtest byte 128)
               (progn (setf raw byte)
                      (setf (midi-file-status mf) byte)
                      (setf size
                            (elt +channel-message-sizes+
                                 (ash (logand byte 112) -4)))
                      (setf (midi-file-size mf) size))
               (progn (setf raw
                            (logior (ash (midi-file-status mf) 8)
                                    byte))
                      (setf size (- (midi-file-size mf) 1))))
           (when (> size 1)
             (dotimes (i (- size 1))
               (setf raw (logior (ash raw 8) (read-byte fp)))))
           (setf (midi-file-message mf)
                 (%midi-encode-channel-message raw
                  (midi-file-size mf)))
           (values (midi-file-message mf)))
          ((= byte +ml-file-meta-marker+)
           (setf byte (read-byte fp))
           (cond ((= byte +ml-file-eot-opcode+)
                  (read-byte fp)
                  (multiple-value-bind (m d)
                      (make-eot)
                    (setf (midi-file-message mf) m)
                    (setf (midi-file-data mf) d)
                    (values m)))
                 ((= byte +ml-file-tempo-change-opcode+)
                  (read-variable-quantity fp)
                  (let ((usecs
                         (logior (ash (read-byte fp) 16)
                                 (ash (read-byte fp) 8)
                                 (read-byte fp))))
                    (multiple-value-bind (m d)
                        (make-tempo-change usecs)
                      (setf (midi-file-message mf) m)
                      (setf (midi-file-data mf) d)
                      (values m))))
                 ((= byte +ml-file-time-signature-opcode+)
                  (let ((len (read-variable-quantity fp)))
                    (unless (= len 4)
                      (error "unexpected time signature length: ~s"
                             len))
                    (multiple-value-bind (m d)
                        (apply #'make-meta-message
                               +ml-file-time-signature-opcode+
                               (loop repeat len
                                collect (read-byte fp)))
                          (setf (midi-file-message mf) m)
                          (setf (midi-file-data mf) d)
                          (values m))))
                  (t
                   (setf size (read-variable-quantity fp))
                   (multiple-value-bind (m d)
                       (apply #'make-meta-message
                              byte
                              (loop repeat size
                               collect (read-byte fp)))
                         (setf (midi-file-message mf) m)
                         (setf (midi-file-data mf) d)
                         (values m)))))
                 (t
                  (setf size (read-variable-quantity fp))
                  (dotimes (i size) (read-byte fp))
                  (midi-file-read-message mf)))))

(defun midi-file-unread-message (mf msg &rest args)
  (let ((fp (io-open mf)) (delta (if (null args) 0 (car args))))
    (set-file-position fp
     (- (+ (midimsg-size msg) (variable-quantity-length delta)))
     nil)))

(defmethod midi-write-message ((msg number) (mf midi-file) time data)
  (let ((fp (io-open mf))
        (size (midimsg-size msg))
        (type (midimsg-upper-status msg)))
    (write-variable-quantity time fp)
    (cond ((< 0 type 15)
           (write-byte (logior (ldb +enc-lower-status-byte+ msg)
                               (ash
                                (ldb +enc-upper-status-byte+ msg)
                                4))
                       fp)
           (when (> size 1)
             (write-byte (ldb +enc-data-1-byte+ msg) fp))
           (when (> size 2)
             (write-byte (ldb +enc-data-2-byte+ msg) fp)))
          ((= type +ml-meta-type+)
           (write-byte 255 fp)
           (write-byte (ldb +enc-data-1-byte+ msg) fp)
           (loop for i below (length data)
                 do (write-byte (elt data i) fp)))
           ((= type 15)
            (let ((byt
                   (logior (ash type 4) (midimsg-lower-status msg))))
              (write-byte byt fp)
              (case byt
                ((240)
                 (write-variable-quantity (- (length data) 1) fp)
                 (loop for i from 1 below (length data)
                       do (write-byte (elt data i) fp)))
                 ((242) (write-byte (ldb +enc-data-1-byte+ msg) fp)
                  (write-byte (ldb +enc-data-2-byte+ msg) fp))
                 ((243) (write-byte (ldb +enc-data-1-byte+ msg) fp))
                 ((246) nil)
                 (t
                  (error "~s is not a valid system message type."
                         byt)))))
            (t (error "msg type neither meta nor system! ")))
           (values)))

(defun midi-file-map-track (fn mf &rest args)
  (let ((beg (if (null args) nil (pop args)))
        (end (if (null args) nil (pop args))))
    beg
    end
    (do ((msg (midi-file-read-message mf)
          (midi-file-read-message mf)))
        ((eot-p msg) (setf (midi-file-track mf) nil) t)
      (funcall fn mf))))

(defun midi-file-set-track (mf track)
  (let ((fil (io-open mf)))
    (setf (midi-file-track mf) track)
    (setf (midi-file-ticks mf) 0)
    (loop for p = +midi-file-header-length+ then
              (+ p 8 (midi-file-read-track-header mf))
          for c from 0
          do (set-file-position fil p t)
          while (< c track))
          (setf (midi-file-tracklen mf)
                (midi-file-read-track-header mf))
          track))

(defun channel-tuning-init (io)
  (let ((tuning (midi-stream-channel-tuning io)))
    (if (not tuning)
        (progn (setf (midi-stream-tunedata io) '()))
        (let ((tune nil) (num1 nil) (num2 nil) (data nil) (type nil))
          (if (consp tuning)
              (setf tune (pop tuning))
              (progn (setf tune tuning) (setf tuning nil)))
          (setf type
                (find-if (lambda (x) (member tune x))
                         %midituningtypes))
          (cond ((eq type (car %midituningtypes))
                 (if (consp tuning)
                     (progn (setf num1 (pop tuning))
                            (setf num2 (or (pop tuning) 15)))
                     (progn (setf num1 0) (setf num2 15)))
                 (unless (<= 0 num1 num2 15)
                   (error "tuning range ~s-~s not in channel range 0-15."
                          num1
                          num2))
                 (setf data
                       (list t
                             (- num2 num1)
                             (- num2 num1)
                             num1
                             (midi-stream-bend-width io))))
                ((not (null type))
                 (setf tune (car type))
                 (setf num1 (if (consp tuning) (pop tuning) 0))
                 (setf num2 tune)
                 (when (> (+ num1 num2) 15)
                   (error "tuning range ~s-~s not in channel range 0-15."
                          num1
                          (+ num1 num2)))
                 (if (equal tune 1)
                     (progn (microtune-channels io 1
                             (midi-stream-bend-width io) 0)
                            (setf data '()))
                     (progn (microtune-channels io num2
                             (midi-stream-bend-width io) num1)
                            (setf data (list num1 num2)))))
                (t
                 (error "~s is not a midi tuning. Valid tunings: ~s"
                        (midi-stream-channel-tuning io)
                        (mapcar #'car %midituningtypes))))
          (setf (midi-stream-tunedata io) data)
          data))))

(defun microtune-channels (io divisions &optional
                           (width *midi-pitch-bend-width*)
                           (channel-offset 0))
  (if (= divisions 1)
      (loop for c below 16
            for m =
                (make-instance
                  (find-class 'midi-pitch-bend)
                  :channel
                  c
                  :time
                  0
                  :bend
                  0)
            do (write-event m io 0))
            (loop repeat divisions
                  for c from channel-offset
                  for m =
                      (let ((bend
                             (round
                              (rescale
                               (/ c divisions)
                               (- width)
                               width
                               -8192
                               8191))))
                        (make-instance
                          (find-class 'midi-pitch-bend)
                          :channel
                          c
                          :time
                          0
                          :bend
                          bend))
                  do (write-event m io 0))))

(defparameter %offs (make-cycl))

(dotimes (i 50) (%qe-dealloc %offs (list nil nil nil nil)))

(defmethod open-io :after ((mf midi-file) dir &rest args) args (if
                                                                (eq
                                                                 dir
                                                                 ':output)
                                                                (let
                                                                 ((div
                                                                   (midi-file-divisions
                                                                    mf)))
                                                                 (setf
                                                                  (midi-file-track
                                                                   mf)
                                                                  0)
                                                                 (setf
                                                                  (midi-file-scaler
                                                                   mf)
                                                                  (*
                                                                   div
                                                                   1.0))
                                                                 (midi-file-write-header
                                                                  mf
                                                                  0
                                                                  1
                                                                  div)
                                                                 (midi-file-write-track-header
                                                                  mf
                                                                  0))
                                                                (multiple-value-bind
                                                                 (fmat
                                                                  tracks
                                                                  divisions)
                                                                 (midi-file-read-header
                                                                  mf)
                                                                 (setf
                                                                  (midi-file-format
                                                                   mf)
                                                                  fmat)
                                                                 (setf
                                                                  (midi-file-tracks
                                                                   mf)
                                                                  tracks)
                                                                 (setf
                                                                  (midi-file-divisions
                                                                   mf)
                                                                  divisions))) mf)

(defmethod initialize-io ((mf midi-file))
  (when (eq (io-direction mf) ':output)
    (let ((msg nil) (data nil))
      (setf (object-time mf) 0)
      (when (midi-file-tempo mf)
        (multiple-value-setq (msg data)
          (make-tempo-change
           (floor (* 1000000 (/ 60 (midi-file-tempo mf))))))
        (midi-write-message msg mf 0 data))
      (when (midi-file-timesig mf)
        (multiple-value-setq (msg data)
          (apply #'make-time-signature (midi-file-timesig mf)))
        (midi-write-message msg mf 0 data))
      (when (midi-file-keysig mf)
        (multiple-value-setq (msg data)
          (apply #'make-key-signature (midi-file-keysig mf)))
        (midi-write-message msg mf 0 data))
      (channel-tuning-init mf)))
  (values))

(defmethod deinitialize-io ((mf midi-file))
  (when (eq (io-direction mf) ':output)
    (flush-pending-offs mf most-positive-fixnum)))

(defmethod close-io :before ((mf midi-file) &rest mode) mode (when
                                                              (eq
                                                               (io-direction
                                                                mf)
                                                               ':output)
                                                              (multiple-value-bind
                                                               (m d)
                                                               (make-eot)
                                                               (midi-write-message
                                                                m
                                                                mf
                                                                0
                                                                d))
                                                              (let*
                                                               ((fp
                                                                 (io-open
                                                                  mf))
                                                                (off
                                                                 (+
                                                                  +midi-file-header-length+
                                                                  +miditrack-header-length+))
                                                                (end
                                                                 (set-file-position
                                                                  fp
                                                                  0
                                                                  nil)))
                                                               (set-file-position
                                                                fp
                                                                +midi-file-header-length+
                                                                t)
                                                               (midi-file-write-track-header
                                                                mf
                                                                (-
                                                                 end
                                                                 off))
                                                               (setf
                                                                (midi-file-track
                                                                 mf)
                                                                nil)
                                                               (%q-flush
                                                                %offs))))

(defun flush-pending-offs (mf time)
  (let ((last (object-time mf)) (scaler (midi-file-scaler mf)))
    (do ((qe (%q-peek %offs) (%q-peek %offs)))
        ((or (null qe) (> (%qe-time qe) time)) last)
      (%q-pop %offs)
      (midi-write-message (%qe-object qe) mf
       (round (* (- (%qe-time qe) last) scaler)) nil)
      (setf last (%qe-time qe))
      (%qe-dealloc %offs qe)
      (setf (object-time mf) last))))

(defun midi-file-print (file &key (stream t) (track 0))
  (let ((old (find-object file nil)) (res nil))
    (if (probe-file file)
        (progn (with-open-io (io file :input)
                (format stream
                        "File: ~a ~%Format: ~s~%Tracks: ~s~%Division: ~s"
                        file
                        (midi-file-format io)
                        (midi-file-tracks io)
                        (midi-file-divisions io))
                (midi-file-set-track io track)
                (format stream
                        "~%Track ~s, length ~s~%"
                        (midi-file-track io)
                        (midi-file-tracklen io))
                (midi-file-map-track
                 (lambda (mf)
                   (let ((q (midi-file-delta mf))
                         (m (midi-file-message mf))
                         (d (midi-file-data mf)))
                     (midi-print-message m q :stream stream :data
                      d)))
                 io)
                (setf res io))
               (if (not old)
                   (remhash (string-downcase (object-name res))
                            *dictionary*))
               file)
        nil)))