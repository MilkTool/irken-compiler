;; -*- Mode: Irken -*-

(include "lib/basis.scm")
(include "lib/map.scm")
(include "lib/asn1/ber.scm")
(include "lib/codecs/hex.scm")

;; example consumer

(define (collector)
  (let ((val '()))
    (define (push x)
      (PUSH val x)
      (string-length x))
    {push  = push
     val   = (lambda () (string-concat val))
     reset = (lambda () (set! val '()))
     }))

;; example producer
(define (string-emitter s)
  (let ((pos 0)
        (len (string-length s)))
    (define (byte)
      (let ((r (string-ref s pos)))
        (set! pos (+ pos 1))
        (char->int r)))
    (define (string n)
      (if (> (+ pos n) len)
          (raise (:BERUnderflow "BER Underflow"))
         (let ((r (substring s pos (+ pos n))))
            (set! pos (+ n pos))
            r)))
    {byte=byte string=string}
    ))

(define (ber->string ob)
  (let ((c (collector)))
    (ber/encode c.push ob)
    (c.val)))

(define (string->ber s)
  (let (((val flags len) (ber/decode (string-emitter s))))
    val))

(define (test0)
  (let ((c (collector))
        (ber (ber:SEQUENCE
              (LIST
               (ber:INTEGER -314159)
               (ber:NULL)
               (ber:STRING (asn1string:OCTET) "testing")
               (ber:OID (LIST 1 2 840 113549 1))
               (ber:SET (LIST (ber:INTEGER 3) (ber:INTEGER 5) (ber:INTEGER 7)))
               ))))
    (for-list x '(0 127 128 256 -128 -129 314159 -314159)
      (c.reset)
      (ber/encode c.push (ber:INTEGER x))
      (printf "val: " (lpad 10 (int x)) " " (string (c.val)) "\n")
      (printn (ber/decode (string-emitter (c.val))))
      )
    (printn (string->ber "\x02\x08\x12\x34\x56\x78\xde\xad\xbe\xef"))
    (printn (string->ber (ber->string (ber:INTEGER 314159265))))
    (printn (string->ber (ber->string (ber:NULL))))
    (printn (string->ber (ber->string (ber:STRING (asn1string:OCTET) "testing, testing"))))
    (printn (string->ber (ber->string (ber:OID (LIST 1 2 840 113549 1)))))
    (printn (string->ber (ber->string (ber:SEQUENCE (LIST (ber:INTEGER 1) (ber:INTEGER 2) (ber:INTEGER 3))))))
    (printn (string->ber (ber->string (ber:BOOLEAN #f))))
    (printn (string->ber (ber->string (ber:BOOLEAN #t))))
    (printf "ber = " (string (ber->string ber)) "\n")
    (let ((ber0 (string->ber (ber->string ber))))
      (printn ber0)
      (printn ber)
      (printf " equal? " (bool (eq? (cmp:=) (magic-cmp ber0 ber))) "\n")
      )))

(define der0 "0\x82\x0c30\x82\x0b\x9c\xa0\x03\x02\x01\x02\x02\x11\x00\xce!\x83\xf6X\xbb.\x80\xe3U\xb8\x1b\x8d\xe0B\xd60\r\x06\t*\x86H\x86\xf7\r\x01\x01\x05\x05\x000\x82\x02\xa81\x0b0\t\x06\x03U\x04\x06\x13\x02DE1\x150\x13\x06\x03U\x04\n\x13\x0cViaThinkSoft1\x110\x0f\x06\x03U\x04\x0b\x13\x08Research1301\x06\x03U\x04\x03\x13*ViaThinkSoft OID-Overflow Test Certificate1\x1b0\x19\x06\x03U\x04\x03\x13\x12badguy.example.com1/0-\x06\t*\x86H\x86\xf7\r\x01\t\x01\x16 daniel-marschall@viathinksoft.de1301\x06\x03U\x04\x03\x13*ViaThinkSoft OID-Overflow Test Certificate1\x1b0\x19\x06\x03U\x04\x03\x13\x12badguy.example.com1,0*\x06\x07\x90\x80\x80\x80U\x04\x03\x13\x1f32bit.overflow.arc2.example.com1,0*\x06\x07U\x90\x80\x80\x80\x04\x03\x13\x1f32bit.overflow.arc1.example.com1,0*\x06\x07U\x04\x90\x80\x80\x80\x03\x13\x1f32bit.overflow.root.example.com1301\x06\x0f\x90\x80\x80\x80U\x90\x80\x80\x80\x04\x90\x80\x80\x80\x03\x13\x1e32bit.overflow.all.example.com110/\x06\x0c\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x04\x03\x13\x1f64bit.overflow.arc2.example.com110/\x06\x0cU\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x03\x13\x1f64bit.overflow.arc1.example.com110/\x06\x0cU\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x03\x13\x1f64bit.overflow.root.example.com1B0@\x06\x1e\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x03\x13\x1e64bit.overflow.all.example.com0\x1e\x17\r141115235427Z\x17\r141116235427Z0\x82\x02\xa81\x0b0\t\x06\x03U\x04\x06\x13\x02DE1\x150\x13\x06\x03U\x04\n\x13\x0cViaThinkSoft1\x110\x0f\x06\x03U\x04\x0b\x13\x08Research1301\x06\x03U\x04\x03\x13*ViaThinkSoft OID-Overflow Test Certificate1\x1b0\x19\x06\x03U\x04\x03\x13\x12badguy.example.com1/0-\x06\t*\x86H\x86\xf7\r\x01\t\x01\x16 daniel-marschall@viathinksoft.de1301\x06\x03U\x04\x03\x13*ViaThinkSoft OID-Overflow Test Certificate1\x1b0\x19\x06\x03U\x04\x03\x13\x12badguy.example.com1,0*\x06\x07\x90\x80\x80\x80U\x04\x03\x13\x1f32bit.overflow.arc2.example.com1,0*\x06\x07U\x90\x80\x80\x80\x04\x03\x13\x1f32bit.overflow.arc1.example.com1,0*\x06\x07U\x04\x90\x80\x80\x80\x03\x13\x1f32bit.overflow.root.example.com1301\x06\x0f\x90\x80\x80\x80U\x90\x80\x80\x80\x04\x90\x80\x80\x80\x03\x13\x1e32bit.overflow.all.example.com110/\x06\x0c\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x04\x03\x13\x1f64bit.overflow.arc2.example.com110/\x06\x0cU\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x03\x13\x1f64bit.overflow.arc1.example.com110/\x06\x0cU\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x03\x13\x1f64bit.overflow.root.example.com1B0@\x06\x1e\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x03\x13\x1e64bit.overflow.all.example.com0\x81\x9f0\r\x06\t*\x86H\x86\xf7\r\x01\x01\x01\x05\x00\x03\x81\x8d\x000\x81\x89\x02\x81\x81\x00\xaf\xaf~\xf9\xfd\x97\xfc\xa5\xfc\xba\xe1\xd5R\xd7w\xc3\x906\xe9\xe7\x8f\x15\xd8\xc7s\xd4\xa4\x96\x92\xf0\x17f\x92z`\x04\rw\x84\x1cMf\xe9m\xb7\xa4\xba\xe4\nJM\x1a#\nS\x03\xda \x1a\x94\xd5T\n\xcfB\x83\xeb\xf2\xc9\x86\x1d\xd6:[?\xd9\xccw\x11)r5\xf5}9\x1e\xa7P-\x18,I\xa0M\x02F\xb2?\x94\xff7\x82\xf0$\x8b}\xc8\x16\xb1\x1b`\x90]z.\x0c\xb7\x80\xfd\x11\x94%\xe2\x05\x7f\x14\x9a\x15\x02\x03\x01\x00\x01\xa3\x82\x05W0\x82\x05S0\x1d\x06\x03U\x1d\x0e\x04\x16\x04\x145-\xb7U2\xa2v#\x80\xc0\xfaU\x8eJE\x0c\xd4\xe2\x06\r0\x82\x02\xea\x06\x03U\x1d#\x04\x82\x02\xe10\x82\x02\xdd\x80\x145-\xb7U2\xa2v#\x80\xc0\xfaU\x8eJE\x0c\xd4\xe2\x06\r\xa1\x82\x02\xb0\xa4\x82\x02\xac0\x82\x02\xa81\x0b0\t\x06\x03U\x04\x06\x13\x02DE1\x150\x13\x06\x03U\x04\n\x13\x0cViaThinkSoft1\x110\x0f\x06\x03U\x04\x0b\x13\x08Research1301\x06\x03U\x04\x03\x13*ViaThinkSoft OID-Overflow Test Certificate1\x1b0\x19\x06\x03U\x04\x03\x13\x12badguy.example.com1/0-\x06\t*\x86H\x86\xf7\r\x01\t\x01\x16 daniel-marschall@viathinksoft.de1301\x06\x03U\x04\x03\x13*ViaThinkSoft OID-Overflow Test Certificate1\x1b0\x19\x06\x03U\x04\x03\x13\x12badguy.example.com1,0*\x06\x07\x90\x80\x80\x80U\x04\x03\x13\x1f32bit.overflow.arc2.example.com1,0*\x06\x07U\x90\x80\x80\x80\x04\x03\x13\x1f32bit.overflow.arc1.example.com1,0*\x06\x07U\x04\x90\x80\x80\x80\x03\x13\x1f32bit.overflow.root.example.com1301\x06\x0f\x90\x80\x80\x80U\x90\x80\x80\x80\x04\x90\x80\x80\x80\x03\x13\x1e32bit.overflow.all.example.com110/\x06\x0c\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x04\x03\x13\x1f64bit.overflow.arc2.example.com110/\x06\x0cU\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x03\x13\x1f64bit.overflow.arc1.example.com110/\x06\x0cU\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x03\x13\x1f64bit.overflow.root.example.com1B0@\x06\x1e\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x03\x13\x1e64bit.overflow.all.example.com\x82\x11\x00\xce!\x83\xf6X\xbb.\x80\xe3U\xb8\x1b\x8d\xe0B\xd60\x0f\x06\x03U\x1d\x13\x01\x01\xff\x04\x050\x03\x01\x01\xff0\x0e\x06\x03U\x1d\x0f\x01\x01\xff\x04\x04\x03\x02\x01\x060\x81\x9d\x06\x03U\x1d%\x01\x01\xff\x04\x81\x920\x81\x8f\x06\x08+\x06\x01\x05\x05\x07\x03\x01\x06\x08+\x06\x01\x05\x05\x07\x03\x02\x06\x03U\x04\x03\x06\x07\x90\x80\x80\x80U\x04\x03\x06\x07U\x90\x80\x80\x80\x04\x03\x06\x07U\x04\x90\x80\x80\x80\x03\x06\x0f\x90\x80\x80\x80U\x90\x80\x80\x80\x04\x90\x80\x80\x80\x03\x06\x0c\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x04\x03\x06\x0cU\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x03\x06\x0cU\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x03\x06\x1e\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x030s\x06\x03U\x1d\x11\x04l0j\x81 daniel-marschall@viathinksoft.de\x86Bhttps://www.viathinksoft.de/~daniel-marschall/asn.1/oid_facts.html\x88\x02\x8870s\x06\x03U\x1d\x12\x04l0j\x81 daniel-marschall@viathinksoft.de\x86Bhttps://www.viathinksoft.de/~daniel-marschall/asn.1/oid_facts.html\x88\x02\x8870\x81\x98\x06\x03U\x1d \x04\x81\x900\x81\x8d0\x05\x06\x03U\x04\x030\t\x06\x07\x90\x80\x80\x80U\x04\x030\t\x06\x07U\x90\x80\x80\x80\x04\x030\t\x06\x07U\x04\x90\x80\x80\x80\x030\x11\x06\x0f\x90\x80\x80\x80U\x90\x80\x80\x80\x04\x90\x80\x80\x80\x030\x0e\x06\x0c\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x04\x030\x0e\x06\x0cU\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x030\x0e\x06\x0cU\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x030 \x06\x1e\x82\x80\x80\x80\x80\x80\x80\x80\x80U\x82\x80\x80\x80\x80\x80\x80\x80\x80\x04\x82\x80\x80\x80\x80\x80\x80\x80\x80\x030\r\x06\t*\x86H\x86\xf7\r\x01\x01\x05\x05\x00\x03\x81\x81\x00\x91\xc1+\xe0\xe9\xd8\x9c#N\xbcM)u\xec\xb9N\xcdf\xa8\x16\xceF\xc1\x1fV\xd5\xbd\xd0\x8d)i\x14\xbfV\xd6\xe4\x9f\x9bT\xb1\x84\xd0\x8dT\x9e\xb6\"\xc1/8B_\xa3t\x85?\xfb\x8f\x88\x81\xbf\xd9\xae\x98\x95\x07f8\xcb\xe7\xf2\x1d\x0fa\xf5\xbd\x17\x1dd,IY\xbd\xcb\x93kp\x11\xfdQ\xbf\xd2\xf8_\x90\xdc]\x91\xa0\xd4\x98\xe6U\xefdz\x82A\xa2p\xff28\xbc}\x8aktA\xa9o\x80\xaf+\x1bnz\x98")

(pp-ber (string->ber der0) 0)

(define der1 (hex->string "603c303a040361626302013202022711020417bc927a3020300602010a020165300602010a020165300602010a020165300602010a0201650101000a0100"))
(pp-ber (string->ber der1) 0)

;(test0)