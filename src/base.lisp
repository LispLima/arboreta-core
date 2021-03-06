
(in-package #:arboreta)

(defun get-block (index size seq)
  (nth index
       (iter (for x from 0 to (length seq) by size)
         (for y from size to (length seq) by size)
         (collect (subseq seq x y)))))

(defun set-hex-color (hex)
  (let ((colors (mapcar (lambda (x) (/ (parse-integer x :radix 16) 256))
                        (iter (for i from 0 to 2) (collect (get-block i 2 hex))))))
    (set-source-rgb (first colors) (second colors) (third colors))))

(defun draw-rectangle (x y w h)
  (new-path)
  (rectangle x y w h)
  (fill-path))

(defun basic-write (str font color x y)
  (let ((pango-layout (pango:pango_cairo_create_layout (slot-value cairo:*context* 'cairo::pointer))))
    (pango:pango_layout_set_font_description pango-layout font)
    (new-path)
    (move-to x y)
    (set-hex-color color)
    (pango:pango_layout_set_text pango-layout str -1)

    (pango:pango_cairo_update_layout (slot-value *context* 'cairo::pointer) pango-layout)
    (pango:pango_cairo_show_layout (slot-value *context* 'cairo::pointer) pango-layout)
    (pango:g_object_unref pango-layout)))

(defclass window ()
  ((width :initform (error "must supply width"))
   (height :initform (error "must supply height"))
   (image-context :initarg :image-context
                  :initform nil
                  :accessor image-context)
   (event-queue :initform ni
                :accessor event-queue)))

(defmethod :after initialize-instance ((window window) &key)
  (with-slots (width height) window
    (setf (image-context window) (cairo::create-window* width height))))

(defmethod start-drawing ((window window))
  (iter (for x = (+ (get-internal-real-time) 20))
    (handle-events window)
    (update window)
    (iter (while (cairo::handle-event window)))
    (let ((delay (/ (- x (get-internal-real-time)) 1000)))
      (sleep (if (> delay 0) delay 0)))))

(defmethod handle-events ((window window))
  (setf (event-queue window) nil))

(defmethod update ((window window))
  (cairo::refresh (image-context window)))

(defmethod shutdown ((window window))
  (cairo::clean-shutdown (image-context window)))
