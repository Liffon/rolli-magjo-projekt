(require racket/gui)
(define *g* 0.0002)
(define *dt* (round (/ 1000 60))) ;; millisekunder
(load "player.scm")

(define *frame* (new frame%
                     [label "testbana"]
                     [width 640]
                     [height 480]))

(define *canvas* (new canvas%
                      [parent *frame*]
                      [paint-callback (lambda (canvas dc)
                                        (send *player* render canvas dc))]))

(define *timer* (new timer%
                     [notify-callback (lambda ()
                                        (send *player* update)
                                        (send *canvas* refresh))]))

(send *timer* start *dt*)

(define *player* (new player%))
(send *frame* show #t)
                     