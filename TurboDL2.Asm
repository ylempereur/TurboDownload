;SAVE"TurboDL2.Asm"
*--------------------------------
; TurboDownload v2.1   (07/08/87)
*-------------------------------+
whichPort = 0    ;(M=0,P=1)     |
*-------------------------------+
         LIST    OFF
*--------------------------------
         INCLUDE ":Sources:Library.Asm"
         INCLUDE ":Sources:Equates.Asm"
*--------------------------------
SOH      EQU     $01
EOT      EQU     $04
ACK      EQU     $06
NAK      EQU     $15
CAN      EQU     $18
*--------------------------------
stopIcon         EQU  0
srcCopy          EQU  0
fnfErr           EQU  -43
dupFNErr         EQU  -48
;
                 DO   whichPort=0
RefIn            EQU  -6
RefOut           EQU  -7
                 ELSE
RefIn            EQU  -8
RefOut           EQU  -9
                 FIN
*================================
* A6 (stack) private storage
*--------------------------------
PrivSize         EQU  -514
;
                 ORG  PrivSize
;
Buf              DEFS 128
PB               DEFS 80
SFR              DEFS 74
Str64            DEFS 64
PBc              DEFS 50
Str32            DEFS 32
EventRecord      DEFS 16
TempRect         DEFS 8
TheWindow        DEFS L
Type             DEFS L
Creator          DEFS L
Flags            DEFS W
Location         DEFS L
Folder           DEFS W
Locked           DEFS W
DataLen          DEFS L
RsrcLen          DEFS L
FlCrDat          DEFS L
FlMdDat          DEFS L
Hdr2Len          DEFS W
TimeOut          DEFS L
MaxBlk           DEFS W
Block            DEFS W
ErrCnt           DEFS W
Srch             DEFS W
BPtr             DEFS W
CRC              DEFS W
Blk              DEFS W
F.Abort          DEFS B
F.First          DEFS B
F.Turbo          DEFS B
F.CRC            DEFS B
                 DEFS *&1
*================================
         TFILE   "TurboDL.Bin"
*--------------------------------
         RFILE   "TurboDL 2.1",DFIL,DMOV
*================================
         DO      whichPort=0
         RSRC    DRVR,12,resPurgeable,"@TurboDL-M"
         ELSE
         RSRC    DRVR,12,resPurgeable,"@TurboDL-P"
         FIN
*--------------------------------
Desk     DATA    /$0000          ;drvrFlags
         DATA    /0              ;drvrDelay
         DATA    /$0000          ;drvrEMask
         DATA    /0              ;drvrMenu
         DATA    /DskOpen-Desk   ;drvrOpen
         DATA    /DskDone-Desk   ;drvrPrime
         DATA    /DskDone-Desk   ;drvrCtl
         DATA    /DskDone-Desk   ;drvrStatus
         DATA    /DskDone-Desk   ;drvrClose
DskTitle STR     "Turbo-Download  --  (C) 1987, Mainstay"
         ADJST
*--------------------------------
DskOpen  MOVEM.L A2-A4,-(SP)
         MOVE.L  A1,A4
         MOVE.L  (A5),A0
         MOVE.L  (A0),-(SP)
         BSR     DnlApp
         MOVE.L  (A5),A0
         MOVE.L  (SP)+,(A0)
         MOVE.L  A4,A1
         MOVEM.L (SP)+,A2-A4
DskDone  MOVEQ   #0,D0
         RTS
*--------------------------------
DnlApp   LINK    A6,#PrivSize
         MOVE    #104,-(SP)
         MOVE    #089,-(SP)
         PEA     .50(PC)
         PEA     .51(PC)
         CLR.L   -(SP)
         PEA     SFR(A6)
         MOVE    #sfPutFile,-(SP)
         _Pack3
         TST.B   SFR+rGood(A6)
         BEQ     .20
         BSR     BDopen
         BSR     Ropen
         LEA     PB(A6),A0
         LEA     SFR+rName(A6),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    SFR+rVolume(A6),ioVRefNum(A0)
         CLR.B   ioVersNum(A0)
         _Delete
         MOVE    ioResult(A0),D0
         BEQ.S   .0
         CMP     #fnfErr,D0
         BNE     .42
