;; Collaboration Hub Contract
;; Manages inter-institutional collaboration and global research network coordination

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-COLLABORATION-NOT-FOUND (err u501))
(define-constant ERR-INVALID-INPUT (err u502))
(define-constant ERR-ALREADY-EXISTS (err u503))
(define-constant ERR-NOT-PARTICIPANT (err u504))

;; Data Variables
(define-data-var next-collaboration-id uint u1)
(define-data-var next-institution-id uint u1)

;; Data Maps
(define-map institutions
  { institution-id: uint }
  {
    name: (string-ascii 200),
    country: (string-ascii 100),
    contact-person: principal,
    specialization: (string-ascii 300),
    research-areas: (string-ascii 500),
    certification-level: uint,
    active: bool,
    registration-date: uint
  }
)

(define-map institution-lookup
  { contact-person: principal }
  { institution-id: uint }
)

(define-map collaborations
  { collaboration-id: uint }
  {
    title: (string-ascii 200),
    description: (string-ascii 1000),
    lead-institution: uint,
    collaboration-type: (string-ascii 100),
    status: (string-ascii 50),
    start-date: uint,
    end-date: uint,
    created-date: uint,
    data-sharing-level: uint,
    participant-count: uint
  }
)

(define-map collaboration-participants
  { collaboration-id: uint, institution-id: uint }
  {
    role: (string-ascii 100),
    join-date: uint,
    contribution-type: (string-ascii 200),
    data-access-level: uint,
    active: bool
  }
)

(define-map data-sharing-agreements
  { collaboration-id: uint }
  {
    agreement-hash: (string-ascii 100),
    terms: (string-ascii 1000),
    privacy-level: uint,
    retention-period: uint,
    geographic-restrictions: (string-ascii 300),
    approved-date: uint,
    expires-date: uint
  }
)

(define-map resource-sharing
  { collaboration-id: uint, resource-id: uint }
  {
    resource-type: (string-ascii 100),
    description: (string-ascii 500),
    provider-institution: uint,
    access-level: uint,
    usage-terms: (string-ascii 300),
    available: bool
  }
)

(define-map collaboration-resource-counts
  { collaboration-id: uint }
  { count: uint }
)

;; Public Functions

;; Register institution
(define-public (register-institution
  (name (string-ascii 200))
  (country (string-ascii 100))
  (specialization (string-ascii 300))
  (research-areas (string-ascii 500))
  (certification-level uint))
  (let
    (
      (institution-id (var-get next-institution-id))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
      (existing-lookup (map-get? institution-lookup { contact-person: tx-sender }))
    )
    (asserts! (is-none existing-lookup) ERR-ALREADY-EXISTS)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len country) u0) ERR-INVALID-INPUT)
    (asserts! (<= certification-level u5) ERR-INVALID-INPUT)

    (map-set institutions
      { institution-id: institution-id }
      {
        name: name,
        country: country,
        contact-person: tx-sender,
        specialization: specialization,
        research-areas: research-areas,
        certification-level: certification-level,
        active: true,
        registration-date: current-time
      }
    )

    (map-set institution-lookup
      { contact-person: tx-sender }
      { institution-id: institution-id }
    )

    (var-set next-institution-id (+ institution-id u1))
    (ok institution-id)
  )
)

