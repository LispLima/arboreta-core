(proclaim '(optimize (speed 0) (safety 3) (debug 3)))

(ql:quickload '(alexandria iterate anaphora cl-cairo2 cl-cairo2-xlib cl-pango) :silent t)

(defpackage arboreta
  (:use cl iterate anaphora cl-cairo2))

(in-package arboreta)

(defparameter context nil)
(defparameter surface nil)
(defparameter layout nil)
(defparameter font nil)

(defparameter w 600)
(defparameter h 400)

(defstruct window
   (attributes (make-hash-table :test #'eq))
   (draw nil))

(defun call-draw (window)
   (funcall (window-draw window) window))

(defun draw-subwindows (window)
   (awhen (gethash 'subwindows (window-attributes window))
          (iter (for x in it)
                (call-draw x))))

(defparameter root-window 
   (make-window :draw 
      (lambda (window)
         (new-path)
         (set-source-rgb 37/255 46/255 50/255)
         (rectangle 0 0 w h)
         (fill-path)
         (draw-subwindows window))))

(defun add-as-subwindow (source-window target-window)
   (push source-window (gethash 'subwindows (window-attributes target-window))))

(add-as-subwindow
   (make-window :draw
      (lambda (window) 
         (new-path)
         (set-source-rgb 50/255 55/255 60/255)
         (rectangle 20 20 200 400)
         (fill-path)
         (draw-subwindows window)))
   root-window)

(defun pango-update ()
   (pango:pango_cairo_update_layout (slot-value *context* 'cairo::pointer) layout)
   (pango:pango_cairo_show_layout (slot-value *context* 'cairo::pointer) layout))

(defun flush-surface ()
   (surface-flush surface)
   (cairo::sync context))

(defun unicode-test ()
   (pango:pango_layout_set_text layout 
     (format nil "~{~a~%~}" 
       '("Hello, glorious pango text rendering!"
         "いあだ〜〜ずかしいです〜〜" 
         "Τη γλώσσα μου έδωσαν ελληνική" 
         "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ"
         "ಬಾ ಇಲ್ಲಿ ಸಂಭವಿಸು ಇಂದೆನ್ನ ಹೃದಯದಲಿ "
         "मैं काँच खा सकता हूँ और मुझे उससे कोई चोट नहीं पहुंचती "))
     -1)
   (pango-update)
   (flush-surface))

;; you might not have this font, change it to a good non-bitmap monospaced font you do have.
(defun update-test ()
   (setf layout (pango:pango_cairo_create_layout (slot-value cairo:*context* 'cairo::pointer)))
   (setf font (pango:pango_font_description_from_string "Fantasque Sans Mono 10"))
   (pango:pango_layout_set_font_description layout font)

   (iter (with str = "Once upon a midnight dreary, while I pondered, weak and weary...")
         (for x from 0 to (length str))
         (set-source-rgb 37/255 46/255 50/255)
         (rectangle 0 0 w h)
         (fill-path)
         (new-path)
         (move-to 0 0)
         (set-source-rgb 148/255 163/255 165/255)
         (pango:pango_layout_set_text layout (subseq str 0 x) -1)
         (pango-update)
         (flush-surface)
         (sleep 0.1)))

;; sleeps so that it doesn't eat all the CPU, need some way to limit drawing or something
(defun window-update-loop ()
   (iter (call-draw root-window)
         (sleep 0.05)
         (flush-surface)))

(defun main ()
   (setf context (create-xlib-image-context w h :window-name "pango-test"))
   (setf surface (get-target context))
   
   (with-context (context)
      (set-source-rgb 37/255 46/255 50/255)
      (rectangle 0 0 w h)
      (fill-path)

      ;; had to do it without the helper macros, because they cause context errors for some reason

      (window-update-loop)
   
      (princ "press enter here to exit")
      (finish-output)
      (when (read-line)
         (cairo:destroy context)
         (sb-ext:exit))))

;;(sb-ext:save-lisp-and-die "arboreta" :toplevel #'main :executable t)
(main)
