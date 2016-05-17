#|
 This file is a part of Maiden
 (c) 2016 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.maiden.agents.commands)

(defvar *commands* ())

(defvar *framework-client* (make-instance 'client :name "FRAMEWORK"))
(defvar *framework-sender* (make-instance 'user :name "FRAMEWORK" :client *framework-client*))
(defvar *dispatch-event* NIL)
(defvar *alternative-distance-threshold* 10)

(define-event framework-message (message-event)
  ()
  (:default-initargs
   :client *framework-client*
   :sender *framework-sender*
   :message ""))

(defmethod reply ((event framework-message) format-string &rest format-args)
  (apply #'v:info :commands format-string format-args))

(define-event command-event (instruction-event)
  ((dispatch-event :initarg :dispatch-event :accessor dispatch-event))
  (:default-initargs
   :dispatch-event (or *dispatch-event* (make-instance 'framework-message))))

(define-consumer commands (agent)
  ())

(defmacro define-command-invoker (command (event &rest args) &body body)
  `(maiden::update-list
    (list ,(string-downcase command)
          (lambda (,event message)
            (with-command-destructuring-bind ,args message
              ,@body)))
    *commands* :key #'first :test #'string-equal))

(defmacro define-command ((consumer name) (instance event &rest args) &body body)
  (form-fiddle:with-body-options (body options command command-event-variable) body
    (let ((fun-kargs (loop for arg in (lambda-fiddle:extract-lambda-vars args)
                           collect (kw arg) collect arg))
          (command-event-variable (or command-event-variable (gensym "COMMAND-EVENT"))))
      `(progn (define-instruction (,consumer ,name) (,instance ,command-event-variable ,@args)
                :superclasses (command-event)
                ,@options
                (let* ((,event (dispatch-event ,command-event-variable))
                       (*dispatch-event* ,event))
                  ,@body))
              (define-command-invoker ,(or command (string name)) (,event ,@args)
                (issue (make-instance ',name :dispatch-event ,event ,@fun-kargs)
                       (event-loop ,event)))))))

(define-handler (commands processor message-event) (c ev message)
  (when (command-p ev)
    (multiple-value-bind (match alternatives) (find-matching-command message)
      (cond ((not (null match))
             (handler-case
                 (handler-bind ((error #'invoke-debugger))
                   (funcall (second match) ev (subseq message (1+ (length (first match))))))
               (command-condition (err)
                 (reply ev "Invalid command: ~a" err))
               (error (err)
                 (reply ev "Unexpected error: ~a" err))))
            ((null alternatives)
             (reply ev "I don't know what you mean."))
            (T
             (setf alternatives (sort alternatives #'compare-alternatives))
             (reply ev "Unknown command. Possible matches:~10{ ~a~}"
                    (mapcar #'second alternatives)))))))

(defmethod command-p ((event message-event))
  T)

(defun find-matching-command (message)
  (let ((match NIL)
        (alternatives ()))
    (loop for command in *commands*
          for prefix = (first command)
          for cut = (subseq message 0 (length prefix))
          for distance = (levenshtein-distance prefix cut)
          do (when (and (= 0 distance)
                        (or (null match) (< (length (first match))
                                            (length prefix))))
               (setf match command))
             (when (< distance *alternative-distance-threshold*)
               (push (cons distance command) alternatives)))
    (values match alternatives)))

(defun compare-alternatives (a b)
  (let ((a-distance (first a))
        (a-length (length (second a)))
        (b-distance (first b))
        (b-length (length (second b))))
    (or (< a-distance b-distance)
        (and (= a-distance b-distance)
             (< b-length a-length)))))

(defun levenshtein-distance (a b)
  (cond ((= 0 (length a)) (length b))
        ((= 0 (length b)) (length a))
        (T
         (let ((v0 (make-array (1+ (length b))))
               (v1 (make-array (1+ (length b)))))
           (dotimes (i (length v0)) (setf (aref v0 i) i))
           (dotimes (i (length a) (aref v1 (length b)))
             (incf (aref v1 0))
             (dotimes (j (length b))
               (let ((cost (if (char= (char a i) (char b j)) 0 1)))
                 (setf (aref v1 (1+ j)) (min (1+ (aref v1 j))
                                             (1+ (aref v0 (1+ j)))
                                             (+ cost (aref v0 j))))))
             (dotimes (j (length v0))
               (setf (aref v0 j) (aref v1 j))))))))