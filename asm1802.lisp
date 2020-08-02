
(in-package :cl-user)
(require 'utilities)


; Mode codes:  r=register b=byte w=word 0=no arg
(defvar *1802-opcode-table*
  '((idl 0 #x00) (ldn r #x00) (inc r #x10) (dec r #x20)
    
    (br b #x30) (bq b #x31) (bz b #x32) ((bdf bpz bge) b #x33)
    (b1 b #x34) (b2 b #x35) (b3 b #x36) (b4 b #x37)
    ((nbr skp) b #x38) (bnq b #x39) (bnz b #x3A) ((bnf bm bl) b #x3B)
    (bn1 b #x3C) (bn2 b #x3D) (bn3 b #x3E) (bn4 b #x3F)
    
    (lda r #x40) (str r #x50)
    
    (irx 0 #x60)
    (out1 0 #x61)(out2 0 #x62)(out3 0 #x63)(out4 0 #x64)
    (out5 0 #x65)(out6 0 #x66)(out7 0 #x67)
    (in1 0 #x69) (in2 0 #x6A) (in3 0 #x6B) (in4 0 #x6C)
    (in5 0 #x6D) (in6 0 #x6E) (in7 0 #x6E)
    
    (ret 0 #x70) (dis 0 #x71) (ldxa 0 #x72) (stxd 0 #x73)
    (adc 0 #x74) (sdb 0 #x75) ((shrc rshr) 0 #x76) (smb 0 #x77)
    (sav 0 #x78) (mark 0 #x79) (seq 0 #x7A) (req 0 #x7B)
    (addi b #x7C) (sdbi b #x7D) (shlc 0 #x7E) (smbi b #x7F)
    
    (glo r #x80) (ghi r #x90) (plo r #xA0) (phi r #xB0)
    
    (lbr w #xC0) (lbq w #xC1) (lbz w #xC2) (lbdf w #xC3)
    (nop 0 #xC4) (lsnq 0 #xC5) (lsnz 0 #xC6) (lsnf 0 #xC7)
    ((lskp nlbr) w #xC8) (lbnq w #xC9) (lbnz w #xCA) (lbnf w #xCB)
    (lsie 0 #xCC) (lsq 0 #xCD) (lsz 0 #xCE) (lsdf 0 #xCF)
    
    (sep r #xD0) (sex r #xE0)
    
    (ldx 0 #xF0) (or 0 #xF1) (and 0 #xF2) (xor 0 #xF3)
    (add 0 #xF4) (sd 0 #xF5) (shr 0 #xF6) (sm 0 #xF7)
    (ldi b #xF8) (ori b #xF9) (andi b #xFA) (xoi b #xFB)
    (adi b #xFC) (sdi b #xFD) (shl 0 #xFE) (smi b #xFF)
    
    ))

(defun lookup-mnemonic (m &optional (table *1802-opcode-table*))
  (find-if (fn (x) (or (eq (car x) m) (and (consp (car x)) (member m (car x)))))
           table))

(defun lookup-opcode (c &optional (table *1802-opcode-table*))
  (and (<= 0 c 255)
       (find-if (fn (x) (or (eq (third x) c)
                            (and (eq (second x) 'r)
                                 (eq (third x) (logand c #xF0)))))
                table)))

(defun asm-instr (instr &optional (emit-fn #'list))
  (let* ( (template (lookup-mnemonic (car instr)))
          (mode (second template))
          (opcode (third template)) )
    (if (null template) (asm-error "Unknown opcode: ~S" instr))
    (case mode
      ( (0 nil) (funcall emit-fn opcode) )
      ( r (funcall emit-fn (logior opcode (regop (second instr)))))
      ( b (funcall emit-fn opcode (byteop (second instr))) )
      ( w (apply emit-fn opcode (wordop (second instr))))
      (otherwise (asm-error "Bogus entry in opcode table: ~S" template)))))

(defun asm-error (msg &rest args)
  (apply #'error msg args))

(defun regop (reg)
  (if (null reg) (asm-error "Missing register operand."))
  (let ( (n (if (fixnump reg)
              reg
              (position reg '(r0 r1 r2 r3 r4 r5 r6 r7 r8
                              r9 r10 r11 r12 r13 r14 r15)))) )
    (if (and (fixnump n) (<= 0 n 15))
      n
      (asm-error "Illegal register: ~S" reg))))

(defun byteop (n)
  (if (null n) (asm-error "Missing byte operand."))
  (if (not (fixnump n)) (asm-error "Illegal byte operand: ~S" n))
  (if (<= 0 n 255)
    n
    (asm-error "Byte operand out of range: ~S" n)))

(defun wordop (n)
  (if (null n) (asm-error "Missing word operand."))
  (if (not (fixnump n)) (asm-error "Illegal word operand: ~S" n))
  (if (<= #x-7FFF n #xFFFF)
    (list (ash (logand n #xFF00) -8) (logand n #xFF))
    (asm-error "Word operand out of range: ~S" n)))

(defun disasm1 (mem &optional (start 0))
  (let* ( (pc start)
          (opcode (get-byte mem pc))
          (template (lookup-opcode opcode))
          (mnemonic (if (atom (car template)) (car template) (caar template)))
          (mode (second template)) )
    (format t "~&~4,'0X: ~2,'0X  ~A" pc opcode (or mnemonic "ILLEGAL OPCODE"))
    (cond
     ( (or (null mode) (eql mode 0)) )
     ( (eq mode 'r) (format t " R~S" (logand opcode 15)) )
     ( (eq mode 'b) (format t " ~2,'0X" (get-byte mem (1+ pc))) )
     ( (eq mode 'w) (format t " ~4,'0X" (+ (ash (get-byte mem (1+ pc)) 8)
                                           (get-byte mem (+ pc 2)))) )
     (t (asm-error "Bogus entry in opcode table: ~S" template)))
    (+ pc (ecase mode ((0 nil) 1) (r 1) (b 2) (w 3)))))

(defun disasm (mem &key (start 0) (n 1))
  (dotimes (i n) (setf start (disasm1 mem start))))
