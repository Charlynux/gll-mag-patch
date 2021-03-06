
;;; 3 vectors -> 2 (accelerated snapshot)

(build-gll-dictionary)

; Rename 2DSP to despin-vector-1
(setf (forth-word-name (lkup '2dsp)) 'despin-vector-1)

; Rename the ROM version of 2DSP so we don't get confused
(setf (forth-word-name (lkup '2dsp)) 'obsolete-rom-2dsp)

(compile-patch ": despin-vector-1 V1 V@ S1PHI @ C1PHI @ DSPN ;")

; Get rid of DSP12 and DSP3, and put snapshot-readout in their place
(incf (forth-word-size (lkup 'dsp12)) (forth-word-size (lkup 'dsp3)))
(length (delete (lkup 'dsp3) (dictionary-entries *the-dictionary*)))
(setf (forth-word-name (lkup 'dsp12)) 'snapshot-readout)

(compile-patch
 ": snapshot-readout
    46FC @ DUP 4800 > IF V@ -6 46FC +!
    ELSE 0 0 M91 C@ DUP 5B = IF 4CEB 46FC ! 4745 C@ SNAP
    THEN V3 V! THEN ;")

; Finally, patch MAIN
(compile-patch
  ": MAIN LCMNDS ?MEMORY
    [' CKIDLE 2+ CPU-CTRL ! 
    [' DROP 2+ DEFAULT-SYS ! 
    [' SNAP 2+ SNAPSHOT ! 
    [' OPT-START 2+ OPTIMAL-AVER ! 
    20 4FF0 C! 0 4E40 ! 0 4E20 ! ENABLE-INT 20 4FF0 C! 
    0 FFF CKSUM ROM-CKSUM ! 4000 6FF CKSUM RAM-CKSUM ! 
    0 CMDPTR !  4CB0 CUR-STOR !  PINIT 9WAIT
    BEGIN INT-CNT C@ 13 >
    IF 9WAIT 0A SE4
       V1 OR! SF20 SF5 TRGFNS V1 V@ IBSV V! WAIT
       V2 OR! despin-vector-1 STATE-V FLTDSPV snapshot-readout
    ELSE 0 V1 9 B! 
    THEN SETSUB AV-VEC 0 END ;")