.0       BSR     Rread
         BNE     .42
         TST.B   Buf+0(A6)
         BNE     .30
         TST.B   Buf+74(A6)
         BNE     .30
         CLR     D2
         LEA     Buf+0(A6),A0
         MOVEQ   #124-1,D3
.1       MOVE.B  (A0)+,D0
         LSL     #8,D0
         EOR     D0,D2
         MOVEQ   #8-1,D1
.2       ADD     D2,D2
         BCC.S   .3
         EOR     #$1021,D2
.3       DBRA    D1,.2
         DBRA    D3,.1
         CMP     Buf+124(A6),D2
         BNE.S   .4
         CMP.B   #129,Buf+123(A6)
         BHI     .30
         MOVE.B  Buf+101(A6),Buf+74(A6)
         MOVE    Buf+120(A6),Hdr2Len(A6)
         BRA.S   .5
.4       TST.B   Buf+82(A6)
         BNE     .30
         TST.B   Buf+122(A6)
         BNE     .30
         CMP.B   #63,Buf+1(A6)
         BHI     .30
         CLR     Hdr2Len(A6)
.5       LEA     Buf+1(A6),A0
         LEA     Str64(A6),A1
         BSR     CopyStr
         LEA     Buf+65(A6),A0
         LEA     Type(A6),A1
         MOVEQ   #34-1,D0
.6       MOVE.B  (A0)+,(A1)+
         DBRA    D0,.6
         LEA     PB(A6),A0
         LEA     Str64(A6),A1
         MOVE.L  A1,ioNamePtr(A0)
         _Create
         MOVE    ioResult(A0),D0
         BEQ.S   .7
         CMP     #dupFNErr,D0
         BNE     .42
         LEA     PB(A6),A0
         LEA     SFR+rName(A6),A1
         MOVE.L  A1,ioNamePtr(A0)
         _Create
         MOVE    ioResult(A0),D0
         BNE     .42
.7       BSR     MaxBin
         ADDQ    #1,MaxBlk(A6)
         BSR     BDname
         TST     Hdr2Len(A6)
         BEQ.S   .10
.8       BSR     Rread
         BNE     .41
         MOVE    #128,D1
         CMP     Hdr2Len(A6),D1
         BLS.S   .9
         MOVE    Hdr2Len(A6),D1
.9       SUB     D1,Hdr2Len(A6)
         BSR     BDdisp
         TST     Hdr2Len(A6)
         BNE.S   .8
.10      TST.L   DataLen(A6)
         BEQ.S   .13
         LEA     PB(A6),A0
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE     .41
         MOVE.L  DataLen(A6),ioReqCount(A0)
         _Allocate
         MOVE    ioResult(A0),D0
         BNE     .40
.11      BSR     Rread
         BNE     .40
         MOVE.L  #128,D1
         CMP.L   DataLen(A6),D1
         BLS.S   .12
         MOVE.L  DataLen(A6),D1
.12      LEA     PB(A6),A0
         LEA     Buf(A6),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  D1,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE     .40
         MOVE.L  ioActCount(A0),D0
         SUB.L   D0,DataLen(A6)
         BSR     BDdisp
         TST.L   DataLen(A6)
         BNE.S   .11
         LEA     PB(A6),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE     .41
.13      TST.L   RsrcLen(A6)
         BEQ.S   .16
         LEA     PB(A6),A0
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _OpenRF
         MOVE    ioResult(A0),D0
         BNE     .41
         MOVE.L  RsrcLen(A6),ioReqCount(A0)
         _Allocate
         MOVE    ioResult(A0),D0
         BNE     .40
.14      BSR     Rread
         BNE     .40
         MOVE.L  #128,D1
         CMP.L   RsrcLen(A6),D1
         BLS.S   .15
         MOVE.L  RsrcLen(A6),D1
