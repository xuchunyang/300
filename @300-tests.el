;;; @300-tests.el --- Tests of @300.el               -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Xu Chunyang

;; Author: Xu Chunyang <mail@xuchunyang.me>
;; Keywords:

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

;;

;;; Code:

(require 'ert)
(require '@300)
(require 'let-alist)

(ert-deftest @300-get-alists ()
  (should (@300-get-alists)))

(ert-deftest @300-filter-by-author+title ()
  (should (string-prefix-p
           "国破山河在，城春草木深。"
           (let-alist (car (@300-filter-by-author+title "杜甫" "春望"))
             .contents))))

(ert-deftest @300-random ()
  (should (@300-random nil nil nil))
  (should-not (@300-random "徐春阳" nil nil))
  (let-alist (@300-random "陈子昂" nil nil)
    (should (equal .title "登幽州台歌"))))

(provide '@300-tests)
;;; @300-tests.el ends here
