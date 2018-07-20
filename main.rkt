#lang racket
(require html-parsing
         json
         sxml)


(define (GB2312->UTF-8 bstr)
  (define convert (bytes-open-converter "GB2312" "UTF-8"))
  (define-values (result-bstr src-read-amt terminated)
    (bytes-convert convert bstr))
  result-bstr)

(module+ test
  (require rackunit)
  (test-case "测试 GB2312->UTF-8"
    (define bstr
      (with-output-to-bytes
        (lambda () (system "/bin/echo -n 你好 | iconv -f UTF-8 -t GB2312"))))
    (check-equal? "你好" (bytes->string/utf-8 (GB2312->UTF-8 bstr)))))

(define raw-bytes
  (with-input-from-file "http:!!www.shiku.org!shiku!gs!tangdai.htm"
    (lambda () (port->bytes))))

(define html (bytes->string/utf-8 (GB2312->UTF-8 raw-bytes)))

(define xexp (html->xexp html))

(define tmpstr
  (with-output-to-string
    (lambda ()
      (for ([i (in-range 3 645)])
        ;; ("\n" "002张九龄：感遇四首之二")
        (define ss ((sxpath (format "/html/body/p[~a]/text()" i)) xexp))
        (define s (string-trim (apply string-append ss)))
        (when (regexp-match #px"^[0-9]{3}" s)
          (display ""))
        (displayln s)))))

(struct poetry (id type author title contents) #:prefab)

(define (id->type id)
  (cond [(<= id 35) "五言古诗"]
        [(<= id 46) "五言乐府"]
        [(<= id 73) "七言古诗"]
        [(<= id 88) "七言乐府"]
        [(<= id 169) "五言律诗"]
        [(<= id 223) "七言律诗"]
        [(<= id 260) "五言绝句"]
        [else "七言绝句"]))

(define (make-poetry s)
  (match-define (list _ id-str author title contents)
    (regexp-match #px"^([0-9]{3})([^：\n]*)：([^\n]*)\n(.*)$" s))
  (define id (string->number id-str))
  (poetry id (id->type id) author title contents))

(module+ test
  (check-true
   (poetry?
    (make-poetry
     "002张九龄：感遇四首之二\n兰叶春葳蕤，桂华秋皎洁。\n欣欣此生意，自尔为佳节。\n谁知林栖者，闻风坐相悦。\n草木有本心，何求美人折？"))))

(define first-poetry
  (poetry 1
          (id->type 1)
          "张九龄"
          "感遇四首之一"
          "孤鸿海上来，池潢不敢顾。
侧见双翠鸟，巢在三珠树。
矫矫珍木巅，得无金丸惧。
美服患人指，高明逼神恶。
今我游冥冥，弋者何所慕。"))

(define poetries
  (cons first-poetry
        (for/list ([x (string-split tmpstr "")])
          (make-poetry (string-trim x)))))

(with-output-to-file "300.json"
  (lambda ()
    (write-json (for/list ([p (in-list poetries)])
                  (hasheq 'id (poetry-id p)
                          'type (poetry-type p)
                          'author (poetry-author p)
                          'title (poetry-title p)
                          'contents (poetry-contents p))))))
