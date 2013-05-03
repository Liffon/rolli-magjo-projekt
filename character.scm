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
    
    (define/public (set-map! new-map)
      (set! the-map new-map))
    
    (define/public (on-ground?)
      (eq? (inexact->exact y) (- (ground-y) height)))
    
    ;; Dessa borde generaliseras till t.ex. (get-edge 'direction)!
    (define/public (roof-y)
      (let ([xs (cons (+ x width -1)
                      (range x (+ x width) (get-field tile-size the-map)))])
        (apply max
               (map (λ (x)
                      (send the-map get-next-solid-pixel 'up x y))
                    xs))))
    
    (define/public (left-x)
      ;; bör funka oavsett storlek på karaktären
      ;; - kollar alla tiles spelaren täcker i y-led
      (let ([ys (range y (+ y height) (get-field tile-size the-map))])
        (apply max
               (map (λ (y)
                      (send the-map get-next-solid-pixel 'left x y))
                    ys))))
    
    (define/public (right-x)
      (let ([ys (range y (+ y height) (get-field tile-size the-map))])
        (apply min
               (map (λ (y)
                      (send the-map get-next-solid-pixel 'right (+ x width -1) y))
                    ys))))
    
    
    (define/public (ground-y)
      (let ([xs (cons (+ x width -1)
                      (range x (+ x width) (get-field tile-size the-map)))])
        (apply min
               (map (λ (x)
                      (send the-map get-next-solid-pixel 'down x (+ y height -1)))
                    xs))))
    
    (define/public (decelerate!)
      (set! vx (* vx 0.85)))
    
    (define/public (push! dvx dvy)
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
    
    (define/public (jump!)
      (set! vy -1))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x y width height))
    
    (define/public (move!)
      (push! 0 (* *g* *dt*)) ;; gravitationsacceleration
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




