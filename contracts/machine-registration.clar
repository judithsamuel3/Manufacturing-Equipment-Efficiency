;; Machine Registration Contract
;; Records details of production equipment

(define-data-var last-machine-id uint u0)

(define-map machines
  { machine-id: uint }
  {
    name: (string-utf8 100),
    model: (string-utf8 100),
    serial-number: (string-utf8 100),
    manufacturer: (string-utf8 100),
    installation-date: uint,
    location: (string-utf8 100),
    owner: principal
  }
)

(define-public (register-machine
    (name (string-utf8 100))
    (model (string-utf8 100))
    (serial-number (string-utf8 100))
    (manufacturer (string-utf8 100))
    (installation-date uint)
    (location (string-utf8 100))
  )
  (let
    (
      (new-id (+ (var-get last-machine-id) u1))
    )
    (var-set last-machine-id new-id)
    (map-set machines
      { machine-id: new-id }
      {
        name: name,
        model: model,
        serial-number: serial-number,
        manufacturer: manufacturer,
        installation-date: installation-date,
        location: location,
        owner: tx-sender
      }
    )
    (ok new-id)
  )
)

(define-read-only (get-machine (machine-id uint))
  (map-get? machines { machine-id: machine-id })
)

(define-read-only (get-machine-count)
  (var-get last-machine-id)
)

(define-public (update-machine-location
    (machine-id uint)
    (new-location (string-utf8 100))
  )
  (let
    (
      (machine (unwrap! (get-machine machine-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner machine)) (err u403))
    (map-set machines
      { machine-id: machine-id }
      (merge machine { location: new-location })
    )
    (ok true)
  )
)

(define-public (transfer-ownership
    (machine-id uint)
    (new-owner principal)
  )
  (let
    (
      (machine (unwrap! (get-machine machine-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner machine)) (err u403))
    (map-set machines
      { machine-id: machine-id }
      (merge machine { owner: new-owner })
    )
    (ok true)
  )
)
