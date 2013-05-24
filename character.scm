;; character.scm
;; =============

;; innehåller klassen character%
;; Init-argument: x, y, width, hp, the-map, bitmap-right, bitmap-left, direction
;; (samtliga frivilliga)

;; Användningsexempel:
; (new character% [x 30] [y 320] [direction 'left] [bitmap-left cat-bitmap] [bitmap-right cat-bitmap])

(load "ring.scm")

(define character%
  (class object%
    (init-field [x 0] ;; x-position
                [y 0] ;; y-position
                [width 40]
                [height 80]
                [hp 100] ;; Liv
                [the-map #f]
                [bitmap-right #f]
                [bitmap-left #f]
                [direction 'right])
    (field [inventory (make-ring)]
           [weapon #f]
           [vx 0]
           [vy 0]
           [maxspeed 0.05])
    
    ;; returnerar ett par med karaktärens x- och y-position.
    ;; (används i leveleditorn för att kunna se var man ska sätta ut fiender)
    (define/public (get-position)
      (cons (inexact->exact (round x))
            (inexact->exact (round y))))
    
    ;; Tar ett föremål som argument och lägger in det i karaktärens inventarium
    ;; samt gör så att föremålet vet vem/vad som bär det. 
    (define/public (add-item! item) 
      (ring-insert! inventory item) 
      (set-field! wielder item this))
    
    ;; Tar ett vapen som argument, gör det till aktuellt vapen (som karaktären
    ;; använder) och lägger in vapnet i inventariet.
    (define/public (take-weapon! new-weapon)  
      (set! weapon new-weapon)                
      (set-field! wielder weapon this)
      (add-item! new-weapon))
    ;; Tar in 'next eller 'prev, roterar inventariet (som är en ring)
    ;; i en viss riktning och sätter det första värdet i ringen till aktuellt vapen. 
    (define/public (switch-weapon! next/prev) 
      (unless (empty-ring? inventory)         
        (if (eq? next/prev 'next)
            (ring-rotate-right! inventory)
            (ring-rotate-left! inventory))
        (set! weapon (ring-first-value inventory))))
    
    ;; Om karaktären har ett vapen så sänder den proceduren fire! till vapnet som gör att vapnet avfyras
    ;; i rätt riktning. 
    (define/public (shoot!) 
      (when weapon          
        (send weapon fire! the-map direction)))
    
    ;; Tar bort karaktären ur banans lista över element.
    (define/public (remove-self!)  
      (when the-map
        (send the-map delete-element! this)))

    ;; Tar in riktningen höger eller vänster som argument och byter från
    ;; vänster till höger eller höger till vänster. 
    (define/public (swap-direction direction) 
      (case direction                         
        ('left 'right)
        ('right 'left)))
    
    ;; Kollar om karaktären står på marken och returnerar #t eller #f. 
    (define/public (on-ground?) 
      (eq? (inexact->exact y) (ground-y)))
    
    ;; Tar in ett booleskt värde (som anger om man letar en solid eller
    ;; tom tile) och en riktning som argument och returnerar närmaste tiles
    ;; pixelkoordinat (antingen i x- eller yled beroende på riktning).  
    (define/public (find-obstacle solid? direction) 
      (let-values                                   
          ([(lower-val upper-val iterator)          
            (case direction
              [(up down) ;; kolla flera olika x
               (values x
                       (+ x width -1)
                       (lambda (x)
                         (send the-map get-next-tile-pixel solid? direction x y)))]
              [(left right) ;; kolla flera olika y
               (values y
                       (+ y height -1)
                       (lambda (y)
                         (send the-map get-next-tile-pixel solid? direction x y)))])])
        (let* ([tile-size (get-field tile-size the-map)]
               [checklist (cons upper-val (range lower-val upper-val tile-size))])
          (apply (if (or (eq? direction 'up)
                         (eq? direction 'left))
                     max
                     min)
                 (map iterator checklist)))))
    
    ;; Returnerar närmsta solida pixel-koordinat ovan karaktären. 
    (define/public (roof-y) 
      (add1 (find-obstacle #t 'up)))
    
    ;; Returnerar närmsta solida pixel-koordinat vänster om karaktären. 
    (define/public (left-x) 
      (find-obstacle #t 'left))
    
    ;; Returnerar närmsta solida pixel-koordinat höger om karaktären. 
    (define/public (right-x) 
      (- (find-obstacle #t 'right) width))
    
    ;; Returnerar närmsta solida pixel-koordinat under karaktären. 
    (define/public (ground-y) 
      (- (find-obstacle #t 'down) height))
    
    ;; Minskar karaktärens hastighet i x-led. 
    (define/public (decelerate!) 
      (set! vx (* vx 0.85)))
    
    ;; Ökar karaktärens hastighet i y-led. 
    (define/public (gravitate!) 
      (push! 0 (* *g* *dt*)))
    
    ;; Tar in ändring av hastighet i både x- och yled och ökar karaktärens hastighet.
    (define/public (push! dvx dvy)  
      (set! vx (+ vx dvx))
      (set! vy (+ vy dvy)))
    
     ;; Ger karaktären en negativ hastighet i y-led. 
    (define/public (jump!)
      (set! vy -0.9))
    
    ;; Tar in canvas och dc som argument och säger åt banan att rita en rektangel. 
    (define/public (render canvas dc) 
      (let ([bitmap (if (eq? direction 'left)
                        bitmap-left
                        bitmap-right)])
        (if bitmap
            (send the-map draw-bitmap bitmap x y canvas dc)
            (send the-map draw-rectangle x y width height "black" canvas dc))))
    
    ;; Exekverar en rad procedurer vid anrop, som talar om hur karaktären skall röra sig.
    (define/public (move!) 
      (when (is-a? the-map map%)
        (unless (on-ground?)
          (gravitate!)) ;; Låter tyngdaccelerationen verka om man inte står på marken. 
        
        (decelerate!)
        
        (let ([new-x (+ x (* vx *dt*))] ;; Detta let-uttryck gör så att karaktären inte kan gå igenom solida tiles. 
              [new-y (+ y (* vy *dt*))] 
              [min-x (left-x)] ;; största och minsta tillåtna värden på koordinaterna
              [max-x (right-x)]
              [min-y (roof-y)]
              [max-y (ground-y)])
          
          (cond
            [(positive? vx) (set! x (min new-x max-x))]
            [(negative? vx) (set! x (max new-x min-x))])
          (cond
            [(positive? vy) (set! y (min new-y max-y))]
            [(negative? vy) (set! y (max new-y min-y))])
          
          (when (or (= x min-x)
                    (= x max-x))
            (set! vx 0))
          (when (or (= y min-y)
                    (= y max-y))
            (set! vy 0)))))

    (define/public (die!) ;; Se remove-self!
      (set! hp 0)
      (remove-self!))
    
     ;; Tar in ett heltal som argument och minskar karaktärens liv med det talet.
    (define/public (hurt! damage) 
      (set! hp (- hp damage))
      (when (not (positive? hp))
        (die!)))
    
    ;; Kör move!-proceduren vid anrop. 
    (define/public (update!) 
      (when the-map
        (move!)))
    
    (super-new)))
