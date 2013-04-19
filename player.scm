(define player%
  (class object%
    (init [x 0]
          [y 0])
    (define x-pos x)
    (define y-pos y)
    (define vx 0)
    (define vy 0)
    (define maxspeed 0.05)
    (define on-ground? #f)
    (define keys (make-hash))
    
    (define/public (set-key! key boolean)
      (dict-set! keys key boolean))
    
    (define/public (get-key key)
      (dict-ref keys key #f))
    
    (define/public (push! dvx dvy)
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
    
    (define/public (move-right!)
      (push! 0.2 0))
    
    (define/public (move-left!)
      (push! -0.2 0))
    
    (define/public (jump!)
      (when on-ground?
        (set! on-ground? #f)
        (push! 0 -0.4)))
    
    (define/public (render canvas dc)
      (send dc draw-rectangle x-pos y-pos 50 50))
    (define/public (update)
     (let ((holding-right? (get-key 'right))
           (holding-left? (get-key 'left))
           (holding-jump? (get-key 'jump)))
      (cond
        ((eq? holding-right? holding-left?)
         ;;bromsa 
         (set! vx (* vx 0.7)))
        (holding-right?
         ;;knuff åt höger
         (push! 0.03 0))
        (holding-left?
         ;;knuff åt vänster
         (push! -0.03 0)))
      
      (when holding-jump?
        ;;knuff uppåt
        ;;todo: kolla att man får hoppa
        (set! vy -1)))
      
      (push! 0 (* *g* *dt*))
      
      (let ((new-x (+ x-pos (* vx *dt*)))
            (new-y (+ y-pos (* vy *dt*)))
            (ground-y 250))
        
        (set! x-pos new-x)
        (set! y-pos (min new-y ground-y)))
      
      
        
        
        
;      (if (and (> y-pos 250)
;               (not on-ground?))
;          (begin (set! vy 0)
;                 (set! y-pos 250)
;                 (set! on-ground? #t))
;          (set! vy (+ vy (* *g* *dt*))))
;          
;      (set! x-pos (+ x-pos (* vx *dt*)))
;      (unless on-ground?
;        (set! y-pos (+ y-pos (* vy *dt*)))))
        )
    
    ;;to-do: gravitation
    (super-new)))



      
