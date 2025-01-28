;; Sustainable Experience NFT Contract

(define-non-fungible-token sustainable-experience uint)

(define-map experience-metadata
  { token-id: uint }
  {
    name: (string-ascii 100),
    description: (string-utf8 500),
    location: (string-ascii 100),
    creator: principal,
    created-at: uint
  }
)

(define-data-var token-id-nonce uint u0)

(define-public (create-experience
  (name (string-ascii 100))
  (description (string-utf8 500))
  (location (string-ascii 100))
)
  (let
    ((new-token-id (+ (var-get token-id-nonce) u1)))
    (try! (nft-mint? sustainable-experience new-token-id tx-sender))
    (map-set experience-metadata
      { token-id: new-token-id }
      {
        name: name,
        description: description,
        location: location,
        creator: tx-sender,
        created-at: block-height
      }
    )
    (var-set token-id-nonce new-token-id)
    (ok new-token-id)
  )
)

(define-read-only (get-experience-metadata (token-id uint))
  (map-get? experience-metadata { token-id: token-id })
)

(define-public (transfer-experience (token-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? sustainable-experience token-id) (err u404))) (err u403))
    (try! (nft-transfer? sustainable-experience token-id tx-sender recipient))
    (ok true)
  )
)

