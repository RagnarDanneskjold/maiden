#|
 This file is a part of Maiden
 (c) 2016 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:maiden-user)
(defpackage #:maiden-quicklisp
  (:nicknames #:org.shirakumo.maiden.agents.quicklisp)
  (:use #:cl #:maiden #:maiden-commands #:maiden-client-entities)
  (:export
   #:quicklisp
   #:update
   #:upgrade
   #:version
   #:quickload
   #:uninstall
   #:install-dist
   #:uninstall-dist))
