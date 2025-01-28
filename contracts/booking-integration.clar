;; Eco-Certification Contract

(define-map certifications
  { entity-id: uint }
  {
    name: (string-ascii 100),
    category: (string-ascii 50),
    certification-level: (string-ascii 20),
    valid-until: uint,
    certifier: principal
  }
)

(define-data-var certification-count uint u0)

(define-public (issue-certification
  (entity-name (string-ascii 100))
  (category (string-ascii 50))
  (certification-level (string-ascii 20))
  (validity-period uint)
)
  (let
    ((new-cert-id (+ (var-get certification-count) u1)))
    (map-set certifications
      { entity-id: new-cert-id }
      {
        name: entity-name,
        category: category,
        certification-level: certification-level,
        valid-until: (+ block-height validity-period),
        certifier: tx-sender
      }
    )
    (var-set certification-count new-cert-id)
    (ok new-cert-id)
  )
)

(define-read-only (get-certification (entity-id uint))
  (map-get? certifications { entity-id: entity-id })
)

(define-public (revoke-certification (entity-id uint))
  (let
    ((cert (unwrap! (map-get? certifications { entity-id: entity-id }) (err u404))))
    (asserts! (is-eq (get certifier cert) tx-sender) (err u403))
    (map-delete certifications { entity-id: entity-id })
    (ok true)
  )
)

(define-read-only (is-certified (entity-id uint))
  (match (map-get? certifications { entity-id: entity-id })
    cert (< block-height (get valid-until cert))
    false
  )
)

