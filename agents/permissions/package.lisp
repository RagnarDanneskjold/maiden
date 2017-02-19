#|
 This file is a part of Maiden
 (c) 2016 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:maiden-user)
(defpackage #:maiden-permissions
  (:nicknames #:org.shirakumo.maiden.agents.permissions)
  (:use #:cl #:maiden #:maiden-commands #:maiden-storage #:maiden-client-entities)
  ;; permissions.lisp
  (:export
   #:generate-token
   #:permission-denied
   #:user
   #:perm
   #:normalize-permission
   #:perm-match-p
   #:user-perm
   #:administrator-p
   #:add-administrator
   #:remove-administrator
   #:add-default-permission
   #:remove-default-permission
   #:allowed-p
   #:grant
   #:deny
   #:check-allowed
   #:with-permission
   #:permissions
   #:check-access
   #:administrate-self))