.15      LEA     PB(A6),A0
         LEA     Buf(A6),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  D1,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE     .40
         MOVE.L  ioActCount(A0),D0
         SUB.L   D0,RsrcLen(A6)
         BSR     BDdisp
         TST.L   RsrcLen(A6)
         BNE.S   .14
         LEA     PB(A6),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE     .41
.16      LEA     PB(A6),A0
         MOVE.L  Type(A6),ioFlFndrInfo+fdType(A0)
         MOVE.L  Creator(A6),ioFlFndrInfo+fdCreator(A0)
         MOVE    Flags(A6),ioFlFndrInfo+fdFlags(A0)
         AND     #$F8FC,ioFlFndrInfo+fdFlags(A0)
         CLR.L   ioFlFndrInfo+fdLocation(A0)
         CLR     ioFlFndrInfo+fdFldr(A0)
         MOVE.L  FlCrDat(A6),ioFlCrDat(A0)
         MOVE.L  FlMdDat(A6),ioFlMdDat(A0)
         _SetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .41
         MOVE.B  Locked(A6),D0
         AND.B   #$01,D0
         BEQ.S   .17
         LEA     PB(A6),A0
         _SetFilLock
         MOVE    ioResult(A0),D0
         BNE     .41
.17      LEA     PB(A6),A0
         _FlushVol
         MOVE    ioResult(A0),D0
         BNE     .42
.18      BSR     Rread
         BEQ.S   .18
         CMP     #1,D0
         BEQ.S   .19
         BSR     Rabort
         BSR     BDclose
         BRA.S   .20
.19      BSR     Rclose
         BSR     BDclose
.20      UNLK    A6
         RTS
.30      LEA     PB(A6),A0
         _Create
         MOVE    ioResult(A0),D0
         BNE     .42
         CLR     ioFDirIndex(A0)
         _GetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .41
         MOVE.L  #$54455854,ioFlFndrInfo+fdType(A0)      ;"TEXT"
         MOVE.L  #$4D414341,ioFlFndrInfo+fdCreator(A0)   ;"MACA"
         _SetFileInfo
         MOVE    ioResult(A0),D0
         BNE.S   .41
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .41
         BRA.S   .32
.31      BSR     Rread
         BNE.S   .33
.32      LEA     PB(A6),A0
         LEA     Buf(A6),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #128,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE.S   .40
         BSR     BDdisp
         BRA.S   .31
.33      CMP     #1,D0
         BNE.S   .40
         LEA     PB(A6),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .41
         _FlushVol
         MOVE    ioResult(A0),D0
         BNE.S   .42
         BSR     Rclose
         BSR     BDclose
         UNLK    A6
         RTS
.40      MOVE    D0,-(SP)
         LEA     PB(A6),A0
         _Close
         MOVE    (SP)+,D0
.41      MOVE    D0,-(SP)
         LEA     PB(A6),A0
         _Delete
         MOVE    (SP)+,D0
.42      MOVE    D0,-(SP)
         BSR     Rabort
         BSR     BDclose
         MOVE    (SP)+,D0
         BSR     DosErr
         UNLK    A6
         RTS
.50      STR     "Save document as:"
.51      STR     "?"
         ADJST
*--------------------------------
MaxBin   CLR.L   D0
         MOVE    Hdr2Len(A6),D0
         MOVE.L  DataLen(A6),D1
         MOVE.L  RsrcLen(A6),D2
         ADD.L   #127,D0
         ADD.L   #127,D1
         ADD.L   #127,D2
         LSR.L   #7,D0
         LSR.L   #7,D1
         LSR.L   #7,D2
         ADD     D1,D0
         ADD     D2,D0
         MOVE    D0,MaxBlk(A6)
         RTS
