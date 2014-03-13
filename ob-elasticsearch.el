;;; ob-elasticsearch.el --- org-babel functions for Elasticsearch queries

;; Copyright (C) 2014 Bjarte Johansen
;; Copyright (C) 2014 Matthew Lee Hinman

;; Author: Bjarte Johansen
;; Keywords: literate programming, reproducible research
;; Homepage: http://www.github.com/dakrone/es-mode
;; Version: 0.0.1

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Provides a way to evaluate Elasticsearch queries in org-mode.

;;; Code:
(require 'ob)
(require 'es-mode)

(defvar org-babel-default-header-args:elasticsearch
  `((:url . ,es-default-url)
    (:method . ,es-default-request-method))
  "Default arguments for evaluating an elasticsearch query
block.")

(defun org-babel-execute:elasticsearch (body params)
  "Execute a block containing an Elasticsearch query with
org-babel.  This function is called by
`org-babel-execute-src-block'. If `es-warn-on-delete-query' is
set to true, this function will also ask if the user really wants
to do that."
  (message "Executing an Elasticsearch query block.")
  (let ((endpoint-url (cdr (assoc :url params)))
        (url-request-method (cdr (assoc :method params)))
        (url-request-data body)
        (url-request-extra-headers
         '(("Content-Type" . "application/x-www-form-urlencoded"))))
    (when (es--warn-on-delete-yes-or-no-p)
      (with-current-buffer (url-retrieve-synchronously endpoint-url)
        (when (string-match "^.* 200 OK$" (thing-at-point 'line))
          (search-forward "\n\n")
          (delete-region (point-min) (point))
          (mark-whole-buffer)
          (es-indent-line))
        (buffer-string)))))

(provide 'ob-elasticsearch)
;;; ob-elasticsearch.el ends here