;; Create collaboration
(define-public (create-collaboration
  (title (string-ascii 200))
  (description (string-ascii 1000))
  (collaboration-type (string-ascii 100))
  (start-date uint)
  (end-date uint)
  (data-sharing-level uint))
  (let
    (
      (collaboration-id (var-get next-collaboration-id))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
      (institution-lookup-result (map-get? institution-lookup { contact-person: tx-sender }))
    )
    (asserts! (is-some institution-lookup-result) ERR-NOT-AUTHORIZED)
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> end-date start-date) ERR-INVALID-INPUT)
    (asserts! (<= data-sharing-level u5) ERR-INVALID-INPUT)

    (let
      (
        (lead-institution (get institution-id (unwrap-panic institution-lookup-result)))
      )
      (map-set collaborations
        { collaboration-id: collaboration-id }
        {
          title: title,
          description: description,
          lead-institution: lead-institution,
          collaboration-type: collaboration-type,
          status: "active",
          start-date: start-date,
          end-date: end-date,
          created-date: current-time,
          data-sharing-level: data-sharing-level,
          participant-count: u1
        }
      )

      ;; Add lead institution as first participant
      (map-set collaboration-participants
        { collaboration-id: collaboration-id, institution-id: lead-institution }
        {
          role: "lead",
          join-date: current-time,
          contribution-type: "leadership",
          data-access-level: data-sharing-level,
          active: true
        }
      )

      (map-set collaboration-resource-counts
        { collaboration-id: collaboration-id }
        { count: u0 }
      )

      (var-set next-collaboration-id (+ collaboration-id u1))
      (ok collaboration-id)
    )
  )
)

