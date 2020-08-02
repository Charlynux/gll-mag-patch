From jmeans@igpp.ucla.edu Wed Feb 24 13:25:13 1993
Return-Path: <jmeans@igpp.ucla.edu>
Received: from igpp.ucla.edu by robotics (4.1/SMI-4.1+DXRm2.5)
	id AA21374; Wed, 24 Feb 93 13:24:29 PST
Received: from polar1.ucla.edu (polar1.igpp.ucla.edu) by igpp.ucla.edu (4.1/SMI-4.1.1)
	id AA21009; Wed, 24 Feb 93 13:24:13 PST
Date: Wed, 24 Feb 93 13:24:13 PST
From: jmeans@igpp.ucla.edu (Joe Means)
Message-Id: <9302242124.AA21009@igpp.ucla.edu>
To: gat@robotics.Jpl.Nasa.Gov
Status: R

 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
 
               The following list of documents and memo's comprise the software
          documentation for the Magnetometer Flight Executive. This documentation
          assumes some knowledge of the instrument capabilities and the FORTH
          programming language. 
 
 
                1.0 Magnetometer Functional Requirements Document (GLL 4-2035)
 
                2.0 Applicable sections of GLL 3-270, GLL 3-280, and GLL 3-290
 
                3.0 microFORTH TECHNICAL MANUAL for the RCA COSMAC (FORTH Inc.)
 
                4.0 MAGNETOMETER ROM-SOURCE documentation
 
                5.0 MAGNETOMETER FLIGHT EXECUTIVE documentation
 
                6.0 MAGNETOMETER DICTIONARY
 
                7.0 fig-FORTH for the APPLE II (FORTH INTEREST GROUP)
 
 
          An introduction to the FORTH Language and Operating system is available in
          the following book: 
 
               Starting FORTH by Leo Brodie, FORTH, Inc. 
 
 
               The operating system supplied in the MAGNETOMETER is a tailored
          version of the microFORTH system supplied by FORTH Inc. for the RCA COSMAC
          computer development system. In order to facilitate the development of the
          RAM EXECUTIVE the 1802 Cross Compiler and Assembler were transfered to the
          APPLE II system utilizing the figFORTH model supplied by the FORTH INTEREST
          GROUP. The APPLE system also contains the CDS interface circuitry which
          provides a convenient test facility for the completed software.  The
          software has been run in the breadboard test chassis to verify that it
          operates properly. 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                              -1-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
               The following is a commented listing of the flight executive provided
          for the GALILEO MAGNETOMETER. This document was prepared by modifying the
          output generated for the MAGFLT2 compilation of the flight executive. Only
          minor changes were made in the source for MAGFLT3. These changes corrected
          some problems found while running MAGFLT2 at JPL. 
 
               The RAM EXECUTIVE source is stored in screens 123 - 135 of the flight
          software disk (GALILEO - 166).  The cross compiled 1802 code is stored in
          locatiions 4000 - 4700 in the APPLE and also on the source disk for
          reloading the code during testing.  The first screen contains the linkage
          to the initialization code, and constant definitions. There are two
          different constant definitions used in screen 123 CONSTANT, and FCONSTANT.
          CONSTANT defines a word in the FLIGHT EXEC code while FCONSTANT defines a
          word in the APPLE operating system which is not part of the cross compiled
          code. 
 
 
 
                    
                    SCREEN # 123
                       ( FLIGHT RAM EXECUTIVE 3/29/84 ) HEX
                    
                       CODE XFER 0C0 RC, RCA ( Linkage to initialization)
                    
                        HERE FCONSTANT VECTOR 00 R, ( VECTOR contains the address
                        where the link to initialization is to be stored)
                       4D50 FCONSTANT SDATA-PTR (Address for interrupt ADC data)
                        0 RC, 4000 R, ( SPIN DELTA CORRECTION FACTOR)
                        HERE 20 + H ! ( Reserve area for command table)
                    
                    ROM-CODE
                    
                       2 CONSTANT 2 3 CONSTANT 3 ( HIDES FIG-FORTH DEFINITIONS)
                    
                       4EE5 CONSTANT INT-CNT 4EE4 CONSTANT M91
                       7FFF CONSTANT 1.0
                    
                       ( Define new user variables which will show up in SUBCOM)
                       66 USER DSP-AVER-CONSTANT
                       68 USER AVER#
                       8A USER ROM-CKSUM 8C USER RAM-CKSUM
                    
                        4CC4 CONSTANT CUR-STOR
                       6 CONSTANT 6 ( 6 is used often, this saves storage)
                    
                       9C USER ADDR-BUFFER ( user variable for data buffer)
                       DECIMAL --> ( Continue on next screen)
 
 
 
 
 
 
 
 
 
                                              -2-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
               Screen 124 contains the source for implementing the SNAPSHOT, and
          Status Voltage Filters.  The SNAPSHOT code consists of two words SNPST and
          SNAP. SNAP checks for an ON command then stores the current time in 4CF0
          and enables the snapshot operation via SNPST. SNPST expects the start
          address and the current mag data address ( VDATA ) on the stack.  Two
          status voltage filters are provided which both filter and scale the status
          voltages. The FI.. word filters one of the subcom data and the SF.. words
          provides the parameters to filter the complete set of data. 
 
 
 
                    SCREEN # 124
                    
                      ( SNAPSHOT AND STATUS VOLTAGE FILTERS ) HEX
                    
                    
                           CODE SNPST S SEX S LDA 8 PHI S LDA 8 PLO
                           S LDA 7 PHI S LDA 7 PLO NEXT
                    
                      : SNAP 55 = IF 4EE0 4CF0 6 MOVE ( IF COMMAND = 55 STORE TIME)
                         4CEB VDATA @ SNPST THEN ; ( AND START SNAPSHOT)
                    
                      ( STATUS VOLTAGE FILTERS)
                      ( 20 VOLT FILTER)
                         : FI20 RD5 + @ OVER @ 28ED S* - SWAP +! ;
                      ( FILTER 20V VALUES)
                         : SF20 VRAM 1A FI20 V12 10 FI20 V10 12 FI20 V-12 14 FI20 ;
                    
                       ( 5 VOLT SUBCOM VALUE FILTER ROUTINE)
                    
                      : FI5 RD5 + @ OVER @ 2000 S* - SWAP +! ;
                       ( FILTER 5V VALUES)
                       : SF5 GND 1E FI5 1-SPARE 16 FI5 2-SPARE 1C FI5
                        T-ELEC 18 FI5 ;
                    
                       DECIMAL --> ( Continue on next screen)
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                              -3-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
               Screen 125 contains some of the power on initialization codes. TTEXEC
          checks the current Mag, Gain status and sends the appropriate commands to
          reset the MAG to its last operating state. Initial power on state is set to
          INB ON, LOW GAIN. 
 
 
 
                    SCREEN # 125
                      ( MAGNETOMETER POWER ON INITIALIZATION) HEX
                    
                      ( TTEXEC EXPECTS SCALE/GAIN FACTOR, HIGAIN CMND # ON STACK)
                      : TTEXEC OVER 0F AND 05 = IF 93 ELSE 6C THEN OVER EXCMND
                       SWAP F0 AND 50 = IF 55 SWAP 2+ EXCMND ELSE DROP THEN ;
                    
                    
                       : PINIT SGOUT C@ 04 TTEXEC SGINB C@ 03 TTEXEC ;
                    
                    
                       DECIMAL --> ( Continue on next screen)
                    
 
               Screen 126 contains the source for the block store, DSPIN store, and
          OPTIMAL AVERAGE storage routines.  The Block store routine will store a
          given value in successive memory locations and is useful for initialization
          procedures. The DSPIN storage stores the time, angle, and despun data in
          the USER area defined for the SUBCOM. The OPTIMAL AVERAGE STORE routine
          stores the optimal average data when activated. This routine uses AVER# as
          a mask to determine when to store data. AVER# should be set to 0, 1, 3, 7,
          etc. to get one value every 1, 2, 4, 8, etc MOD91 counts. 
 
 
 
                    SCREEN # 126
                    
                      ( BLOCK STORE, DSPIN STORE) HEX
                      ( BLOCK STORE VAL ADDR #BYTES B! )
                      : B! 2* OVER + SWAP DO DUP I ! 2 +LOOP DROP ;
                    
                      ( DSPIN STORAGE )
                      : TS! 4EE1 OVER 4 MOVE 2+ 2+
                       4EF4 @ OVER ! 2+ 4EF2 @ OVER ! 2+
                       <R CUR-STOR @ V@ R> V! ;
                    
                    
                      ( OPTIMAL AVERAGER STORAGE) HEX
                      :  OPT-START 4800 CUR-STOR DUP @ 4800 4 MOVE ! 4CF0 TS! ;
                       : OPTST DATA-BUFFER-STATUS C@ 55 = IF
                      4EE2 @ AVER# @ AND 0= IF
                      CUR-STOR @ DUP 6 + DUP CUR-STOR ! 0 OVER 6 B! 6 MOVE
                       CUR-STOR @ 4CAF > IF AA DATA-BUFFER-STATUS C! THEN
                       THEN THEN ;
                    
                    
                       DECIMAL --> ( Continue on next screen)
 
 
                                              -4-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
               Screen 127 contains the source for generating the RAM, and ROM
          checksums and for loading the instrument parameters provided by DML load
          procedures. The checksums for 128 bytes of RAM and ROM memory are generated
          every MOD91 count. The complete sequence of checksums requires 32 MOD91
          counts to complete.  The checksums for the ROM and EXECUTIVE RAM areas
          should remain constant. The instrument parameters ( OFFSETS, ROTATION
          MATRICES, GAINS, and OPTIMAL AVERAGER CONSTANTS) are loaded via a DML
          command according to DML table.  These parameters must be reset as
          indicated in the table when the instrument operations are changed. 
 
                    SCREEN # 127
                      ( SUBCOM CKSUM, MAT-LOAD ROUTINES ) HEX
                    
                       82 USER CKSUM-PTR
                    
                       : CKSUM-GEN 80 CKSUM-PTR +! CKSUM-PTR @ DUP 1000 > IF
                       DROP 0 CKSUM-PTR 4 B! 
                       ELSE <R I 4000 + DUP 80 CKSUM SWAP R>
                        80 CKSUM CKSUM-PTR 2+ V! THEN ;
                    
                      : MAT-LOAD 4E80 @ A5A5 = IF 4EA6 @ A5A5 = IF
                       4E82 @ SCF ! 
                      4E84 DSP-AVER-CONSTANT 4 MOVE
                         4E88 1GAIN 1E MOVE
                        0 4E80 ! 0 4EA6 ! THEN THEN ;
                      : CKDANGLE SP-DELTA @ 4006 @ S* SP-DELTA ! CKDANGLE ;
                    
                    
                       DECIMAL --> ( Continue on next screen)
 
 
 
 
               Screen 128 contains the source for storage of the SUBCOM values during
          the MOD91 sequence. 
 
 
 
                    SCREEN # 128
                       ( FLIGHT EXECUTIVE SUBCOM ) HEX
                      ( TIME/SECTOR STORAGE ADDRESS ON STACK )
                    
                      : SDSPIN DUP 15 = IF 1ST-DSPVECTOR TS! THEN DUP 28 = IF
                      ADDR-BUFFER DUP @ 20 + DUP 4CF8 > IF DROP 4800 THEN
                       DUP ROT 2+ 20 MOVE ADDR-BUFFER !  THEN
                       DUP 34 = IF CKSUM-GEN THEN
                       DUP 42 = IF 2ND-DSPVECTOR TS! THEN
                       DUP 5A = IF OPTST MAT-LOAD 4FF0 C@ 20 - 2/ CMDPTR +! THEN ;
                      ( STORE SUBCOM IN S/C BUFFER)
                       : SETSUB M91 C@ DUP 5B = IF DROP
                      7500 C@ HD-PARITY C! PFLIP C@ 1 > IF PFLIP C@ 1 - PFLIP C! ELSE
                        FLIPPER POWER OFF 0 PFLIP C! THEN CKCOMM CKDANGLE SGOUT
                      ELSE SDSPIN 2* SGOUT + THEN @ BUFFER-ADDRESS ! ;
                       DECIMAL --> ( Continue on next screen)
                    
 
                                              -5-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
               Screen 129 contains the default parameter reset and memory
          initialization routines. The word PARESET sets the gains to 1.0, offsets to
          0 and the rotation matrix to the unity matrix.  ?MEMORY checks memory to
          see if it has been previously initialized. If the memory has not been
          initialized, then default values are set where needed. 
                    SCREEN # 129
                       ( MATRIX RESET ZERO-USER) HEX
                      : PARESET 4000 1GAIN 3 B! 0 OF1 3 B! 
                        RM1 0 OVER 9 B! 
                         1.0 OVER ! 8 + 1.0 OVER ! 8 + 1.0 SWAP !  ;
                      : MAT-RESET 0 SGOUT 5A B! ( ZERO SUBCOM)
                         PARESET 4800 ADDR-BUFFER ! ;
                    
                       : ?MEMORY DEFAULT-SYS @ [' DROP 2+ =
                        NOT IF MAT-RESET 8 FLTIM C! 
                      0 AVER# !  800 DSP-AVER-CONSTANT ! 
                       1 SCF ! AA5A SGOUT ! AA PFLIP !  THEN ;
                       DECIMAL --> ( Continue on next screen)
                    
                    
                    
 
               The words defined in screen 130 perform the rotation, scaling and
          offset correction of the magnetometer data. In addition two recursive
          filters are defined which are used to filter the Despun Subcom parameters
          and vectors. 
 
 
 
                    SCREEN # 130
                      ( DATA ROTATION, SCALING AND OFFSET CORRECTION )
                       ( EXPECTS ##, SCF ON STACK WHERE SCF=-2TO1.999 )
                      : SCALE H32 OVER OVER E+ OVER OVER E+ SWAP DROP ;
                    
                       : SC/RT 3GAIN @ SCALE SWAP 2GAIN @ SCALE ROT 1GAIN @ SCALE ;
                    
                      : OR!  <R VDATA @ OF1 V- SC/RT I V! 
                        RM1 I VROT SWAP ROT R> V!  ;
                    
                      ( GENERAL FILTER DIN, CONST, ADDR)
                      : FILT <R <R I H32 R> MINUS I @ H32 E+ DUP 0= + R> +!  DROP ;
                      ( 0= + INSURES NON ZERO VALUES)
                       ( AOUT = AOUT - CON*AOUT + CONST * DIN )
                     ( FAST FILT FOR STATE VECTOR TAKES SHORTEST ROUTE TO ANSWER)
                      0 RC, ( ALIGN FOR BAD MEMORY LOCATION 4494 BIT 0=1
                      : FILTF <R SWAP I @ - H32 DUP 0= + R> +! DROP ;
                       DECIMAL --> ( Continue on next screen)
                    
 
 
 
 
 
 
 
 
                                              -6-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
               Screen 131 contains the routines to generate the state vector
          information and the DSPIN data. 
 
 
 
                    SCREEN # 131
                      ( COMBINED STATE-VECTOR,DSPIN ROUTINES) HEX
                      : FIL256 DSP-AVER-CONSTANT @ SWAP FILT ; ( DATA, ADDR ==> 0)
                    
                    
                       : FIL!  DSP-AVER-CONSTANT @ SWAP FILTF ;
                      : AV-VEC INT-CNT C@ 1C < IF
                       IBSV V@ OBSV FIL!  OBSV 6 + FIL! 
                        OBSV 0C + FIL! THEN ;
                      ( CMPCAL CALC AND FILTERS DATA*SIN AND DATA * COS )
                      : CMPCAL <R DUP S1PHI @ S* I FIL!  C1PHI @ S* R> 2+ FIL!  ;
                    
                    
                      : STATE-V V1 V@ OBSV 2+ CMPCAL OBSV 8 + CMPCAL
                       OBSV 0E + CMPCAL ;
                        ( Z YDSP XDSP ON STACK)
                      DECIMAL --> ( Continue on next screen)
                    
 
 
 
 
               Screen 132 contains the routines for despinning all the data for the
          spacecraft. If full DSPIN is selected, then the state-vector information is
          not calculated due to time restrictions.
 
 
 
                    SCREEN # 132
                      ( FULL DESPINNING ROUTINES ) HEX
                       : DSPN S-CPROD SWAP - <R + R> ;
                      ( DSP VECTOR 2 FOR SUBCOM USE AND FULL DSPIN)
                       : 2DSP V2 V@ S2PHI @ C2PHI @ DSPN ;
                    
                       : FLTDSPV CUR-STOR @ <R I FIL256
                      I Y FIL256 R> Z FIL256 ;
                    
                      : DSP12 2DSP DSP-STAT C@ 55 = IF V2 V! 
                       V1 V@ S1PHI @ C1PHI @ DSPN V1 V! 
                       V2 V@ ELSE STATE-V THEN FLTDSPV ;
                       : DSP3 DSP-STAT C@ 55 = IF
                       V3 V@ S3PHI @ C3PHI @ DSPN V3 V! THEN ;
                    
                      DECIMAL --> ( Continue on next screen)
                    
 
 
 
 
 
 
                                              -7-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
               Screen 133 contains special WAIT routines which provide information in
          locations 4E60-4E68 about the timeing of the routines. WAIT is used to wait
          for a set number of interrupts, and 9WAIT waits until the S/C MOD10 time
          word = 9. The MOD10 time word counts from 9 to 29 in the magnetometer. 
 
 
 
                    SCREEN # 133
                       ( TEST WAIT ROUTINES ) HEX
                    
                      : WAIT BEGIN RD4 0< END ;
                    
                       : 9WAIT BEGIN INT-CNT C@ 9 = END
                       1 M91 C@ + M91 C! ;
                    
                       DECIMAL --> ( Continue on next screen)
 
               Screen 134 contains the MAIN executive routine which performs the
          following tasks: 
                A.  Initializes the command table
                B.  Checks and initializes memory if necessary
                C.  Sets up transfer vectors for IDLE, SNAPSHOT, and OPTIMAL-AVER
                    routines
                D.  Performs a checksum on ROM and EXEC-RAM (4000-46FF)
                E.  Initializes the magnetometers ( PINIT)
                F.  Waits for time sychronization ( 9WAIT)
                G.  Starts an endless loop which samples rotates, and scales the
                    data, calculates the SUBCOM values, DSPINS the data and maintains
                    time sychronization.
 
          The timing for these routines has been carefully checked and fully utilizes
          the time available. Changes in these routines must be carefully checked for
          timing as well as proper functional operation to insure that data is not
          lost.
 
 
                    SCREEN # 134
                      ( MODIFIED DEFAULT SYSTEM USE) HEX
                      : MAIN LCMNDS ?MEMORY
                         [' CKIDLE 2+ CPU-CTRL ! 
                         [' DROP 2+ DEFAULT-SYS ! 
                         [' SNAP 2+ SNAPSHOT ! 
                         [' OPT-START 2+ OPTIMAL-AVER ! 
                       20 4FF0 C! 0 4E40 ! 0 4E20 ! ENABLE-INT 20 4FF0 C! 
                        0 FFF CKSUM ROM-CKSUM ! 4000 6FF CKSUM RAM-CKSUM ! 
                       0 CMDPTR !  4CB0 CUR-STOR !  PINIT 9WAIT
                      BEGIN INT-CNT C@ 13 >
                      IF 9WAIT 6 SE4 V1 OR! SF20 SF5 TRGFNS V1 V@ IBSV V! WAIT
                           6 SE4 V2 OR!  DSP12 WAIT V3 OR! DSP3
                      ELSE 0 V1 9 B! 
                      THEN SETSUB AV-VEC 0 END ;
                      DECIMAL
                       --> ( Continue on next screen)
                    
 
 
                                              -8-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE               MARCH 29, 1984
 
 
               Screen 135 contains the 1802 register initialization code and the
          initial FORTH startup of the MAIN routine.
          
 
 
 
                    
                    SCREEN # 135
                      ( FINAL INITIALIZATION CODE ) HEX
                      CODE INIT
                      0C # LD 01 PHI 79 # LD 01 PLO
                       SDATA-PTR 100 / # LD 5 PHI
                       SDATA-PTR # LD 5 PLO
                      4E # LD 06 PHI 00 # LD 06 PLO
                       7 PHI 8 PHI 8 PLO U PLO F PHI
                      47 # LD U PHI
                      4D # LD R PHI S PHI
                      F0 # LD R PLO 40 # LD S PLO
                       'NEXT # LD F PLO 7 PLO
                      ' MAIN RCA DUP
                       100 / ASSEMBLER # LD I PHI # LD I PLO
                       NEXT
                      RCA LAST @ 2+ VECTOR R!  FORTH DECIMAL ;S
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                              -9-
 
 
 
 
          MAGNETOMETER                VOCABULARY MAGFLT3               MARCH 29, 1984
 
 
                      NAME            LINK ADDR (SCREEN)  COMMENTS
                                     APPLE  RCA    
                    
                      INIT                 46C4 (135)  Initialization code
                      MAIN                 45F7 (134)  RAM Exeutive main
                      9WAIT                45DB (133)  Wait for MOD10 = 9
                      WAIT                 45D0 (133)  Wait until reg 4 < 0
                      DSP3                 45AE (132)  DSPIN Vector 3
                      DSP12                457B (132)  DSPIN Vectors 1,2
                      FLTDSPV              4561 (132)  Average the Despun Vector
                      2DSP                 454F (132)  DSPIN vector 2
                      DSPN                 453F (132)  Calculate DESPUN vector
                      STATE-V              451F (131)  Calculate State Vector Info
                      CMPCAL               4501 (131)  Calc. D*SIN  D*COS, Filter
                      AV-VEC               44D8 (131)  Calc. State Vector Aver.
                      FIL!                 44CC (131)  Single Prec. Filter, Store
                      FIL256               44C0 (131)  Double Prec. Filter, Store
                      FILTF                44A4 (130)  Single Prec. fast filter
                      FILT                 4480 (130)  Double Prec. filter
                      OR!                  445E (130)  Offset,Rotate, Scale Data
                      SC/RT                4444 (130)  Scale Data, Rotate vector
                      SCALE                442E (130)  Scale data (-2. to 1.999)
               ?MEMORY              43ED (129)  Check MEMORY for reset?
                      MAT-RESET            43D6 (129)  Set rotation matrix to unity
                      PARESET              4399 (129)  Set Offsets, Gains to 0, 1.0
                      SETSUB               433E (128)  Store Subcom in USER array
                      SDSPIN               42BE (128)  Store DSPIN, CKSUM, MATLOD
                      CKDANGLE             42A8 (127)  Check, Scale Delta-angle
                      MAT-LOAD             4256 (127)  Load from DML area
                      CKSUM-GEN            420E (127)  128 word CKSUMS for RAM,ROM
                      CKSUM-PTR            420B (127)  Pointer for RAM CKSUM
                      OPTST                41BA (126)  Check,start OPTIMAL AVERAGE
                      OPT-START            419C (126)  INITIATE OPTIMAL AVERAGE
                      TS!                  4165 (126)  Store Time, Sector, DSPIN V
                      B!                   414A (126)  Block Storage
                      PINIT                4134 (125)  POR initialization 
                      TTEXEC               40F7 (125)  Mag Command Exec on POR
                      SF5                  40D7 (124)  SUBCOM FILTER 5 VOLTS
                      FI5                  40BD (124)  Five Volt Recursive Filter
                      SF20                 409D (124)  SUBCOM FILTER 20 VOLTS
                      FI20                 4083 (124)  Twenty Volt Recursive Filter
                      SNAP                 4061 (124)  Start SNAPSHOT if commanded
                      SNPST                4055 (124)  Start SNAPSHOT running
                      ADDR-BUFFER          4052 (123)  Data Buffer Address Pointer
                      6                    404E (123)  Constant  " 6 "
                      CUR-STOR             404A (123)  DSPIN pointer
                      RAM-CKSUM            4047 (123)  SUBCOM pointer for RAM CKSUM
                      ROM-CKSUM            4044 (123)  SUBCOM pointer for ROM CKSUM
                      AVER#                4041 (123)  SUBCOM pointer for AVER #
                      DSP-AVER-CONSTANT    403E (123)  SUBCOM pointer for DSP AVR K
                      1.0                  403A (123)  Constant " 1.0 "
                      M91                  4036 (123)  Position of MOD91 in time
                      INT-CNT              4032 (123)  Position of Int-counter
                      3                    402E (123)  Constant " 3 "
                      2                    402A (123)  Constant " 2 "
 
                                             -10-
 
 
 
 
          MAGNETOMETER                VOCABULARY MAGFLT3               MARCH 29, 1984
 
 
                      NAME            LINK ADDR (SCREEN)  COMMENTS
                                     APPLE  RCA
                    
                      SDATA-PTR      B2C1       (123)  APPLE FORTH CONSTANT  ADC
                      VECTOR         5389       (123)  APPLE FORTH CONSTANT  XFER
                      XFER                 4002 (123)  XFER TO INITIALIZATION    
                      MAIN                  F8D (384)    ROM MAIN ROUTINE
                      DFS                   F5B (383)    
                      DFSYS                 EF6 (382)
                      WAIT                  EE7 (382)
                      CKCOMM                EA6 (382)
                      DATA-STORE            E91 (
                      ENABLE-INT            E8B (382)
                      ZERO-USER             E75 (382)
                      SE4                   E6D (382)
                      RD4                   E64 (382)
                      2E/                   E4B (380)
                      2/                    E3C (380)
                      3DSP                  E26 (377)
                      2DSP                  E10 (377)
                      1DSP                  DFA (377)
                      V3                    DEF (377)
                      V2                    DE4 (377)
                      V1                    DDC (377)
                      DROT                  DC8 (377)
                      TRGFNS                DC0 (376)
                      TRFN                  D90 (376)
                      TRG-2                 D74 (376)
                      CKDANGLE              D48 (376)
                      C3PHI                 D45 (376)
                      S3PHI                 D42 (376)
                      C2PHI                 D3F (376)
                      S2PHI                 D3C (376)
                      C1PHI                 D39 (376)
                      S1PHI                 D36 (376)
                      DCOS                  D33 (376)
                      DSIN                  D30 (376)
                      DANGLE                D2D (376)
                      ANG-CONV              D29 (376)
                      ANGLE                 D25 (376)
                      SP-DELTA              D21 (376)
                      CKIDLE                D13 (370)
                      IDL                   CFB (370)
                      IDLE                  CC8 (370)
                      INTERRUPT-CODE        C5F (369)
                      FILTER                C33 (367)
                      A/4                   C07 (366)
                      XFER3                 C02 (251)
                      SNAP-SHOT             BDB (365)
                      ?COMND                BAA (364)
                      T/S-UPDATE            B69 (363)
                      SAMPLE                B3E (362)
 
 
 
 
                                             -11-
 
 
 
 
          MAGNETOMETER                VOCABULARY MAGFLT3               MARCH 29, 1984
 
 
                      NAME            LINK ADDR (SCREEN)  COMMENTS
                                     APPLE  RCA
                    
                      EXCMND                B2B (345)
                      LCMNDS                AF9 (345)
                      COMMNDS               AF5 (345)
                      COMMND-TAB            AD3 (345)
                      CMF                   AC9 (344)
                      CME                   ABF (344)
                      CMD                   AB7 (344)
                      CMC                   AAF (344)
                      CMB                   AA7 (344)
                      CMA                   A9F (344)
                      CM9                   A8F (344)
                      CM8                   A7D (344)
                      CM7                   A73 (344)
                      CM6                   A5A (344)
                      CM5                   A41 (344)
                      CM4                   A33 (344)
                      CM3                   A25 (344)
                      CM2                   A1B (344)
                      CM1                   A0F (344)
                      CM0                   A05 (344)
                      RD5                   9FC (343)
                      SF0                   9E2 (343)
                      S0F                   9C8 (343)
                      VDATA                 9C5 (343)
                      SNAPSHOT              9C2 (343)
                      OPTIMAL-AVER          9BF (343)
                      DEFAULT-SYS           9BC (343)
                      CPU-CTRL              9B9 (343)
                      FLIPC                 97B (342)
                      CFST                  94F (342)
                      FLP                   920 (342)
                      HI/LOW                8F0 (342)
                      ON/OFF                8C0 (342)
                      ERROR                 8AC (342)
                      SICOS                 859 (333)
                      S-CPROD               833 (333)
                      SICOS-DELTA           807 (333)
                      XFER2          53CB       (251)    XFER VECTOR FOR POR
                      TRIGE                 7F6 (330)
                      TRIG                  772 (330)
                      VROT                  746 (325)
                      VDOT                  6FE (325)
                      V+                    6C4 (325)
                      V-                    68A (325)
                      V!                    672 (325)
                      V@                    65A (325)
                      Z                     652 (325)
                      Y                     64C (325)
                      X                     648 (325)
                      BUFFER-ADDRESS        632 (324)
                      S*                    622 (323)
                      H32                   5BB (322)
 
                                             -12-
 
 
 
 
          MAGNETOMETER                VOCABULARY MAGFLT3               MARCH 29, 1984
 
 
                      NAME            LINK ADDR (SCREEN)  COMMENTS
                                     APPLE  RCA
                    
                      H*                    5A6 (321)                     MEM-PROTECT           59C (316)
                      RIGHT                 58F (313)
                      LEFT                  587 (313)
                      FLIP                  583 (313)
                      FLIPPER               57F (313)
                      CALIBRATE             57B (313)
                      HIGAIN                571 (313)
                      POWER                 567 (313)
                      INB                   563 (313)
                      OUT                   55F (313)
                      OFF                   554 (313)
                      ON                    549 (313)
                      ALL-OFF               531 (313)
                      HAMP                  4F5 (309)
                      PG                    4ED (309)
                      PC                    4DF (309)
                      CORRECT               4CE (308)
                      IR-RECOV              4C3 (308)
                      PARITY                4AD (308)
                      EOR                   4A4 (308)
                      CTAB                  49A (308)
                      CKSUM                 476 (302)
                      CMDPTR                473 (298)
                      DATA-BUFFER           470 (298)
                      2ND-DSPVECTOR         46D (298)
                      OBSV                  46A (298)
                      IBSV                  467 (298)
                      SF-PARITY             464 (298)
                      HD-PARITY             461 (298)
                      2-SPARE               45E (298)
                      1-SPARE               45B (298)
                      T-ELEC                458 (298)
                      GND                   455 (298)
                      VREF                  452 (298)
                      V-12                  44F (298)
                      V10                   44C (298)
                      V12                   449 (298)
                      VRAM                  446 (298)
                      DATA-BUFFER-STATUS    443 (298)
                      S/C-CAL               440 (298)
                      1ST-DSPVECTOR         43D (298)
                      DSP-STAT              43A (298)
                      RM1                   437 (298)
                      OF3                   434 (298)
                      OF2                   431 (298)
                      OF1                   42E (298)
                      3GAIN                 42B (298)
                      2GAIN                 428 (298)
                      1GAIN                 425 (298)
 
 
 
                                             -13-
 
 
 
 
          MAGNETOMETER                VOCABULARY MAGFLT3               MARCH 29, 1984
 
 
                      NAME            LINK ADDR (SCREEN)  COMMENTS
                                     APPLE  RCA
                    
                      PCAL                  422 (298)
                      PFLIP                 41F (298)
                      LINBFL                41C (298)
                      LOUTFL                419 (298)
                      CINBFL                416 (298)
                      COUTF                 413 (298)
                      SGINB                 410 (298)
                      SGOUT                 40D (298)
                      SCF                   40A (298)
                      FLTIM                 407 (298)
                      XFER1                 402 (251)
                      S*                    3CF (255)
                      M32                   3A3 (255)
                      ABSE                  39C (254)
                      MINE                  389 (254)
                      E@                    379 (254)
                      E!                    369 (254)
                      EXT                   355 (254)
                      E+                    33C (254)
                      DZ                    338 (254)
                      /                     32E (253)
                      *                     324 (253)
                      MOD                   31C (253)
                      /MOD                  30E (253)
                      */                    304 (253)
                      */MOD                 2F6 (253)
                      M/MOD                 2DA (253)
                      M*                    2BE (253)
                      ROT                   2B2 (253)
                      MIN                   2A1 (253)
                      MAX                   290 (253)
                      CZ                    28A (252)
                      -DUP                  27F (252)
                      2*                    277 (252)
                      ABS                   270 (252)
                      MINUS                 265 (252)
                      2+                    25F (252)
                      1+                    253 (252)
                      NOT                   24D (252)
                      =                     245 (252)
                      1                     241 (252)
                      >                     239 (252)
                      <                     231 (252)
                      0                     22D (252)
                      J                     21A ( 29)
                      LEAVE                 20D ( 29)
                      MEMORY-SWITCH         1FF (314)
                      I                     1F3 ( 52)
                      R>                    1E8 ( 52)
                      <R                    1DD ( 52)
 
 
 
                                             -14-
 
 
 
 
          MAGNETOMETER                VOCABULARY MAGFLT3               MARCH 29, 1984
 
 
                      NAME            LINK ADDR (SCREEN)  COMMENTS
                                     APPLE  RCA
                    
                      0<                    1D2 ( 52)
                      0=                    1C2 ( 52)
                      +!                    1B1 ( 52)
                      !                     1A5 ( 52)
                      @                     197 ( 51)
                      OVER                  187 ( 51)
                      SWAP                  173 ( 51)
                      DROP                  16E ( 51)
                      DUP                   162 ( 51)
                      U/                    13D ( 51)
                      U*                    11E ( 51)
                      MOVE                  105 ( 51)
                      -                      F8 ( 51)
                      +                      EB ( 51)
                      AND                    DE ( 51)
                      ;S                     D7 ( 51)
                      ':'            3BC2       (110)   PART OF CROSSCOMPILER
                      'DOES>'        2783       (110)    "    "    "    "
                      'USER'         2787       (110)    "    "    "    "
                      'CONSTANT'     2786       (110)    "    "    "    "
                      'VARIABLE'     278A       (110)    "    "    "    "
                      C!                     98 ( 51)
                      C@                     8C ( 51)
                      END            20A0       (109)   PART OF CROSSCOMPILER
                      BEGIN          650C       (109)    "    "    "    "
                      THEN           650C       (109)    "    "    "    "
                      WHILE          6622       (109)    "    "    "    "
                      ELSE           82FB       (109)    "    "    "    "
                      IF             82FB       (109)    "    "    "    "
                      +LOOP          20A0       (109)    "    "    "    "
                      LOOP           20A0       (109)    "    "    "    "
                      DO             82FB       (109)    "    "    "    "
                      WHILE                  89 ( 51)
                      ELSE                   86 ( 51)
                      END                    7B ( 51)
                      IF                     78 ( 51)
                      LOOP                   4B ( 51)
                      +LOOP                  48 ( 51)
                      DO                     35 ( 51) 
                      LIT                    2C ( 51)
                      [']                   21 ( 51) 
                      EXECUTE                14 ( 51)
                      'NEXT          45C7       (110)    PART OF CROSSCOMPILER
                      ZERO           2785       (110)    APPLE CONSTANT
                    
 
 
 
 
 
 
 
 
                                             -15-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE                MARCH 29,1984
 
 
 
 
 
 
 
                    4000  40  2 C0 46 C4  0 40  0 
                    4008   4  2  4  2  4  2  4  2 
                    4010   4  2  4  2  4  2  4  2 
                    4018   4  2  4  2  4  2  4  2 
                    4020   4  2  4  2  4  2  4  2 
                    4028   0 A7  0  2  0 A7  0  3 
                    4030   0 A7 4E E5  0 A7 4E E4 
                    4038   0 A7 7F FF  0 B0 66  0 
                    4040  B0 68  0 B0 8A  0 B0 8C 
                    4048   0 A7 4C C4  0 A7  0  6 
                    4050   0 B0 9C 40 55 EE 4E B8 
                    4058  4E A8 4E B7 4E A7 DF  0 
                    4060  CA  0 2A 55  2 43  0 76 
                    4068  17  0 1F 4E E0  0 1F 4C 
                    4070  F0 40 4C  1  3  0 1F 4C 
                    4078  EB  9 C3  1 95 40 53  0 
                    4080  D5  0 CA  9 FA  0 E9  1 
                    4088  95  1 85  1 95  0 1F 28 
                    4090  ED  6 20  0 F6  1 71  1 
                    4098  AF  0 D5  0 CA  4 44  0 
                    40A0  2A 1A 40 81  4 47  0 2A 
                    40A8  10 40 81  4 4A  0 2A 12 
                    40B0  40 81  4 4D  0 2A 14 40 
                    40B8  81  0 D5  0 CA  9 FA  0 
                    40C0  E9  1 95  1 85  1 95  0 
                    40C8  1F 20  0  6 20  0 F6  1 
                    40D0  71  1 AF  0 D5  0 CA  4 
                    40D8  53  0 2A 1E 40 BB  4 59 
                    40E0   0 2A 16 40 BB  4 5C  0 
                    40E8  2A 1C 40 BB  4 56  0 2A 
                    40F0  18 40 BB  0 D5  0 CA  1 
                    40F8  85  0 2A  F  0 DC  0 2A 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                             -16-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE                MARCH 29,1984
 
 
 
 
 
 
 
                    4100   5  2 43  0 76  7  0 2A 
                    4108  93  0 84  4  0 2A 6C  1 
                    4110  85  B 29  1 71  0 2A F0 
                    4118   0 DC  0 2A 50  2 43  0 
                    4120  76  D  0 2A 55  1 71  2 
                    4128  5D  B 29  0 84  3  1 6C 
                    4130   0 D5  0 CA  4  B  0 8A 
                    4138   0 2A  4 40 F5  4  E  0 
                    4140  8A  0 2A  3 40 F5  0 D5 
                    4148   0 CA  2 75  1 85  0 E9 
                    4150   1 71  0 33  1 60  1 F1 
                    4158   1 A3 40 28  0 46 F6  1 
                    4160  6C  0 D5  0 CA  0 1F 4E 
                    4168  E1  1 85  0 2A  4  1  3 
                    4170   2 5D  2 5D  0 1F 4E F4 
                    4178   1 95  1 85  1 A3  2 5D 
                    4180   0 1F 4E F2  1 95  1 85 
                    4188   1 A3  2 5D  1 DB 40 48 
                    4190   1 95  6 58  1 E6  6 70 
                    4198   0 D5  0 CA  0 1F 48  0 
                    41A0  40 48  1 60  1 95  0 1F 
                    41A8  48  0 40 4C  1  3  1 A3 
                    41B0   0 1F 4C F0 41 63  0 D5 
                    41B8   0 CA  4 41  0 8A  0 2A 
                    41C0  55  2 43  0 76 42  0 1F 
                    41C8  4E E2  1 95 40 3F  1 95 
                    41D0   0 DC  1 C0  0 76 31 40 
                    41D8  48  1 95  1 60 40 4C  0 
                    41E0  E9  1 60 40 48  1 A3  2 
                    41E8  2B  1 85 40 4C 41 48 40 
                    41F0  4C  1  3 40 48  1 95  0 
                    41F8  1F 4C AF  2 37  0 76  8
 
 
 
 
 
 
                                             -17-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE                MARCH 29,1984
 
 
 
 
 
 
 
                    4200   0 2A AA  4 41  0 96  0 
                    4208  D5  0 B0 82  0 CA  0 2A 
                    4210  80 42  9  1 AF 42  9  1 
                    4218  95  1 60  0 1F 10  0  2 
                    4220  37  0 76  F  1 6C  2 2B 
                    4228  42  9  0 2A  4 41 48  0 
                    4230  84 21  1 DB  1 F1  0 1F 
                    4238  40  0  0 E9  1 60  0 2A 
                    4240  80  4 74  1 71  1 E6  0 
                    4248  2A 80  4 74 42  9  2 5D 
                    4250   6 70  0 D5  0 CA  0 1F 
                    4258  4E 80  1 95  0 1F A5 A5 
                    4260   2 43  0 76 40  0 1F 4E 
                    4268  A6  1 95  0 1F A5 A5  2 
                    4270  43  0 76 31  0 1F 4E 82 
                    4278   1 95  4  8  1 A3  0 1F 
                    4280  4E 84 40 3C  0 2A  4  1 
                    4288   3  0 1F 4E 88  4 23  0 
                    4290  2A 1E  1  3  2 2B  0 1F 
                    4298  4E 80  1 A3  2 2B  0 1F 
                    42A0  4E A6  1 A3  0 D5  0 CA 
                    42A8   D 1F  1 95  0 1F 40  6 
                    42B0   1 95  6 20  D 1F  1 A3 
                    42B8   D 46  0 D5  0 CA  1 60 
                    42C0   0 2A 15  2 43  0 76  5 
                    42C8   4 3B 41 63  1 60  0 2A 
                    42D0  28  2 43  0 76 2C 40 50 
                    42D8   1 60  1 95  0 2A 20  0 
                    42E0  E9  1 60  0 1F 4C F8  2 
                    42E8  37  0 76  7  1 6C  0 1F 
                    42F0  48  0  1 60  2 B0  2 5D 
                    42F8   0 2A 20  1  3 40 50  1 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                             -18-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE                MARCH 29,1984
 
 
 
 
 
 
 
                    4300  A3  1 60  0 2A 34  2 43 
                    4308   0 76  3 42  C  1 60  0 
                    4310  2A 42  2 43  0 76  5  4 
                    4318  6B 41 63  1 60  0 2A 5A 
                    4320   2 43  0 76 16 41 B8 42 
                    4328  54  0 1F 4F F0  0 8A  0 
                    4330  2A 20  0 F6  E 3A  4 71 
                    4338   1 AF  0 D5  0 CA 40 34 
                    4340   0 8A  1 60  0 2A 5B  2 
                    4348  43  0 76 3C  1 6C  0 1F 
                    4350  75  0  0 8A  4 5F  0 96 
                    4358   4 1D  0 8A  2 3F  2 37 
                    4360   0 76 10  4 1D  0 8A  2 
                    4368  3F  0 F6  4 1D  0 96  0 
                    4370  84  D  5 7D  5 65  5 52 
                    4378   2 2B  4 1D  0 96  E A4 
                    4380  42 A6  4  B  0 84  9 42 
                    4388  BC  2 75  4  B  0 E9  1 
                    4390  95  6 30  1 A3  0 D5  0 
                    4398  CA  0 1F 40  0  4 23 40 
                    43A0  2C 41 48  2 2B  4 2C 40 
                    43A8  2C 41 48  4 35  2 2B  1 
                    43B0  85  0 2A  9 41 48 40 38 
                    43B8   1 85  1 A3  0 2A  8  0 
                    43C0  E9 40 38  1 85  1 A3  0 
                    43C8  2A  8  0 E9 40 38  1 71 
                    43D0   1 A3  0 D5  0 CA  2 2B 
                    43D8   4  B  0 2A 5A 41 48 43 
                    43E0  97  0 1F 48  0 40 50  1 
                    43E8  A3  0 D5  0 CA  9 BA  1 
                    43F0  95  0 1F  1 6C  2 5D  2 
                    43F8  43  2 4B  0 76 2D 43 D4 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                             -19-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE                MARCH 29,1984
 
 
 
 
 
 
 
                    4400   0 2A  8  4  5  0 96  2 
                    4408  2B 40 3F  1 A3  0 1F  8 
                    4410   0 40 3C  1 A3  2 3F  4 
                    4418   8  1 A3  0 1F AA 5A  4 
                    4420   B  1 A3  0 2A AA  4 1D 
                    4428   1 A3  0 D5  0 CA  5 B9 
                    4430   1 85  1 85  3 3A  1 85 
                    4438   1 85  3 3A  1 71  1 6C 
                    4440   0 D5  0 CA  4 29  1 95 
                    4448  44 2C  1 71  4 26  1 95 
                    4450  44 2C  2 B0  4 23  1 95 
                    4458  44 2C  0 D5  0 CA  1 DB 
                    4460   9 C3  1 95  4 2C  6 88 
                    4468  44 42  1 F1  6 70  4 35 
                    4470   1 F1  7 44  1 71  2 B0 
                    4478   1 E6  6 70  0 D5  0 CA 
                    4480   1 DB  1 DB  1 F1  5 B9 
                    4488   1 E6  2 63  1 F1  1 95 
                    4490   5 B9  3 3A  1 60  1 C0 
                    4498   0 E9  1 E6  1 AF  1 6C 
                    44A0   0 D5  0 CA  1 DB  1 71 
                    44A8   1 F1  1 95  0 F6  5 B9 
                    44B0   1 60  1 C0  0 E9  1 E6 
                    44B8   1 AF  1 6C  0 D5  0 CA 
                    44C0  40 3C  1 95  1 71 44 7E 
                    44C8   0 D5  0 CA 40 3C  1 95 
                    44D0   1 71 44 A2  0 D5  0 CA 
                    44D8  40 30  0 8A  0 2A 1C  2 
                    44E0  2F  0 76 1A  4 65  6 58 
                    44E8   4 68 44 CA  4 68 40 4C 
                    44F0   0 E9 44 CA  4 68  0 2A 
                    44F8   C  0 E9 44 CA  0 D5  0 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                             -20-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE                MARCH 29,1984
 
 
 
 
 
 
 
                    4500  CA  1 DB  1 60  D 34  1 
                    4508  95  6 20  1 F1 44 CA  D 
                    4510  37  1 95  6 20  1 E6  2 
                    4518  5D 44 CA  0 D5  0 CA  D 
                    4520  DA  6 58  4 68  2 5D 44 
                    4528  FF  4 68  0 2A  8  0 E9 
                    4530  44 FF  4 68  0 2A  E  0 
                    4538  E9 44 FF  0 D5  0 CA  8 
                    4540  31  1 71  0 F6  1 DB  0 
                    4548  E9  1 E6  0 D5  0 CA  D 
                    4550  E2  6 58  D 3A  1 95  D 
                    4558  3D  1 95 45 3D  0 D5  0 
                    4560  CA 40 48  1 95  1 DB  1 
                    4568  F1 44 BE  1 F1  6 4A 44 
                    4570  BE  1 E6  6 50 44 BE  0 
                    4578  D5  0 CA 45 4D  4 38  0 
                    4580  8A  0 2A 55  2 43  0 76 
                    4588  1E  D E2  6 70  D DA  6 
                    4590  58  D 34  1 95  D 37  1 
                    4598  95 45 3D  D DA  6 70  D 
                    45A0  E2  6 58  0 84  3 45 1D 
                    45A8  45 5F  0 D5  0 CA  4 38 
                    45B0   0 8A  0 2A 55  2 43  0 
                    45B8  76 13  D ED  6 58  D 40 
                    45C0   1 95  D 43  1 95 45 3D 
                    45C8   D ED  6 70  0 D5  0 CA 
                    45D0   E 62  1 D0  0 79 FA  0 
                    45D8  D5  0 CA 40 30  0 8A  0 
                    45E0  2A  9  2 43  0 79 F5  2 
                    45E8  3F 40 34  0 8A  0 E9 40 
                    45F0  34  0 96  0 D5  0 CA  A 
                    45F8  F7 43 EB  0 1F  D 11  2 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                             -21-
 
 
 
 
          MAGNETOMETER                 MAGFLT3 EXECUTIVE                MARCH 29,1984
 
 
 
 
 
 
 
                    4600  5D  9 B7  1 A3  0 1F  1 
                    4608  6C  2 5D  9 BA  1 A3  0 
                    4610  1F 40 5F  2 5D  9 C0  1 
                    4618  A3  0 1F 41 9A  2 5D  9 
                    4620  BD  1 A3  0 2A 20  0 1F 
                    4628  4F F0  0 96  2 2B  0 1F 
                    4630  4E 40  1 A3  2 2B  0 1F 
                    4638  4E 20  1 A3  E 89  0 2A 
                    4640  20  0 1F 4F F0  0 96  2 
                    4648  2B  0 1F  F FF  4 74 40 
                    4650  42  1 A3  0 1F 40  0  0 
                    4658  1F  6 FF  4 74 40 45  1 
                    4660  A3  2 2B  4 71  1 A3  0 
                    4668  1F 4C B0 40 48  1 A3 41 
                    4670  32 45 D9 40 30  0 8A  0 
                    4678  2A 13  2 37  0 76 30 45 
                    4680  D9 40 4C  E 6B  D DA 44 
                    4688  5C 40 9B 40 D5  D BE  D 
                    4690  DA  6 58  4 65  6 70 45 
                    4698  CE 40 4C  E 6B  D E2 44 
                    46A0  5C 45 79 45 CE  D ED 44 
                    46A8  5C 45 AC  0 84  A  2 2B 
                    46B0   D DA  0 2A  9 41 48 43 
                    46B8  3C 44 D6  2 2B  0 79 B4 
                    46C0   0 D5 46 C4 F8  C B1 F8 
                    46C8  79 A1 F8 4D B5 F8 50 A5 
                    46D0  F8 4E B6 F8  0 A6 B7 B8 
                    46D8  A8 AC BF F8 47 BC F8 4D 
                    46E0  B2 BE F8 F0 A2 F8 40 AE 
                    46E8  F8  6 AF A7 F8 45 BD F8 
                    46F0  F7 AD DF  0  0  0  0  0 
                    46F8   0  0  0  0  0  0  0  0
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                             -22-
 
 
 
 
                                GALILEO MAGNETOMETER DICTIONARY
 
 
                         The following dictionary of FORTH defined words is
 
                    provided in the GALILEO MAGNETOMETER experiment. The
 
                    operation of these words is indicated using the following
 
                    abbreviation for stack operations: 
 
 
 
                         Stack notation:  ( before --> after ) ; top of stack on
 
                    right
 
 
                         b, b1 ...  8-bit byte
 
                         n, n1 ... 16-bit signed numbers
 
                         d, d1 ... 32-bit signed numbers
 
                         u, u1 ... 16-bit unsigned numbers
 
                         ud, ud1 ... 32-bit unsigned numbers
 
                         f ... Boolean flag
 
                         c ... ASCII character value
 
                         addr ... address
 
 
                    Numbers are presented in hexidecimal unless otherwise
 
                    indicated. 

 
                         This dictionary includes all words defined at this time
 
                    including the core FORTH definitions, the ROM definitions
 
                    and the RAM executive definitions. Those words that are
 
                    associated with the Interrupt Routines are not available for
 
                    use outside of the interrupt routines. Some words associated
 
                    with the Despin routines provided in ROM have errors and are
 
                    redefined in RAM.
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -23-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               !               1A5 ( 52) ( n addr --> )
 
                              Stores 16-bit number into the address
 
               ;S              D7 ( 51) ( --> )
 
                              End of FORTH definition, return to next word,
                              transfer set up by ' ; ' in crosscompiler
 
               ':'             3BC2 (110) ( --> )
 
                              Crosscompiler code for :  Creates new entry in
                              vocabulary
 
               'CONSTANT'      2786 (110) ( n --> )
 
                              Crosscompiler code creating constant
 
               'DOES>'         2783 (110) ( --> )
 
                              Crosscompiler code creating compiling words
 
               'NEXT           2015 (110) ( --> )
 
                              Cross compiler location for next
 
               'USER'          2787 (110) ( n --> )
 
                              Crosscompiler word gererating USER variable
 
               'VARIABLE'      278A (110) ( n --> )
 
                              Crosscompiler word generating variable
 
               *               324 (253) ( n n1 --> n-prod )
 
                              Unsigned multiply (software 16-bit)
 
               */              304 (253) ( n n1 n2 --> n-result)
 
                              Multiplies then divides using software (n*n1/n2).
                              Uses 24-bit intermediate results. 
 
               */MOD           2F6 (253) ( u1 u2 u3 --> u-rem u-result )
 
                              Multiplies then divides leaving rem, result uses
                              24 bit intermediate results
 
               +               EB ( 51) (n1 n2 --> n-sum)
 
                              Adds
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -24-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               +!              1B1 ( 52) (n1 addr --> )
 
                              Adds 16 bit number n1 to contents of the address
                              and stores the result at addr
 
               +LOOP           48 ( 51) (n1 --> )
 
                              End of loop structure, adds n1 to loop index. 
 
               +LOOP           20A0 (109)
 
                              Cross compiler word sets up call +LOOP
 
               -               F8 ( 51) (n1 n2 --> n-diff)
 
                              Subtracts
 
               -DUP            27F (252) (n1 --> n1 f)
 
                              Duplicates stack if non zero with true flag leaves
                              false flag if stack=0. 
 
               /               32E (253) (u1 u2 --> u-quot)
 
                              Divides (n1/n2)
 
               /MOD            30E (253) (u1 u2 --> u-rem u-quot)
 
                              Divides. Returns remainder and quotient. 
 
               0               22D (252) ( --> 00 )
 
                              Constant zero
 
               0<              1D2 ( 52) ( n --> f )
 
                              Returns true if n is negative. 
 
               0=              1C2 ( 52) ( n --> f )
 
                              Returns true if n is zero. 
 
               1               241 (252) ( --> 01 )
 
                              Constant one
 
               1+              253 (252) ( n --> n+1)
 
                              Adds one to n. 
 
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -25-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               1-SPARE         45B (298) ( --> addr)
 
                              User address
 
               1.0             403A (123) ( --> 7fff)
 
                              Constant 7fff (1.0)
 
               1DSP            DFA (377) ERROR IN ROUTINE
 
                              User address
 
               1GAIN           425 (298) ( --> addr)
 
                              User address
 
               1ST-DSPVECTOR   43D (298) ( --> addr )
 
                              User address
 
               2               402A (123) ( --> 02 )
 
                              Constant 2
 
               2*              277 (252) ( n --> 2*n )
 
                              Multiplies n by 2. 
 
               2+              25F (252) ( n --> n + 2 )
 
                              Adds 2 to number on stack
 
               2-SPARE         45E (298) ( --> addr )
 
                              User address
 
               2/              E3C (380) ( n --> n/2 )
 
                              Divides n by 2
 
               2DSP            E10 (377) ERROR IN ROUTINE
 
                              Error in code do not use
 
               2DSP            454F (132) ( --> )
 
                              Despin second vector (replacement routine)
 
               2E/             E4B (380)
 
                              Extended precision divide by 2
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -26-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               2GAIN           428 (298) ( --> addr)
 
                              User variable
 
               2ND-DSPVECTOR    46D (298) ( --> addr )
 
                              User variable
 
               3               402E (123) ( --> 03 )
 
                              Constant 03
 
               3DSP            E26 (377) ERROR IN ROUTINE
 
                              ERROR DO NOT USE
 
               3GAIN           42B (298) ( --> addr )
 
                              User variable
 
               6               404E (123) ( --> 06 )
 
                              Constant 06
 
               9WAIT           45DB (133) ( --> )
 
                              Wait for Mod10 time = 9 ( start of frame)
 
               <               231 (252) ( n1 n2 --> f )
 
                              Leave true flag if n1 < n2
 
               <R              1DD ( 52) ( n --> )
 
                              Pops a value off parameter stack and pushes it on
                              the return stack
 
               =               245 (252) ( n1 n2 --> f)
 
                              Leaves true flag if n1 = n2
 
               >               239 (252) ( n1 n2 --> f)
 
                              Leaves true flag if n1 > n2
 
               ?COMND          BAA (364)
 
               ?MEMORY         43ED (129) Check MEMORY for reset? 
 
               @               197 ( 51) ( addr --> n1 )
 
                              Pushes the contents of addr on the parameter
                              stack. 
 
 
 
          MAGNETOMETER DICTIONARY            -27-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               A/4             C07 (366) ( --> )
 
                              Interrupt routine not for general use. 
 
               ABS             270 (252) ( n1 --> Abs n1 )
 
                              Absolute value of top of stack
 
               ABSE            39C (254) ( d1 --> Abs d1 )
 
                              Double precision extended precision
 
               ADDR-BUFFER     4052 (123) ( --> Buffer dump addr )
 
                              Buffer address for subcom data-buffer dump
 
               ALL-OFF         531 (313)
 
                              Turns OFF all commandable hardware
 
               AND             DE ( 51) ( n1 n2 --> n1 )
 
                              Logical and of n1, n2
 
               ANG-CONV        D29 (376) ( --> n )
 
                              Constant for ANGLE CONVERSION ( 7168 decimal)
 
               ANGLE           D25 (376) ( --> addr )
 
                              Address for angle
 
               AV-VEC          44D8 (131) Calc. State Vector Aver. 
 
                              Calculates state vector
 
               AVER#           4041 (123) ( --> addr)
 
                              User variable
 
               B!              414A (126) ( n1 addr nbytes --> )
 
                              Stores n1 in block addr to addr+nbytes
 
               BEGIN           650C (109) ( --> )
 
                              Cross compiler start of indefinite loop
 
               BUFFER-ADDRESS   632 (324) ( --> addr)
 
                              Routine which provides current buffer address
                              depending on S/C time. 
 
 
 
 
          MAGNETOMETER DICTIONARY            -28-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               C!              98 ( 51) ( n addr --> )
 
                              Stores low order byte of n at addr
 
               C1PHI           D39 (376) ( --> addr)
 
                              User variable contains cos(phi) for v1
 
               C2PHI           D3F (376) ( --> addr)
 
                              User variable contains cos(phi) for v2
 
               C3PHI           D45 (376) ( --> addr)
 
                              User variable contains cos(phi) for v3
 
               C@              8C ( 51) ( addr --> n)
 
                              Reads byte at addr into low order of n, high order
                              set = 0
 
               CALIBRATE       57B (313) ( --> addr )
 
                              Address for calibrate power control
 
               CFST            94F (342) ( f n-cmnd --> )
 
                              Depend on f turns on INB or OUT FLIPPER, sets
                              FLTIM
 
               CINBFL          416 (298) ( --> addr)
 
                              User Variable Current Inb Flip Direction
 
               CKCOMM          EA6 (382) ( --> )
 
                              Reads / executes commands from secondary command
                              buffer
 
               CKDANGLE        42A8 (127) ( --> )
 
                              Checks Spin Delta for change, updates, scales
                              Delta Angles
 
               CKIDLE          D13 (370) ( n --> )
 
                              Checks for idle on command, executes IDL if n = 55
 
               CKSUM           476 (302) ( addr n-bytes --> n-cksm)
 
                              Performs checksum on memory from addr to
                              addr+n-bytes
 
 
 
 
          MAGNETOMETER DICTIONARY            -29-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               CKSUM-GEN       420E (127) ( --> )
 
                              Generates CKSUMS for 128 byte blocks of RAM and
                              ROM
 
               CKSUM-PTR       420B (127) ( --> addr )
 
                              User variable ROM address for CKSUM
 
               CM0             A05 (344) ( n-cmnd --> )
 
                              Execute Mag command 0 ( ERROR )
 
               CM1             A0F (344) ( n-cmnd --> )
 
                              Execute Mag command 1 ( CALIBRATE ON/OFF )
 
               CM2             A1B (344) ( n-cmnd --> )
 
                              Execute Mag command 2 ( ERROR )
 
               CM3             A25 (344) ( n-cmnd --> )
 
                              Execute Mag command 3 ( INB GAIN HIGH/LOW)
 
               CM4             A33 (344) ( n-cmnd --> )
 
                              Execute Mag command 4 ( OUT GAIN HIGH/LOW)
 
               CM5             A41 (344) ( n-cmnd --> )
 
                              Execute Mag command 5 ( INB POWER ON/OFF)
 
               CM6             A5A (344) ( n-cmnd --> )
 
                              Execute Mag command 6 ( OUT POWER ON/OFF)
 
               CM7             A73 (344) ( n-cmnd --> )
 
                              Execute Mag command 7 ( CPU-CTRL ON/OFF)
 
               CM8             A7D (344) ( n-cmnd --> )
 
                              Execute Mag command 8 ( SNAPSHOT ON/OFF)
 
               CM9             A8F (344) ( n-cmnd --> )
 
                              Execute Mag command 9 ( OPTIMAL AVER ON/OFF )
 
               CMA             A9F (344) ( n-cmnd --> )
 
                              Execute Mag command A ( DSPIN ON/OFF )
 
 
 
 
          MAGNETOMETER DICTIONARY            -30-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               CMB             AA7 (344) ( n-cmnd --> )
 
                              Execute Mag command B ( INB FLIPPER
                              FLIP/FL-RT/FL-LT)
 
               CMC             AAF (344) ( n-cmnd --> )
 
                              Execute Mag command C ( S/C CALCOIL ON/OFF )
 
               CMD             AB7 (344) ( n-cmnd --> )
 
                              Execute Mag command D ( OUT FLIPPER
                              FLIP/FL-RT/FL-LT)
 
               CMDPTR          473 (298) ( --> addr )
 
                              User character variable
 
               CME             ABF (344) ( n-cmnd --> )
 
                              Execute Mag command E ( DEFAULT-SYS ON/OFF)
 
               CMF             AC9 (344) ( n-cmnd --> )
 
                              Execute Mag command F ( ERROR )
 
               CMPCAL          4501 (131) ( n addr --> )
 
                              Calculates n*sin(phi1) and n*cos(phi1) and stores
                              in addr, addr+2
 
               COMMND-TAB      AD3 (345) ( --> addr )
 
                              Address of start of ROM command table
 
               COMMNDS         AF5 (345) ( --> 4008 )
 
                              Address of start of RAM command table
 
               CORRECT         4CE (308) ( n1 n2 --> n-cor )
 
                              Hamming error correction procedure
 
               COUTF           413 (298) ( --> addr )
 
                              User cvariable Current out flip
 
               CPU-CTRL        9B9 (343) ( --> addr )
 
                              User variable points to word for CPU-CTRL command
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -31-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               CTAB            49A (308) ( --> addr )
 
                              Hamming error correction table start address
 
               CUR-STOR        404A (123) ( --> 4CC4 )
 
                              Address for current DSPIN storage
 
               CZ              28A (252) ( --> b=0 )
 
                              Push single byte on stack ( =0 )
                              
 
               DANGLE          D2D (376) ( --> addr )
 
                              User variable with current delta angle
 
               DATA-BUFFER     470 (298) ( --> addr )
 
                              User address for start of 16 word data buffer
 
               DATA-BUFFER-STATUS   443 (298) ( --> addr )
 
                              Optimal Aver and Snapshot status
 
               DATA-STORE      E91 (382) ( n1 --> )
 
                              Stores raw data into S/C buffer with offset n1
 
               DCOS            D33 (376) ( --> addr )
 
                              User variable with Delta Cos
 
               DEFAULT-SYS     9BC (343) ( --> addr )
 
                              User variable holding start address for default
                              system
 
               DFS             F5B (383) ( n-cmnd --> )
 
                              ROM default system initialization if n-cmnd = $55
 
               DFSYS           EF6 (382) ( --> )
 
                              ROM default system ( not used now)
 
               DO              35 ( 51) ( n-end n-beg --> )
 
                              Start of DO ... LOOP structure
 
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -32-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               DO              82FB (109)
 
                              Cross compiler DO stores current addr and calls
                              above DO
 
               DROP            16E ( 51) ( n --> )
 
                              Drops top of parameter stack
 
               DROT            DC8 (377) ERROR IN ROUTINE
 
                              | ERROR IN ROUTINE DO NOT USE >
 
               DSIN            D30 (376) ( --> addr )
 
                              User variable with delta sin
 
               DSP-AVER-CONSTANT   403E (123) ( --> addr )
 
                              User variable containing the recursive filter
                              constant for DESPIN routines
 
               DSP-STAT        43A (298) ( --> addr )
 
                              User cvariable containing DSPIN status
 
               DSP12           457B (132) ( --> )
 
                              DSPIN vectors 1,2 if DSPIN is on, generate state
                              vector or filter dspn
 
               DSP3            45AE (132) ( --> )
 
                              DSPIN vector 3 if DSPIN is on
 
               DSPN            453F (132) ( v n-sin n-cos --> v-dspn)
 
                              Performs actual DESPIN calculations
 
               DUP             162 ( 51) ( n --> n n )
 
                              Duplicate top of stack
 
               DZ              338 (254) ( b --> )
 
                              Opposite of cz, drops one byte from stack
 
               E!              369 (254) ( d addr --> )
 
                              Extended precision store
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -33-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               E+              33C (254) ( d1 d2 --> d-sum)
 
                              Extended precision sum
 
               E@              379 (254) ( addr --> d )
 
                              Extended precision read
 
               ELSE            86 ( 51)
 
                              Part of IF ... ELSE ... THEN structure
 
               ELSE            82FB (109)
 
                              Cross compiler setup for ELSE
 
               ENABLE-INT      E8B (382) ( --> )
 
                              Enables interrupts
 
               END             7B ( 51) ( f --> )
 
                              Part of BEGIN ... END structure Returns to BEGIN
                              if flag = 0
 
               END             20A0 (109) PART OF CROSSCOMPILER
 
                              Cross compiler END setup
 
               EOR             4A4 (308) ( n1 n2 --> n)
 
                              Exclusive or function
 
               ERROR           8AC (342) ( n1 n2 --> n2)
 
                              Command Error, increments SF parity
 
               EXCMND          B2B (345) ( n-cmnd n-tabl --> )
 
                              Execute command from COMMNDS table in RAM
 
               EXECUTE         14 ( 51) ( p-addr --> ) Execute FORTH definitions
                              given its parameter address on stack
 
               EXT             355 (254) ( n --> d )
 
                              Signed extension from 16-bit to 32-bit words
 
               FI20            4083 (124) ( addr n --> )
 
                              Twenty volt scale/filter routine uses as inputs
                              RD5+n and (addr) stores result in addr
 
 
 
 
          MAGNETOMETER DICTIONARY            -34-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               FI5             40BD (124) ( addr n --> )
 
                              Five volt scale/filter routine uses as inputs
                              RD5+n and (addr) stores result in addr
 
               FIL!            44CC (131) ( n addr --> )
 
                              Recursive filter using DSP-AVER-CONST
 
               FIL256          44C0 (131) ( n addr --> )
 
                              Double precision Recursive filter
 
               FILT            4480 (130) ( d-in n-cons addr --> )
 
                              Double Precision Recursive Filter
 
               FILTER          C33 (367)
 
                              INTERRUPT SERVICE recursive filter
 
               FILTF           44A4 (130) ( n-in n-cons addr --> )
 
                              Single precision recursive filter
 
               FLIP            583 (313) ( --> $74f8 )
 
                              Constant used in FLIP command
 
               FLIPC           97B (342) ( n1 n2 --> )
 
                              Execute Flip Command or Error
 
               FLIPPER         57F (313) ( --> 5 )
 
                              Constant 5 used in FLIP command
 
               FLP             920 (342) ( n --> )
 
                              Flip Command (Flips opposite of last command)
 
               FLTDSPV         4561 (132) ( --> )
 
                              Filter current DSPUN data
 
               FLTIM           407 (298) ( --> addr )
 
                              User cvariable minute counter for flipper (
                              currently initialized to 8 )
 
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -35-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               GND             455 (298) ( --> addr )
 
                              User variable for GND measuer
 
               H*              5A6 (321) ( n1 n2 --> n )
 
                              Hardware 8*8 multiply routine using low byte n1,n2
 
               H32             5BB (322) ( n1 n2 --> d )
 
                              Hardware 16*16 signed multiply
 
               HAMP            4F5 (309) ( n1 n2 --> n1-c n2-c)
 
                              Hamming code processor. Corrects n1, n2 if
                              possible else leaves $f0 on stack
 
               HD-PARITY       461 (298) ( --> addr )
 
                              User address for storage of hardware parity
                              counter
 
               HI/LOW          8F0 (342) ( n1 n2 --> )
 
                              High/Low command processor
 
               HIGAIN          571 (313) ( n-sel --> $74f3 + n-sel)
 
                              Setup for gain commands
 
               I               1F3 ( 52) ( --> n)
 
                              Index for DO ... LOOP structure
 
               IBSV            467 (298) ( --> addr )
 
                              User variable point to inboard status vector
 
               IDL             CFB (370) ( --> )
 
                              Idle command initialization
 
               IDLE            CC8 (370) ( --> )
 
                              Idle loop, executes commands but no data
 
               IF              78 ( 51) ( f --> )
 
                              Begin of IF ... ELSE ... THEN structure
 
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -36-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               IF              82FB (109)
 
                              Cross compiler setup for IF ... THEN structure
 
               INB             563 (313) ( --> )
 
                              Selector for INBOARD commands
 
               INIT            46C4 (135)
 
                              Final RAM Executive initialization
 
               INT-CNT         4032 (123) ( --> $4EE5 )
 
                              Interrupt counter area used in 9WAIT
 
               INTERRUPT-CODE    C5F (369)
 
                              Main INTERRUPT service routine
 
               IR-RECOV        4C3 (308) ( n1 n2 --> 0f )
 
                              Hamming uncorrectable error routine
 
               J               21A ( 29) ( --> n )
 
                              Outer loop variable in DO ... DO ... LOOP ... LOOP
                              structure. Inner loop uses I
 
               LCMNDS          AF9 (345) ( --> )
 
                              Loads RAM command table using ROM table. 
 
               LEAVE           20D ( 29) ( --> )
 
                              Forces termination of DO ... LOOP before normal
                              completion
 
               LEFT            587 (313) ( n-sel --> )
 
                              Turns on selected flipper circuit
 
               LINBFL          41C (298) ( --> addr )
 
                              User cvariable with last INB FLIP
 
               LIT             2C ( 51) ( --> n )
 
                              Used to push in-line constants on stack
 
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -37-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               LOOP            4B ( 51) ( --> )
 
                              End of DO ... LOOP structure
 
               LOOP            20A0 (109)
 
                              Cross compiler support for above LOOP
 
               LOUTFL          419 (298) ( --> addr )
 
                              User cvariable with last OUT flip position
 
               M*              2BE (253) ( u1 u2 --> 24-bit )
 
                              Software multiply leaving 24 bit product
 
               M/MOD           2DA (253)
 
                              Software core divide routine
 
               M32             3A3 (255) ( u1 u2 --> d )
 
                              Software mult leaving 32 bit product
 
               M91             4036 (123) ( --> $4ee4 ) Address where S/C Mod91
                              time is stored
 
               MAIN            F8D (384) ( --> )
 
                              ROM based main program. Not used with RAM EXEC. 
 
               MAIN            45F7 (134) ( --> )
 
                              RAM EXEC main routine
 
               MAT-LOAD        4256 (127) ( --> )
 
                              RAM routine to load DML data to status matrix
 
               MAT-RESET       43D6 (129) ( --> )
 
                              Reset status matrix to default ( unity matrix 0
                              offsets)
 
               MAX             290 (253) ( n1 n2 --> n-max)
 
                              Leaves maximum of n1, n2
 
               MEM-PROTECT     59C (316) ( n-page --> )
 
                              Turns on/off memory protect for selected page
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -38-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               MEMORY-SWITCH   1FF (314) ( --> )
 
                              Memory Switch routine Swaps RAM, ROM
 
               MIN             2A1 (253) ( n1 n2 --> n-min )
 
                              Leaves minimum on n1,n2 on stack
 
               MINE            389 (254) ( d --> -d )
 
                              Extended precision minus
 
               MINUS           265 (252) ( n --> -n )
 
                              Changes sign of n
 
               MOD             31C (253) ( n1 n2 --> n-rem)
 
                              Leaves remainder of n1/n2
 
               MOVE            105 ( 51) ( addr-s addr-d n --> )
 
                              Moves n bytes from addr-s to addr-d
 
               NOT             24D (252) ( f --> -f)
 
                              Negates flag
 
               OBSV            46A (298) ( --> addr )
 
                              User Outboard state vector pointer
 
               OF1             42E (298) ( --> addr )
 
                              User variable with sensor1 offset
 
               OF2             431 (298) ( --> addr )
 
                              User variable with sensor2 offset
 
               OF3             434 (298) ( --> addr )
 
                              User variable with sensor3 offset
 
               OFF             554 (313) ( n --> )
 
                              Turns selected function n OFF
 
               ON              549 (313) ( n --> )
 
                              Turns selected function n ON
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -39-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               ON/OFF          8C0 (342) ( n1 n2 --> )
 
                              Selects ON or OFF depend on n1, n2 is select for
                              ON OFF
 
               OPT-START       419C (126) ( --> )
 
                              Initiates optimal average processing
 
               OPTIMAL-AVER    9BF (343) ( --> addr )
 
                              User variable where optimal aver exec code is
                              stored
 
               OPTST           41BA (126) ( --> )
 
                              Checks and moves current store if optimal average
                              is turned on and aver# AND mod91 = 0
 
               OR!             445E (130) ( addr --> )
 
                              Offset/ rotate data to S/C co-ord store vector at
                              addr
 
               OUT             55F (313) ( --> 1 )
 
                              Select outboard for command execution
 
               OVER            187 ( 51) ( n1 n2 --> n1 n2 n1 )

                              Copies n1 to top of stack
 
               PARESET         4399 (129) ( --> )
 
                              Resets offsets, scales, and matrix to default
 
               PARITY          4AD (308) ( n --> 0,1)
 
                              Generates parity of low order byte now on stack
 
               PC              4DF (309)
 
                              Part of Hamming Checker
 
               PCAL            422 (298) ( --> addr )
 
                              User cvariable for calibrate power
 
               PFLIP           41F (298) ( --> addr )
 
                              User cvariable for flipper power
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -40-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               PG              4ED (309)
 
                              Part of Hamming Checker
 
               PINIT           4134 (125) ( --> )
 
                              Power on Initialization
 
               POWER           567 (313) ( n1 --> n1+$74F1 )
 
                              Power select for commands
 
               R>              1E8 ( 52) ( --> n1 )
 
                              Pulls from return stack and pushes on parameter
                              stack
 
               RAM-CKSUM       4047 (123) ( --> addr )
 
                              User variable with current pointer for start of
                              128 byte RAM checksum
 
               RD4             E64 (382) ( --> n )
 
                              Reads register 4 and puts value on stack
 
               RD5             9FC (343) ( --> n )
 
                              Reads register 5 and puts value on stack
 
               RIGHT           58F (313) ( n-sel --> )
 
                              Flip power select/ control
 
               RM1             437 (298) ( --> addr )
 
                              User address with start of rotation matrix
 
               ROM-CKSUM       4044 (123) ( --> addr )
 
                              User variable with address for ROM 128 byte
                              checksum
 
               ROT             2B2 (253) ( n1 n2 n3 --> n2 n3 n1 )
 
                              Rotates n1 to top of stack
 
               S*              3CF (255) ( n1 n2 --> n-prod )
 
                              Signed 16 bit product ( software )
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -41-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               S*              622 (323) ( n1 n2 --> n-prod )
 
                              Signed 16 bit product ( hardware )
 
               S-CPROD         833 (333) (n1 n2 n3 n4-->p1 p2 p3 p4)
 
                              Sin-cos product p1=n1*n4 p2=n2*n3 p3=n1*n3
                              p4=n2*n4
 
               S/C-CAL         440 (298) ( --> addr )
 
                              User cvariable for S/C Cal flag
 
               S0F             9C8 (343) ( n1 n2 --> )
 
                              Set Gain flag
 
               S1PHI           D36 (376) ( --> addr )
 
                              User variable containing sin phi for v1
 
               S2PHI           D3C (376) ( --> addr )
 
                              User variable containing sin phi for v2
 
               S3PHI           D42 (376) ( --> addr )
 
                              User variable containing sin phi for v3
 
               SAMPLE          B3E (362)
 
                              INTERRUPT routine which controls ADC
 
               SC/RT           4444 (130) ( vr --> v-scaled/rotated)
 
                              Scale and rotate vr data to produce v for storage
                              etc. 
 
               SCALE           442E (130) ( n1 n2 --> n-prod )
 
                              Extended prec scale ( 7FFF = 2.0 )
 
               SCF             40A (298) ( --> addr )
 
                              User variable containing the scale Factor for
                              field data set by DML
 
               SDATA-PTR       B2C1 (123)
 
                              Sample Data pointer stored in crosscompiler only
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -42-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               SDSPIN          42BE (128) ( n1 --> n1 )
 
                              Stores DSPIN and other Subcom data depending on n1
                              = MOD91
 
               SE4             E6D (382) ( n1 --> )
 
                              Set reg 4 to n1
 
               SETSUB          433E (128) ( --> )
 
                              Sets Subcom into S/C buffer, stores some Subcom
 
               SF-PARITY       464 (298) ( --> addr )
 
                              User cvariable for storage of Hamming Errors
 
               SF0             9E2 (343) ( n1 n2 --> )
 
                              Sets power flag for magnetometer
 
               SF20            409D (124) ( --> )
 
                              Store/filter 20V subcom data
 
               SF5             40D7 (124) ( --> )
 
                              Store/filter 5V subcom data
 
               SGINB           410 (298) ( --> addr )
 
                              User cvariable with scale/gain for INB
 
               SGOUT           40D (298) ( --> addr )
 
                              User cvariable with scale/gain for OUT
 
               SICOS           859 (333) ( n1 --> n-cos n-sin )
 
                              Generates the SIN and COS of angle n1
 
               SICOS-DELTA     807 (333) ( n1 --> n-cos n-sin )
 
                              Generates the SIN and COS of LSB of angle n1 using
                              small angle approximations
 
               SNAP            4061 (124) ( n1 --> )
 
                              Checks for ON command then starts SNAPSHOT
 
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -43-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               SNAP-SHOT       BDB (365)
 
                              INTERRUPT ROUTINE which implements snapshot
 
               SNAPSHOT        9C2 (343) ( --> addr )
 
                              User variable for storage of executable snapshot (
                              SNAP )
 
               SNPST           4055 (124) ( addr d-addr --> )
 
                              Start snapshot at address addr using data d-addr
 
               SP-DELTA        D21 (376) ( --> $4E32 )
 
                              Address where spin delta is available
 
               STATE-V         451F (131) ( --> v2-dspn)
 
                              Calculates state vector info leaves dspun v2 on
                              stack
 
               SWAP            173 ( 51) ( n1 n2 --> n2 n1 )
 
                              Swaps top two stack items
 
               T-ELEC          458 (298) ( --> addr )
 
                              User variable for storing temp electronics
 
               T/S-UPDATE      B69 (363)
 
                              INTERRUPT ROUTINE updates time/ sector
 
               THEN            650C (109)
 
                              Cross compiler THEN support
 
               TRFN            D90 (376)
 
                              Part of trig function routines, calculates sin,
                              cos for vectors 1,3 from vector 2 sin, cos and
                              delta sin,cos
 
               TRG-2           D74 (376)
 
                              Calculates sin, cos for vector 2
 
               TRGFNS          DC0 (376)
 
                              Calls TRG-2 and TRFN to calculate all sines,
                              cosines
 
 
 
 
          MAGNETOMETER DICTIONARY            -44-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               TRIG            772 (330)
 
                              Address for start of trig table
 
               TRIGE           7F6 (330)
 
                              90-degree shifted trig table entry
 
               TS!             4165 (126) ( addr --> )
 
                              Stores time amd sector starting at addr
 
               TTEXEC          40F7 (125) ( n1 n2 --> )
 
                              Part of power on initialization ( PINIT )
 
               U*              11E ( 51) ( u1 u2 --> u-prod)
 
                              Unsigned 8-bit multiply giving 16 bit product
 
               U/              13D ( 51) ( u1 u2 --> u-quot u-rem)
 
                              Unsigned division u1=16 bit, u2 = 7 bit
 
               V!              672 (325) ( nz ny nx addr --> )
 
                              Vector store
 
               V+              6C4 (325) (addr1 addr2-->nxs nys nzs)
 
                              Vector sum ( results are rotated )
 
               V-              68A (325) (addr1 addr2-->nxd nyd nzd)
 
                              Vector difference ( results are rotated )
 
               V-12            44F (298) ( --> addr )
 
                              User variable for storage of -12V status
 
               V1              DDC (377) ( --> addr )
 
                              Bufferdress storage for V1
 
               V10             44C (298) ( --> addr )
 
                              User variable for storage of 10V status
 
               V12             449 (298) ( --> addr )
 
                              User variable for storage of 12V status
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -45-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               V2              DE4 (377) ( --> addr )
 
                              Buffer address storage for V2
 
               V3              DEF (377) ( --> addr )
 
                              Buffer address storage for V3
 
               V@              65A (325) ( addr --> v1)
 
                              Vector read
 
               VDATA           9C5 (343) ( --> addr )
 
                              User variable containing current active Mag data
                              pointer ( set by power, gain changes)
 
               VDOT            6FE (325) ( v1 v2 --> n1 )
 
                              Dot product of two vectors stored on stack
 
               VECTOR          5389 (123)
 
                              Cross compiler vector to initialization routine
 
               VRAM            446 (298) ( --> addr )
 
                              User variable for V-RAM status
 
               VREF            452 (298) ( --> addr )
 
                              User variable for V-REF status
 
               VROT            746 (325) ( v1 addr --> vr)
 
                              Rotate vector V using matrix starting at addr (
                              this leaves rotated vector on stack )
 
               WAIT            EE7 (382) ( --> )
 
                              Wait until Reg 4 < 0 ROM routine
 
               WAIT            45D0 (133) ( --> )
 
                              RAM wait routine counts loops and stores in $4e60
 
               WHILE           89 ( 51)
 
                              Part of BEGIN ... WHILE structure
 
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -46-                      MARCH 29, 1984
 
 
 
 
                WORD      LINK  (DEC-SCREEN#)  ( STACK OPERATIONS)
 
 
               WHILE           6622 (109) " " " "
 
                              Cross compiler support for WHILE
 
               X               648 (325)
 
                              X component selector for vector using @
 
               XFER            4002 (123) XFER TO INITIALIZATION
 
                              Link to POR initialization
 
               XFER1           402 (251)
 
               XFER2           53CB (251) APPLE CONSTANT
 
               XFER3           C02 (251)
 
               Y               64C (325)
 
                              Y component selector for vector using @
 
               Z               652 (325)
 
                              Z component selector for vector using @
 
               ZERO            2785 (110)
 
                              Cross-compiler defined constant
 
               ZERO-USER       E75 (382) ( --> )
 
                              Zeros subcom data in USER area
 
               [']             21 ( 51)
 
                              Pushes parameter stack of next word on stack
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
          MAGNETOMETER DICTIONARY            -47-                      MARCH 29, 1984
 
 
 
 
                          GALILEO MAGNETOMETER DEFAULT DML-LOAD OCTOBER 27, 1983
 
 
          MAG-SELl        INBOARD            l           OUTBOARD       l
          FLP-POSl   LEFT      l   RIGHT     l    LEFT     l   RIGHT    l
           GAIN  l LOW  l HIGH l LOW  l HIGH l LOW  l HIGH l LOW  l HIGHl
          RANGE  l16384 l 512  l16384 l 512  l 512  l 32   l 512  l 32  l
          ---------------------------------------------------------------
          ADDRESSl      l      l      l      l      l      l      l     l
           4E80  l A5A5 l A5A5 l A5A5 l A5A5 l A5A5 l A5A5 l A5A5 l A5A5l
                 l      l      l      l      l      l      l      l     l
           4E82  l 0002 l 0040 l 0002 l 0040 l 0040 l 0400 l 0040 l 0400l
                 l      l      l      l      l      l      l      l     l
           4E84  l 1000 l 1000 l 1000 l 1000 l 1000 l 1000 l 1000 l 1000l
                 l      l      l      l      l      l      l      l     l
           4E86  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4E88  l 4000 l 4000 l 4000 l 4000 l 4000 l 4000 l 4000 l 4000l
                 l      l      l      l      l      l      l      l     l
           4E8A  l 4000 l 4000 l 4000 l 4000 l 4000 l 4000 l 4000 l 4000l
                 l      l      l      l      l      l      l      l     l
           4E8C  l 4000 l 4000 l 4000 l 4000 l 4000 l 4000 l 4000 l 4000l
                 l      l      l      l      l      l      l      l     l
           4E8E  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4E90  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4E92  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4E94  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4E96  l 7FFF l 7FFF l -0-  l -0-  l 7FFF l 7FFF l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4E98  l -0-  l -0-  l 8000 l 8000 l -0-  l -0-  l 8000 l 8000l
                 l      l      l      l      l      l      l      l     l
           4E9A  l 7FFF l 7FFF l 7FFF l 7FFF l 7FFF l 7FFF l 7FFF l 7FFFl
                 l      l      l      l      l      l      l      l     l
           4E9C  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4E9E  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4EA0  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4EA2  l -0-  l -0-  l 8000 l 8000 l -0-  l -0-  l 8000 l 8000l
                 l      l      l      l      l      l      l      l     l
           4EA4  l 8000 l 8000 l -0-  l -0-  l 8000 l 8000 l -0-  l -0- l
                 l      l      l      l      l      l      l      l     l
           4EA6  l A5A5 l A5A5 l A5A5 l A5A5 l A5A5 l A5A5 l A5A5 l A5A5l
                 l      l      l      l      l      l      l      l     l
                 l      l      l      l      l      l      l      l     l
 
 
 
 
 
 
 
 
                                           -48-
 
 
6) ( addr --> )
 
                              Stores time amd sector starting at addr
 
               TTEXEC          40F7 (125) ( n1 n2 --> )
 
                              Part of power on initialization ( PINIT )
 
               U*              11E ( 51) ( u1 u2 --> u-prod)
 
                              Unsigned 8-bit multiply giving 16 bit product
 
               U/              13D ( 51) ( u1 u2 --> u-quot u-rem)
 
                              Unsigned division u1=16 bit, u2 = 7 bit
 
               V!              672 (325) ( nz ny nx addr --> )
 
                              Vector store
 
               V+              6C4 (325) (addr1 addr2-->nxs nys nzs)
 
                              Vector sum ( results are rotated )
 
               V-              68A (325) (addr1 addr2-->nxd nyd nzd)
 
                              Vector difference ( results are rotated )
 
               V-12            44F (298) ( --> addr )
 
             

