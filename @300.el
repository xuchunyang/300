;;; @300.el --- 《唐诗三百首》                        -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Xu Chunyang

;; Author: Xu Chunyang <mail@xuchunyang.me>
;; URL: https://github.com/xuchunyang/300
;; Package-Requires: ((emacs "25"))
;; Created: Sat Jul 21 14:19:22 CST 2018
;; Version: 2018.07.21

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; To use, type M-x @300

;;; Code:

(require 'json)
(require 'seq)
(require 'subr-x)

(defconst @300-json (expand-file-name
                     "300.json"
                     (file-name-directory (or load-file-name buffer-file-name))))

(defvar @300-alists nil)

(defun @300-get-alists ()
  (unless @300-alists
    (setq @300-alists
          (let ((json-object-type 'alist)
                (json-array-type  'list)
                (json-key-type    'symbol)
                (json-false       nil)
                (json-null        nil))
            (json-read-file @300-json))))
  @300-alists)

;;;###autoload
(defun @300-filter (author title type)
  (seq-filter (lambda (alist)
                (and (if author
                         (equal (alist-get 'author alist) author)
                       t)
                     (if title
                         (equal (alist-get 'title alist) title)
                       t)
                     (if type
                         (equal (alist-get 'type alist) type)
                       t)))
              (@300-get-alists)))

(defun @300-filter-by-author (author)
  (@300-filter author nil nil))

(defun @300-filter-by-author+title (author title)
  (@300-filter author title nil))

(defun @300-display-buffer (alist)
  (with-current-buffer (get-buffer-create "*唐诗三百首*")
    (erase-buffer)
    (insert (alist-get 'title alist))
    (newline)
    (insert (alist-get 'author alist))
    (newline)
    (newline)
    (insert (alist-get 'contents alist))
    (unless (get-buffer-window (current-buffer))
      (display-buffer (current-buffer)))))

(defun @300-completing-read-author+title ()
  (let (author title)
    (setq author (completing-read "作者: "
                                  (delete-dups
                                   (mapcar
                                    (lambda (alist)
                                      (alist-get 'author alist))
                                    (@300-get-alists)))
                                  nil
                                  :require-match))
    (setq title (completing-read (format "%s 的: " author)
                                 (mapcar (lambda (alist)
                                           (alist-get 'title alist))
                                         (@300-filter-by-author author))
                                 nil
                                 :require-match))
    (list author title)))

;;;###autoload
(defun @300 (author title)
  (interactive (@300-completing-read-author+title))
  (when-let ((alist (car (@300-filter-by-author+title author title))))
    (@300-display-buffer alist)))

;;;###autoload
(defun @300-random (&optional author title type)
  (interactive)
  (when-let ((filtered (@300-filter author title type)))
    (let-alist (seq-random-elt filtered)
      (@300 .author .title))))

(provide '@300)
;;; @300.el ends here
