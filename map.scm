(define map%
  (class object%
    (define objects '())

    (define/public (add-object! object)
      (set! objects (cons object objects)))
    
    (define/public (delete-object! object)
      (set! objects (filter (λ (obj)
                              (not (eq? obj object)))
                            objects)))
    
    (define/public (update)
      (for-each (λ (obj)
                 (send obj update))
               objects))
    
    (define/public (render canvas dc)
      (for-each (λ (obj)
                 (send obj render canvas dc))
               objects))
    (super-new)))