BDopen   CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     D.10(PC)
         PEA     D.11(PC)
         ST      -(SP)
         MOVE    #dBoxProc,-(SP)
         MOVE.L  MinusOne,-(SP)
         SF      -(SP)
         CLR.L   -(SP)
         _NewWindow
         MOVE.L  (SP),TheWindow(A6)
         _SetPort
         MOVE    #monaco,-(SP)
         _TextFont
         MOVE    #9,-(SP)
         _TextSize
         MOVE    #srcCopy,-(SP)
         _TextMode
         MOVE    #004+00*06,-(SP)
         MOVE    #011+00*11,-(SP)
         _MoveTo
         PEA     D.20(PC)
         _DrawString
         PEA     SFR+rName(A6)
         _DrawString
         MOVE    #004+00*06,-(SP)
         MOVE    #011+01*11,-(SP)
         _MoveTo
         PEA     D.21(PC)
         _DrawString
         PEA     D.22(PC)
         _DrawString
         PEA     D.23(PC)
         _DrawString
         PEA     D.30(PC)
         _FrameRect
         MOVE    #004+00*06,-(SP)
         MOVE    #011+03*11,-(SP)
         _MoveTo
         PEA     DskTitle(PC)
         _DrawString
         CLR     MaxBlk(A6)
         CLR     Block(A6)
         BRA.S   BDdisp
BDname   PEA     D.40(PC)
         _EraseRect
         MOVE    #004+00*06,-(SP)
         MOVE    #011+00*11,-(SP)
         _MoveTo
         PEA     D.20(PC)
         _DrawString
         PEA     Str64(A6)
         _DrawString
BDsize   MOVE    #004+00*06,-(SP)
         MOVE    #011+01*11,-(SP)
         _MoveTo
         PEA     D.21(PC)
         _DrawString
         MOVE.L  DataLen(A6),D0
         ADD.L   RsrcLen(A6),D0
         LEA     Str32(A6),A0
         MOVE    #numToString,-(SP)
         _Pack7
         MOVE.L  A0,-(SP)
         _DrawString
         PEA     D.23(PC)
         _DrawString
BDdisp   MOVE    #004+27*06,-(SP)
         MOVE    #011+01*11,-(SP)
         _MoveTo
         PEA     D.24(PC)
         _DrawString
         CLR.L   D0
         MOVE    Block(A6),D0
         LEA     Str32(A6),A0
         MOVE    #numToString,-(SP)
         _Pack7
         MOVE.L  A0,-(SP)
         _DrawString
         TST     MaxBlk(A6)
         BEQ.S   .0
         LEA     TempRect(A6),A0
         MOVE.L  D.30+topLeft(PC),topLeft(A0)
         MOVE.L  D.30+botRight(PC),botRight(A0)
         MOVE    Block(A6),D0
         MULU    #226,D0
         DIVU    MaxBlk(A6),D0
         ADD     #005,D0
         MOVE    D0,right(A0)
         MOVE.L  A0,-(SP)
         _FrameRect
         PEA     TempRect(A6)
         MOVE.L  #$00010001,-(SP)
         _InsetRect
         PEA     TempRect(A6)
         MOVE.L  (A5),A0
         PEA     gray(A0)
         _FillRect
.0       RTS
BDclose  MOVE.L  TheWindow(A6),-(SP)
         _DisposWindow
         RTS
D.10     DATA    /147,/138,/195,/373
D.30     DATA    /026,/004,/033,/231
D.40     DATA    /002,/004,/013,/424
D.11     STR     ""
D.20     STR     "File: "
D.21     STR     "Size: "
D.22     STR     "?"
D.23     STR     " bytes"
D.24     STR     "Block: "
         ADJST
*--------------------------------
CopyStr  CLR     D0
         MOVE.B  (A0),D0
.0       MOVE.B  (A0)+,(A1)+
         DBRA    D0,.0
         RTS
*--------------------------------
DosErr   MOVE    D0,D7
         CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     .10(PC)
         PEA     .13(PC)
         ST      -(SP)
         MOVE    #dBoxProc,-(SP)
         MOVE.L  MinusOne,-(SP)
         SF      -(SP)
         CLR.L   -(SP)
         _NewWindow
         MOVE.L  (SP),TheWindow(A6)
         _SetPort
         PEA     .11(PC)
         CLR.L   -(SP)
         MOVE    #stopIcon,-(SP)
         _GetIcon
         _PlotIcon
         MOVE    #sysFont,-(SP)
         _TextFont
         MOVE    #12,-(SP)
         _TextSize
         MOVE    #72,-(SP)
         MOVE    #39,-(SP)
         _MoveTo
         LEA     TErr(PC),A0
