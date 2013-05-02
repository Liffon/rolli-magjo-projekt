(define character%
  (class object%
    (init [x 0]
          [y 0]
          [w 25]
          [h 50])
    (define x-pos x)
    (define y-pos y)
    (define vx 0)
    (define vy 0)
    (define maxspeed 0.05)
    (define width w)
    (define height h)
    (define map #f) 
    (define/public (set-map! new-map)
      (set! map new-map))
    
    (define/public (on-ground?)
      (eq? (inexact->exact y-pos) (ground-y)))
    
    (define/public (roof-y)
      (let ((roof-left-y (send map get-next-solid-pixel 'up x-pos y-pos))
            (roof-right-y (send map get-next-solid-pixel 'up (+ x-pos width) y-pos)))
        (max roof-left-y roof-right-y)))
    
    (define/public (left-x)
      (let ((upper-left-x (send map get-next-solid-pixel 'left x-pos y-pos))
            (lower-left-x (send map get-next-solid-pixel 'left x-pos (+ y-pos 
                                                                        (/ height
                                                                           2))))) ;;kanske borde använda nåt annat än height/2
                                                                                  ;;för att kunna ha andra storlekar på en character?
        (max upper-left-x lower-left-x))) ;för att spelaren är större än en tile
    
      (define/public (right-x)
        (let ((upper-right-x (send map get-next-solid-pixel 'right (+ x-pos width) y-pos))
            (lower-right-x (send map get-next-solid-pixel 'right (+ x-pos width) (+ y-pos 
                                                                        (/ height
                                                                           2)))))
        (min upper-right-x lower-right-x)))
            
    
    (define/public (ground-y)
      (let* ((down-edge (+ y-pos height))
            (new-ground-left-edge (send map get-next-solid-pixel 'down x-pos down-edge))
            (new-ground-right-edge (send map get-next-solid-pixel 'down (+ x-pos width) down-edge))) ;map ska skicka blabla till tilemap
        (- (min new-ground-left-edge
                new-ground-right-edge) ;;för att kunna stå på hela tilen!
           height)))
    
    (define/public (decelerate!)
      (set! vx (* vx 0.85)))
    
    (define/public (push! dvx dvy)
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
       
    (define/public (jump!)
      (set! vy -1))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x-pos y-pos width height))
    
    (define/public (move!)
      (push! 0 (* *g* *dt*))
      (decelerate!)
      (let ((new-x (+ x-pos (* vx *dt*)))
            (new-y (+ y-pos (* vy *dt*))))
        (if (< (+ new-x 
                  width) (right-x)) 
            (set! x-pos (max new-x (left-x))) ;; Tile-kollision åt vänster
            (set! x-pos (- (right-x) (+ width 1)))) ;; Tile-kollision åt höger, en pixel ifrån att röra dock...
        (if (> new-y (roof-y))
            (set! y-pos (min new-y (ground-y)))
            (set! y-pos (+ (roof-y) 1))))) ;;Tile-kollision uppåt
    
    (define/public (update!)
      (move!))    
    (super-new)))



      