;; Join collaboration
(define-public (join-collaboration
  (collaboration-id uint)
  (role (string-ascii 100))
  (contribution-type (string-ascii 200))
  (requested-access-level uint))
  (let
    (
      (collaboration (map-get? collaborations { collaboration-id: collaboration-id }))
      (institution-lookup-result (map-get? institution-lookup { contact-person: tx-sender }))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    (asserts! (is-some collaboration) ERR-COLLABORATION-NOT-FOUND)
    (asserts! (is-some institution-lookup-result) ERR-NOT-AUTHORIZED)
    (asserts! (> (len role) u0) ERR-INVALID-INPUT)

    (let
      (
        (collaboration-data (unwrap-panic collaboration))
        (institution-id (get institution-id (unwrap-panic institution-lookup-result)))
        (max-access-level (get data-sharing-level collaboration-data))
        (actual-access-level (if (<= requested-access-level max-access-level) requested-access-level max-access-level))
      )
      ;; Check if already participating
      (asserts! (is-none (map-get? collaboration-participants { collaboration-id: collaboration-id, institution-id: institution-id })) ERR-ALREADY-EXISTS)

      (map-set collaboration-participants
        { collaboration-id: collaboration-id, institution-id: institution-id }
        {
          role: role,
          join-date: current-time,
          contribution-type: contribution-type,
          data-access-level: actual-access-level,
          active: true
        }
      )

      ;; Update participant count
      (map-set collaborations
        { collaboration-id: collaboration-id }
        (merge collaboration-data {
          participant-count: (+ (get participant-count collaboration-data) u1)
        })
      )

      (ok true)
    )
  )
)

;; Create data sharing agreement
(define-public (create-data-sharing-agreement
  (collaboration-id uint)
  (agreement-hash (string-ascii 100))
  (terms (string-ascii 1000))
  (privacy-level uint)
  (retention-period uint)
  (geographic-restrictions (string-ascii 300))
  (expires-date uint))
  (let
    (
      (collaboration (map-get? collaborations { collaboration-id: collaboration-id }))
      (institution-lookup-result (map-get? institution-lookup { contact-person: tx-sender }))
      (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    )
    (asserts! (is-some collaboration) ERR-COLLABORATION-NOT-FOUND)
    (asserts! (is-some institution-lookup-result) ERR-NOT-AUTHORIZED)

    (let
      (
        (collaboration-data (unwrap-panic collaboration))
        (institution-id (get institution-id (unwrap-panic institution-lookup-result)))
      )
      ;; Verify institution is lead or authorized participant
      (asserts! (or
        (is-eq institution-id (get lead-institution collaboration-data))
        (is-some (map-get? collaboration-participants { collaboration-id: collaboration-id, institution-id: institution-id }))
      ) ERR-NOT-AUTHORIZED)

      (map-set data-sharing-agreements
        { collaboration-id: collaboration-id }
        {
          agreement-hash: agreement-hash,
          terms: terms,
          privacy-level: privacy-level,
          retention-period: retention-period,
          geographic-restrictions: geographic-restrictions,
          approved-date: current-time,
          expires-date: expires-date
        }
      )
      (ok true)
    )
  )
)

;; Share resource
(define-public (share-resource
  (collaboration-id uint)
  (resource-type (string-ascii 100))
  (description (string-ascii 500))
  (access-level uint)
  (usage-terms (string-ascii 300)))
  (let
    (
      (collaboration (map-get? collaborations { collaboration-id: collaboration-id }))
      (institution-lookup-result (map-get? institution-lookup { contact-person: tx-sender }))
      (current-count (default-to { count: u0 } (map-get? collaboration-resource-counts { collaboration-id: collaboration-id })))
      (resource-id (get count current-count))
    )
    (asserts! (is-some collaboration) ERR-COLLABORATION-NOT-FOUND)
    (asserts! (is-some institution-lookup-result) ERR-NOT-AUTHORIZED)
    (asserts! (> (len resource-type) u0) ERR-INVALID-INPUT)

    (let
      (
        (institution-id (get institution-id (unwrap-panic institution-lookup-result)))
      )
      ;; Verify institution is participant
      (asserts! (is-some (map-get? collaboration-participants { collaboration-id: collaboration-id, institution-id: institution-id })) ERR-NOT-PARTICIPANT)

      (map-set resource-sharing
        { collaboration-id: collaboration-id, resource-id: resource-id }
        {
          resource-type: resource-type,
          description: description,
          provider-institution: institution-id,
          access-level: access-level,
          usage-terms: usage-terms,
          available: true
        }
      )

      (map-set collaboration-resource-counts
        { collaboration-id: collaboration-id }
        { count: (+ resource-id u1) }
      )

      (ok resource-id)
    )
  )
)

;; Read-only functions

;; Get institution
(define-read-only (get-institution (institution-id uint))
  (map-get? institutions { institution-id: institution-id })
)

;; Get institution by contact
(define-read-only (get-institution-by-contact (contact-person principal))
  (let
    (
      (lookup (map-get? institution-lookup { contact-person: contact-person }))
    )
    (if (is-some lookup)
      (map-get? institutions { institution-id: (get institution-id (unwrap-panic lookup)) })
      none
    )
  )
)

;; Get collaboration
(define-read-only (get-collaboration (collaboration-id uint))
  (map-get? collaborations { collaboration-id: collaboration-id })
)

;; Get collaboration participant
(define-read-only (get-collaboration-participant (collaboration-id uint) (institution-id uint))
  (map-get? collaboration-participants { collaboration-id: collaboration-id, institution-id: institution-id })
)

;; Get data sharing agreement
(define-read-only (get-data-sharing-agreement (collaboration-id uint))
  (map-get? data-sharing-agreements { collaboration-id: collaboration-id })
)

;; Get shared resource
(define-read-only (get-shared-resource (collaboration-id uint) (resource-id uint))
  (map-get? resource-sharing { collaboration-id: collaboration-id, resource-id: resource-id })
)

;; Get total institutions
(define-read-only (get-total-institutions)
  (- (var-get next-institution-id) u1)
)

;; Get total collaborations
(define-read-only (get-total-collaborations)
  (- (var-get next-collaboration-id) u1)
)

;; Check if institution can access collaboration
(define-read-only (can-access-collaboration (collaboration-id uint) (institution-id uint))
  (let
    (
      (participant (map-get? collaboration-participants { collaboration-id: collaboration-id, institution-id: institution-id }))
    )
    (if (is-some participant)
      (get active (unwrap-panic participant))
      false
    )
  )
)

;; Get collaboration effectiveness score
(define-read-only (get-collaboration-effectiveness (collaboration-id uint))
  (let
    (
      (collaboration (map-get? collaborations { collaboration-id: collaboration-id }))
    )
    (if (is-some collaboration)
      (let
        (
          (collaboration-data (unwrap-panic collaboration))
          (participant-count (get participant-count collaboration-data))
          (resource-count (get count (default-to { count: u0 } (map-get? collaboration-resource-counts { collaboration-id: collaboration-id }))))
        )
        ;; Simple effectiveness calculation based on participants and resources
        (some (+ (* participant-count u10) (* resource-count u5)))
      )
      none
    )
  )
)
