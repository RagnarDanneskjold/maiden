#|
 This file is a part of Maiden
 (c) 2017 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.maiden.agents.lookup)

(define-consumer lookup (agent)
  ())

(define-command (lookup look-up) (c ev archive &string term)
  :command "look up"
  (destructuring-bind (url &optional title) (look-up archive term)
    (reply ev "~@[~@(~a~) ~]~a" title url)))

(defmacro define-shorthand-command (name &key (archive (string name)) (command (string name)))
  `(define-command (lookup ,name) (c ev &string term)
     :command ,command
     (issue (make-instance 'look-up :term term :archive ,(string archive) :dispatch-event ev)
            (core ev))))

(define-shorthand-command clhs)
(define-shorthand-command mop)