.0       MOVE    (A0)+,D0
         BEQ.S   .1
         CMP     D7,D0
         BEQ.S   .1
         ADD     (A0)+,A0
         BRA.S   .0
.1       PEA     2(A0)
         _DrawString
         PEA     .12(PC)
         _DrawString
         MOVE    #4,-(SP)
         _SysBeep
.2       CLR.B   -(SP)
         MOVE    #$003F,-(SP)
         PEA     EventRecord(A6)
         _GetNextEvent
         TST.B   (SP)+
         BEQ.S   .2
         MOVE    EventRecord+evtNum(A6),D0
         CMP     #1,D0
         BEQ.S   .3
         CMP     #3,D0
         BNE.S   .2
.3       MOVE.L  TheWindow(A6),-(SP)
         _DisposWindow
         RTS
.10      DATA    /136,/104,/206,/408
.11      DATA    /010,/020,/042,/052
.12      STR     " error."
.13      STR     ""
         ADJST
*--------------------------------
ESTR     MACRO
         DATA    /]1,/:1-:0
:0       STR     "]2"
         ADJST
:1
         ENDM
*--------------------------------
TErr     ESTR    -33,"Directory full"
         ESTR    -34,"Disk full"
         ESTR    -35,"No such volume"
         ESTR    -36,"Disk I/O"
         ESTR    -39,"End of file"
         ESTR    -43,"File not found"
         ESTR    -44,"Write protected diskette"
         ESTR    -45,"File locked"
         ESTR    -46,"Volume locked"
         ESTR    -47,"File busy"
         ESTR      2,"Cancel"
         ESTR      1,"End of text"
         ESTR      0,"Unknown"
*--------------------------------
Ropen    ST      F.Turbo(A6)
         ST      F.CRC(A6)
         ST      F.First(A6)
         SF      F.Abort(A6)
         CLR     Block(A6)
         RTS
Rread    ADDQ    #1,Block(A6)
.0       CLR     ErrCnt(A6)
         TST.B   F.First(A6)
         BNE.S   .1
         MOVEQ   #ACK,D0
         TST.B   F.Turbo(A6)
         BEQ.S   .2
         SF      F.Turbo(A6)
         BSR     Snd
         BSR     Snd
         BRA.S   .2
.1       BSR     WaitQ1
         MOVEQ   #NAK,D0
         TST.B   F.First(A6)
         BEQ.S   .2
         TST.B   F.CRC(A6)
         BEQ.S   .2
         MOVEQ   #'C',D0
.2       BSR     Snd
         MOVE    #160,Srch(A6)
.3       BSR     Recv10
         BEQ.S   .4
         CMP.B   #CAN,D0
         BEQ.S   .6
         CMP.B   #EOT,D0
         BEQ.S   .7
         CMP.B   #SOH,D0
         BEQ.S   .8
         SUBQ    #1,Srch(A6)
         BNE.S   .3
.4       TST.B   F.Abort(A6)
         BNE.S   .6
         TST.B   F.First(A6)
         BEQ.S   .5
         CMP     #2,ErrCnt(A6)
         BNE.S   .5
         SF      F.CRC(A6)
.5       ADDQ    #1,ErrCnt(A6)
         CMP     #10,ErrCnt(A6)
         BLO.S   .1
.6       MOVEQ   #2,D0
         RTS
.7       MOVEQ   #1,D0
         RTS
.8       SF      F.First(A6)
         BSR     Recv10
         BEQ.S   .4
         MOVE.B  D0,Blk(A6)
         BSR     Recv10
         BEQ.S   .4
         NOT.B   D0
         CMP.B   Blk(A6),D0
         BNE.S   .5
         CLR     CRC(A6)
         CLR     BPtr(A6)
