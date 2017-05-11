(defsystem "arboreta-core"
  :name "arboreta-core"
  :serial t
  :version "0.3"
  :author "Dylan Ball <Arathnim@gmail.com>"
  :depends-on ("alexandria"
               "anaphora"
               "cl-cairo2"
               "cl-cairo2-xlib"
               "cl-colors"
               "cl-pango"
               "cl-ppcre"
               "iterate"
               "dynamic-classes")
  :pathname "src/"
  :components ((:file "packages")
               (:file "cl-xkb")
               (:file "cairo2-extensions" :depends-on ("packages"))
               (:file "base" :depends-on ("cl-xkb" "cairo2-extensions" "packages"))))
