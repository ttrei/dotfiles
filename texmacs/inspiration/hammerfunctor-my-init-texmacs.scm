;; https://github.com/hammerfunctor/dotfiles/blob/450e57c39422c39317262a4c060cefeb42dbc5ff/texmacs/progs/my-init-texmacs.scm

(use-modules (dynamic session-edit))
(set-session-multiline-input "python" "default" #t)
(set-session-multiline-input "scheme" "default" #t)
(set-session-multiline-input "julia" "default" #t)
(set-session-multiline-input "mma" "default" #t)
(set-session-multiline-input "gnuplot" "default" #t)
(set-session-multiline-input "graph" "default" #t)



;;(use-modules (texmacs menus main-menu))
;; I don't know how to add a new item to the `texmacs-menu'
;;(tm-menu (my-menu)
;;  (-> "Opening"
;;      ("Dear Sir" (insert "Dear Sir,"))
;;      ("Dear Madam" (insert "Dear Madam,")))
;;  (-> "Closing"
;;      ("Yours sincerely" (insert "Yours sincerely,"))
;;      ("Greetings" (insert "Greetings."))))

;; To define new menus, you have to evaluate it first.
;; They are `lazy-define'd, which is not covered in the doc.
;;(developer-menu)
;;(menu-bind developer-menu
;;  (group "User defined") (link my-menu)
;;  ---
;;  (former))

(define (image? t) (tree-is? t 'image))
(define (find-image t)
  (car (tree-search (tree-outer t) image?)))
(define (set-image-size t size)
  (tree-set! t 1 (string->tree size)))

(kbd-map
 ;; general
 ;; for macOS, `M-L` doesn't work, it's `load`, `C-L` and `A-L` work
 ;; for Linux, `C-L` doesn't work, it's also `load`, `A-L`, `M-L` work
 ;;("C-V"                      (clipboard-paste-import "verbatim" "primary"))
 ;;("C-L"                      (clipboard-paste-import "latex" "primary"))
 ("A-V" (clipboard-paste-import "verbatim" "primary"))
 ("A-l p" (clipboard-paste-import "latex" "primary"))
 ("A-l c" (clipboard-copy-export "latex" "primary"))
 ("A-c s" (init-page-rendering "automatic")) ; page breaking -> screen
 ("A-G" (set-image-size (find-image (cursor-tree)) "0.318par"))
 ;; ("M-x" (insert "This is Meta-X"))
 ;; ("A-x" (insert "This is Alt-X"))
 ;; ("C-l" (insert "This is Ctrl-l"))

 ("M-E p" (my/export-to-pdf))

 ;; dices
 ("@ tab 1" "<#2680>")
 ("@ tab 2" "<#2681>")
 ("@ tab 3" "<#2682>")
 ("@ tab 4" "<#2683>")
 ("@ tab 5" "<#2684>")
 ("@ tab 6" "<#2685>")
 )

(kbd-map
 (:mode in-math?)
 ;; ========== double letters
 ;; ("s s" (insert '(concat (big "sum") (rsub "k"))))
 ("s s" (begin
          (insert '(big "sum"))
          (insert-go-to '(rsub "") '(0 0))))
 ;; ("i i" (make-big-operator "int"))
 ("i i" (begin
          (insert '(big "int"))
          (insert-go-to '(rsub "") '(0 0))))
 ("p p" (begin
          (insert '(big "prod"))
          (insert-go-to '(rsub "") '(0 0))))
 ("m m" (make 'matrix))
 ("f f" (make 'frac))
 ("r r" (make 'sqrt))
 ("^ ^" (make-wide "^"))
 ;; ("d d" (insert '(wide "x" "<dot>")))
 ("d d" (insert-go-to '(rsub "") '(0 0)))
 ;; ("d d" (make-wide "<dot>"))
 ("u u" (insert-go-to '(rsup "") '(0 0)))
 ("u b" (insert-go-to '(below (wide* "" "<wide-underbrace>") "") '(0 0 0)))
 ("o b" (insert-go-to '(above (wide "" "<wide-overbrace>") "") '(0 0))) ; wide and wide*
 ("d e l" (insert "<nabla>"))

 ;; bold-up char to denote vectors
 ;; 65 - 90
 ;; elisp:
 ;; (dotimes (i 26)
 ;;          (let ((c (+ i 65)))
 ;;            (insert (format "(\"v v %c\" (insert \"<b-up-%c>\"))" c c)))
 ;;          (newline-and-indent))
 ("v v A" (insert "<b-up-A>"))
 ("v v B" (insert "<b-up-B>"))
 ("v v C" (insert "<b-up-C>"))
 ("v v D" (insert "<b-up-D>"))
 ("v v E" (insert "<b-up-E>"))
 ("v v F" (insert "<b-up-F>"))
 ("v v G" (insert "<b-up-G>"))
 ("v v H" (insert "<b-up-H>"))
 ("v v I" (insert "<b-up-I>"))
 ("v v J" (insert "<b-up-J>"))
 ("v v K" (insert "<b-up-K>"))
 ("v v L" (insert "<b-up-L>"))
 ("v v M" (insert "<b-up-M>"))
 ("v v N" (insert "<b-up-N>"))
 ("v v O" (insert "<b-up-O>"))
 ("v v P" (insert "<b-up-P>"))
 ("v v Q" (insert "<b-up-Q>"))
 ("v v R" (insert "<b-up-R>"))
 ("v v S" (insert "<b-up-S>"))
 ("v v T" (insert "<b-up-T>"))
 ("v v U" (insert "<b-up-U>"))
 ("v v V" (insert "<b-up-V>"))
 ("v v W" (insert "<b-up-W>"))
 ("v v X" (insert "<b-up-X>"))
 ("v v Y" (insert "<b-up-Y>"))
 ("v v Z" (insert "<b-up-Z>"))

 ;; 97 - 122
 ("v v a" (insert "<b-up-a>"))
 ("v v b" (insert "<b-up-b>"))
 ("v v c" (insert "<b-up-c>"))
 ("v v d" (insert "<b-up-d>"))
 ("v v e" (insert "<b-up-e>"))
 ("v v f" (insert "<b-up-f>"))
 ("v v g" (insert "<b-up-g>"))
 ("v v h" (insert "<b-up-h>"))
 ("v v i" (insert "<b-up-i>"))
 ("v v j" (insert "<b-up-j>"))
 ("v v k" (insert "<b-up-k>"))
 ("v v l" (insert "<b-up-l>"))
 ("v v m" (insert "<b-up-m>"))
 ("v v n" (insert "<b-up-n>"))
 ("v v o" (insert "<b-up-o>"))
 ("v v p" (insert "<b-up-p>"))
 ("v v q" (insert "<b-up-q>"))
 ("v v r" (insert "<b-up-r>"))
 ("v v s" (insert "<b-up-s>"))
 ("v v t" (insert "<b-up-t>"))
 ("v v u" (insert "<b-up-u>"))
 ("v v v" (insert "<b-up-v>"))
 ("v v w" (insert "<b-up-w>"))
 ("v v x" (insert "<b-up-x>"))
 ("v v y" (insert "<b-up-y>"))
 ("v v z" (insert "<b-up-z>"))

 )

(kbd-map
 (:mode in-text?)

 ;; insert information of title and author
 ("h u z f tab" (insert-go-to (title-author-info) '(0 0 0 0)))

 ;; math environment
 ("d e f tab" (make 'definition))
 ("l e m tab" (make 'lemma))
 ("p r o p tab" (make 'proposition))
 ("t h m tab" (make 'theorem))
 ("p f tab" (make 'proof))
 ("n o t e tab" (make 'note))
 ("r k tab" (make 'remark))
 ("e x m tab" (make 'example))

 ("c m t tab" (my/comment))

 ;; insert a session
 ("g p tab" (my/session-small "gnuplot"))
 ("s c m tab" (my/session-small "scheme"))
 ("j l tab" (my/session-small "julia"))
 ("p y tab" (my/session-small "python"))
 ("g r a p h tab" (my/session-small "graph"))
 ("m m a tab" (my/session-small "mma"))
 ("m m a f o l d tab" (my/fold-small "mma" ""))
 ("g f o l d tab" (my/fold-small "graph" "%tikz -width 300"))
 ("m a x i m a tab"(my/session-small "maxima"))
 ("t k c d tab" (my/tikz #t))
 ("t k tab" (my/tikz #f))
 ("i n p u t tab" (my/input))

 ;; insert some code
 ("' ' ' c p p return"       (make 'cpp-code))
 ("' ' ' p y t h o n return" (make 'python-code))
 ("' ' ' s c m return"       (make 'scm-code)))

;; export to pdf
(tm-define (my/export-to-pdf)
  (with name (propose-name-buffer)
        (if (string-ends? name ".tm")
            (with pdf-name (string-append (string-drop-right name 3) ".pdf")
                  (wrapped-print-to-file pdf-name)))))

;; use small font for code
(tm-define (my/session-small type)
  (insert-go-to '(really-tiny "") '(0 0))
  (make-session type "default"))

(tm-define (my/fold-small type line)
  (insert-go-to `(center (tiny (script-input ,type "default" ,line ""))) `(0 0 2 ,(string-length line)))
  (insert-raw-return))

;; insert a tikz executable fold with prescribed text
(tm-define (my/tikz cd?)
  (:secure #t)
  (my/fold-small "tikz" "%tikz -width 0.318par")
  ;;  (insert-go-to '(center "") '(0 0))
  ;;  (insert-go-to '(script-input "tikz" "default" "" "") '(2 0))
  ;;  (insert "%tikz -width 0.318par")
  (when cd?
    (insert "\\usetikzlibrary{cd}")
    (insert-return)))

(tm-define (my/comment)
  (let ((s "[huzf: ]"))
    (insert-go-to `(with "color" "blue" ,s) `(2 ,(- (string-length s) 1)))))

(tm-define (my/input)
  (my/fold-small "graph" "%tikz -width 400")

  (insert "\\documentclass[10pt]{standalone}")
  (insert-raw-return)
  (insert "\\input{/home/huzf/tex-src/}")
  )

;; add a comment
;; (use-modules (various comment-edit))
;; (tm-define (my/comment)
;;   (:secure #t)
;;   (let* ((id (create-unique-id))
;;          (mirror-id (create-unique-id))
;;          (by "huzf")
;;          (date (number->string (current-time)))
;;          (lab (if (inside-comment?) 'nested-comment 'unfolded-comment))
;;          (pos (list 6 0))
;;          (type "comment"))
;;     (insert-go-to `(,lab ,id ,mirror-id ,type ,by ,date "" "") pos)
;;     ;;(notify-comments-editor)
;;     )
;;   )

;; insert the information of title and author
(tm-define (title-author-info)
  (:secure #t)
  '(document
    (doc-data
     (doc-title "")
     (doc-author
      (author-data
       (author-name "Zhengfei Hu")
       (author-note
        (concat
         "Florida State University, Tallahassee, Florida 32306, "
         (hlink "zh22d@fsu.edu" "mailto:zh22d@fsu.edu")))))
     (doc-date (concat "(Dated: " (date "%B %e, %Y, %A") ")")))))


;; How to insert texts?
;;
;; Consecutive texts are yeilded by
;;   `(concat "hahaha" (hlink "clickme" "www.duckduckgo.com"))
;; like: (tm-define (h-text)
;;         `(concat "hahaha" (hlink "clickme" "127.0.0.1")))
;; Vectical consecutive texts are given by substituting `concat' by `document'
;;
;; Texts generated by <extern|horizontal-text> are uneditable,
;; while texts inserted by `insert' is editable.
;; If the scheme function contains some params, then params are still
;; editable under `extern', though inconvenient.
;; E.g., (tm-define (hello t) `(concat "Hello, " ,t "."))

(tm-define (in-theorem? t)
  (cond ((tree-is-buffer? t) #f)
        ((tree-is? t 'theorem) #t)
        (else (in-theorem? (tree-up t)))))

(tm-define (count n)
  (:secure #t)
  (with color (if (in-theorem? n) "red" "black")
        (with hop `(with "color" ,color ,n)
              (with k (string->number (tree->string n))
                    ($inline "Counting "
                             ($for (i (.. 1 k))
                                   (number->string i) ", ")
                             hop ".")))))

;; (load "init-joris-magic.scm")