.9       BSR     Recv10
         BEQ.S   .4
         LEA     Buf(A6),A0
         ADD     BPtr(A6),A0
         MOVE.B  D0,(A0)
         BSR.S   .20
         ADDQ    #1,BPtr(A6)
         CMP     #128,BPtr(A6)
         BLO.S   .9
         TST.B   F.CRC(A6)
         BEQ.S   .10
         BSR     Recv10
         BEQ.S   .4
         BSR.S   .20
         BSR     Recv10
         BEQ     .4
         BSR.S   .20
         TST     CRC(A6)
         BNE.S   .5
         BRA.S   .11
.10      BSR     Recv10
         BEQ     .4
         CMP.B   CRC+1(A6),D0
         BNE     .5
.11      MOVE.B  Block+1(A6),D0
         CMP.B   Blk(A6),D0
         BEQ.S   .12
         SUBQ.B  #1,D0
         CMP.B   Blk(A6),D0
         BEQ     .0
         BRA     .6
.12      MOVEQ   #0,D0
         RTS
.20      TST.B   F.CRC(A6)
         BEQ.S   .23
         EOR.B   D0,CRC(A6)
         MOVE    CRC(A6),D2
         MOVEQ   #8-1,D1
.21      ADD     D2,D2
         BCC.S   .22
         EOR     #$1021,D2
.22      DBRA    D1,.21
         MOVE    D2,CRC(A6)
         RTS
.23      ADD.B   D0,CRC+1(A6)
         RTS
Rabort   BSR     WaitQ3
         MOVEQ   #CAN,D0
         BSR     Snd
         BRA.S   Rclos
Rclose   BSR     WaitQ1
         MOVEQ   #ACK,D0
         BSR     Snd
Rclos    BSR     WaitQ1
         MOVE    #4,-(SP)
         _SysBeep
         RTS
*--------------------------------
WaitQ1   BSR     Recv1
         BNE.S   WaitQ1
         RTS
WaitQ3   BSR     Recv3
         BNE.S   WaitQ3
         RTS
Recv10   MOVE    #10*60,A0
         BRA.S   Recv
Recv3    MOVE    #03*60,A0
         BRA.S   Recv
Recv1    MOVE    #01*60,A0
Recv     ADD.L   Ticks,A0
         MOVE.L  A0,TimeOut(A6)
.0       LEA     PBc(A6),A0
         MOVE    #RefIn,ioRefNum(A0)
         MOVE    #2,csCode(A0)
         _Status
         TST     ioResult(A0)
         BNE.S   .1
         TST.L   csParam(A0)
         BNE.S   .2
         BSR.S   Abort
         BNE.S   .1
         MOVE.L  Ticks,A0
         CMP.L   TimeOut(A6),A0
         BLO.S   .0
.1       MOVEQ   #0,D7
         RTS
.2       CLR.B   -(SP)
         LEA     PBc(A6),A0
         MOVE    #RefIn,ioRefNum(A0)
         MOVE.L  A7,ioBuffer(A0)
         MOVE.L  #1,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Read
         MOVE.B  (SP)+,D0
         TST     ioResult(A0)
         BNE.S   .1
         MOVEQ   #1,D7
         RTS
Snd      MOVE.B  D0,-(SP)
         LEA     PBc(A6),A0
         MOVE    #RefOut,ioRefNum(A0)
         MOVE.L  A7,ioBuffer(A0)
         MOVE.L  #1,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE.B  (SP)+,D0
         RTS
Abort    LEA     EventRecord(A6),A0
         MOVE    #$003F,D0
         _GetOSEvent
         TST.B   D0
         BNE.S   .0
         MOVE    EventRecord+evtNum(A6),D0
         CMP     #3,D0
         BNE.S   .0
         MOVE    EventRecord+evtMeta(A6),D0
         BTST    #8,D0
         BEQ.S   .0
         MOVE.L  EventRecord+evtMessage(A6),D0
         CMP.B   #'.',D0
         BNE.S   .0
         ST      F.Abort(A6)
         MOVEQ   #-1,D0
         RTS
.0       MOVEQ   #0,D0
         RTS
*--------------------------------
         ENDR
*================================
         END
