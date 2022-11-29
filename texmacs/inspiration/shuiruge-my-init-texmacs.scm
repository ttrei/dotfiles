;; https://github.com/shuiruge/my-texmacs-configuration/blob/088c394f3463ff78a66c8d5e8d212a13b64a69fd/my-init-texmacs.scm

(kbd-map
  (:mode in-math?)
  
  ;; quantum mechanics:
  ("| >" "| <rangle>")             ; ket
  ("< |" "<langle> |")             ; bra
  ("< | >" "<langle> | <rangle>")  ; bracket
  ("h b a r" "<hbar>")             ; hbar
  ("d a g" "<dagger>")             ; dagger
  
  ;;; Define shortcut by doubling a key in main-region.
  ;;; Assuming that you never encounter such case where
  ;;; you have to input, such as, a quantity denoted by
  ;;; "dd".
  ;;; (If you are mad, you can instead use "\text".)
  ;;; (You can input math "d d" by "d d <space> d d".)
  
  ;; general notations:
  ("f f" (make-fraction))          ; fraction (another)
  ("s s" (make-sqrt))              ; sqrt
  ("d d" "<mathd>")                ; derivative
  ("p d" "<partial>")              ; partial derivative
  ("i n t" (math-big-operator "int"))  ; integral

  ;; ornaments:
;  ("o o ^" (make-wide "^"))        ; hat
;  ("o o ~" (make-wide "~"))        ; tilde
  ("o 6" (make-wide "^"))           ; hat
  ("o `" (make-wide "~"))           ; tilde
  ("o ." (make-wide "<dot>"))       ; dot
  ("o . var" (make-wide "<ddot>"))  ; ddot
  ("o -" (make-wide "<bar>"))       ; bar

  ;; positions:
  ("a a" (make-above))             ; above
  ("b b" (make-below))             ; below
  
  ;; some constants.
  ("e e" "<mathe>")                ; Euler constant
;  ("p p" "<mathpi>")               ; 3.14...
  ("i i" "<mathi>")                ; imaginary unit

  ;; fonts:
  ("m c" (make-with "font" "cal"))    ; mathcal
  ("m b" (make-with "font" "Bbb"))    ; mathbb
  ("m f" (make-with "font" "Euler"))  ; mathfrak
  
  ;; Some tabing order is unconvenient.
  ;; Ensure that the previous definitions have been
  ;; commented out!
  ("* var" "<cdot>")
  ("* var var" "<times>")
  ("* var var var" "<ast>")
  )

(kbd-map
  (:mode in-math?)
  ;; Using 'space space' to go out of the tmp structure.
  ;; This can be established only in math-mode.
  ("space space" (structured-exit-right))

  ;; Using 's h/l' to jump to the previous/next similar.
  ;; "s" for "similar".
  ("s h" (traverse-previous))
  ("s l" (traverse-next))
  )

;; For the "how-to":
;; (0) Find out the keywords in some menu. In this instance,
;; "Focus" menu under math-mode. You then find what you want
;; is the keywords "Exit right".
;; (1) "Help -> Search -> Documentation"; type in the keywords
;; you find, in this instance, "Exit right".
;; (2) In the returned file, in this instance, "generic/generic-
;; menu.scm", search the keyword, i.e., "Exit" (or any other
;; related keyword. Keeping trying several times.), finding
;; that the operator is "structured-exit-right".
;; (3) Write a kbd-map like above, by using this operator.
;; Q.E.D.


(kbd-map
  (:mode in-std-text?)
  ("text I" (make-tmlist 'itemize-minus))
  )
