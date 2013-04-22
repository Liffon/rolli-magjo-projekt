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
    (define on-ground? #f)
    (define width w)
    (define height h)
    
    (define/public (push! dvx dvy)
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
       
    (define/public (jump!)
      (when on-ground?
        (set! on-ground? #f)
        (push! 0 -0.4)))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x-pos y-pos width height))
    (define/public (update)
  
      
      (push! 0 (* *g* *dt*))
      
      (let ((new-x (+ x-pos (* vx *dt*)))
            (new-y (+ y-pos (* vy *dt*)))
            (ground-y 250))
        
        (set! x-pos new-x)
        (set! y-pos (min new-y ground-y))))    
    (super-new)))



      
