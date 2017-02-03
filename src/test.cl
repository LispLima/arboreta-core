(ql:quickload 'arboreta-core)

(in-package arboreta)

(setf *print-pretty* nil)

(defparameter window nil)
(defparameter root nil)

(defclass example-container (rect)
   (width 600)
   (height 50))

(defun main ()
   (setf window 
      (make-instance window :width 600 :height 400
         (handle-events (*this*)
            (with-slots (event-queue) this
               (when event-queue
						(let ((e (pop event-queue)))
							(format t "~s~%" e)
							(finish-output)
							(when (and (eq (first e) :keypress) (equalp (second e) 4) (equalp (third e) 113)) ;; C-q
								(sb-ext:exit))))))))
   (setf (root-container window)
      (rect :width 600 :height 400 :color "252E32"
         (vertical-list :width 600 :height 400
            (make-instance example-container :color "8FC029")
            (make-instance example-container :color "DC2566")
            (make-instance example-container :color "55BCCE"))))
   (setf root (root-container window))
   (start-drawing window))

;; (sb-ext:save-lisp-and-die "test" :executable t :toplevel #'main)

