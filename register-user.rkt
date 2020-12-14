#lang racket

(require json
         net/http-client)


(define client-id (getenv "NFL_API_CLIENT_ID"))
(define client-secret (getenv "NFL_API_CLIENT_SECRET"))
(define username (getenv "NFL_API_USERNAME"))
(define password (getenv "NFL_API_PASSWORD"))

(define get-access-token
  (lambda ()
    (displayln "Getting access token...")
    (let-values
      ([(status headers response-port)
        (http-sendrecv
          "api.nfl.com"
          "/v1/oauth/token"
          #:ssl? #t
          #:method "POST"
          #:headers '("Content-Type: application/x-www-form-urlencoded")
          #:data (string-append
                   "grant_type=client_credentials"
                   "&client_id=" client-id
                   "&client_secret=" client-secret))])
      (hash-ref (read-json response-port) 'access_token))))

(define post-user
  (lambda ()
    (displayln "Posting new user...")
    (let-values
      ([(status headers response-port)
        (http-sendrecv
          "api.nfl.com"
          "/v2/users"
          #:ssl? #t
          #:method "PUT"
          #:headers (list
                      "Content-Type: application/json"
                      (string-append
                        "Authorization: Bearer " (get-access-token)))
          #:data (jsexpr->string
                   (make-hasheq
                     (list
                       (cons 'username username)
                       (cons 'password password)
                       (cons 'firstName "Timmy")
                       (cons 'lastName "Turner")
                       (cons 'emailAddress "timturner@yahoo.com")
                       (cons 'birthDay "21")
                       (cons 'birthMonth "3")
                       (cons 'birthYear "1992")
                       (cons 'country "US")
                       (cons 'optIn #f)
                       (cons 'tos #t)))))])
      (displayln (read-json response-port)))))

(define register
  (lambda ()
    (displayln "Registering a user with api.nfl.com")
    (displayln (format "Password: ~a" password))
    (post-user)))

(register)

