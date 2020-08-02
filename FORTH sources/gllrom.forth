From jmeans@igpp.ucla.edu Wed Feb 24 13:26:34 1993
Return-Path: <jmeans@igpp.ucla.edu>
Received: from igpp.ucla.edu by robotics (4.1/SMI-4.1+DXRm2.5)
	id AA21375; Wed, 24 Feb 93 13:25:05 PST
Received: from polar1.ucla.edu (polar1.igpp.ucla.edu) by igpp.ucla.edu (4.1/SMI-4.1.1)
	id AA21012; Wed, 24 Feb 93 13:24:40 PST
Date: Wed, 24 Feb 93 13:24:40 PST
From: jmeans@igpp.ucla.edu (Joe Means)
Message-Id: <9302242124.AA21012@igpp.ucla.edu>
To: gat@robotics.Jpl.Nasa.Gov
Status: R

1�����KKUVVNORMAL.STYW@�LKU� 
          MAGNETOMETER              DOCUMENTATION               PRELIMINARY
 
 
 
 
               The following is the first draft of the documentation for the ROM
          programming on the GALILEO magnetometer. The basis for this document is the RCA
          1802 COSMAC code which was compiled and dumped into files for text processing.
          Suggestions on restructuring blocks etc are invited but the basic screen format
          will be retained to reduce typographical errors. Please indicate areas where
          expanded comments would be useful in understanding the use of the routines. It
          is assumed that the reader is already familiar with the FORTH programming style
          and knows about the basic operations of the magnetometer. 
 
 
               From a Software point of view the Magnetometer can be controlled entirely
          by storing the appropriate codes into specific memory locations. The codes used
          for most of these softswitches are:
 
 
                    AA - Turns the switch OFF
 
                    BB - Turns the switch ON
 
          The memory locations used and the function that they control are: 
 
                            70yy MUX/ADC CONTROL/DATA
                                 Y7 Bit not used
                                 Y6-Y3 Channel Select for MUX
                                 Y2-Y0 DATA SEL,START ADC
                                         0 READ ADC LSB / WRITE SELECT CHANNEL
                                         1 READ ADC MSB / WRITE START ADC
                                         4 READ STATUS
 
 
                            72X0 MULTIPLIER WRITE X
                            72X1 MULTIPLIER WRITE Y, START MPY
                            72X2 READ LSB OF RESULT
                            72X3 READ MSB OF RESULT
 
 
                            74F0 RAM/ROM Memory Switch
                            74F1 INBOARD MAG POWER
                            74F2 OUTBOARD MAG POWER
                            74F3 INBOARD HIGH GAIN
                            74F4 OUTBOARD HIGH GAIN
                            74F5 INTERNAL CALIBRATE
                            74F6 FLIPPER POWER
                    
                            74F8 INBOARD FLIP LEFT
                            74F9 OUTBOARD FLIP LEFT
                            74FA INBOARD FLIP RIGHT
                            74FB OUTBOARD FLIP RIGHT
 
                            75XX READ HARDWARE COUNTER
 
                            77X0 Protect RAM Page 40XX
                            77X1 Protect RAM Page 41XX
                             ..  ..  ..  ..  .. 
 
                                         -1-
 
 
 
          MAGNETOMETER                     SOFTWARE NOTES                      PRELIMINARY
 
 
                             ..  ..  ..  ..  .. 
                            77X6 Protect RAM Page 46XX
                            77X7 Protect RAM Page 47XX
 
          The above controls respond only to the ON/OFF bytes AB/AA. The POR state for all
          switches is OFF. X represents any value. 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                         -2-
 
 
 
          MAGNETOMETER                  TIME SYNCHRONIZATION                   PRELIMINARY
 
 
               TIme sychronization with the S/C time is accomplished by the interrupt
          driven routines as follows: 
 
                1.  Current S/C Time is received during RTI 8 in locations 4E20-4E26. 
 
                2.  The instruments recognizes the time while processing RTI 9 interrupt
 
                3.  During interrupt processing for RTI 0, the time is transferred to
                    locations 4EE0 - 4EE6 for use by the FORTH program as follows: 
 
                         4EE5 - MOD10 count starts at 9 and counts to 29 4EE4 - MOD91
                         count must be incremented by one to get current time 4EE3-4EE1 -
                         S/C Frame count
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                         -3-
 
 
 
          MAGNETOMETER                  INTERRUPT HANDLING
 
 
               Interrupts are generated by a counter in the MAG and by RTI pulses which
          reset this counter. The external flag bit 1 on the 1802 is set if the interrupt
          is generated by the RTI pulse. The counter is set such that equal spaced 30 Hz
          interrupts are produced.  The interrupt routine does the following operations: 
                    1. Decrement Reg 4
                    2. Save STATUS,ACC,CF,REG'S 2,3,4,9,A
                    3. Sample Analog Data
                    4. If RTI interrupt check for time,command
                    5. If Snapshot ON store analog data
                    6. Filter INB and OUT MAG Data
                    7. Add 1 to 4EE5
                    8. Restore registers and return from interrupt
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -4-
 
 
 
          MAGNETOMETER                 INSTRUMENT DESCRIPTION                FEBRUARY 1983
 
 
                    280 SCREEN
                        ( GALILEO MAGNETOMETER SYSTEM DESCRIPTION  ) ;S
                    
                             The galileo magnetometer system consists of three
                    major
                         components, two triaxial magnetometers and one digital
                    system.
                        The two magnetometers are identical except for dynamic
                    ranges.
                        The inboard ranges are 1024 gamma P-P or 32767 gamma P-P.
                        The outboard ranges are 64 gamma P-P or 1024 gamma P-P.
                        The digital system digitizes the output from the
                    magnetometers
                        processes the data and buffers it for the spacecraft data
                        system.  In addition the digital system receives commands
                    from
                        the spacecraft and controls the analog magnetometers.
                    
                    281 SCREEN
                        (   SYSTEM DESCRIPTION    )  ;S
                    
                             Each magnetometer sensor includes a flipper which
                    allows
                         two sensors to be rotated by 90 degrees when commanded. 
                    The
                         standard applied to determine the direction of flip is
                             FLIP RIGHT  causes a clockwise rotation of the
                    sensors
                             when viewed from the base of the sensor assembly.
                    
                           Sensor  1 points along the spacecraft  Y  axis
                           Sensor 2 points along the spacecraft -Z axis (FLIP
                    RIGHT)
                           Sensor 3 points along the spacecraft -X axis (FLIP
                    RIGHT)
                    
                           Sensor 2 points along the spacecraft X axis (FLIP LEFT)
                           Sensor 3 points along the spacecraft -Z axis (FLIP
                    LEFT)
                    282 SCREEN
                        ( SYSTEM DESCRIPTION )  ;S
                    
                             The digital system includes the following major
                        elements.
                           1. CDS interface circuits utilizing invisible
                              direct memory access (DMA) to all memory.
                           2. 1802 CPU operating at approx. 1.6 MHz
                           3. 4K bytes of ROM with FORTH operating system
                           4. 4K bytes of RAM for data and program storage.
                              The first 2K bytes include write protection.
                           5. Hardware multiplier (8 bit X 8 bit)
                           6. MUX / ADC circuits (12 BIT with 1/4 bit acc.)
                              16 channel MUX
                           7. Control circuits for power, flippers, write-protect
                             calibration and memory switch
 
 
                                                -5-
 
 
 
          MAGNETOMETER                 INSTRUMENT DESCRIPTION                FEBRUARY 1983
 
 
                    283 SCREEN
                         (  1802 CPU  OPERATIONS )
                            The instrument utilizes the 1802 CPU operating
                        at approx. 1.6 MHz. At this clock rate the CPU
                        requires 10 microseconds to execute 2 cycle
                        instructions. This CPU contains sixteen 16 bit
                        registers which are utilized as memory pointers
                        or temporary storage locations. These registers
                        are assigned specific functions for the GALILEO
                        magnetometer FORTH based operating system.
                         REGISTER  USAGE      COMMENTS
                            0       DMA       NOT USED
                            1       INT       INTERRUPT SERVICE
                            2        R        FORTH RETURN STACK
                            3        P          "   PROGRAM STACK
                            4       INT       TEMP STORAGE INT ROUTINES
                            4       FORTH     TIMER DECREMENTS EACH RTI
                    284 SCREEN
                        (   1802 REGISTER ASSIGNMENTS ) ;S
                         REGISTER  USAGE      COMMENTS
                            5       INT       DATA POINTER INT ROUTINES
                            6       INT       INT RETURN STACK
                            7       INT        SNAPSHOT STORAGE
                            8       N/A        N/A
                            9        W       FORTH CURRENT WORD EXEC
                            A        A       FORTH TEMP REG
                            B        B       FORTH TEMP REG
                            C        U       FORTH USER -- SUBCOM STORAGE
                            D        I       FORTH INSTRUCTION POINTER
                            E        S       FORTH DATA STACK POINTER
                            F        F       FORTH CODE RETURN POINTER
                    317 SCREEN
                        ( MEMORY ASSIGNMENT ) ;S
                    
                            The 1802 CPU has the capability of addressing
                        64K memory locations.  This memory is conveniently
                        split into 16 banks of memory each containing 4096 bytes
                          The GALILEO magnetometer utilizes the following banks:
                    
                          BANK 0  -  ROM MEMORY
                          BANK 4  -  RAM MEMORY
                          BANK 7  -  HARDWARE INTERFACES
                    
                        Included in the hardware interface is a switch
                        which will swap banks 0 and 4 in case of failure
                        or  special tests.
                    
 
 
 
 
 
 
 
 
 
 
                                                -6-
 
 
 
          MAGNETOMETER                 INSTRUMENT DESCRIPTION                FEBRUARY 1983
 
 
                    318 SCREEN
                        ( ROM MEMORY ASSIGNMENTS )  ;S
                    
                             The ROM memory contains 16 pages of memory
                        assigned as follows:
                    
                         PAGE             CONTENTS
                          00           CORE FORTH ROUTINES
                          01            "    "     "  "
                          02         MEMORY SWITCH + EXTENDED MATH
                          03            "      "        "       "
                          04         INST. STATUS LINKS, CKSUM, HAMMING
                          05         MAG CONTROL CODE- HDWR INTERFACE
                          06         HDWR MULT. + VECTOR MATH
                          07         SIN-COS ROUTINES
                          08         COMMAND EXECUTIVE ROUTINES
                    
                    319 SCREEN
                        ( ROM MEMORY ASSIGNMENTS CONT. )  ;S
                    
                          PAGE         CONTENTS
                          09         COMMAND EXECUTION
                          10         COMMAND EXECUTION TABLE
                          11         INTERRUPT ROUTINES
                          12         INTERRUPT MAIN ROUTINE
                          13         VECTOR ROTATION/MATH
                          14         EXTENDED PRECISION MATH
                          15         ROM-MAIN AND INITIALIZATION
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -7-
 
 
 
          MAGNETOMETER                 INSTRUMENT DESCRIPTION                FEBRUARY 1983
 
 
                    286 SCREEN
                        (  RAM ASSIGNMENT   )  ;S
                    
                          ADDRESS  WP  USAGE     ADDRESS  WP  USAGE
                            40XX   Y   EXEC PROG     48XX   N   OPTIMAL AVER
                            41XX   Y    "    "       49XX   N     "      "
                            42XX   Y    "    "       4AXX   N     "      "
                            44XX   Y    "    "       4BXX   N     "      "
                            44XX   Y    "    "       4CXX   N     "      "
                            45XX   Y    "    "       4DXX   N     "      "
                            46XX   Y    "    "       4EXX   N   SPACECRAFT COMM.
                            47XX   Y   USER VARI.    4FXX   N     "      "
                    
                         4400 - 4420  INB SENSOR ROTATION MATRIX
                         4420 - 4440  OUT   "       "       "
                    
                    
                    287 SCREEN
                        ( GALILEO MAGNETOMETER S/C COMMUNICATIONS ASSIGNMENTS ) ;S
                           ADDRESS             USAGE
                          4E00-4E1F       DATA BUFFER A
                          4E20-4E2F       S/C TIME INPUT BUFFER
                          4E30-4E3F       S/C SECTOR DATA INPUT BUFFER
                          4E40-4E7F       COMMAND INPUT BUFFER
                          4E80-4EAF       MAG ROTATION VECTORS INBOARD
                          4EB0-4EDF       MAG ROTATION VECTORS OUTBOARD
                          4EE0-4EFF    S/C TIME AND SECTOR
                          4F00-4F1F       DATA BUFFER B
                          4F20-4FEF      SECONDARY COMMAND BUFFER
                          4FF0-4FFF  MISC. POINTERS
                         DATA BUFFER A WILL BE READ DURING EVEN RTI
                         INTERVALS (MOD91 BIT 1 = SCCLOCK BIT 1)
                         DATA BUFFER B WILL BE READ DURING ODD RTI'S
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -8-
 
 
 
          MAGNETOMETER                   INSTRUMENT CONTROL                  FEBRUARY 1983
 
 
                    310 SCREEN
                        ( GALILEO MAGNETOMETER CONTROL PG 1 ) ;S
                    
                           These routines provide primary control over the
                        operations of the magnetometer.  All hardware control
                        functions are accessed by memory reads and writes in
                        bank 7. Power control and magnetometer state are controlled
                        by writes to addresses 74FX, memory protection is activated
                        by writing to memory locations 77XX, the multiplier is
                        activated by accessing locations 72XX, and the MUX/ADC is
                        controlled by addressing 70XX. 
                           Status for these commands can be obtained by reading
                        as indicated below: 
                        7003 bit 0 flipper power, bit 1 FLI, bit 2 FLO, bit 3 FRI,
                              bit 4 FRO, bit 5 1802 DIS
                        7002 bit 0 MEMSW, bit 1 INBD PWR, bit 2 OUTB PWR,
                             bit 3 INBD HILO, bit 4 OUTB HILO, bit 5 CALIB
                    311 SCREEN
                        ( MAGNETOMETER CONTROL CIRCUIT DESCRIPTION PG 2 )  ;S
                    
                          The control circuits are designed so that they respond
                    to
                        to only the following data values:
                              AA  turns off the control
                              AB  turns on the control
                    
                          Writing one of the above to the following locations will
                        provide the indicated control.
                          74F0 - MEMORY SWITCH    74F8 - FLIP INB LEFT
                          74F1 - INB POWER        74F9 - FLIP OUT LEFT
                          74F2 - OUT POWER        74FA - FLIP INB RIGHT
                          74F3 - HI GAIN INB      74FB - FLIP OUT RIGHT
                          74F4 - HI GAIN OUT
                          74F5 - CALIBRATE
                          74F6 - FLIP POWER  (74F7  -  1802 DISABLE)
                    312 SCREEN
                        ( MAGNETOMETER CONTROL FUNCTION DESCRIPTION  PG 3  )  ;S
                           MEMORY SWITCH - when on swaps RAM and ROM addresses
                          INB POWER - controls power to inboard magnetometer
                          OUT POWER - controls power to outboard magnetometer
                          HI GAIN INB - puts inboard mag. in high gain
                          HI GAIN OUT - puts outboard mag. in high gain
                          CALIBRATE - turns on calibrate circuit
                          FLIP POWER - enables flip circuit and power
                         The following commands require FLIP POWER to be ON and
                         are automatically reset to OFF when FLIP POWER is OFF.
                         These commands are interlocked so only one can be ON at
                         any time.
                          FLIP INB LEFT - flip inboard sensor left
                          FLIP OUT LEFT - flip outboard sensor left
                          FLIP INB RIGHT - flip inboard sensor right
                          FLIP OUT RIGHT - flip outboard sensor right
 
 
 
 
 
                                                -9-
 
 
 
          MAGNETOMETER                   INSTRUMENT CONTROL                  FEBRUARY 1983
 
 
                    340 SCREEN
                        ( MAGNETOMETER COMMAND DEFINITIONS ) ;S
                            CODE   FUNCTION SEL    ACCEPTABLE COMMANDS
                             00        N/A
                             E1 (225)        SENSOR CALIB    ON-OFF
                             72 (114)      SPARE
                             93 (147)   INB. SENSOR RANGE    HIGH/LOW
                             B4 (180)   OUT. SENSOR RANGE    HIGH/LOW
                             55 ( 85)   INB. SENSOR SELECT   ON/OFF
                             C6 (198)   OUT. SENSOR SELECT   ON/OFF
                             27 ( 39)   PROCESSOR IDLE       ON/OFF
                    
                            COMMAND   CODE         |     COMMAND   CODE
                              ON       55 ( 85)    |        OFF      AA (170)
                              HIGH     93 (147)    |        LOW      6C (108)
                            FLIP-RT    E1 (225)    |      FLIP-LT    1E ( 39)
                              FLIP     27 ( 39)    |
                    341 SCREEN
                        ( GALILEO COMMAND DEFINITIONS  CONT. ) ;S
                            CODE   FUNCTION SEL    ACCEPTABLE COMMANDS
                            D8 (216)   SNAPSHOT             ON/OFF
                            39 ( 57)   OPTIMAL AVERAGE      ON/OFF
                            AA (170)   DSPIN SELECT         ON/OFF
                            4B ( 75)   INB. SENSOR FLIP     FLIP/FLIP-RT/FLIP-LT
                            6C (108)   CALIB. COIL          ON/OFF
                            8D (141)   OUT. SENSOR FLIP     FLIP/FLIP-RT/FLIP-LT
                            1E ( 30)   DEFAULT OPSYS        ON ( IDLE MODE ONLY)
                            FF (255)       TBD
                    
                            COMMAND       CODE         |     COMMAND     CODE
                              ON           55 ( 85)    |       OFF        AA (170)
                              HIGH         93 (147)    |       LOW        6C (108)
                            FLIP-RT        E1 (225)    |     FLIP-LT      1E ( 30)
                              FLIP         27 ( 39)    |
                    285 SCREEN
                        (     MUX CHANNEL ASSIGNMENTS ) ;S
                          MUX CHANNEL       ASSIGNMENTS
                            0-2             1,2,3 DIFFERENTIAL INBOARD MAG
                             3              DIFFERENTIAL  INBOARD REF GND
                            4-6             1,2,3 DIFFERENTIAL OUTBOARD MAG
                             7              DIFFERENTIAL  OUTBOARD REF GND
                             8              S.E. HOUSEKEEPING +12V MONITOR
                             9              S.E. HOUSEKEEPING +10V MONITOR
                            10              S.E. HOUSEKEEPING -12V MONITOR
                            11              S.E. HOUSEKEEPING +VCLIP 
                            12              S.E. HOUSEKEEPING TEMP ELECT.
                            13              S.E. HOUSEKEEPING MEMORY KEEP ALIVE
                            14              S.E. HOUSEKEEPING -VCLIP
                            15              S.E. HOUSEKEEPING REF. GND
 
 
 
 
 
 
 
 
                                                -10-
 
 
 
          MAGNETOMETER                      DATA FORMATS                     FEBRUARY 1983
 
 
                    291 SCREEN
                        ( GALILEO MAGNETOMETER MINOR FRAME FORMAT )  ;S
                    
                      WORDS         QUANTITY                          COMMENTS
                      0-1      MSB/LSB INST STATUS                 SEE INST STATUS
                      2-3      MSB/LSB X SAMPLE AT MINOR FRAME        FIELD UNITS
                      4-5      MSB/LSB Y SAMPLE AT MINOR FRAME        FIELD UNITS
                      6-7      MSB/LSB Z SAMPLE AT MINOR FRAME        FIELD UNITS
                      8-9      MSB/LSB X SAMPLE AT MF + 222.22 MSEC   FIELD UNITS
                      10-11    MSB/LSB Y SAMPLE AT MF + 222.22 MSEC   FIELD UNITS
                      12-13    MSB/LSB Z SAMPLE AT MF + 222.22 MSEC   FIELD UNITS
                      14-15    MSB/LSB X SAMPLE AT MF + 444.44 MSEC   FIELD UNITS
                      16-17    MSB/LSB Y SAMPLE AT MF + 444.44 MSEC   FIELD UNITS
                      18-19    MSB/LSB Z SAMPLE AT MF + 444.44 MSEC   FIELD UNITS
                    
                      FIELD UNITS = SCALE * GAMMA  WHERE SCALE IS IN INST STATUS
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -11-
 
 
 
          MAGNETOMETER                      DATA FORMATS                     FEBRUARY 1983
 
 
                    292 SCREEN
                        ( GALILEO MAGNETOMETER INST STATUS FORMATS   ) ;S
                        MOD91 COUNT         FUNCTION            UNITS
                         0     CURRENT SCALE FACTOR         COUNTS/GAMMA
                         1     MAG SELECT/GAIN             MSB OUT,LSB INB(*SEL)
                         2     CURRENT FLIP POSITION       MSB OUT, LSB INB(RT,LT)
                         3     LAST FLIP COMMAND EXEC      MSB OUT, LSB INB(RT,LT)
                         4     FLIP POWER / CALIBRATE      MSB FLP, LSB CAL(ON,OFF)
                         5     GAIN 1                        +-1.000
                         6     GAIN 2                        +-1.000
                         7     GAIN 3                        +-1.000
                         8     OFFSET 1                      FIELD UNITS
                         9     OFFSET 2                        "     "
                        10     OFFSET 3                        "     "
                        11     ROTATION 11                   +-1.000
                        12     ROTATION 12                   +-1.000
                        13     ROTATION 13                   +-1.000
                    29  SCREEN
                        ( GALILEO MAGNETOMETER INST STATUS FORMATS  CONT. ) ;S
                       MOD91 COUNT         FUNCTION            UNITS
                        14     ROTATION 21                   +- 1.000
                        15     ROTATION 22                    |
                        16     ROTATION 23                    |
                        17     ROTATION 31                    |
                        18     ROTATION 32                    |
                        19     ROTATION 33                   +-1.000
                        20     DSPIN STATUS                   LSB ONLY (ON,OFF)
                        21     S/C TIME                       RIM
                        22     S/C TIME                      RIM/MOD 91
                        23     SECTOR INFO                   SPIN ANGLE
                        24     SECTOR INFO                   SPIN DELTA
                        25     X-DSPIN AT (21)               FIELD UNITS
                        26     Y-DSPIN AT (21)               FIELD UNITS
                        27     Z-DSPIN AT (21)               FIELD UNITS
                    294 SCREEN
                        ( GALILEO MAGNETOMETER INST STATUS FORMATS  CONT. ) ;S
                       MOD91 COUNT         FUNCTION            UNITS
                        28     S/C CAL COIL                  LSB ONLY (ON,OFF)
                        29     DATA BUFFER STATUS      OPT.AVER/SNAPSHOT(ON/OFF)
                        30     MEMORY KEEP ALIVE             +- 20  VOLTS
                        31     +12 VOLT                      +- 20 VOLTS
                        32     +10 VOLT READING              +-20 VOLTS
                        33     -12 VOLT                      +-20 VOLTS
                        34     REFERENCE VOLT                +-20 VOLTS
                        35     REFERENCE GND                 +-5 VOLTS
                        36     TEMP. ELECTRONICS             +- 5 VOLTS
                        37     +VCLIP
                        38     -VCLIP
                        39     PARITY ERROR COUNTERS        MSB - HDWR, LSB-SFTWR
                        40     AVER XI                       FIELD UNITS
                        41     AVER XI*SIN                   FIELD UNITS
 
 
 
 
 
 
                                                -12-
 
 
 
          MAGNETOMETER                      DATA FORMATS                     FEBRUARY 1983
 
 
                    295 SCREEN
                        ( GALILEO MAGNETOMETER INST STATUS FORMATS  CONT. ) ;S
                         MOD91 COUNT         FUNCTION            UNITS
                           42     AVER XI*COS                   FIELD UNITS
                           43     AVER YI                         "    "
                           44     AVER YI*SIN
                           45     AVER YI*COS
                           46     AVER ZI
                           47     AVER ZI*SIN
                           48     AVER ZI*COS
                           49     TBD
                           50     AVER XO                       FIELD UNITS
                           51     AVER XO*SIN
                           52     AVER XO*COS
                           53     AVER YO
                           54     AVER YO*SIN
                           55     AVER YO*COS
                    296 SCREEN
                        ( GALILEO MAGNETOMETER INST STATUS FORMATS  CONT. ) ;S
                         MOD91 COUNT         FUNCTION            UNITS
                           56     AVER ZO                       FIELD UNITS
                           57     AVER ZO*SIN                     "     "
                           58     AVER ZO*COS                     "     "
                           59     TBD
                           60     ROM CKSUM PTR                BEGIN ADDRESS
                           61     ROM CKSUM                 MSB-N/A, LSB-CKSUM
                           62     RAM CKSUM PTR                BEGIN ADDRESS
                           63     RAM CKSUM                 MSB-N/A, LSB-CKSUM
                           64     TBD
                           65     TBD
                           66     S/C TIME                     RIM
                           67     S/C TIME                     RIM/MOD 91
                           68     SECTOR INFO                  SPIN ANGLE
                           69     SECTOR INFO                  SPIN DELTA
                    297 SCREEN
                        ( GALILEO MAGNETOMETER INST STATUS FORMATS  CONT. ) ;S
                         MOD91 COUNT         FUNCTION            UNITS
                           70     X-DSPIN AT (66)              FIELD UNITS
                           71     Y-DSPIN AT (66)                "     "
                           72     Z-DSPIN AT (66)                "     "
                           73     BEGIN ADDRESS DATA BUFFER OUTPUT
                           74     DATA BUFFER OUTPUT
                           75        "       "      "
                            |       |        |      |
                            |       |        |      |
                            |       |        |      |
                           89     DATA BUFFER OUTPUT
                           90     RCVD COMMAND BYTES          LSB = # BYTES RCVD.
                    
                    
 
 
 
 
 
 
 
                                                -13-
 
 
 
          MAGNETOMETER                      DATA FORMATS                     FEBRUARY 1983
 
 
                    300 SCREEN
                        ( GALILEO INST STATUS -- DATA FORMATS )   ;S
                          The data supplied in the INST. STATUS field will utilize
                        the following formats.
                    
                         (ON,OFF)  ON = 55    OFF = AA   (hex)
                         (LT,RT)  LT = 1E      RT = E1
                    
                         (*SEL) Has following forms
                            5X = ON     X5 = HI
                            AX = OFF    XA = LOW
                    
                         Flip  power is special in that is is a counter
                              when = 0000  power is OFF  otherwise it = # frames
                              left (MOD 91 )  until power is turned off
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -14-
 
 
 
          MAGNETOMETER                 PROGRAM TIME SEQUENCE                 FEBRUARY 1983
 
 
                    289 SCREEN
                        ( GALILEO MAGNETOMETER TIME SEQUENCE OPERATIONS )  ;S
                    
                      INTER  MSEC  RTI         OPERATION
                        0     0     0     1st Vector storage including scaling
                        1     33    0     Command storage/exec
                        2     66    1     Command storage/execution
                        3    100    1     DSPIN calculations  optimal average calc
                        4    133    2       "       "            "      "      "
                        5    166    2       "       "            "      "      "
                        6    200    3       "       "            "      "      "
                        7    233    3       2nd Vector scaling and storage
                        8    266    4   DSPIN calculations ...                 "
                        9    300    4       "       "            "      "      "
                    
                    
                    
                    290 SCREEN
                        ( GALILEO MAGNETOMETER TIME SEQUENCE OPERATIONS )  ;S
                    
                      INTER  MSEC  RTI         OPERATION
                       10    333    5     DSPIN calculations  optimal average calc.
                       11    366    5       "       "            "      "       "
                       12    400    6       "       "            "      "       "
                       13    433    6       "       "            "      "       "
                       14    466    7       3rd vector scaling and storage
                       15    500    7     DSPIN calculations ...
                       16    533    8     DSPIN calculations  optimal average calc.
                       17    566    8       "       "            "      "       "
                       18    600    9       "       "            "      "       "
                       19    633    9       "       "            "      "       "
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -15-
 
 
 
          MAGNETOMETER                      ROM-1 SOURCE                     FEBRUARY 1983
 
 
                    299 SCREEN
 
 
                         ( ROM 1 ROUTINE DESCRIPTION  )  ;S
                    
                         ROM 1 includes the core FORTH routines as defined by the
                               EQU  and  EMPLACE codes in the following screens.
                               These routines are written in assembly language and
                                provide a common base of routines for all FORTH
                               programmed systems.
                    
                             Following the core routines are general math routines
                        needed in the GALILEO system. These routines have been
                    used
                        extensively in other FORTH systems.
                    
                    
                    
                    
                    51 SCREEN
 
 
                        0003 EQU     ZERO               0006 EQU     'NEXT
                        0014 EMPLACE EXECUTE            0021 EMPLACE [']
                        002C EMPLACE LIT                0035 EMPLACE DO
                        0048 EMPLACE +LOOP              004B EMPLACE LOOP
                        0078 EMPLACE IF                 007B EMPLACE END
                        0086 EMPLACE ELSE               0089 EMPLACE WHILE
                        0009 LOAD    CR                 008C EMPLACE C@
                        0098 EMPLACE C!                 00A0 EQU     'VARIABLE'
                        00A7 EQU     'CONSTANT'         00B0 EQU     'USER'
                        00B9 EQU     'DOES>'            00CA EQU     ':'
                        00D7 EMPLACE ;S                 00DE EMPLACE AND
                        00EB EMPLACE +                  00F8 EMPLACE -
                        0105 EMPLACE MOVE               011E EMPLACE U*
                        013D EMPLACE U/                 0162 EMPLACE DUP
                        016E EMPLACE DROP               0173 EMPLACE SWAP
                        0187 EMPLACE OVER               0197 EMPLACE @
 
 
 
                    52 SCREEN
 
 
                        01A5 EMPLACE !                  01B1 EMPLACE +!
                        01C2 EMPLACE 0=                 01D2 EMPLACE 0<
                        01DD EMPLACE <R                 01E8 EMPLACE R>
                        01F3 EMPLACE I                  01FD ORG     ;S
                    
                    
                    
                    
                    
 
 
 
 
                                                -16-
 
 
 
          MAGNETOMETER                      ROM-1 SOURCE                     FEBRUARY 1983
 
 
                    314 SCREEN
 
 
                         ( MAGNETOMETER  MEMORY SWITCH CODE )  HEX
                        ( START OF GALILEO SPECIFIC FORTH CODE)
                    
                    
                    
                          CODE  MEMORY-SWITCH
                                74 # LD T PHI  F0 # LD T PLO  AB # LD
                               T STR 0000 , NEXT
                    
                          DECIMAL  ;S
                    
                    
                    29 SCREEN
 
 
                        ( MISCELLANEOUS WORDS)
                        CODE LEAVE R LDA T PHI R LDA R INC R STR R DEC
                           T GHI R STR R DEC R DEC NEXT
                        CODE J R INC R INC R INC R INC R INC R LDN S DST
                           R DEC R LDN R DEC R DEC R DEC R DEC PUSH
                    
                        ;S
                    
                    
                    
                    
                    
                    
                    252 SCREEN
 
 
                        ( MORE DEFINITIONS)
                        0 CONSTANT 0 : < - 0< ; : > SWAP < ;
                        1 CONSTANT 1 : = - 0= ; : NOT 0= ;
                         CR HEX 12 PAGE
                        CODE 1+ 1 # LD HERE S INC S SEX ADD STXD
                           0#LD +C ADD S STR NEXT
                        CODE 2+ 2 # LD BR
                           11 PAGE
                        CODE MINUS BEGIN S INC S SEX 0#LD SM STXD
                           0#LD +C SM S STR NEXT CR
                        CODE ABS S LDN SHL DFL NOT END NEXT
                        : 2* DUP + ;
                         :  -DUP DUP IF DUP THEN ;
                        CODE CZ F GHI S DEC S STR NEXT
                         DECIMAL ;S
 
 
 
 
 
 
 
 
                                                -17-
 
 
 
          MAGNETOMETER                      ROM-1 SOURCE                     FEBRUARY 1983
 
 
                    253 SCREEN
 
 
                           ( ARITHMETIC OPERATORS)
                        : MAX OVER OVER < IF SWAP THEN DROP ;
                        : MIN OVER OVER > IF SWAP THEN DROP ;
                        : ROT <R SWAP R> SWAP ;
                        HEX
                        : M* <R DUP I U* SWAP FF00 AND CZ R> U* + ;
                        : M/MOD <R I U/ SWAP CZ DROP SWAP R> U/ <R + R> ;
                        : */MOD <R M* R> M/MOD SWAP ; : */ */MOD SWAP DROP ;
                        CR : /MOD <R CZ R> M/MOD SWAP ; : MOD /MOD  DROP ;
                        : * M* CZ DROP ; : / /MOD SWAP DROP ;
                         DECIMAL ;S
                    
                    
                    
                    254 SCREEN
 
 
                        ( EXTENDED PREC ROUTINES ) HEX
                         CODE DZ S INC NEXT
                         CODE E+ S SEX LDXA 9 PLO LDXA 9 PHI LDXA A PLO LDXA
                               S INC S INC S INC ADD STXD A GLO +C ADD STXD
                               9 GHI +C ADD STXD 9 GLO +C ADD S STR NEXT
                        : EXT DUP 0< IF -1 ELSE 0 THEN ;
                        : E!  <R I ! R> 2+ ! ;
                        : E@ <R I 2+ @ R> @ ;
                          29 PAGE
                        CODE MINE BEGIN S INC S INC S INC
                         S SEX 0#LD SM STXD 0#LD +C SM STXD
                           0#LD +C SM STXD 0#LD +C SM S STR NEXT
                        CODE ABSE S LDN SHL DFL NOT END NEXT
                           DECIMAL ;S
                    
                    
                    255 SCREEN
 
 
                        ( 16 BIT MULT. ROUTINES ) HEX
                    
                        : M32 CZ <R CZ OVER <R M* R> I OVER <R U* + R> FF00
                           AND CZ R> U* + ;
                    
                        : S* OVER ABS OVER ABS M32 DUP + SWAP
                            0< IF 1 + THEN <R
                            0< IF MINUS THEN R> SWAP
                            0< IF MINUS THEN ;
                         DECIMAL ;S
                    
                     ( 20 PAGE FORCES CODE TO BEGINING OF ROM.2)
                    
 
 
 
 
 
                                                -18-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                      (ROM CODE LINKAGE 402 ZERO ! )
                      (CODE XFER C0 C, 0 , from screen 251)
 
                    298 SCREEN
 
 
                        ( INSTRUMENT STATUS STORAGE - UTILIZES USER VARIABLES)
                        ( refer to screens 292 - 297 )
                          9 USER FLTIM
                         192 USER SCF 12 USER SGOUT 13 USER SGINB 14 USER COUTFL CR
                         15 USER CINBFL 16 USER LOUTFL 17 USER LINBFL 18 USER PFLIP CR
                         19 USER PCAL 20 USER 1GAIN 22 USER 2GAIN 24 USER 3GAIN
                         26 USER OF1 28 USER OF2 30 USER OF3 CR 32 USER RM1
                         50 USER DSP-STAT 52 USER 1ST-DSPVECTOR CR
                         66 USER S/C-CAL 68 USER DATA-BUFFER-STATUS
                         70 USER VRAM 72 USER V12 74 USER V10 76 USER V-12 CR
                         78 USER VREF 80 USER GND 82 USER T-ELEC
                         84 USER 1-SPARE 86 USER 2-SPARE
                         88 USER HD-PARITY CR 89 USER SF-PARITY
                         90 USER IBSV 110 USER OBSV ( INB/OUT STATUS VECTORS)
                         142 USER 2ND-DSPVECTOR
                          158 USER DATA-BUFFER ( BUFFERED DATA OUTPUT ) 190 USER CMDPTR
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -19-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    301 SCREEN
 
 
                        ( GALILEO checksum routine based on P Springers routine  ) ;S
                    
                    
                            The following routine generates an 8 bit checksum utilizing
                         addition with carry. This routine is a direct copy of
                         the routine provided by P. Springer. 
                    
                    
                    
                            This routine takes approximately 12 MSEC per 256 bytes
                        of memory checked. 
                    
                    
                    
                    
                    
                    302 SCREEN
 
 
                        ( GALILEO checksum routine based on P Springers routine  )
                        HEX
                          21 PAGE
                        CODE CKSUM
                             S LDA T PHI S LDA T PLO ( STORE # BYTES )
                             S LDA W PHI S LDN W PLO ( STORE START ADDR & LEAVE S )
                             0 # LD A PLO W SEX 0 # ADD ( INITIALIZE )
                             BEGIN BEGIN A GLO +C ADD A PLO
                                           W INC T DEC T GLO 0=
                                    END
                                    T GHI 0=
                             END
                             S SEX A GLO 0 # +C ADD STXD 0 # LD S STR
                        NEXT
                        DECIMAL ;S THIS ROUTINE GENERATES AN 8 BIT CHECKSUM
                            USAGE -- START ADDRESS, #BYTES, CKSUM
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -20-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    305 SCREEN
 
 
                        ( HAMMING ROUTINES DESCRIPTION PG 1 ) ;S
                        Based on article by M. Wimble BYTE Feb. 1979
                           The commands utilized by GALILEO are designed to utilize
                        a 4 bit nybble with 4 bits of parity utilizing hamming codes. 
                        This coding enables one to correct single bit errors and
                        detect double bit errors in data received from the CDS. 
                           The four parity bits are defined as follows: 
                               P4 is the parity of all 8 bits ( P4=1 for odd parity)
                               P3 is the parity of the above word ANDED with 27
                               P2 is the parity of the above word ANDED with 4B
                               P1 is the parity of the above word ANDED with 8D
                    
                        If all the parity bits = 0 then there was no error detected. 
                        If P4 = 0 and some other P = 1 then 2 bit errors have
                        occured and the data must be discarded. 
                        If P4 = 1 then the data can be corrected . 
                    
                    306 SCREEN
 
 
                        ( HAMMING ERROR CORRECTING DESCRIPTION PG 2 ) ;S
                    
                           If P4 = 1 then a correctable error has occurred. The error
                        is corrected by using an exclusive or of the data and the
                        following table values. 
                            P3  P2  P1   ERROR BYTE
                            0   0   0        10
                            0   0   1        80
                            0   1   0        40
                            0   1   1        08
                            1   0   0        20
                            1   0   1        04
                            1   1   0        02
                            1   1   1        01
                    
                    
                    307 SCREEN 
 
 
                        (  HAMMING ROUTINES   PG 3  )  ;S
                    
                         ACCEPTABLE CODES FOR HAMMING ERROR CORRECTION
                           DATA     HAMMING         DATA      HAMMING
                          NYBBLE     BYTE          NYBBLE      BYTE
                    
                            0         00             8          D8
                            1         E1             9          39
                            2         72             A          AA
                            3         93             B          4B
                            4         B4             C          6C
                            5         55             D          8D
                            6         C6             E          1E
                            7         27             F          FF
 
                                                -21-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -22-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    308 SCREEN
 
 
                        (  HAMMING CODE        PG 4  )
                          HEX
                         TABLE  CTAB  10 C,  80 C,  40 C,  08 C,  20 C,  04 C,
                                 02 C,  01 C,
                    
                          CODE EOR  S INC S LDA S INC S SEX XOR S STXD NEXT
                    
                          15 PAGE
                         CODE PARITY 0#LD T PLO  S INC S LDN S DEC S DEC
                             BEGIN  SHL DFL
                                IF  T INC  THEN   0= END
                           T GLO 1 # AND S STR 0#LD S DEC S STR NEXT
                    
                         : IR-RECOV  DROP DROP  F0 ;
                         : CORRECT  7 AND CTAB + C@  EOR ;
                        DECIMAL ;S
                    
                    309 SCREEN
 
 
                        (  HAMMING CODE   PG 5  )
                    
                          HEX
                    
                         : PC  AND PARITY SWAP DROP + ;
                         : PG  2* OVER ;
                        : HAMP    PARITY PG
                                27  PC PG   4B PC PG  8D PC
                                DUP 0= NOT IF DUP  8 AND  0=  IF
                               IR-RECOV  ELSE  CORRECT THEN
                               ELSE  DROP  THEN  ;
                        DECIMAL ;S
                    
                           HAMP  takes approximately 12 MSEC to execute.
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -23-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    
                    310 SCREEN
 
 
                        ( GALILEO MAGNETOMETER CONTROL PG 1 ) ;S
                    
                           These routines provide primary control over the
                        operations of the magnetometer.  All hardware control
                        functions are accessed by memory reads and writes in
                        bank 7. Power control and magnetometer state are controlled
                        by writes to addresses 74FX, memory protection is activated
                        by writing to memory locations 77XX, the multiplier is
                        activated by accessing locations 72XX, and the MUX/ADC is
                        controlled by addressing 70XX. 
                           Status for these commands can be obtained by reading
                        as indicated below: 
                        7003 bit 0 flipper power, bit 1 FLI, bit 2 FLO, bit 3 FRI,
                              bit 4 FRO, bit 5 1802 DIS
                        7002 bit 0 MEMSW, bit 1 INBD PWR, bit 2 OUTB PWR,
                             bit 3 INBD HILO, bit 4 OUTB HILO, bit 5 CALIB 311 SCREEN
 
 
                        ( MAGNETOMETER CONTROL CIRCUIT DESCRIPTION PG 2 ) ;S
                    
                          The control circuits are designed so that they respond to
                        to only the following data values: 
                              AA turns off the control
                              AB turns on the control
                    
                          Writing one of the above to the following locations will
                        provide the indicated control. 
                          74F0 - MEMORY SWITCH 74F8 - FLIP INB LEFT
                          74F1 - INB POWER 74F9 - FLIP OUT LEFT
                          74F2 - OUT POWER 74FA - FLIP INB RIGHT
                          74F3 - HI GAIN INB 74FB - FLIP OUT RIGHT
                          74F4 - HI GAIN OUT
                          74F5 - CALIBRATE
                          74F6 - FLIP POWER 74F7 - 1802 DISABLE
                    
                    312 SCREEN
 
 
                        ( MAGNETOMETER CONTROL FUNCTION DESCRIPTION PG 3 ) ;S
                           MEMORY SWITCH - when on swaps RAM and ROM addresses
                          INB POWER - controls power to inboard magnetometer
                          OUT POWER - controls power to outboard magnetometer
                          HI GAIN INB - puts inboard mag. in high gain
                          HI GAIN OUT - puts outboard mag. in high gain
                          CALIBRATE - turns on calibrate circuit
                          FLIP POWER - enables flip circuit and power
                         The following commands require FLIP POWER to be ON and
                         are automatically reset to OFF when FLIP POWER is OFF. 
                         These commands are interlocked so only one can be ON at
                         any time. 
                          FLIP INB LEFT - flip inboard sensor left
                          FLIP OUT LEFT - flip outboard sensor left
 
                                                -24-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                          FLIP INB RIGHT - flip inboard sensor right
                          FLIP OUT RIGHT - flip outboard sensor right
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -25-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    
                    313 SCREEN
 
 
                        ( MAGNETOMETER CONTROL FUNCTIONS PG 4 )
                         HEX
                        : ALL-OFF 74F7 7400 DO AA I C! LOOP ;
                        : ON AB SWAP C! ; : OFF AA SWAP C! ;
                         1 CONSTANT OUT 0 CONSTANT INB
                        : POWER 74F1 + ; CR
                        : HIGAIN 74F3 + ;
                        ( 74F0 ADDRESS FOR MEMORY-SWITCH CONTROL )
                         74F5 CONSTANT CALIBRATE
                         5 CONSTANT FLIPPER
                           74F8 CONSTANT FLIP
                            : LEFT + ON ; : RIGHT + 2 + ON ;
                         DECIMAL ;S
                        USAGE :  INB POWER ON OUT HIGAIN OFF
                                 FLIPPER POWER ON OUT FLIP LEFT
                    
                    314 SCREEN
 
 
                         ( MAGNETOMETER MEMORY SWITCH CODE ) HEX
                        ( START OF GALILEO SPECIFIC FORTH CODE)
                    
                    
                    
                          CODE MEMORY-SWITCH
                                74 # LD T PHI F0 # LD T PLO AB # LD
                               T STR 0000 , NEXT
                    
                          DECIMAL ;S
                    
                    
                    
                    
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -26-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    
                    
                    315 SCREEN
 
 
                        ( MAGNETOMETER MEMORY PROTECT DESCRIPTION ) ;S
                        Memory protection is possible for the first 8 pages of
                        RAM by use of the memory protect circuits.  This circuit
                        has a power on reset which turns OFF all memory protect. 
                          This circuit responds to the ON = AB and OFF = AA commands
                        in the same manner as the control circuits. 
                         Memory access is as follows: 
                          ADDRESS (X=ANY VALUE) MEMORY PROTECTED (X=ANY VALUE)
                             77X0 40XX
                             77X1 41XX
                             77X2 42XX
                             77X3 43XX
                             77X4 44XX
                             77X5 45XX
                             77X6 46XX
                             77X7 47XX
                    
                    316 SCREEN
 
 
                        ( MEMORY PROTECT CONTROL WORDS ) HEX
                        ( USES ON AND OFF FROM CONTROL CODE )
                    
                        : MEM-PROTECT 7700 + ;
                    
                         DECIMAL ;S
                    
                         USAGE: 
                             PAGE #, MEM-PROTECT, ON
                             PAGE #, MEM-PROTECT, OFF
                    
                    
                    
                    
                    
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -27-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    317 SCREEN
 
 
                        ( MEMORY ASSIGNMENT ) ;S
                    
                            The 1802 CPU has the capability of addressing
                        64K memory locations.  This memory is conveniently
                        split into 16 banks of memory each containing 4096 bytes
                          The GALILEO magnetometer utilizes the following banks: 
                    
                          BANK 0 - ROM MEMORY
                          BANK 4 - RAM MEMORY
                          BANK 7 - HARDWARE INTERFACES
                    
                        Included in the hardware interface is a switch
                        which will swap banks 0 and 4 in case of failure
                        or special tests. 
                    
                    
                    318 SCREEN
 
 
                        ( ROM MEMORY ASSIGNMENTS ) ;S
                    
                             The ROM memory contains 16 pages of memory
                        assigned as follows: 
                    
                         PAGE CONTENTS
                          00 CORE FORTH ROUTINES
                          01 " " " "
                          02 MEMORY SWITCH + EXTENDED MATH
                          03 " " " "
                          04 INST. STATUS LINKS, CKSUM, HAMMING
                          05 MAG CONTROL CODE- HDWR INTERFACE
                          06 HDWR MULT. + VECTOR MATH
                          07 SIN-COS ROUTINES
                          08 COMMAND EXECUTIVE ROUTINES
                    
                    319 SCREEN
 
 
                        ( ROM MEMORY ASSIGNMENTS CONT. ) ;S
                    
                          PAGE CONTENTS
                          09 COMMAND EXECUTION
                          10 COMMAND EXECUTION TABLE
                          11 INTERRUPT SERVICE ROUTINES
                          12 INTERRUPT ROUTINE
                          13 ROTATION ROUTINES
                          14 EXTENDED PRECISION ROUTINES
                          15 ROM-MAIN AND INITIALIZATION
                    
                    
 
 
 
 
                                                -28-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    320 SCREEN
 
 
                        ( HARDWARE MULTIPLY ROUTINE UTILIZING HDWR BOARD )
                        ( HDWR BOARD RESPONDS TO ADDRESSES 72XX AS FOLLOWS)
                        ( 72X0 - LOADS X VALUE)
                        ( 72X1 - LOADS Y VALUE AND STARTS MULTIPLICATION )
                        ( THIS VALUE IS REPLACED WITH PRODUCT )
                        ( AFTER 16 CLOCK CYCLES )
                        ( 72X1 - READS LSB BYTE OF PRODUCT )
                        ( 72X2 - READS MSB BYTE OF PRODUCT )
                        ( 72X2 - 72X4 REPEAT OPERATIONS OF 72X0-72X2 )
                        ( THE SOFTWARE TAKES APPROXIMATELY 1.5 MSEC )
                        ( TO DO 16*16 SIGNED PRODUCT )
                         HEX
                         141 LOAD 142 LOAD 143 LOAD ;S
                          DECIMAL ;S
                    
                    
                    321 SCREEN
 
 
                         ( 8*8 HARDWARE MULTIPLY ROUTINE ) HEX
                    
                         CODE H* S SEX
                             72 # LD 9 PHI 0 # LD 9 PLO
                             S INC S LDA 9 STR 9 INC
                             S INC S LDN 9 STR
                             9 LDA STXD 9 LDA S STR
                         NEXT
                    
                         ;S
                    
                    
                    
                    
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -29-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    322 SCREEN
 
 
                        ( 16*16 SIGNED HARDWARE MULTIPLY ) HEX 30 PAGE
                          CODE H32 S SEX
                          S LDA A PHI S LDA A PLO ( STORE A VALUE)
                          S LDA B PHI S LDN B PLO ( STORE B VALUE)
                          72 # LD 9 PHI 0#LD 9 PLO ( STORE MPY ADDRESS)
                          STXD STXD STXD S STR S INC ( PRESET PARAMETER STACK)
                          B GHI 0< IF A GLO SD STXD A GHI +C SD S STR S INC THEN
                          A GHI 0< IF B GLO SD STXD B GHI +C SD S STR S INC THEN
                           S INC S INC ( PREPARE FOR MULTIPLICATION )
                          A GLO 9 STR 9 INC ( STORE X VALUE - ALO)
                         B GLO 9 STR 9 LDN ( STORE Y VALUE = BLO, START MPY, DELAY)
                         9 LDA STXD 9 LDN S STR ( STORE PARTIAL PRODUCT)
                          A GLO 9 STR 9 INC ( STORE X VALUE = ALO)
                         B GHI 9 STR 9 LDN ( SET Y=BHI AND START MPY, DELAY)
                         9 LDA ADD STXD 9 LDN +C ADD STXD 0#LD +C ADD S STR
                          ( ADD PARTIAL PRODUCT TO STACK )
 
                    323 SCREEN
 
 
                        ( 16*16 SIGNED MULTIPLY CONT.  )
                         S INC S INC ( RESTORE STACK PNTR)
                         A GHI 9 STR 9 INC ( SET X=AHI )
                         B GLO 9 STR 9 LDN ( SET Y=BLO AND START MPY, DELAY )
                         9 LDA ADD STXD 9 LDN +C ADD STXD 0#LD +C ADD S STR
                         S INC ( ADD PARTIAL PRODUCT AND RESET STK PTR)
                         A GHI 9 STR 9 INC ( SET X=AHI )
                         B GHI 9 STR 9 LDN ( Y=BHI, START MPY, DELAY)
                         9 LDA ADD STXD 9 LDN +C ADD S STR
                         NEXT
                    
                         : S* H32 OVER OVER E+ SWAP DROP ;
                         DECIMAL ;S
                    
                        ( H32 TAKES APPROXIMATELY 1.5 MSEC )
                        ( S* TAKES APPROXIMATELY 3.0 MSEC )
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -30-
 
 
 
          MAGNETOMETER                      ROM-2 SOURCE                     FEBRUARY 1983
 
 
                    324 SCREEN
 
 
                        ( MISCELLANEOUS USEFUL WORDS ) HEX
                        ( BUFFER-ADDRESS PUTS A OR B BUFFER ADDRESS ON STACK)
                         ( DEPENDING ON SC TIME )
                         CODE BUFFER-ADDRESS S SEX S DEC 0 # LD STXD
                          4E # LD 9 PHI E3 # LD 9 PLO 9 SEX 9 LDA XOR 1 # AND
                          4F # XOR S STR NEXT
                    
                         DECIMAL ;S
                    
                    
                    
                    
                    
                     325 SCREEN
 
 
                         ( VECTOR ARITHMETIC OPERATORS )
                           : x ; : y 2+ ; : z 2+ 2+ ;
                        ( THE FOLLOWING READS/STORES FULL VECTOR ON STACK )
                         : V@ <R I 2+ 2+ @ I 2+ @ R> @ ;
                         : V!  <R I ! I 2+ ! R> 2+ 2+ ! ;
                    
                         ( THE FOLLOWING EXPECT ADDRESSES OF TWO VECTORS AND PROVIDE )
                           ( THE RESULTING SUM AND PRODUCTS ON THE STACK FOR V! )
                        : V- <R DUP <R <R I @ J @ - I 2+ @ J 2+ @ -
                              R> DROP R> 2+ 2+ @ R> 2+ 2+ @ - ;
                        : V+ <R DUP <R <R I @ J @ + I 2+ @ J 2+ @ +
                              R> DROP R> 2+ 2+ @ R> 2+ 2+ @ + ;
                        : VDOT <R DUP <R <R I @ J @ H32 I 2+ @ J 2+ @ H32 E+ R> DROP
                               R> 2+ 2+ @ R> 2+ 2+ @ H32 E+ OVER OVER E+ SWAP DROP ;
                        : VROT <R DUP <R <R I J VDOT I 6 + J VDOT R> DROP R> 12 + R>
                              VDOT ; DECIMAL ;S
                    
                    330 SCREEN
 
 
                        ( SINE-COSINE ROUTINE )
                    
                         TABLE TRIG 0 , 804 , 1608 , 2410 , 3212 , 4011 , 4808 ,
                                 5602 , 6393 , 7179 , 7962 , 8739 , 9512 , 10278 ,
                                11039 , 11793 , 12539 , 13279 , 14010 , 14732 ,
                                15446 , 16151 , 16846 , 17530 , 18204 , 18868 ,
                                19519 , 20159 , 20787 , 21403 , 22005 , 22594 ,
                                23170 , 23731 , 24279 , 24811 , 25329 , 25832 ,
                                26319 , 26790 , 27245 , 27683 , 28105 , 28510 ,
                                28898 , 29268 , 29621 , 29956 , 30273 , 30571 ,
                                30852 , 31113 , 31356 , 31580 , 31785 , 31971 ,
                                32137 , 32285 , 32412 , 32521 , 32609 , 32678 ,
                                32728 , 32757 , 32767 ,
                    
                         HEX ' TRIG 80 + CONSTANT TRIGE DECIMAL
                         ;S
                    
 
                                                -31-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                    ( 20 PAGE SCREEN 251 - FORCE CODE TO NEXT PAGE)
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -32-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                      ( LINKAGE SCREEN 251)
                      ( HEX 802 ' XFER 1+ ! CODE XFER C0 C,
                     ROM-3 CODE 3/12/82
 
                    SCREEN 333
 
 
                        ( MODIFIED SICOS ROUTINES 4/27/81) HEX
                    
                        : SICOS-DELTA <R 7FFF CZ I 0A H* CZ SWAP DROP -
                           R> 8 H* 6480 H32 SWAP DROP ;
                         ( LEAVES COSINE,SINE DELTA ON STACK)
                    
                        : S-CPROD <R SWAP <R <R DUP I S* SWAP
                             J S* R> I S* ROT R> R> S* ;
                        ( ENTER WITH CX,SX,CY,SY LEAVES CX*SY,CY*SX,CX*CY,SX*SY)
                    
                        : SICOS CZ <R CZ SICOS-DELTA
                         I 3F AND DUP + TRIGE OVER - @ SWAP TRIG + @
                         S-CPROD - <R + R> SWAP ( COS,SIN VALUES)
                         I 40 AND IF MINUS SWAP THEN
                         R> 80 AND IF MINUS SWAP MINUS SWAP THEN ;
                         DECIMAL ;S
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -33-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                    SCREEN 340
 
 
                        ( MAGNETOMETER COMMAND DEFINITIONS ) ;S
                            CODE   FUNCTION SEL    ACCEPTABLE COMMANDS
                             00        N/A
                             E1 (225)        SENSOR CALIB    ON-OFF
                             72 (114)      SPARE
                             93 (147)   INB. SENSOR RANGE    HIGH/LOW
                             B4 (180)   OUT. SENSOR RANGE    HIGH/LOW
                             55 ( 85)   INB. SENSOR SELECT   ON/OFF
                             C6 (198)   OUT. SENSOR SELECT   ON/OFF
                             27 ( 39)   PROCESSOR IDLE       ON/OFF
                    
                            COMMAND   CODE         |     COMMAND   CODE
                              ON       55 ( 85)    |        OFF      AA (170)
                              HIGH     93 (147)    |        LOW      6C (108)
                            FLIP-RT    E1 (225)    |      FLIP-LT    1E ( 39)
                              FLIP     27 ( 39)    |
                    
                    SCREEN 341
 
 
                        ( GALILEO COMMAND DEFINITIONS  CONT. ) ;S
                            CODE   FUNCTION SEL    ACCEPTABLE COMMANDS
                            D8 (216)   SNAPSHOT             ON/OFF
                            39 ( 57)   OPTIMAL AVERAGE      ON/OFF
                            AA (170)   DSPIN SELECT         ON/OFF
                            4B ( 75)   INB. SENSOR FLIP     FLIP/FLIP-RT/FLIP-LT
                            6C (108)   CALIB. COIL          ON/OFF
                            8D (141)   OUT. SENSOR FLIP     FLIP/FLIP-RT/FLIP-LT
                            1E ( 30)   DEFAULT OPSYS        ON ( ONLY FROM IDLE   )
                            FF (255)       TBD
                    
                            COMMAND   CODE         |     COMMAND     CODE
                              ON       55 ( 85)    |       OFF        AA (170)
                              HIGH     93 (147)    |       LOW        6C (108)
                            FLIP-RT    E1 (225)    <     flip-lt      1E (139)
                              FLIP     27 ( 39)    <    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -34-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                    
                    SCREEN 342 
 
 
                        ( COMMAND DETECTION AND EXECUTION)  HEX
                         : ERROR SWAP DROP SF-PARITY DUP C@ 1+ SWAP C! ;
                         : ON/OFF SWAP DUP 55 = IF DROP ON 55 ELSE DUP
                            AA = IF DROP OFF AA ELSE ERROR THEN THEN ;
                         : HI/LOW SWAP DUP 93 = IF DROP ON 55 ELSE DUP
                            6C = IF DROP OFF AA ELSE ERROR THEN THEN ;
                         : FLP DUP 0= IF LINBFL ELSE LOUTFL THEN  
                            <R I C@ 1E = IF E1 ELSE 1E THEN DUP R> C! ;
                         : CFST OVER 0= IF CINBFL OVER LINBFL
                            ELSE COUTFL OVER LOUTFL THEN C! C!
                            FLIPPER POWER ON FLTIM C@ PFLIP C! ;
                         : FLIPC SWAP DUP 27 = IF DROP FLP THEN
                            DUP E1 = IF CFST FLIP RIGHT ELSE
                            DUP 1E = IF CFST FLIP LEFT ELSE DROP ERROR
                            THEN THEN ;  ( FLTIM MUST BE INITIALIZED AT POR)
                         DECIMAL  ;S
 
                    SCREEN 343
 
 
                        ( COMMAND DETECTION AND EXECUTION )
                    
                         194 USER CPU-CTRL
                        196 USER DEFAULT-SYS
                        198 USER OPTIMAL-AVER
                        200 USER SNAPSHOT
                         202 USER VDATA
                         HEX
                         : S0F  SWAP 0F AND OVER C@ F0 AND + SWAP C! ;
                         : SF0  SWAP F0 AND OVER C@ 0F AND + SWAP C! ;
                    
                         CODE RD5  S SEX S DEC 5 GLO STXD 5 GHI S STR   NEXT
                    
                         DECIMAL  ;S
 
                    SCREEN 344
 
 
                        ( COMMAND DETECTION TO BE MODIFIED FOR TABLE LOOKUP )  HEX
                         : CM0 DUP ERROR DROP ;  : CM1  CALIBRATE ON/OFF PCAL C! ;
                        : CM2 DUP ERROR DROP ;
                        : CM3  INB HIGAIN HI/LOW   SGINB S0F ;
                        : CM4 OUT HIGAIN HI/LOW  SGOUT S0F  ;
                        : CM5 INB POWER ON/OFF  SGINB SF0 RD5  22 + VDATA !  ;
                        : CM6  OUT POWER ON/OFF  SGOUT SF0 RD5  2A + VDATA ! ;
                        : CM7  CPU-CTRL  @ EXECUTE ; CR
                         : CM8 DUP DATA-BUFFER-STATUS 1+  C! SNAPSHOT @ EXECUTE ;
                         : CM9 DUP DATA-BUFFER-STATUS C!  OPTIMAL-AVER @ EXECUTE ;
                         : CMA DSP-STAT C!   ;
                         : CMB  INB FLIPC  ;
                        :  CMC  S/C-CAL C!    ;
                         : CMD  OUT FLIPC   ;
 
                                                -35-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                         : CME DEFAULT-SYS @ EXECUTE ;   : CMF DUP  ERROR DROP ;
                         DECIMAL  ;S
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -36-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                    SCREEN 345
 
 
                         ( COMMAND DETECTION AND EXECUTION )   HEX
                         TABLE COMMND-TAB ' CM0 , ' CM1 , ' CM2 , ' CM3 , ' CM4 ,
                            ' CM5 , ' CM6 , ' CM7 , ' CM8 , ' CM9 , ' CMA ,
                            ' CMB ,  ' CMC , ' CMD , ' CME , ' CMF ,
                         4008 CONSTANT COMMNDS  ( 20 RESERVE  )
                        : LCMNDS 20 0 DO COMMND-TAB I + @ COMMNDS I + ! 2 +LOOP
                          COMMND-TAB 1C + DUP 2+ @ SWAP ! ; ( DELETE DEFAULT-SYS)
                        : EXCMND  0F AND 2* COMMNDS + @ EXECUTE ;
                    
                    
                    
                         DECIMAL  ;S
                    
                    
                    
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -37-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                    SCREEN 360
 
 
                        ( GALILEO INTERRUPT ROUTINES   )   ;S
                          These routines are designed to operate when
                        the interrupt system is enabled.  These routines
                        use the following registers:
                          REGISTER    USAGE     COMMENTS
                            1          Int     P REG for interrupts
                            2          Int    P-reg for subroutines
                            3          Int      "    "      "
                            4          Int     Temp pointer for int.
                            5          Int     Data pointer for int.
                            6          Int     Stack for interrupts
                            7          Int     Snapshot storage pointer
                            8          Int     Snapshot variable pointer
                            9          Int     Temp pointer ( Saved for forth)
                            A          Int      "     "         "    "    "
                    
 
                    SCREEN 361
 
 
                        (  GALILEO INTERRUPT ROUTINE DESC. ) ;S
                           COMMAND TRANSFER CODE
                          These routines do not use any registers normally used by
                        FORTH .  The structure of the routines is as follows:
                    
                           EXIT  CODE
                           ENTRY CODE
                           DATA SAMPLE ROUTINE
                           TIME UPDATE CODE
                           COMMAND TRANSFER CODE
                            SNAPSHOT DATA STORAGE
                           RECURSIVE FILTER ROUTINES
                           BRANCH TO EXIT
                    
 
                    SCREEN 362
 
 
                        ( SAMPLE ROUTINE REG 5=DATA POINTER  MUST BE 33<PAGE)
                        (    RETURNS THRU REG 1   REG 4 IS USED FOR TEMP STORAGE )
                    
                         HEX  20 PAGE
                         CODE SAMPLE   70 # LD 4 PHI 00 # LD 4 PLO
                            BEGIN   4 STR  4 INC 4 STR ( SET CHAN START ADC)
                             4 GLO  7 # ADD  4 PLO C4 C, 4 PLO  4 STR ( INC CHAN &
                    SET)
                             4 LDA  5 STR  5 INC  4 LDN  5 STR  5 INC ( GET DATA)
                             4 DEC  4 GLO  0< END  ( CHECK FOR LAST CHAN)
                             2 # LD  4 PLO  4 LDA  5 STR 5 INC  ( STORE STATUS1)
                             4 LDN 5 STR   ( STORE STATUS2)
                             5 GLO  21 # SM  5 PLO  ( RESTORE 5)
                         1 SEP  (  RETURN)
                         DECIMAL  ;S
 
                                                -38-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                    SCREEN 363
 
 
                        (  TIME UPDATE ROUTINE)  HEX
                         40 PAGE
                         CODE T/S-UPDATE  4E # LD 4 PHI E0 # LD 4 PLO 4 LDN
                         0= IF 20 # LD 4 PLO 4 LDN 9 PLO 0 # LD 4 STR
                              E0 # LD 4 PLO 9 GLO 4 STR
                            ELSE  4 GHI 9 PHI 0 # LD A PHI 4 STR
                               20 # LD 9 PLO E0 # LD 4 PLO 6 # LD A PLO
                                 BEGIN 9 LDA 4 STR 4 INC A DEC A GLO  0= END
                               30 # LD 9 PLO F0 # LD 4 PLO 6 # LD A PLO
                                 BEGIN 9 LDA 4 STR 4 INC A DEC A GLO  0= END
                         THEN 1 SEP   DECIMAL  ;S
                    
                         REG 1 - INTERRUPT RETURN
                         4E20  TIME INPUT BUFFER   4E30  SECTOR INPUT BUFFER
                         4EE0  CURRENT TIME        4EF0  CURRENT SECTOR
                         4EE5  COUNTS FROM 9 TO 18 FOR INTERRUPTS
 
                    SCREEN 364
 
 
                        ( INTERRUPT  COMMAND TEST / STORAGE ) HEX
                         30 PAGE
                        CODE ?COMND  4E # LD 4 PHI  40 # LD 4 PLO  4 LDN
                           0= NOT IF
                              4F # LD 9 PHI  F0 # LD 9 PLO  9 LDN 11 # ADD DFL
                                  IF 20 # LD 9 STR 9 PLO ELSE 9 LDN  9 PLO THEN
                              4 LDA 9 STR 9 INC 4 LDN 9 STR 9 INC
                         9 GLO 4 STR   F0 # LD 9 PLO 4 LDN 9 STR
                          0 # LD 4 STR 4 DEC 4 STR
                           THEN    1 SEP   DECIMAL  ;S
                    
                         COMMAND INPUT BUFFER  4E40
                          SECONDARY COMMAND BUFFER  4F20-4FEF
                            "         "     POINTER   4FF0
                    
 
                    SCREEN 365
 
 
                         ( SNAPSHOT CONTROL ROUTINE )  HEX
                         1A  PAGE
                        CODE SNAP-SHOT  7 GHI  48 # SM < NOT
                            IF  7 SEX 8 LDA STXD 8 LDA  STXD 8 LDA  STXD
                             8 LDA STXD  8 LDA STXD  8 LDN STXD
                               8 DEC 8 DEC 8 DEC 8 DEC 8 DEC  THEN
                         1 SEP
                          DECIMAL  ;S
                    
                         SNAPSHOT USES REGISTER 7 FOR STORAGE POINTER
                             AND REGISTER 8 FOR DATA POINTER
                          ONE SET OF 3 SAMPLES WILL BE STORED EVERY INT.
                           UNTIL REGISTER 7 < 48
                    
 
                                                -39-
 
 
 
          MAGNETOMETER                      ROM-3 SOURCE                     FEBRUARY 1983
 
 
                    (  20 PAGE  TO FORCE CODE TO NEXT ROM SCREEN 251)
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -40-
 
 
 
          MAGNETOMETER                      ROM-4 SOURCE                     FEBRUARY 1983
 
 
                      ( ROM LINKAGE)
                      ( HEX C02 ' XFER 1+ ! CODE XFER C0 C, 0 , )
 

                    ( ROM-4 CODE  3/12/82)    
                    SCREEN 366
 
 
                        ( RECURSIVE FILTER ROUTINES ) HEX
                        ( REG 4 POINTS TO OUT STORAGE, REG 5 POINTS TO INPUT )
                         (  REG 9 POINTS TO TEMP STORAGE )
                        ( OUT = OUT + IN/4 - OUT/4 )
                        CODE A/4 9 SEX  4 LDA 9 STR 9 INC 4 LDN STXD
                         9 LDN SHL 9 LDN +C SHR 9 STR 9 INC 9 LDN +C SHR STXD
                         9 LDN SHL 9 LDN +C SHR 9 STR 9 INC 9 LDN +C SHR 9 STR
                         4 SEX  9 LDN SD STXD 9 DEC 9 LDN +C SD 4 STR
                         4 INC  5 INC 5 LDN ADD STXD 5 DEC 5 LDN +C ADD 4 STR
                         2 SEP
                         DECIMAL  ;S
                    
                         REGISTER 3 IS PROGRAM REGISTER
                    
                    SCREEN 367
 
 
                        (  FILTER MAG DATA CHANNELS)  HEX  2D PAGE
                        CODE FILTER
                          5 GHI 4 PHI 5 GLO 22 # ADD 4 PLO  6 DEC 6 DEC
                        6 GHI 9 PHI  6 GLO 9 PLO  8 # LD A PLO  6 INC 6 INC
                          BEGIN ' A/4 CZ # LD 3 PHI CZ # LD 3 PLO 3 SEP
                             4 INC 4 INC 5 INC 5 INC A DEC A GLO 0= END
                         8 # LD A PLO
                         BEGIN 5 DEC 5 DEC A DEC A GLO 0= END
                         1 SEP
                         DECIMAL  ;S
                         REG 4 POINTS TO FILTERED STORAGE ARRAY
                         REG 5 POINTS TO SAMPLED DATA
                         REG 9 POINTS TO TEMP STORAGE AREA
                         REG 2 IS PROGRAM REGISTER
                         FILTERS MAGNETOMETER DATA ONLY
                         FILTERS MAGNETOMETER DATA ONLY
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -41-
 
 
 
          MAGNETOMETER                      ROM-4 SOURCE                     FEBRUARY 1983
 
 
                    SCREEN 369
 
 
                        (  INTERRUPT SERVICE ROUTINE)  HEX  68 PAGE
                        CODE INTERRUPT-CODE  6 SEX 6 INC 6 LDA A PHI 6 LDA  A PLO
                          6 LDA  9 PHI  6 LDA 9 PLO
                          6 LDA 4 PHI  6 LDA 4 PLO  6 LDA 3 PHI  6 LDA 3 PLO 6 LDA
                          2 PHI 6 LDA 2 PLO 6 LDA +C SHL 6 LDA 70 C, ( ENTRY PT. )
                         6 SEX 6 DEC 78 C, 6 DEC STXD +C SHR STXD 2 GLO STXD
                         2 GHI STXD 3 GLO STXD 3 GHI STXD 4 DEC 4 GLO STXD 4 GHI 
                          STXD 9 GLO STXD 9 GHI STXD A GLO STXD  A GHI STXD
                             ' SAMPLE      CZ # LD 2 PHI CZ # LD 2 PLO 2 SEP
                          1 EFL NOT IF
                             ' T/S-UPDATE  CZ # LD 2 PHI CZ # LD 2 PLO 2 SEP
                             ' ?COMND      CZ # LD 2 PHI CZ # LD 2 PLO 2 SEP THEN
                             ' SNAP-SHOT    CZ # LD 2 PHI CZ # LD 2 PLO 2 SEP
                             ' FILTER      CZ # LD 2 PHI CZ # LD 2 PLO 2 SEP
                          4E # LD 2 PHI  E5 # LD 2 PLO 2 LDN 1 # ADD 2 STR
                         ( EXIT)  ' INTERRUPT-CODE  BR   DECIMAL  ;S
                    SCREEN 370
 
 
                        (  IDLE  MODE  ROUTINES )  HEX
                        : IDLE BEGIN  4E40 @ 0= NOT IF  4E41 C@ 4E40 C@ HAMP
                               0F AND 2* COMMND-TAB + @ EXECUTE
                               THEN  0 END ;
                    
                         CODE IDL  P SEX 71 C, 33 C, ( TURN OFF INTR.)
                             4FF0 CZ # LD R PHI  CZ # LD R PLO
                             4FD0 CZ # LD S PHI  CZ # LD S PLO
                             ' IDLE CZ # LD I PHI CZ # LD I PLO NEXT
                    
                        : CKIDLE  55 = IF IDL THEN ;  ( ' CKIDLE -> CPU-CTRL)
                    
                         DECIMAL  ;S
                         THESE ROUTINES USE MEMORY 4FA0-4FF0 ONLY.  ANY
                         COMMANDS RECIEVED ARE CHECKED AND EXECUTED
                         IMMEDIATELY.
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -42-
 
 
 
          MAGNETOMETER                      ROM-4 SOURCE                     FEBRUARY 1983
 
 
                    SCREEN 375
 
 
                        ( DSPIN ROUTINES ) ;S
                          The DSPIN routines are designed to operate around
                        the second vector sample.  The sin / cos of the angle
                        corresponding to this vector and the delta sin/cos
                        for 233 msec utilized in calculations for vectors 1 and 3. 
                    
                          The spin angle given in the sector information is accurate
                        for the beginning of the RTI interval.  The angle for the
                        second vector can be obtained utilizing the spin delta. 
                    
                          The spin delta corresponds to the rotation during 8.333
                        msec. The updated angle can be obtained by multiplying this
                        information by 7168 using S*. 
                              7168 = 233.333/8.333*256
                            A time interval of xxx msec from RTI to samples is not
                        accounted for in these calculations. 
 
                    SCREEN 376
 
 
                        ( DSPIN CALCULATIONS CONT. )
                         HEX 4E32 CONSTANT SP-DELTA 4E34 CONSTANT ANGLE
                         DECIMAL 7168 CONSTANT ANG-CONV
                         204 USER DANGLE 206 USER DSIN CR 208 USER DCOS
                           210 USER S1PHI 212 USER C1PHI
                         214 USER S2PHI 216 USER C2PHI CR
                         218 USER S3PHI 220 USER C3PHI
                        : CKDANGLE SP-DELTA @ ANG-CONV S* DUP DANGLE @ =
                            IF DROP ELSE DUP DANGLE ! SICOS DSIN ! DCOS ! THEN ;
                        : TRG-2 ANGLE @ DANGLE @ + SICOS OVER OVER S2PHI ! 
                          C2PHI ! ;
                         : TRFN DCOS @ DSIN @ S-CPROD
                         OVER OVER - C3PHI ! + C1PHI ! 
                         OVER OVER + S3PHI ! SWAP - S1PHI ! ;
                        : TRGFNS TRG-2 TRFN ; ( CALCULATES SICOS FOR ALL DSPIN)
                        DECIMAL ;S
 
                    SCREEN 377
 
 
                        ( DSPIN ROUTINES CONTINUED )
                         ( GIVEN VECTOR,COS,SIN ON STACK - LEAVES DSPUN VECT)
                         : DROT OVER OVER SWAP S-CPROD + <R - R> ;
                         : V1 BUFFER-ADDRESS 2+ ;
                         : V2 BUFFER-ADDRESS 8 + ;
                         : V3 BUFFER-ADDRESS 14 + ;
                         : 1DSP V1 V@ C1PHI @ S1PHI @ DROT V1 V! ;
                         : 2DSP V2 V@ C2PHI @ S2PHI @ DROT V2 V! ;
                         : 3DSP V3 V@ C3PHI @ S3PHI @ DROT V3 V! ;
                    
                        DECIMAL ;S
 
 
 
                                                -43-
 
 
 
          MAGNETOMETER                      ROM-4 SOURCE                     FEBRUARY 1983
 
 
                    SCREEN 380
 
 
                        ( OPTIMAL AVERAGING ROUINES) HEX
                    
                         CODE 2/  A INC S LDN SHL S LDN +C SHR S STR
                            S INC S LDN +C SHR S STR S DEC A DEC NEXT
                    
                        CODE 2E/ A INC S LDN SHL S LDN +C SHR S STR S INC
                             S LDN +C SHR S STR S INC  S LDN +C SHR S STR S INC
                             S LDN +C SHR S STR S DEC S DEC S DEC A DEC NEXT
                    
                    
                         DECIMAL  ;S
                    
                    SCREEN 382
 
 
                         ( DEFAULT OPERATING SYSTEM )  HEX
                        CODE RD4 S SEX S DEC 4 GLO STXD 4 GHI S STR NEXT
                        CODE SE4 S SEX S LDA 4 PHI S LDA 4 PLO NEXT
                         : ZERO-USER SCF SGOUT DO  0 I !  2 +LOOP ;
                         CODE ENABLE-INT  P SEX 7033 , NEXT
                         : DATA-STORE  2+ BUFFER-ADDRESS + VDATA @ SWAP 6 MOVE ;
                         : CKCOMM  4FF0 C@ 20 > IF 4FF0 C@ 4F00 + 4F20 DO
                          I 1+ C@ I C@ HAMP EXCMND 2 +LOOP 20 4FF0 C! THEN ;
                         : WAIT  SE4  BEGIN  CKCOMM  RD4 0< END ;
                        : DFSYS  20 4FF0 C!  0 4E20 ! ZERO-USER   ENABLE-INT
                             BEGIN  CKCOMM 4EE4 C@ 0= END
                             BEGIN  0 DATA-STORE 6 WAIT 6 DATA-STORE 6 WAIT
                                    0C DATA-STORE 4EE4 C@ 2* SGOUT + @ 
                                    BUFFER-ADDRESS !
                                    BEGIN  CKCOMM 4EE5 C@ 9 = END
                             0  END  ;   DECIMAL  ;S
 
                    SCREEN 383
 
 
                         ( DEFAULT OPERATING SYSTEM INITIALIZATION )  HEX
                    
                    
                         CODE DFS  S INC S LDA 55 # XOR 0= IF
                           45 # LD 5 PHI   47 # LD 6 PHI  U PHI
                           00 # LD 5 PLO   6 PLO   U PLO   F PHI  7 PHI
                              46E0 CZ # LD R PHI  CZ # LD R PLO
                            4680 CZ # LD S PHI  CZ # LD S PLO
                           ' INTERRUPT-CODE 1A + CZ # LD 1 PHI  CZ # LD 1 PLO
                         'NEXT # LD F PLO
                         ' DFSYS CZ # LD I PHI CZ # LD I PLO THEN NEXT
                         DECIMAL  ;S
                    
 
 
 
 
 
 
                                                -44-
 
 
 
          MAGNETOMETER                      ROM-4 SOURCE                     FEBRUARY 1983
 
 
                    SCREEN 384
 
 
                         (  MAIN INITIALIZATIN  EXECUTED ON POR )
                    
                         : MAIN
                             ['] CKIDLE  CPU-CTRL !
                             ['] DFS  DEFAULT-SYS !
                             8  FLTIM C!
                            ['] DROP SNAPSHOT !  ( DUMMY SNAPSHOT)
                            ['] DROP OPTIMAL-AVER !  ( DUMMY OPTIMAL-AVERAGER)
                             IDLE ;
                         DECIMAL  ;S
                    
                    SCREEN 385
 
 
                        ( GALILEO INITIALIZATION ROUTINES )  HEX  20  PAGE
                         HERE  ' XFER 1+ !  ( STORE TRANSFER VECTOR)
                        4000  CZ # LD 3 PHI  CZ # LD 3 PLO  ( CHECK FOR TEST ROMS)
                          3 LDA  40 # XOR 0= IF  3 LDA  02 # XOR 0= IF
                          3 LDN  C0 # XOR 0= IF  3 SEP THEN THEN THEN
                         4600 CZ # LD 6 PHI CZ # LD 6 PLO
                         0 # LD 7 PHI 8 PHI F PHI  ( SET 7,8,F  TO ZERO )
                         4FF0 CZ # LD R PHI  CZ # LD R PLO   ( SETUP FOR IDLE )
                         4F80 CZ # LD S PHI  CZ # LD S PLO
                         4700 CZ # LD U PHI  CZ # LD U PLO
                         ' INTERRUPT-CODE 1A + CZ # LD 1 PHI  CZ # LD 1 PLO
                           'NEXT # LD F PLO  7 PLO
                         ' MAIN  CZ # LD I PHI  CZ # LD I PLO  NEXT
                         DECIMAL  ;S
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -45-
 
 
 
          MAGNETOMETER                    COMPILATION 3/82                   FEBRUARY 1983
 
 
                    FORTH DEFINITIONS FORGET TASK : TASK ; OK
                    (  3/12/82  CROSS COMPILE) OK
                    251 LIST 
                      0 (  GALILEO ROM CROSSCOMPILE  6/5/81 )
                      1 (   271 LOAD  272 LOAD  273 LOAD 274 LOAD  ( DOCUMENTATION )
                      2 (   275 LOAD  (  DOCUMENTATION LISTING UPDATES)
                      3  CROSS LOAD  NUCLEUS LOAD PROM LOAD  COLON LOAD  314 LOAD
                      4 29 LOAD HEX  402A RES    DECIMAL 252 LOAD  253 LOAD
                      5  254 LOAD DECIMAL  255 LOAD 20 PAGE  CR
                      6 HEX 402 ZERO !  CODE XFER C0 C, 0 , DECIMAL
                      7  298 LOAD  302 LOAD  308 LOAD  309 LOAD 313 LOAD 316  LOAD
                      8  320 LOAD  324 LOAD  325 LOAD  330 LOAD  100 PAGE
                      9 HEX 802 ' XFER 1+  ! CODE XFER C0 C, 0 , DECIMAL
                     10  333 LOAD  342 LOAD  343 LOAD  344 LOAD  345 LOAD
                     11   362 LOAD 363 LOAD   364 LOAD  365 LOAD
                     12  100 PAGE HEX C02 ' XFER 1+  ! CODE XFER C0 C, 0 , DECIMAL
                     13   366 LOAD  367 LOAD
                     14   369 LOAD 370 LOAD 376 LOAD 377 LOAD 380 LOAD 382 LOAD
                     15  383 LOAD 384 LOAD  385  LOAD  ( INIT. CODE)     DECIMAL  ;S
                    251 LOAD 
 
 
 
 
                         The following free-form load map was generated during the
                    compilation of the above routines.  This map first prints the screen
                    that is being loaded. This is followed by the start address and names
                    as they are defined. 
                    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -46-
 
 
 
          MAGNETOMETER                     FORTH LOAD MAP                    FEBRUARY 1983
 
 
                    48 33 3 ZERO 6 'NEXT 9
                     A0 'VARIABLE' A7 'CONSTANT' B0 'USER' B9 'DOES>' CA ':' 34 46 47 314
                    1FF MEMORY-SWITCH 29 20D LEAVE 21A J 252 22D 0 231 < 239 > 241 1 245 =
                    24D NOT
                     0 253 1+ 25F 2+ 0 265 MINUS
                     270 ABS 277 2* 27F -DUP 28A CZ 253 290 MAX 2A1 MIN 2B2 ROT 2BE M* 2DA
                    M/MOD 2F6 */MOD 304 */
                     30E /MOD 31C MOD 324 * 32E / 254 338 DZ 33C E+ 355 EXT 369 E! 379 E@
                    0 389 MINE 39C ABSE 255 3A3 M32 3CF S* 2
                     402 XFER 298 407 FLTIM 40A SCF 40D SGOUT 410 SGINB 413 COUTFL
                     416 CINBFL 419 LOUTFL 41C LINBFL 41F PFLIP
                     422 PCAL 425 1GAIN 428 2GAIN 42B 3GAIN 42E OF1 431 OF2 434 OF3
                     437 RM1 43A DSP-STAT 43D 1ST-DSPVECTOR
                     440 S/C-CAL 443 DATA-BUFFER-STATUS 446 VRAM 449 V12 44C V10 44F V-12
                     452 VREF 455 GND 458 T-ELEC 45B 1-SPARE 45E 2-SPARE 461 HD-PARITY
                     464 SF-PARITY 467 IBSV 46A OBSV 46D 2ND-DSPVECTOR 470 DATA-BUFFER 473
                    CMDPTR 302 0 476 CKSUM 308 49A CTAB 4A4 EOR 0 4AD PARITY 4C3 IR-RECOV
                    4CE CORRECT 309 4DF PC 4ED PG 4F5 HAMP 313 531 ALL-OFF 549 ON 554 OFF
                    55F OUT 563 INB 567 POWER
                     571 HIGAIN 57B CALIBRATE 57F FLIPPER 583 FLIP 587 LEFT 58F RIGHT 316
                    59C MEM-PROTECT 320 141 5A6 H* 142 0 5BB H32 143 622 S* 324 632
                    BUFFER-ADDRESS 325 648 x 64C y 652 z 65A V@ 672 V! 68A V- 6C4 V+ 6FE
                    VDOT 746 VROT 330 772 TRIG 7F6 TRIGE 8 802 XFER 333 807 SICOS-DELTA
                    833 S-CPROD 859 SICOS 342 8AC ERROR 8C0 ON/OFF 8F0 HI/LOW 920 FLP 94F
                    CFST 97B FLIPC 343 9B9 CPU-CTRL 9BC DEFAULT-SYS 9BF OPTIMAL-AVER 9C2
                    SNAPSHOT 9C5 VDATA 9C8 S0F 9E2 SF0 9FC RD5 344 A05 CM0 A0F CM1 A1B CM2
                    A25 CM3 A33 CM4 A41 CM5 A5A CM6 A73 CM7
                     A7D CM8 A8F CM9 A9F CMA AA7 CMB AAF CMC AB7 CMD ABF CME AC9 CMF 345
                    AD3 COMMND-TAB AF5 COMMNDS AF9 LCMNDS B2B EXCMND 362 0 B3E SAMPLE 363
                    0 B69 T/S-UPDATE 364 0 BAA ?COMND 365 0 BDB SNAP-SHOT D C02 XFER 366
                    C07 A/4 367 0 C33 FILTER 369 0 C5F INTERRUPT-CODE 370 CC8 IDLE CFB IDL
                    D13 CKIDLE 376 D21 SP-DELTA D25 ANGLE D29 ANG-CONV D2D DANGLE D30 DSIN
                     D33 DCOS D36 S1PHI D39 C1PHI D3C S2PHI D3F C2PHI
                     D42 S3PHI D45 C3PHI D48 CKDANGLE D74 TRG-2 D90 TRFN DC0 TRGFNS 377
                    DC8 DROT DDC V1 DE4 V2 DEF V3 DFA 1DSP E10 2DSP E26 3DSP 380 E3C 2/
                    E4B 2E/ 382 E64 RD4 E6D SE4 E75 ZERO-USER E8B ENABLE-INT E91
                    DATA-STORE EA6 CKCOMM EE7 WAIT EF6 DFSYS 383 F5B DFS 384 F8D MAIN 385
                    0 OK
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -47-
 
 
 
          MAGNETOMETER                       DICTIONARY                      FEBRUARY 1983
 
 
                    The following dictionary listing provides the RCA name and code field
                    in a tabular form. this list is in reverse order to the compilation
                    sequence.  DICT
                         4MAI F8D 3DFS F5B 5DFS EF6 4WAI EE7 6CKC EA6
                         ADAT E91 AENA E8B 9ZER E75 3SE4 E6D 3RD4 E64
                         32E/ E4B 22/ E3C 43DS E26 42DS E10 41DS DFA
                         2V3 DEF 2V2 DE4 2V1 DDC 4DRO DC8 6TRG DC0
                         4TRF D90 5TRG D74 8CKD D48 5C3P D45 5S3P D42
                         5C2P D3F 5S2P D3C 5C1P D39 5S1P D36 4DCO D33
                         4DSI D30 6DAN D2D 8ANG D29 5ANG D25 8SP- D21
                         6CKI D13 3IDL CFB 4IDL CC8 EINT C5F 6FIL C33
                         3A/4 C07 4XFE C02 9SNA BDB 6?CO BAA AT/S B69
                         6SAM B3E 6EXC B2B 6LCM AF9 7COM AF5 ACOM AD3
                         3CMF AC9 3CME ABF 3CMD AB7 3CMC AAF 3CMB AA7
                         3CMA A9F 3CM9 A8F 3CM8 A7D 3CM7 A73 3CM6 A5A
                         3CM5 A41 3CM4 A33 3CM3 A25 3CM2 A1B 3CM1 A0F
                         3CM0 A05 3RD5 9FC 3SF0 9E2 3S0F 9C8 5VDA 9C5
                         8SNA 9C2 COPT 9BF BDEF 9BC 8CPU 9B9 5FLI 97B
                         4CFS 94F 3FLP 920 6HI/ 8F0 6ON/ 8C0 5ERR 8AC
                         5SIC 859 7S-C 833 BSIC 807 4XFE 802 5TRI 7F6
                         4TRI 772 4VRO 746 4VDO 6FE 2V+ 6C4 2V- 68A
                         2V!  672 2V@ 65A 1z 652 1y 64C 1x 648
                         EBUF 632 2S* 622 3H32 5BB 2H* 5A6 BMEM 59C
                         5RIG 58F 4LEF 587 4FLI 583 7FLI 57F 9CAL 57B
                         6HIG 571 5POW 567 3INB 563 3OUT 55F 3OFF 554
                         2ON 549 7ALL 531 4HAM 4F5 2PG 4ED 2PC 4DF
                         7COR 4CE 8IR- 4C3 6PAR 4AD 3EOR 4A4 4CTA 49A
                         5CKS 476 6CMD 473 BDAT 470 D2ND 46D 4OBS 46A
                         4IBS 467 9SF- 464 9HD- 461 72-S 45E 71-S 45B
                         6T-E 458 3GND 455 4VRE 452 4V-1 44F 3V10 44C
                         3V12 449 4VRA 446 12DAT 443 7S/C 440 D1ST 43D
                         8DSP 43A 3RM1 437 3OF3 434 3OF2 431 3OF1 42E
                         53GA 42B 52GA 428 51GA 425 4PCA 422 5PFL 41F
                         6LIN 41C 6LOU 419 6CIN 416 6COU 413 5SGI 410
                         5SGO 40D 3SCF 40A 5FLT 407 4XFE 402 2S* 3CF
                         3M32 3A3 4ABS 39C 4MIN 389 2E@ 379 2E!  369
                         3EXT 355 2E+ 33C 2DZ 338 1/ 32E 1* 324
                         3MOD 31C 4/MO 30E 2*/ 304 5*/M 2F6 5M/M 2DA
                         2M* 2BE 3ROT 2B2 3MIN 2A1 3MAX 290 2CZ 28A
                         4-DU 27F 22* 277 3ABS 270 5MIN 265 22+ 25F
                         21+ 253 3NOT 24D 1= 245 11 241 1> 239
                         1< 231 10 22D 1J 21A 5LEA 20D DMEM 1FF ## 1; 2EF## 1( 2905## 6[SW
                    129## 3['] 1C54## 7IN- 1315
                         1I 1F3 2R> 1E8 2<R 1DD 20< 1D2 20= 1C2
                         2+!  1B1 1!  1A5 1@ 197 4OVE 187 4SWA 173
                         4DRO 16E 3DUP 162 2U/ 13D 2U* 11E 4MOV 105
                         1- F8 1+ EB 3AND DE 2;S D7 2C!  98
                         2C@ 8C## 3END 19B6## 5BEG 129## 4THE 129## 5WHI 174 ## 4ELS
                    12D2## 2IF 12D2## 5+LO 19B6## 4LOO 19B6## 2DO 12D2
                         5WHI 89 4ELS 86 3END 7B 2IF 78 4LOO 4B
                         5+LO 48 2DO 35 3LIT 2C 3['] 21 7EXE 14
                    
 
 
 
                    Checksums not added for ROMS
 
                                                -48-
 
 
 
          MAGNETOMETER                HEXADECIMAL MEMORY DUMP                FEBRUARY 1983
 
 
                    0 1000 DUMP 
 
                         0   71  0 C0  4  2 D3 4D B9   4D A9 49 B3 49 A3 30  5
                        10   1D  0  0 14 4E B9 4E A9   29 29 1F 1F 1F 1F DF  0
                        20   21 4D BB 4D 2E 5E 9B 2E   5E DF  0 2C 4D 2E 5E 9F
                        30   2E 5E DF  0 35 4E BB 4E   AB 4E BA 4E E2 22 73 9A
                        40   73 8B 73 9B 52 DF  0 4E   FF  0 50  0  1 FF EE 13
                        50   E9 72 BB 72 12 E2 F4 AB   73 9B 74 BB 52 12 12 12
                        60   8B F7 22 9B 77 3B 6B 12   12 1D DF 22 22 ED 8D F4
                        70   AD 9D E9 74 BD DF  0 7C    0  0 7C FF 4E EE F1 1E
                        80   32 6D 1D DF  0 6D  0  0   6D FF  0 8C 4E BB  E AB
                        90    B 5E 9F 2E 5E DF  0 98   4E BB 4E AB 1E 4E 5B DF
                        A0   89 2E 5E 99 2E 5E DF 49   BB 49 2E 5E 9B 2E 5E DF
                        B0   8C E9 F4 2E 5E 9C 2E 5E   DF 8D 22 52 9D 22 52 49
                        C0   BD 49 AD 89 2E 5E 99 2E   5E DF 8D 22 52 9D 22 52
                        D0   99 BD 89 AD DF  0 D7 42   BD 42 AD DF  0 DE 4E BB
                        E0   4E 1E EE F2 73 9B F2 5E   DF  0 EB 4E BB 4E 1E EE
                        F0   F4 73 9B 74 5E DF  0 F8   4E BB 4E 1E EE F5 73 9B
                       100   75 5E DF  1  5 4E BB 4E   AB 4E B9 4E A9 4E BA 4E
                       110   AA 4A 59 19 2B 8B 3A 11   9B 3A 11 DF  1 1E F8  8
                       120   AA 9F BB 1E 4E F6 AB 1E   EE 9B 3B 2D F4 76 BB 8B
                       130   76 AB 2A 8A 3A 29 8B 73   9B 5E DF  1 3D F8  8 AA
                       140   1E 4E BA 4E BB  E FE AB   9A 5E EE 9B 7E BB F7 3B
                       150   52 BB 8B 7E AB 2A 8A 3A   4B 8B 73 9F 73 9B 73 DF
                       160    1 62 4E BB  E 2E 2E 5E   9B 2E 5E DF  1 6E 1E 1E
                       170   DF  1 73 4E BB 4E AB 4E   BA  E AA 8B EE 73 9B 73
                       180   8A 73 9A 5E DF  1 87 1E   1E 4E BB  E 2E 2E 2E 2E
                       190   5E 9B 2E 5E DF  1 97 4E   BB  E AB 4B BA 4B 5E 9A
                       1A0   2E 5E DF  1 A5 4E BB 4E   AB 4E 5B 1B 4E 5B DF  1
                       1B0   B1 4E BB 4E AB 4E BA 4E   1B EB F4 73 9A 74 5B DF
                       1C0    1 C2 4E EE F1 32 C9 F8    1 FD  1 5E 9F 2E 5E DF
                       1D0    1 D2 4E FA 80 32 CB F8    1 30 CB  1 DD 4E BB 4E
                       1E0   22 52 9B 22 52 DF  1 E8   42 BB 42 2E 5E 9B 2E 5E
                       1F0   DF  1 F3 42 BB  2 22 2E   5E 9B 2E 5E DF  1 FF F8
                       200   74 BB F8 F0 AB F8 AB 5B    0  0 DF  2  D 42 BB 42
                       210   12 52 22 9B 52 22 22 DF    2 1A 12 12 12 12 12  2
                       220   2E 5E 22  2 22 22 22 22   2E 5E DF  0 A7  0  0  0
                       230   CA  0 F6  1 D0  0 D5  0   CA  1 71  2 2F  0 D5  0
                       240   A7  0  1  0 CA  0 F6  1   C0  0 D5  0 CA  1 C0  0
                       250   D5  2 53 F8  1 1E EE F4   73 9F 74 5E DF  2 5F F8
                       260    2 30 55  2 65 1E EE 9F   F7 73 9F 77 5E DF  2 70
                       270    E FE 33 65 DF  0 CA  1   60  0 E9  0 D5  0 CA  1
                       280   60  0 76  3  1 60  0 D5    2 8A 9F 2E 5E DF  0 CA
                       290    1 85  1 85  2 2F  0 76    3  1 71  1 6C  0 D5  0
                       2A0   CA  1 85  1 85  2 37  0   76  3  1 71  1 6C  0 D5
                       2B0    0 CA  1 DB  1 71  1 E6    1 71  0 D5  0 CA  1 DB
                       2C0    1 60  1 F1  1 1C  1 71    0 1F FF  0  0 DC  2 88
                       2D0    1 E6  1 1C  0 E9  0 D5    0 CA  1 DB  1 F1  1 3B
                       2E0    1 71  2 88  1 6C  1 71    1 E6  1 3B  1 DB  0 E9
                       2F0    1 E6  0 D5  0 CA  1 DB    2 BC  1 E6  2 D8  1 71
 
 
 
 
 
 
 
                                                -49-
 
 
 
          MAGNETOMETER                HEXADECIMAL MEMORY DUMP                FEBRUARY 1983
 
 
                       300    0 D5  0 CA  2 F4  1 71    1 6C  0 D5  0 CA  1 DB
                       310    2 88  1 E6  2 D8  1 71    0 D5  0 CA  3  C  1 6C
                       320    0 D5  0 CA  2 BC  2 88    1 6C  0 D5  0 CA  3  C
                       330    1 71  1 6C  0 D5  3 38   1E DF  3 3C EE 72 A9 72
                       340   B9 72 AA 72 1E 1E 1E F4   73 8A 74 73 99 74 73 89
                       350   74 5E DF  0 CA  1 60  1   D0  0 76  8  0 1F FF FF
                       360    0 84  3  2 2B  0 D5  0   CA  1 DB  1 F1  1 A3  1
                       370   E6  2 5D  1 A3  0 D5  0   CA  1 DB  1 F1  2 5D  1
                       380   95  1 E6  1 95  0 D5  3   89 1E 1E 1E EE 9F F7 73
                       390   9F 77 73 9F 77 73 9F 77   5E DF  3 9C  E FE 33 89
                       3A0   DF  0 CA  2 88  1 DB  2   88  1 85  1 DB  2 BC  1
                       3B0   E6  1 F1  1 85  1 DB  1   1C  0 E9  1 E6  0 1F FF
                       3C0    0  0 DC  2 88  1 E6  1   1C  0 E9  0 D5  0 CA  1
                       3D0   85  2 6E  1 85  2 6E  3   A1  1 60  0 E9  1 71  1
                       3E0   D0  0 76  5  2 3F  0 E9    1 DB  1 D0  0 76  3  2
                       3F0   63  1 E6  1 71  1 D0  0   76  3  2 63  0 D5  0  0
                       400    4  2 C0  8  2  0 B0  9    0 B0 C0  0 B0  C  0 B0
                       410    D  0 B0  E  0 B0  F  0   B0 10  0 B0 11  0 B0 12
                       420    0 B0 13  0 B0 14  0 B0   16  0 B0 18  0 B0 1A  0
                       430   B0 1C  0 B0 1E  0 B0 20    0 B0 32  0 B0 34  0 B0
                       440   42  0 B0 44  0 B0 46  0   B0 48  0 B0 4A  0 B0 4C
                       450    0 B0 4E  0 B0 50  0 B0   52  0 B0 54  0 B0 56  0
                       460   B0 58  0 B0 59  0 B0 5A    0 B0 6E  0 B0 8E  0 B0
                       470   9E  0 B0 BE  4 76 4E BB   4E AB 4E B9  E A9 F8  0
                       480   AA E9 FC  0 8A 74 AA 19   2B 8B 3A 84 9B 3A 84 EE
                       490   8A 7C  0 73 F8  0 5E DF    0 A0 10 80 40  8 20  4
                       4A0    2  1  4 A4 1E 4E 1E EE   F3 73 DF  4 AD 9F AB 1E
                       4B0    E 2E 2E FE 3B B7 1B 3A   B3 8B FA  1 5E 9F 2E 5E
                       4C0   DF  0 CA  1 6C  1 6C  0   2A F0  0 D5  0 CA  0 2A
                       4D0    7  0 DC  4 98  0 E9  0   8A  4 A2  0 D5  0 CA  0
                       4E0   DC  4 AB  1 71  1 6C  0   E9  0 D5  0 CA  2 75  1
                       4F0   85  0 D5  0 CA  4 AB  4   EB  0 2A 27  4 DD  4 EB
                       500    0 2A 4B  4 DD  4 EB  0   2A 8D  4 DD  1 60  1 C0
                       510    2 4B  0 76 17  1 60  0   2A  8  0 DC  1 C0  0 76
                       520    6  4 C1  0 84  3  4 CC    0 84  3  1 6C  0 D5  0
                       530   CA  0 1F 74 F7  0 1F 74    0  0 33  0 2A AA  1 F1
                       540    0 96  0 49 F7  0 D5  0   CA  0 2A AB  1 71  0 96
                       550    0 D5  0 CA  0 2A AA  1   71  0 96  0 D5  0 A7  0
                       560    1  0 A7  0  0  0 CA  0   1F 74 F1  0 E9  0 D5  0
                       570   CA  0 1F 74 F3  0 E9  0   D5  0 A7 74 F5  0 A7  0
                       580    5  0 A7 74 F8  0 CA  0   E9  5 47  0 D5  0 CA  0
                       590   E9  0 2A  2  0 E9  5 47    0 D5  0 CA  0 1F 77  0
                       5A0    0 E9  0 D5  5 A6 EE F8   72 B9 F8  0 A9 1E 4E 59
                       5B0   19 1E  E 59 49 73 49 5E   DF  5 BB EE 4E BA 4E AA
                       5C0   4E BB  E AB F8 72 B9 9F   A9 73 73 73 5E 1E 9B FA
                       5D0   80 32 DA 8A F5 73 9A 75   5E 1E 9A FA 80 32 E6 8B
                       5E0   F5 73 9B 75 5E 1E 1E 1E   8A 59 19 8B 59  9 49 73
                       5F0    9 5E 8A 59 19 9B 59  9   49 F4 73  9 74 73 9F 74
 
 
 
 
 
 
 
 
 
                                                -50-
 
 
 
          MAGNETOMETER                HEXADECIMAL MEMORY DUMP                FEBRUARY 1983
 
 
                       600   5E 1E 1E 9A 59 19 8B 59    9 49 F4 73  9 74 73 9F
                       610   74 5E 1E 9A 59 19 9B 59    9 49 F4 73  9 74 5E DF
                       620    0 CA  5 B9  1 85  1 85    3 3A  1 71  1 6C  0 D5
                       630    6 32 EE 2E F8  0 73 F8   4E B9 F8 E3 A9 E9 49 F3
                       640   FA  1 FB 4F 5E DF  0 CA    0 D5  0 CA  2 5D  0 D5
                       650    0 CA  2 5D  2 5D  0 D5    0 CA  1 DB  1 F1  2 5D
                       660    2 5D  1 95  1 F1  2 5D    1 95  1 E6  1 95  0 D5
                       670    0 CA  1 DB  1 F1  1 A3    1 F1  2 5D  1 A3  1 E6
                       680    2 5D  2 5D  1 A3  0 D5    0 CA  1 DB  1 60  1 DB
                       690    1 DB  1 F1  1 95  2 18    1 95  0 F6  1 F1  2 5D
                       6A0    1 95  2 18  2 5D  1 95    0 F6  1 E6  1 6C  1 E6
                       6B0    2 5D  2 5D  1 95  1 E6    2 5D  2 5D  1 95  0 F6
                       6C0    0 D5  0 CA  1 DB  1 60    1 DB  1 DB  1 F1  1 95
                       6D0    2 18  1 95  0 E9  1 F1    2 5D  1 95  2 18  2 5D
                       6E0    1 95  0 E9  1 E6  1 6C    1 E6  2 5D  2 5D  1 95
                       6F0    1 E6  2 5D  2 5D  1 95    0 E9  0 D5  0 CA  1 DB
                       700    1 60  1 DB  1 DB  1 F1    1 95  2 18  1 95  5 B9
                       710    1 F1  2 5D  1 95  2 18    2 5D  1 95  5 B9  3 3A
                       720    1 E6  1 6C  1 E6  2 5D    2 5D  1 95  1 E6  2 5D
                       730    2 5D  1 95  5 B9  3 3A    1 85  1 85  3 3A  1 71
                       740    1 6C  0 D5  0 CA  1 DB    1 60  1 DB  1 DB  1 F1
                       750    2 18  6 FC  1 F1  0 2A    6  0 E9  2 18  6 FC  1
                       760   E6  1 6C  1 E6  0 2A  C    0 E9  1 E6  6 FC  0 D5
                       770    0 A0  0  0  3 24  6 48    9 6A  C 8C  F AB 12 C8
                       780   15 E2 18 F9 1C  B 1F 1A   22 23 25 28 28 26 2B 1F
                       790   2E 11 30 FB 33 DF 36 BA   39 8C 3C 56 3F 17 41 CE
                       7A0   44 7A 47 1C 49 B4 4C 3F   4E BF 51 33 53 9B 55 F5
                       7B0   58 42 5A 82 5C B3 5E D7   60 EB 62 F1 64 E8 66 CF
                       7C0   68 A6 6A 6D 6C 23 6D C9   6F 5E 70 E2 72 54 73 B5
                       7D0   75  4 76 41 77 6B 78 84   79 89 7A 7C 7B 5C 7C 29
                       7E0   7C E3 7D 89 7E 1D 7E 9C   7F  9 7F 61 7F A6 7F D8
                       7F0   7F F5 7F FF  0 A7  7 F2    0  0  0  0  0  0  0  0
                       800    8  2 C0  C  2  0 CA  1   DB  0 1F 7F FF  2 88  1
                       810   F1  0 2A  A  5 A4  2 88    1 71  1 6C  0 F6  1 E6
                       820    0 2A  8  5 A4  0 1F 64   80  5 B9  1 71  1 6C  0
                       830   D5  0 CA  1 DB  1 71  1   DB  1 DB  1 60  1 F1  6
                       840   20  1 71  2 18  6 20  1   E6  1 F1  6 20  2 B0  1
                       850   E6  1 E6  6 20  0 D5  0   CA  2 88  1 DB  2 88  8
                       860    5  1 F1  0 2A 3F  0 DC    1 60  0 E9  7 F4  1 85
                       870    0 F6  1 95  1 71  7 70    0 E9  1 95  8 31  0 F6
                       880    1 DB  0 E9  1 E6  1 71    1 F1  0 2A 40  0 DC  0
                       890   76  5  2 63  1 71  1 E6    0 2A 80  0 DC  0 76  9
                       8A0    2 63  1 71  2 63  1 71    0 D5  0 CA  1 71  1 6C
                       8B0    4 62  1 60  0 8A  2 51    1 71  0 96  0 D5  0 CA
                       8C0    1 71  1 60  0 2A 55  2   43  0 76  B  1 6C  5 47
                       8D0    0 2A 55  0 84 17  1 60    0 2A AA  2 43  0 76  B
                       8E0    1 6C  5 52  0 2A AA  0   84  3  8 AA  0 D5  0 CA
                       8F0    1 71  1 60  0 2A 93  2   43  0 76  B  1 6C  5 47
 
 
 
 
 
 
 
 
 
                                                -51-
 
 
 
          MAGNETOMETER                HEXADECIMAL MEMORY DUMP                FEBRUARY 1983
 
 
                       900    0 2A 55  0 84 17  1 60    0 2A 6C  2 43  0 76  B
                       910    1 6C  5 52  0 2A AA  0   84  3  8 AA  0 D5  0 CA
                       920    1 60  1 C0  0 76  6  4   1A  0 84  3  4 17  1 DB
                       930    1 F1  0 8A  0 2A 1E  2   43  0 76  7  0 2A E1  0
                       940   84  4  0 2A 1E  1 60  1   E6  0 96  0 D5  0 CA  1
                       950   85  1 C0  0 76  A  4 14    1 85  4 1A  0 84  7  4
                       960   11  1 85  4 17  0 96  0   96  5 7D  5 65  5 47  4
                       970    5  0 8A  4 1D  0 96  0   D5  0 CA  1 71  1 60  0
                       980   2A 27  2 43  0 76  5  1   6C  9 1E  1 60  0 2A E1
                       990    2 43  0 76  A  9 4D  5   81  5 8D  0 84 18  1 60
                       9A0    0 2A 1E  2 43  0 76  A    9 4D  5 81  5 85  0 84
                       9B0    5  1 6C  8 AA  0 D5  0   B0 C2  0 B0 C4  0 B0 C6
                       9C0    0 B0 C8  0 B0 CA  0 CA    1 71  0 2A  F  0 DC  1
                       9D0   85  0 8A  0 2A F0  0 DC    0 E9  1 71  0 96  0 D5
                       9E0    0 CA  1 71  0 2A F0  0   DC  1 85  0 8A  0 2A  F
                       9F0    0 DC  0 E9  1 71  0 96    0 D5  9 FC EE 2E 85 73
                       A00   95 5E DF  0 CA  1 60  8   AA  1 6C  0 D5  0 CA  5
                       A10   79  8 BE  4 20  0 96  0   D5  0 CA  1 60  8 AA  1
                       A20   6C  0 D5  0 CA  5 61  5   6F  8 EE  4  E  9 C6  0
                       A30   D5  0 CA  5 5D  5 6F  8   EE  4  B  9 C6  0 D5  0
                       A40   CA  5 61  5 65  8 BE  4    E  9 E0  9 FA  0 2A 22
                       A50    0 E9  9 C3  1 A3  0 D5    0 CA  5 5D  5 65  8 BE
                       A60    4  B  9 E0  9 FA  0 2A   2A  0 E9  9 C3  1 A3  0
                       A70   D5  0 CA  9 B7  1 95  0   12  0 D5  0 CA  1 60  4
                       A80   41  2 51  0 96  9 C0  1   95  0 12  0 D5  0 CA  1
                       A90   60  4 41  0 96  9 BD  1   95  0 12  0 D5  0 CA  4
                       AA0   38  0 96  0 D5  0 CA  5   61  9 79  0 D5  0 CA  4
                       AB0   3E  0 96  0 D5  0 CA  5   5D  9 79  0 D5  0 CA  9
                       AC0   BA  1 95  0 12  0 D5  0   CA  1 60  8 AA  1 6C  0
                       AD0   D5  0 A0  A  5  A  F  A   1B  A 25  A 33  A 41  A
                       AE0   5A  A 73  A 7D  A 8F  A   9F  A A7  A AF  A B7  A
                       AF0   BF  A C9  0 A7 40  8  0   CA  0 2A 20  2 2B  0 33
                       B00    A D1  1 F1  0 E9  1 95    A F3  1 F1  0 E9  1 A3
                       B10    0 2A  2  0 46 EB  A D1    0 2A 1C  0 E9  1 60  2
                       B20   5D  1 95  1 71  1 A3  0   D5  0 CA  0 2A  F  0 DC
                       B30    2 75  A F3  0 E9  1 95    0 12  0 D5  B 3E F8 70
                       B40   B4 F8  0 A4 54 14 54 84   FC  7 A4 C4 A4 54 44 55
                       B50   15  4 55 15 24 84 FA 80   32 44 F8  2 A4 44 55 15
                       B60    4 55 85 FF 21 A5 D1  B   69 F8 4E B4 F8 E0 A4  4
                       B70   3A 81 F8 20 A4  4 A9 F8    0 54 F8 E0 A4 89 54 30
                       B80   A7 94 B9 F8  0 BA 54 F8   20 A9 F8 E0 A4 F8  6 AA
                       B90   49 54 14 2A 8A 3A 90 F8   30 A9 F8 F0 A4 F8  6 AA
                       BA0   49 54 14 2A 8A 3A A0 D1    B AA F8 4E B4 F8 40 A4
                       BB0    4 32 D8 F8 4F B9 F8 F0   A9  9 FC 11 3B C4 F8 20
                       BC0   59 A9 30 C6  9 A9 44 59   19  4 59 19 89 54 F8 F0
                       BD0   A9  4 59 F8  0 54 24 54   D1  B DB 97 FF 48 3B F2
                       BE0   E7 48 73 48 73 48 73 48   73 48 73  8 73 28 28 28
                       BF0   28 28 D1  0  0  0  0  0    0  0  0  0  0  0  0  0
 
 
 
 
 
 
 
 
 
                                                -52-
 
 
 
          MAGNETOMETER                HEXADECIMAL MEMORY DUMP                FEBRUARY 1983
 
 
                       C00    C  2 C0  F B8  C  7 E9   44 59 19  4 73  9 FE  9
                       C10   76 59 19  9 76 73  9 FE    9 76 59 19  9 76 59 E4
                       C20    9 F5 73 29  9 75 54 14   15  5 F4 73 25  5 74 54
                       C30   D2  C 33 95 B4 85 FC 22   A4 26 26 96 B9 86 A9 F8
                       C40    8 AA 16 16 F8  C B3 F8    7 A3 D3 14 14 15 15 2A
                       C50   8A 3A 44 F8  8 AA 25 25   2A 8A 3A 56 D1  C 5F E6
                       C60   16 46 BA 46 AA 46 B9 46   A9 46 B4 46 A4 46 B3 46
                       C70   A3 46 B2 46 A2 46 7E 46   70 E6 26 78 26 73 76 73
                       C80   82 73 92 73 83 73 93 73   24 84 73 94 73 89 73 99
                       C90   73 8A 73 9A 73 F8  B B2   F8 3E A2 D2 34 AC F8  B
                       CA0   B2 F8 69 A2 D2 F8  B B2   F8 AA A2 D2 F8  B B2 F8
                       CB0   DB A2 D2 F8  C B2 F8 33   A2 D2 F8 4E B2 F8 E5 A2
                       CC0    2 FC  1 52 30 5F  0 CA    0 1F 4E 40  1 95  1 C0
                       CD0    2 4B  0 76 1E  0 1F 4E   41  0 8A  0 1F 4E 40  0
                       CE0   8A  4 F3  0 2A  F  0 DC    2 75  A D1  0 E9  1 95
                       CF0    0 12  2 2B  0 79 D2  0   D5  C FB E3 71 33 F8 4F
                       D00   B2 F8 F0 A2 F8 4F BE F8   D0 AE F8  C BD F8 C8 AD
                       D10   DF  0 CA  0 2A 55  2 43    0 76  3  C F9  0 D5  0
                       D20   A7 4E 32  0 A7 4E 34  0   A7 1C  0  0 B0 CC  0 B0
                       D30   CE  0 B0 D0  0 B0 D2  0   B0 D4  0 B0 D6  0 B0 D8
                       D40    0 B0 DA  0 B0 DC  0 CA    D 1F  1 95  D 27  6 20
                       D50    1 60  D 2B  1 95  2 43    0 76  6  1 6C  0 84 11
                       D60    1 60  D 2B  1 A3  8 57    D 2E  1 A3  D 31  1 A3
                       D70    0 D5  0 CA  D 23  1 95    D 2B  1 95  0 E9  8 57
                       D80    1 85  1 85  D 3A  1 A3    D 3D  1 A3  0 D5  0 CA
                       D90    D 31  1 95  D 2E  1 95    8 31  1 85  1 85  0 F6
                       DA0    D 43  1 A3  0 E9  D 37    1 A3  1 85  1 85  0 E9
                       DB0    D 40  1 A3  1 71  0 F6    D 34  1 A3  0 D5  0 CA
                       DC0    D 72  D 8E  0 D5  0 CA    1 85  1 85  1 71  8 31
                       DD0    0 E9  1 DB  0 F6  1 E6    0 D5  0 CA  6 30  2 5D
                       DE0    0 D5  0 CA  6 30  0 2A    8  0 E9  0 D5  0 CA  6
                       DF0   30  0 2A  E  0 E9  0 D5    0 CA  D DA  6 58  D 37
                       E00    1 95  D 34  1 95  D C6    D DA  6 70  0 D5  0 CA
                       E10    D E2  6 58  D 3D  1 95    D 3A  1 95  D C6  D E2
                       E20    6 70  0 D5  0 CA  D ED    6 58  D 43  1 95  D 40
                       E30    1 95  D C6  D ED  6 70    0 D5  E 3C 1A  E FE  E
                       E40   76 5E 1E  E 76 5E 2E 2A   DF  E 4B 1A  E FE  E 76
                       E50   5E 1E  E 76 5E 1E  E 76   5E 1E  E 76 5E 2E 2E 2E
                       E60   2A DF  E 64 EE 2E 84 73   94 5E DF  E 6D EE 4E B4
                       E70   4E A4 DF  0 CA  4  8  4    B  0 33  2 2B  1 F1  1
                       E80   A3  0 2A  2  0 46 F5  0   D5  E 8B E3 70 33 DF  0
                       E90   CA  2 5D  6 30  0 E9  9   C3  1 95  1 71  0 2A  6
                       EA0    1  3  0 D5  0 CA  0 1F   4F F0  0 8A  0 2A 20  2
                       EB0   37  0 76 30  0 1F 4F F0    0 8A  0 1F 4F  0  0 E9
                       EC0    0 1F 4F 20  0 33  1 F1    2 51  0 8A  1 F1  0 8A
                       ED0    4 F3  B 29  0 2A  2  0   46 ED  0 2A 20  0 1F 4F
                       EE0   F0  0 96  0 D5  0 CA  E   6B  E A4  E 62  1 D0  0
                       EF0   79 F8  0 D5  0 CA  0 2A   20  0 1F 4F F0  0 96  2
 
 
 
 
 
 
 
 
 
                                                -53-
 
 
 
          MAGNETOMETER                HEXADECIMAL MEMORY DUMP                FEBRUARY 1983
 
 
                       F00   2B  0 1F 4E 20  1 A3  E   73  E 89  E A4  0 1F 4E
                       F10   E4  0 8A  1 C0  0 79 F4    2 2B  E 8F  0 2A  6  E
                       F20   E5  0 2A  6  E 8F  0 2A    6  E E5  0 2A  C  E 8F
                       F30    0 1F 4E E4  0 8A  2 75    4  B  0 E9  1 95  6 30
                       F40    1 A3  E A4  0 1F 4E E5    0 8A  0 2A  9  2 43  0
                       F50   79 F1  2 2B  0 79 C2  0   D5  F 5B 1E 4E FB 55 3A
                       F60   8A F8 45 B5 F8 47 B6 BC   F8  0 A5 A6 AC BF B7 F8
                       F70   46 B2 F8 E0 A2 F8 46 BE   F8 80 AE F8  C B1 F8 79
                       F80   A1 F8  6 AF F8  E BD F8   F6 AD DF  0 CA  0 1F  D
                       F90   13  9 B7  1 A3  0 1F  F   5B  9 BA  1 A3  0 2A  8
                       FA0    4  5  0 96  0 1F  D C8    9 C0  1 A3  0 1F  D C8
                       FB0    9 BD  1 A3  C C6  0 D5   F8 10 B3 F8  0 A3 43 FB
                       FC0   10 3A CE 43 FB  2 3A CE    3 FB C0 3A CE D3 F8 46
                       FD0   B6 F8  0 A6 F8  0 B7 B8   BF F8 4F B2 F8 F0 A2 F8
                       FE0   4F BE F8 80 AE F8 47 BC   F8  0 AC F8  C B1 F8 79
                       FF0   A1 F8  6 AF A7 F8  F BD   F8 8D AD DF  0  0  0  0
 
 
 
 
 
                         The compilation and documentation listings provided were
                    controlled by the following load screens. 
                    
                    
                    
                    251 SCREEN
                        ( GALILEO ROM CROSSCOMPILE 6/5/81 )
                          271 LOAD 272 LOAD 273 LOAD 274 LOAD ( DOCUMENTATION )
                        ( 275 LOAD ( DOCUMENTATION LISTING UPDATES)
                         CROSS LOAD NUCLEUS LOAD PROM LOAD COLON LOAD 314 LOAD
                        29 LOAD HEX 402A RES DECIMAL 252 LOAD 253 LOAD
                         254 LOAD DECIMAL 255 LOAD 20 PAGE CR
                        HEX 402 ZERO !  CODE XFER C0 C, 0 , DECIMAL
                         298 LOAD 302 LOAD 308 LOAD 309 LOAD 313 LOAD 316 LOAD
                         320 LOAD 324 LOAD 325 LOAD 330 LOAD 100 PAGE
                        HEX 802 ' XFER 1+ ! CODE XFER C0 C, 0 , DECIMAL
                         333 LOAD 342 LOAD 343 LOAD 344 LOAD 345 LOAD
                          362 LOAD 363 LOAD 364 LOAD 365 LOAD
                         100 PAGE HEX C02 ' XFER 1+ ! CODE XFER C0 C, 0 , DECIMAL
                          366 LOAD 367 LOAD
                          369 LOAD 370 LOAD 376 LOAD 377 LOAD 380 LOAD 382 LOAD
                         383 LOAD 384 LOAD 385 LOAD ( INIT. CODE) DECIMAL  ;S 271 CREEN
                         ( GALILEO DOCUMENTATION LISTING -- ROM 1 ) FORTH DEFINITIONS
                          FORGET TASK 0 VARIABLE PGE : PPGE 1 PGE +! [ PAGE  PGE ? ;
                         : TF 12 ECHO CR CR CR CR CR CR 10 MESSAGE PPGE CR ;
                         : LIST DUP SCR !  16 0 DO CR 16 SPACES
                           I SCR @ LINE -TRAILING TYPE LOOP CR 64 .R CR ; : TASK ;
                         TF 280 LIST 281 LIST 282 LIST
                         TF 283 LIST 284 LIST
                         TF 317 LIST 318 LIST 319 LIST
                          TF 286 LIST 287 LIST TF 340 LIST 341 LIST
                         TF 310 LIST 311 LIST 312 LIST TF 285 LIST
                         TF 291 LIST 300 LIST TF 292 LIST 293 LIST 294 LIST
                         TF 295 LIST 296 LIST 297 LIST
                         TF 289 LIST 290 LIST TF 346 LIST
 
                                                -54-
 
 
 
          MAGNETOMETER             ROM DOCUMENTATION/LOAD SCREENS            FEBRUARY 1983
 
 
                        TF 299 LIST 51 LIST 52 LIST
                        TF 314 LIST 29 LIST 252 LIST
                         TF 253 LIST 254 LIST 255 LIST DECIMAL ;S 272 SCREEN
                         ( GALILEO DOCUMENTATION LISTING -- ROM 2 )
                         TF 300 LIST 292 LIST 293 LIST
                         TF 294 LIST 295 LIST 296 LIST
                         TF 297 LIST 298 LIST
                         TF 301 LIST 302 LIST
                         TF 305 LIST 306 LIST 307 LIST
                         TF 308 LIST 309 LIST
                         TF 310 LIST 311 LIST 312 LIST
                         TF 313 LIST 314 LIST
                         TF 315 LIST 316 LIST
                         TF 317 LIST 318 LIST 319 LIST
                         TF 320 LIST
                         TF 321 LIST 322 LIST 323 LIST
                         TF 324 LIST 325 LIST
                         TF 330 LIST 333 LIST
                         ;S
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -55-
 
 
 
          MAGNETOMETER             ROM DOCUMENTATION/LOAD SCREENS            FEBRUARY 1983
 
 
                    273 SCREEN
                         ( GALILEO DOCUMENTATION LISTING -- ROM 3 & 4 )
                         TF 340 LIST 341 LIST
                         TF 342 LIST 343 LIST 344 LIST
                         TF 345 LIST
                        TF 360 LIST 361 LIST
                        TF 362 LIST 364 LIST
                         ( ROM 4 ) 363 LIST
                         TF 365 LIST 366 LIST 367 LIST
                         TF 369 LIST 370 LIST TF 375 LIST 376 LIST 377 LIST
                         TF 380 LIST
                         TF 382 LIST 383 LIST 384 LIST TF 385 LIST
                         DECIMAL ;S
                    
                    274 SCREEN
                         ( GALILEO DOCUMENTATION LISTING -- TESTING CODE )
                    
                        ( TEST ROUTINES) TF 277 LIST
                         TF 240 LIST
                         TF 267 LIST 268 LIST 269 LIST
                         TF 335 LIST 261 LIST 262 LIST
                         TF 263 LIST 266 LIST
                          274 LIST TF FORGET PGE : TASK ; ;S
                        ( ***************** END OF DOCUMENTATION **********)
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
                                                -56-
 
 
  D 3D  1 A3  0 D5  0 CA
                       D90    D 31  1 95  D 2E  1 95    8 31  1 85  1 85  0 F6
                       DA0    D 43  1 A3  0 E9  D 37    1 A3  1 85  1 85  0 E9
                       DB0    D 40  1 A3  1 71  0 F6    D 34  1 A3  0 D5  0 CA
                       DC0    D 72  D 8E  0 D5  0 CA    1 85  1 85  1 71  8 31
                       DD0    0 E9  1 DB  0 F6  1 E6    0 D5  0 CA  6 30  2 5D
                       DE0    0 D5  0 CA  6 30  0 2A    8  0 E9  0 D5  0 CA  6
                       DF0   30  0 2A  E  0 E9  0 D5    0 CA  D DA  6 58  D 37
                       E00    1 95  D 34  1 95  D C6    D DA  6 70  0 D5  0 CA
                       E10    D E2  6 58  D 3D  1 95    D 3A  1 95  D C6  D E2
                       E20    6 70  0 D5  0 CA  D ED    6 58  D 43  1 95  D 40
                       E30    1 95  D C6  D ED  6 70    0 D5  E 3C 1A  E FE  E
                       E40   76������������������������������������������������������������������������������������������������������������������������������܀��w������������������������������������������������������������������������������������������������������������������������������������'��������4��
4������>��������������:��h��j��
jl������������������P��������
����H����������������@��t�����
������������J��}��������	��)	��
)	\	���	���	���	���	��2
��4
��k
���
���
��
�
�
����������c��e��g��������
�����c�����������������������
�������������������������������
�������������������������������
�������������������������������
�������������������������������
����������������*�,�.�0���
����������e��g����������
l��n�������G��I��K��M��O��Q��
QS��U��W��Y��[��]��_��a��c��e��
eg��i��k��m��o��q��s��u��w��y��
y{��}�������������������������
�������������������������������
����������������i�������v��
v��������@��x����������(��*��
*,��.��0��2��4��6��8��:��<��>��
>@��B��D��F��H��J��L��N��P��R��
RT��V��X��Z��\��^��`��b��d��f��
fh��j��l��n��p��r��t��v��x��z��
z|��~�����������������������
8��������������N��j��������'��
'w��������4�������������!��Y��
Yn��������*��B�����������I��^��
^��������_��z��������0��J��i��
i��������� ��i��������?��������
� ��d ��� ��� ��!�� !��"!��V!��X!��Z!��
Z!\!���!���!���!���!����X"���"���"��*#��
*#r#���#��$��E$��|$���$���$��4%��v%���%��
�%&��%&��`&���&���&��'��^'���'���'��(��
(N(���(���(��%)��l)���)���)���)��*��f*��
f*�*��+��+��M+��}+���+���+��,��[,���,��
�,�,���,���,���,���,���,���,���,���,���,��
�,�,���,���,���,���,��D-��F-��H-��g-���-��
�-�-���-��(.��=.��p.���.���.��&/��h/���/��
�/�/��40��j0���0���0���0��1��01��`1���1��
�1�1��2��H2���2���2��3��3��3��3��3��
33��3��!3��#3��%3��'3��)3��+3��-3��/3��
/313��33��53��73��93��;3��=3��?3��A3��C3��
C3E3��G3��I3��K3��M3���3���3���3���3���3��
�3�3���3��4��74��L4���4���4��(5��s5���5��
�5	6��T6���6���6��7��F7���7���7���7���7��
�7 8��U8���8���8��9��S9���9���9��:��U:��
U:�:���:��;��P;���;���;���;���;���;���;��
�;�;���;���;���;���;���;���;���;���;���;��
�;�;���;���;���;���;���;���;���;���;���;��
�;�;���;���;��Z<��\<��^<��}<���<���<��=��
=l=���=����a>���>��?��:?���?���?��
@��

@B@���@���@���@��DA��YA���A���A���A��4B��
4BkB���B���B��
C��QC���C���C��(D��UD���D��
�D�D���D��5E���E���E��F��fF���F���F��5G��
5G�G���G��&H��IH���H���H��I��[I��]I��_I��
_IaI��cI��eI���I���I���I���I���I���I���I��
�IJ��]J���J���J��K��DK���K���K��L��XL��
XL�L���L���L��GM���M���M��N��7N��yN���N��
�NO��FO���O���O��P��nP���P���P��Q��QQ��
QQ�Q���Q��JR���R���R���R��S��`S���S���S��
�SAT���T���T��"U��hU���U��V��GV���V���V��
�V�V���V���V���V���V���V���V���V���V���V��
�V�V��4W��6W��8W��WW���W���W��X��VX���X��
�X�X��LY���Y���Y��BZ���Z���Z��8[��M[���[��
�[�[���[���[���[���[���[���[���[���[���[��
�[�[���[���[���[���[���[���[���[���[���[��
�[�[���[���[���[���[���[���[���[���[���[��
�[�[���[���[���[���[���[���[���[���[���[��
�[�[��%\��'\��)\��+\���\���\���\���\���\��
�\9]���]���]��&^��y^���^��_��W_���_���_��
�_,`��s`���`���`��Ba��aa���a���a��;b��{b��
{b�b���b��;c���c���c��d��Zd���d���d��3e��
3e|e���e���e��3f��xf���f��g��bg���g���g��
�g;h���h���h��i��8i��^i���i���i��Bj��Dj��
DjFj��Hj��Jj��Lj��Nj���j���j���j���j���j��
�j�j���j��k��Vk���k���k��2l��`l���l���l��
�l�l��m��:m���m���m���m��n��:n��hn���n��
�n�n��o��io���o���o��#p��pp���p��q��[q��
[q�q���q���q��4r��~r���r���r��6s��}s���s��
�st��Zt���t���t��u��>u��tu���u���u��1v��
1vFv��[v��]v��_v��av��cv��ev��gv��iv���v��
�v�v���v���v���v��w��w��"w��gw���w���w��
�w�w��=x��tx���x���x���x��y��3y��{y���y��
�yz��)z��+z��-z��/z��1z��3z��5z��7z��9z��
9z;z��=z��?z��Az��Cz��Ez��Gz��Iz��Kz��Mz��
MzOz��Qz��Sz��Uz��Wz��Yz��[z��]z��_z��az��
azcz��ez��gz��iz��kz��mz��oz��qz��sz��uz��
uzwz��yz��{z���z���z���z���z��{��{��{��
{4{���{���{���{��|��^|���|���|��F}���}��
�}�}��3~���~���~���~���~����3��������
����#���u���ǀ�����d�����������K�������
��������������
������������������
���������������� ���"���$���&���(���
(�*���,���.���0���2���4���6���k���m���o���
o�q���̃��΃��Ѓ�����������/���D�������
�����:�����������҅��%���t�������Ɇ��ކ��
ކ���������;���=���?�������Ӈ�����e���
e���������A�������݉��&���o�����������G���
G�����؋��ڋ��܋��ދ�������������H�������
��،�� ���5���J���_���t�������������������
������ƍ��ȍ��ʍ��̍��'���)���+���J���L���
L�N�������ю������������>�����������ʏ��
ʏ����������8���:���<���k����������3���
3�w���������������ё������������%���D���
D�F���H���t�������������U�����������ԓ��
ԓ���J�����������ޔ�����9���;���=���?���
?�A���C���E���G���I���~���������������ߕ��
ߕ���������������9���w�������������
�E�������ܗ��'���e���������������Ș�����
�������"���N����������0���i�������ƚ��
ƚ���"���^�������ܛ��������,���K���M���
M�O�����������������'���e�������ȝ������
�����0���q���������������������������Ş��
ŞǞ��ɞ��˞��&���(���*���_���������������
�������������F���m����������h�����������
��;�������ʢ�����C��������������������
����!���#���%���'���)���+���-���/���1���
1�3���5���7���9���;���=���?���A���C���E���
E�G���I���K���M���O���Q���S���U���W���Y���
Y�[���]���_�������������������������������
�����������r���������������C�����������
�������������@���U���j��������������ȧ��
ȧʧ��̧�����;���]�������Ǩ�����b�������
��ީ�����3���T��������������E���G���I���
I�K���M���O���Q���S���U���W���Y���[���]���
]�_���a���c���e���g���i���k���������������
���������������$���&���(���i����������
�Y�����������D����������9���������������
��B�������ǰ��ܰ��������������H���]�������
�����6���j�������ʲ������*���Z�����������
������������4���6���8���r�������δ�����
�X���m����������6���y�����������B�������
������������������·��������!���6���8���
8�:���<���>���@���B���D���F���H���J���L���
L�N���P���R���T���V���X���Z���\���^���`���
`�b���d���f���h���j���l���n���p���r���t���
t�v���x���z���|���~�����������������������
������������������������������������������
����������������������۸��ݸ��߸�����<���
<�>���@���_���a���c��������������5���J���
J���������ͺ�����B���{�������ջ��
���E���
E�h���}���������������Ҽ�����������R���
R�{����������$���`�����������˾�����)���
)�+���-���/���1���3���5���7���9���;���=���
=�?���A���C���E���G���I���K���M���O�������
���������������������������������!���
!�b���w����������]����������T�����������
��.���[�����������0�����������������������
��@���|���������������Q�������������N���
NǑ�����������)���>���]���_���a�����������
��K�����������(���i�����������P�����������
�����L���N�������������������������������
��-���s���u���w���y���{���}��������������
�ͅ���������������������������������������
�͙���������������������������������������
�ͭ���������������������������������������
������������������������������������������
���������������������������������������
����w���y���{��������������������������
�N������������������[���������������#���
#�G���������������������������=���}�������
�ҧ�����������-���^���s�������������������
������������������	��������������
����������������������!���#���%���
%�'���\���^���`���b�����������������������
��
���������U�����������G��������������
�g������������������*���Q���x�����������
�����������������R���g�������������������
�����:���p�������������������������������
���������������������������������������
�������
���������C���E���G���I�������
�ۦ��������������������������[�����������
��I���^������������������M���������������
������
���������D���Y������������������
�<���a��������������?���u���������������
�����������O���d���������������(���W���
W��������������"���$���&���(���*���_���
_�a���c���e���������������������������2���
2�~�����������9���k�����������,���r�������
����������"���7���L���k���m���o�����������
������"���W�������������������	������3���
3�H���]���r���t���v���x���z���|���~�������
�����������������������������������������
�����������������������������0���2���4���
4�S���U���W�����������
���M�����������5���
5�����������c�����������<���������������
��������������!���\�����������/���w�������
������1���O���d������������������Q���S���
S�U���W���Y���[���]���_���a���c���e���g���
g�i���k���m���o���q���s���u���������������
�������������.���0���2���m�����������
��2��������������������������&���;���P���
P�p���r���t�����������/���h��������������
�`�����������(���h����������g�����������
���������������������e����������X�������
������H�����������8���p�������������������
������-���/���1���3�����������������������
������������������������������������������
����������������������������������������
��������
������������
���������� ��"��$��&��(��
(*��,��.��0��2��4��6��8��:��<��
<>��@��B��D��F��{��}����������
���������H��p��r��������������
����1��i�����������3�����������
���U��������������������������
���������������	��������
����������������!��#��
#%��'��)��+��-��/��1��3��5��j��
jl��n��p��������������������2��
2y����������_��������-��q�����
����	��j	���	���	��
��!
��#
��%
��g
��
g
�
���
��4��w�������\�����������
�>��������+��d��f��h��j��l��n��
np��r��t��v��x��z��|��~��������
������������������������ ��"��
"7��W��Y��[��������+��r�������
C����������I����������Z����
������������������ ��M��{�����
�������1��x���������������5��
57��9����������M��������)��a��
a�����5��b��������������������
����X��Z��\��������������������
�������������������������������
�����������������������������
������
��������������
�������� ��"��$��&��(��*��
*,��.��0��2��4��6��8��:��<��>��
>@��u��w��y��{�����������������
����@��������#��c�������G��\��
\q��������������������������
��	������������������
������!��#��%��'��)��+��-��
-/��1��3��5��7��9��;��=��?��A��
AC��E��G��I��K�����������������
������� �� �� ��F ��� ��� ��
!��C!��
C!�!���!��	"��N"���"���"��#��h#���#��$��
$$��$��9$��;$��=$��}$���$��%��O%��d%��
d%�%���%���%��&��<&��n&���&���&���&���&��
�&'��'��'��U'���'���'���'��&(��s(���(��
�(�(��1)��{)���)��*��I*��t*���*���*���*��
�*�*���*���*��1+��3+��5+��T+��V+��X+���+��
�+�+���+��@,��x,���,��-��N-���-���-��.��
.*.��\.���.���.��3/��5/��T/��V/��X/���/��
�/�/��0��)0��x0���0��
1��K1��~1���1���1��
�1�1��<2��w2���2���2���2���2���2���2��3��
3K3���3���3��4��64��\4��q4���4���4��=5��
=5n5���5���5���5���5���5���5��6��6��6��
6e6��g6��i6��k6��m6��o6��q6��s6��u6��w6��
w6y6��{6��}6��6���6���6���6���6���6���6��
�6�6���6���6���6���6���6���6���6���6���6��
�6�6���6���6���6���6���6���6���6���6���6��
�6�6���6���6���6���6���6���6���6���6���6��
�6�6���6���6���6���6���6���6��
7��7��7��
77��k7��m7��o7���7���7���7���7��8��'8��
'8)8��+8��e8���8���8��$9��i9���9��:��L:��
L:�:���:���:���:��+;��@;��_;��a;��c;���;��
�;�;��<��^<���<���<��=��R=��q=���=���=��
�=>��G>��z>���>���>���>���>���>���>���>��
�>�>���>���>���>���>��?��?��?��?��?��
?
?��??��A?��C?��E?���?���?���?���?���?��
�?�?��@��]@���@���@��7A���A���A��"B��oB��
oB�B���B��5C���C���C��D��`D��D���D���D��
�D�D��E��GE��tE���E���E��F��NF���F���F��
�F�F��G��0G��xG���G���G���G���G���G���G��
�G�G���G���G���G���G���G���G���G���G���G��
�GH��H��H��H��H��=H��?H��AH��CH���H��
�H�H���H���H���H���H���H��?I���I���I��,J��
,JAJ���J���J��9K��NK���K���K��+L��bL���L��
�L�L���L��M��M��M��MM���M���M��N��NN��
NN�N���N��O��YO���O���O���O��7P��uP���P��
�P�P���P��	Q��Q����BQ���Q���Q��R��8R��
8RlR���R���R��5S��JS��mS��oS��qS��sS���S��
�S�S���S���S��	T��T����,T��.T��0T��iT��
iT~T���T��	U��U��hU���U��V��V��/V��TV��
TViV���V���V���V���V��W��TW���W���W��%X��
%XoX���X���X��KY���Y���Y��Z��NZ���Z���Z��
�Z�Z���Z���Z���Z��4[��I[��^[���[���[��$\��
$\d\���\���\��]��a]���]���]���]���]���]��
�]�]���]���]���]���]���]���]��=^��?^��A^��
A^`^��b^��d^���^���^���^��_��C_��l_���_��
�_�_��"`��G`��\`��{`��}`��`���`��a��ba��
ba�a���a��)b��sb���b���b��9c���c���c���c��
�c!d��#d��%d��'d��)d��+d��-d��/d��1d��3d��
3d5d��7d��9d��;d��=d��?d��Ad��Cd��Ed��Gd��
GdId��Kd��Md��Od��Qd��Sd��Ud���d���d���d��
�d�d���d���d���d��.e��ae��e���e��f��Zf��
Zf�f���f��8g��|g���g��h��bh���h���h��@i��
@imi���i��j��0j��2j��4j��6j��8j���j���j��
�j>k��hk��}k��k���k���k���k���k���k���k��
�k�k���k���k���k���k���k���k���k���k���k��
�k�k���k���k���k���k���k���k���k���k���k��
�k�k���k���k���k���k��Kl��Ml��Ol��zl���l��
�l/m��Km��|m���m��n��\n���n���n��,o���o��
�o�o��p��mp���p��"q��|q���q��r��Xr���r��
�r	s��cs���s��t��St���t��u��_u���u��v��
v[v���v��w��\w���w���w���w���w���w���w��
�w�w���w���w���w���w���w���w���w���w���w��
�w�w���w���w���w���w��*x��,x��.x��0x���x��
�x�x���x���x��Ay��ey���y���y��6z��yz���z��
�z{��K{���{���{��|��c|���|���|��5}��{}��
{}�}��~��K~���~���~����Z��������)���
)�o�����������B�������΁�����X�������݂��
݂!���e�����������/���o�����������2�������
��΅�����N���c���e���g���i�����������ц��
цӆ��Ն��׆��2���4���6���W���Y�����������
��F����������3�������щ�� ���o���������
\�����������I����������6�������ԍ��#���
#�r����������_�����������L����������9���
9�����ב��&���u���Ē�����b����������O���
O��������<�������ڕ��)���+���-���/���1���
1�3���5���7���l���n���p���r���͖��ϖ��і��
і ���o���������\�����������I����������
�6�������Ԛ��#���r����������_�����������
��L����������9�������מ��&���u���ğ�����
�b����������O�����������<�������ڢ��)���
)�x���ǣ�����e����������R���������������
���������������������������������������
����I���K���M����������:�������ا��'���
'�v���Ũ�����c����������P����������=���
=�����۫��*���y���Ȭ�����f����������S���
S��������@�������ޯ��-���|���˰�����i���
i��������V�����������C����������0������
�δ��������!���#���%���'���)���+���-���
-�/���d���f���h���j���ŵ��ǵ��ɵ�����g���
g��������T����������A�������߸��.���}���
}�̹�����j����������W�����������D�������
�����1�������Ͻ�����m����������Z�������
������G�����������4�����������!���p�������
�����]�����������J�����������������������
��������������������������������������A���
A�C���E�����������2��������������n�������
�����[�����������H�����������5�����������
��"���q����������^�����������K�����������
��8�����������%���t����������a�����������
��N�����������;�����������(���w����������
����������������!���#���%���'���\���
\�^���`���b������������������_�����������
��L�����������9�����������&���u����������
�b�����������������������������L���a���
a�v���������������6���z����������N�������
������'���o�����������E���q����������o���
o��������Q�����������	���@��������������
�J��������������������������������� ���
 �T��������������Q������������������I���
I����������������8���o�������������������
������������������������������������������
������������������	��������������
����������������������!���#���%���
%�'���)���+���-���/���1���3���h���j���l���
l�n�������������������4���b���������������
�����D���{�����������/���S���h�����������
���������A���x��������������g���i���k���
k�m���o���q���s���u���w���y���{���}������
�����������������������������������������
������������������������������������������
����������������������K�����������8�������
������%���t����������a�������������/�=���0*�=�-���������������������������������������������������������������������������������������������������������P
�7���� �)?0b3);�A�JV<[e_�iHs�y�z���{���\�w��ɪ{����Ҽ��E�5ͣ���p��޲�
�0�g�v���NM�`Z��"P*267t>	E�I�REZ�_dk1r�x�.�g�/������
����������3WPQ	
7G5II&D )!T"C#$$%[&'(L)*F+,-.E/012345D6789B:;G<=#>?@ABXCFDGEOFOGHOIOJKOLM7NOP������������������������������������������������������������������������������������������������������������������������������������������ (04/14/9204/14/92���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������

