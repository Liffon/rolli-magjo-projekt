(define character%
  (class object%
    (init-field [x 0]
                [y 0]
                [width 25]
                [height 50])
    (define vx 0)
    (define vy 0)
    (define maxspeed 0.05)
    (define the-map #f)
    
    (define/public (x-pos)
      x)
    (define/public (y-pos)
      y)
    (define/public (set-map! new-map)
      (set! the-map new-map))
    
    (define/public (on-ground?)
      (eq? (inexact->exact y) (- (ground-y) height)))
    
    (define/public (find-obstacle direction)
      (let-values
          ([(lower-val upper-val iterator)
            (case direction
              [(up down) ;; kolla flera olika x
               (values x
                       (+ x width -1)
                       (lambda (x)
                         (send the-map get-next-solid-pixel direction x y)))]
              [(left right) ;; kolla flera olika y
               (values y
                       (+ y height -1)
                       (lambda (y)
                         (send the-map get-next-solid-pixel direction x y)))])])
        (let* ([tile-size (get-field tile-size the-map)]
               [checklist (cons upper-val (range lower-val upper-val tile-size))])
          (apply (if (or (eq? direction 'up)
                         (eq? direction 'left))
                     max
                     min)
                 (map iterator checklist)))))
    
    (define/public (roof-y)
      (find-obstacle 'up))
    (define/public (left-x)
      (find-obstacle 'left))
    (define/public (right-x)
      (find-obstacle 'right))
    (define/public (ground-y)
      (find-obstacle 'down))
    
    (define/public (decelerate!)
      (set! vx (* vx 0.85)))
    
    (define/public (push! dvx dvy)
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
    
    (define/public (jump!)
      (set! vy -0.9))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x y width height))
    
    (define/public (move!)
      (when (not (on-ground?))
           (push! 0 (* *g* *dt*))) ;; gravitationsacceleration
      (decelerate!)
      (let ((new-x (+ x (* vx *dt*)))
            (new-y (+ y (* vy *dt*))))
        (if (< (+ new-x 
                  width) (right-x)) 
            (set! x (max new-x (left-x))) ;; Tile-kollision åt vänster
            (set! x (- (right-x) width))) ;; Tile-kollision åt höger
                                          ;;  (tog bort pixeln mellan ty det verkade funka utan)
        (if (> new-y (roof-y))
            (set! y (min new-y (- (ground-y) height)))
            (set! y (+ (roof-y) 1))))) ;;Tile-kollision uppåt
    
    (define/public (update!)
      (move!))    
    (super-new)))




