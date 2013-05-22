(load "tilemap.scm")

(define map%
  (class object%
    (init-field width
                height
                tile-size
                canvas ;; för att kunna läsa av storleken på utritningsytan
                [tiles #f]) ;; för initiering av tiles (vector eller filnamn)

    (define tilemap (new tilemap%
                         [width width]
                         [height height]
                         [tile-size tile-size]
                         [tiles tiles]))
    (field [scrolled-distance 0] ;; anger hur långt skärmen har scrollat åt höger
           [items '()]
           [characters '()]
           [bullets '()]
           [player #f])
    
    ;; tillfällig start-bana
    ;(send tilemap set-tile! 1 11 'ground)
    
    ;; spara tiles-vectorn till en fil med filnamn filename
    (define/public (dump-tiles-to-file filename)
      (send tilemap dump-tiles-to-file filename))
    
    ;; colliding? : objekt, objekt -> boolean
    ;; returnerar sant om objekten överlappar varandra
    (define/public (colliding? obj1 obj2)
      ;; kollar om paren ligger utan "överlappande punkter"
      (define (separated-pairs? x1a x1b x2a x2b)
        (or (> (min x1a x1b) (max x2a x2b))
            (< (max x1a x1b) (min x2a x2b))))
      (if (and (or (is-a? obj1 player%)
                   (is-a? obj1 enemy%)
                   (is-a? obj1 bullet%)
                   (is-a? obj1 character%)
                   (is-a? obj1 weapon%))
               (or (is-a? obj2 player%)
                   (is-a? obj2 enemy%)
                   (is-a? obj2 bullet%)
                   (is-a? obj2 character%)
                   (is-a? obj2 weapon%)))
          (let ([x1 (get-field x obj1)]
                [y1 (get-field y obj1)]
                [x2 (get-field x obj2)]
                [y2 (get-field y obj2)]
                [w1 (get-field width obj1)]
                [h1 (get-field height obj1)]
                [w2 (get-field width obj2)]
                [h2 (get-field height obj2)])
            (and (not (separated-pairs? x1 (+ x1 w1)
                                        x2 (+ x2 w2)))
                 (not (separated-pairs? y1 (+ y1 h1)
                                        y2 (+ y2 h2)))))
          (error "Cannot check collision for these objects:" obj1 obj2)))
    
    ;; returnerar alla bullets som kolliderar med obj
    (define/public (colliding-bullets obj)
      (colliding-in bullets obj))
    
    ;; returnerar alla characters som kolliderar med obj
    (define/public (colliding-characters obj)
      (colliding-in characters obj))
    
    ;; returnerar alla items som kolliderar med obj
    (define/public (colliding-items obj)
      (colliding-in items obj))
    
    ;; returnerar alla element i lst som kolliderar med obj
    (define/public (colliding-in lst obj)
      (filter (λ (element)
                (and (not (eq? obj element)) ;; krockar inte med sig själv
                     (colliding? obj element)))
              lst))
    
    ;; returnerar en lista med alla koordinater (x . y) för tiles som obj överlappar
    (define/public (overlapping-tiles obj)
      (let ([x (round (inexact->exact (get-field x obj)))]
            [y (round (inexact->exact (get-field y obj)))]
            [obj-width (get-field width obj)]
            [obj-height (get-field height obj)])
        (let ([xs (cons (+ x obj-width -1) (range x (+ x obj-width -1) tile-size))]
              [ys (cons (+ y obj-height -1) (range y (+ y obj-height -1) tile-size))]
              [xy-pairs '()])
          (for-each (λ (x)
                      (for-each (λ (y)
                                  (let-values ([(x y) (send tilemap get-tile-coord-pos x y)])
                                    (set! xy-pairs (cons (cons x y) xy-pairs))))
                                ys))
                    xs)
          (filter (λ (coord) ;; returnera bara koorinater som existerar i tilemapen
                    (send tilemap valid-tile-coord? (car coord) (cdr coord)))
                  (remove-duplicates xy-pairs)))))
    
    ;; returnerar #t om obj överlappar en solid tile, annars #f
    ;  TODO: implementation m.h.a. overlapping-tiles
    (define/public (colliding-tiles obj)
      (let ([x (get-field x obj)]
            [y (get-field y obj)]
            [width (get-field width obj)]
            [height (get-field height obj)])
        (or (solid-tile-at? x y)
            (solid-tile-at? (+ x width -1) y)
            (solid-tile-at? x (+ y height -1))
            (solid-tile-at? (+ x width -1) (+ y height -1)))))

    ;; get-next-tile-pixel : solid? x y direction -> heltal
    ;;   Börjar på position (x,y) och går åt hållet direction
    ;;   tills den stöter på en solid eller tom (beroende på "solid?") tile
    ;;   eller tills banan tar slut. Returnerar x- eller y-koordinaten för den punkten
    ;;   (beroende på om den letade i x- eller y-led)
    (define/public (get-next-tile-pixel . args) ;; skicka vidare alla argument
      (send tilemap get-next-tile-pixel . args)) ; till tilemap
    
    ;; samma som get-next-tile-pixel fast kollar alltid efter solid tile
    (define/public (get-next-solid-pixel . args)
      (get-next-tile-pixel #t . args))
    
    ;; samma som get-next-tile-pixel fast kollar alltid efter tom tile
    (define/public (get-next-empty-pixel . args)
      (get-next-tile-pixel #f . args))
    
    ;; get-position-tile : x, y -> tile
    ;; returnerar värdet på en tile vid pixlar (x,y)
    (define/public (get-position-tile . args)
      (send tilemap get-position-tile . args))
    
    ;; get-screen-position-tile : x, y -> tile
    ;; returnerar värdet på en tile vid pixlar (x,y)
    ;; med x kompenserat för scrollning
    (define/public (get-screen-position-tile x y)
      (get-position-tile (+ x scrolled-distance) y))
    
    ;; solid-tile-at? : x, y -> boolean
    ;; returnerar sant om givna pixelkoordinater är del av en solid tile
    (define/public (solid-tile-at? . args)
      (send tilemap solid-tile-at? . args))
    
    ;; valid-tile-coord? : x, y (tile-koordinater) -> boolean
    ;; returnerar sant om x, y är giltiga koordinater för tiles
    (define/public (valid-tile-coord? . args)
      (send tilemap valid-tile-coord? . args))
    
    ;; valid-tile-coord-at-screen? : x, y (pixel-koordinater) -> boolean
    ;; returnerar sant om x, y konverterat till tile-koordinater är giltiga koordinater för tiles
    ;; (x kompenseras för scrollning)
    (define/public (valid-tile-coord-at-screen? x y)
      (let-values ([(x y) (send tilemap get-tile-coord-pos (+ x scrolled-distance) y)])
        (valid-tile-coord? x y)))
    
    ;; set-tile-at-screen! : pixel-x, pixel-y, value -> void
    ;; ändrar tilen vid pixel-koordinater x, y till value
    ;; med x kompenserat för scrollning
    (define/public (set-tile-at-screen! x y value)
      (let-values ([(x y) (send tilemap get-tile-coord-pos (+ x scrolled-distance) y)])
        (send tilemap set-tile! x y value)))
    
    ;; player-or-enemy? : object -> boolean
    ;; returnerar sant om object är en player% eller en enemy%
    (define (player-or-enemy? object)
      (or (is-a? object player%)
          (is-a? object enemy%)))
    
    ;; player-or-enemy? : object -> boolean
    ;; returnerar sant om object är en bullet%
    (define (bullet? object)
      (is-a? object bullet%))
    
    ;; Lägger in ett element i banan.
    ;; sätter fältet wielder (för vapen) eller the-map (för characters)
    ;; och lägger in elementet i rätt lista beroende på klass
    (define/public (add-element! element)
      (if (is-a? element weapon%) ;; om element är ett vapen, sätt wielder istället för the-map
          (set-field! wielder element this)
          (set-field! the-map element this)) ;; berätta för objektet vad the-map är
      
      ;; om elementet är en spelare, låt player peka på den
      (when (is-a? element player%)
        (set! player element))
      
      ;; lägg elementet i rätt lista beroende på klass
      (cond
        [(player-or-enemy? element)
          (set! characters (cons element characters))]
        [(bullet? element)
         (set! bullets (cons element bullets))]
        [else (set! items (cons element items))])) ;; om varken bullet eller player/enemy, lägg i items
    
    ;; Tar bort ett element från banan.
    ;; dvs tar bort elementet ur rätt lista (characters, bullets eller items)
    ;; och rensar the-map eller wielder (för vapen)
    (define/public (delete-element! element)
      ;; elementet tillhör ingen map längre
      (if (is-a? element weapon%) ;; om element är ett vapen, rensa wielder istället för the-map
          (set-field! wielder element #f)
          (set-field! the-map element #f))
      (cond
        [(player-or-enemy? element)
         (set! characters (filter (λ (elem)
                                    (not (eq? elem element)))
                                  characters))]
        [(bullet? element)
         (set! bullets (filter (λ (elem)
                                 (not (eq? elem element)))
                               bullets))]
        [else (set! items (filter (λ (elem)
                                  (not (eq? elem element)))
                                items))])) ;; om varken bullet eller player/enemy, ta bort ur items
    
    ;; - uppdaterar alla characters och bullets på banan
    ;; - uppdatera positioner
    ;; - kolla om spelaren har vunnit
    ;; - justera scrolled-distance
    ;; - ta bort bullets som inte ska vara kvar
    (define/public (update!)
      ;; uppdatera characters
      (for-each (λ (character)
                  (send character update!))
                characters)
      ;; uppdatera bullets
      (for-each (λ (bullet)
                  (send bullet update!))
                bullets)
      
      ;; kolla om spelaren har vunnit, dvs befinner sig på minst en exit-tile
      (when (not (null? (filter (λ (coords)
                                  (let* ([x (car coords)]
                                         [y (cdr coords)]
                                         [tile-type (send tilemap get-tile x y)])
                                    (eq? tile-type 'exit)))
                                (overlapping-tiles player))))
        (set-field! has-won? *player* #t)
        (send *timer* stop))
      
      ;; justera scrolled-distance så att spelaren är på skärmen
      (let ([canvas-width (send canvas get-width)]
            [player-x (get-field x player)]
            [scroll-width 280])
        (set! scrolled-distance
              (cond
                [(< player-x (+ scrolled-distance scroll-width))
                 (max 0 (- player-x scroll-width))]
                [(> player-x (+ scrolled-distance canvas-width (- scroll-width)))
                 (min (- (* tile-size width) canvas-width)
                      (+ player-x scroll-width (- canvas-width)))]
                [else scrolled-distance])))
      
      ;; ta bort bullets som kolliderar med tiles
      (set! bullets (filter (λ (bullet)
                              (not (colliding-tiles bullet)))
                            bullets))
      ;; ta bort bullets som är utanför skärmen
      ;; (hänsyn bör tas till varje bullets storlek också)
      ;; Ska det verkligen vara utanför skärmen eller bör det vara utanför banan?
      ;;   Dvs ska man kunna skjuta fiender utanför skärmen?
      (set! bullets (filter (λ (bullet)
                              (<= scrolled-distance
                                  (get-field x bullet)
                                  (+ scrolled-distance
                                     (send canvas get-width))))
                            bullets)))                       
    
    ;; ritar ut allting i banan
    (define/public (render canvas dc)
      (let-values ([(canvas-width canvas-height) (send canvas get-virtual-size)])
        ;; En enkel bakgrund
        (send dc set-brush (make-color 200 200 255) 'solid)
        (send dc set-pen "black" 0 'transparent)
        (send dc draw-rectangle 0 0 canvas-width canvas-height)
        (send tilemap render canvas dc scrolled-distance) ;; alla tiles
        (for-each (λ (elem) ;; alla bullets
                    (send elem render canvas dc))
                  bullets)
        (for-each (λ (elem) ;; alla items
                    (send elem render canvas dc))
                items)
        (for-each (λ (elem) ;; alla characters
                    (send elem render canvas dc))
                  characters)))
    
    ;; Ritar ut en rektangel med en viss färg och kompenserar i x-led för sidoscrollning
    (define/public (draw-rectangle x y width height color canvas dc)
      (send dc set-brush color 'solid)
      (send dc draw-rectangle (- x scrolled-distance) y width height))
    
    ;; Ritar ut en bitmap och kompenserar i x-led för sidoscrollning
    (define/public (draw-bitmap bitmap x y canvas dc)
      (send dc draw-bitmap bitmap (- x scrolled-distance) y))
    
    (super-new)))
