;SAVE"TD.Asm"
*-------------------------------+
Port = 0         ;(M=0,P=1)     |
*-------------------------------+
         LIST    OFF
*--------------------------------
         INCLUDE "Library.Asm"
*--------------------------------
SOH      EQU     $01
EOT      EQU     $04
ACK      EQU     $06
LF       EQU     $0A
NAK      EQU     $15
CAN      EQU     $18
SUB      EQU     $1A
*--------------------------------
resPurgeable     EQU  32
;
dBoxProc         EQU  1
;
GrafGlobals      EQU  0
thePort          EQU  $0
;
sysFont          EQU  0
;
srcOr            EQU  1
;
Ticks            EQU  $16A
;
fsWrPerm         EQU  2
;
Good             EQU  0
fType            EQU  2
vRefNum          EQU  6
version          EQU  8
fName            EQU  10
RefNum           EQU  74         ;Not Standard
;
SFPutFile        EQU  1
;
stopIcon         EQU  0
*--------------------------------
* RAM driver's private storage
*--------------------------------
         ORG     0
;
SavBuf   DEFS    1024
XBuf     DEFS    128
ParaBlk  DEFS    80
SFR      DEFS    74+2
TmpNam   DEFS    64
ClpNam   DEFS    64
ParCom   DEFS    50
Number   DEFS    6
;
Type     DEFS    L
Creator  DEFS    L
Flags    DEFS    W
Location DEFS    L
Folder   DEFS    W
Locked   DEFS    W
DataLen  DEFS    L
RsrcLen  DEFS    L
FlCrDat  DEFS    L
FlMdDat  DEFS    L
Length   DEFS    L
;
DialPtr  DEFS    L
TimeOut  DEFS    L
SavPtr   DEFS    L
SavLen   DEFS    L
RefCin   DEFS    W
RefCout  DEFS    W
MaxBlk   DEFS    W
Block    DEFS    W
ErrCnt   DEFS    W
XBPtr    DEFS    W
Srch     DEFS    W
XCRC     DEFS    W
Blk      DEFS    B
AbortFl  DEFS    B
F.First  DEFS    B
F.CRC    DEFS    B
F.Accel  DEFS    B
;
         DEFS    *&1
PrivSize EQU     *
*--------------------------------
         TFILE   "Buffer.Bin"
*--------------------------------
         RFILE   "TurboDL",DFIL,DMOV
*================================
         DO      Port=0
         RSRC    DRVR,28,resPurgeable,"@TurboDL-M"
         ELSE
         RSRC    DRVR,28,resPurgeable,"@TurboDL-P"
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
DskTitle STR     "Turbo-Download -- © 1985, Mainstay"
         ADJST
*--------------------------------
DskOpen  MOVEM.L A2-A4,-(SP)
         MOVE.L  A1,A4
         MOVE.L  GrafGlobals(A5),A0
         MOVE.L  thePort(A0),-(SP)
         MOVE.L  A6,-(SP)
         MOVE.L  #PrivSize,D0
         OST     NewPtr
         MOVE.L  A0,A6
         BSR     DnLoad
         MOVE.L  A6,A0
         OST     DisposPtr
         MOVE.L  (SP)+,A6
         MOVE.L  GrafGlobals(A5),A0
         MOVE.L  (SP)+,thePort(A0)
         MOVE.L  A4,A1
         MOVEM.L (SP)+,A2-A4
DskDone  MOVEQ   #0,D0
         RTS
*--------------------------------
DnLoad   MOVE.L  wBounds(PC),-(SP)
         PEA     Prompts(PC)
         PEA     DfltNam(PC)
         CLR.L   -(SP)
         PEA     SFR(A6)
         MOVE    #SFPutFile,-(SP)
         TBX     Pack3
         TST.B   SFR+Good(A6)
         BEQ     .4
         BSR     DeleteF
         BNE     .8
         LEA     SFR+fName(A6),A0
         LEA     TmpNam(A6),A1
         BSR     CopyStr
         BSR     Ropen
         BSR     Rread
         BNE     .7
         LEA     XBuf(A6),A0
         TST.B   0(A0)
         BNE     .9
         TST.B   74(A0)
         BNE     .9
         TST.B   82(A0)
         BNE     .9
         BSR     LdHdr
         BNE     .9
         BSR     DspNam
         BSR     GetInfo
         BNE.S   .0
         LEA     TmpNam(A6),A0
         LEA     SFR+fName(A6),A1
         BSR     CopyStr
         BRA.S   .1
.0       CMP     #-43,D7
         BNE     .7
.1       BSR     CreateF
         BNE     .6
         MOVE.L  Type(A6),32(A0)
         MOVE.L  Creator(A6),36(A0)
         MOVE    Flags(A6),40(A0)
         AND     #$F800,40(A0)
         MOVE.L  Location(A6),42(A0)
         MOVE    Folder(A6),46(A0)
         MOVE.L  FlCrDat(A6),72(A0)
         MOVE.L  FlMdDat(A6),76(A0)
         OST     SetFileInfo
         MOVE    16(A0),D7
         BNE.S   .6
         BSR     MaxBin
         ADDQ    #1,MaxBlk(A6)
         MOVEQ   #fsWrPerm,D0
         BSR     OpenData
         BNE.S   .5
         MOVE.L  DataLen(A6),Length(A6)
         BSR     GetBlk
         BNE.S   .5
         BSR     CloseF
         BNE.S   .5
         MOVEQ   #fsWrPerm,D0
         BSR     OpenRsrc
         BNE.S   .5
         MOVE.L  RsrcLen(A6),Length(A6)
         BSR     GetBlk
         BNE.S   .5
         BSR     CloseF
         BNE.S   .5
         MOVE.B  Locked(A6),D0
         AND.B   #$01,D0
         BEQ.S   .2
         BSR     SetLock
         BNE.S   .6
.2       BSR     Rread
         BEQ.S   .2
         CMP     #1,D7
         BEQ.S   .3
         BSR     Rabort
.3       BSR     Rclose
.4       RTS
.5       MOVE    D7,-(SP)
         BSR     CloseF
         MOVE    (SP)+,D7
.6       MOVE    D7,-(SP)
         BSR     DeleteF
         MOVE    (SP)+,D7
.7       MOVE    D7,-(SP)
         BSR     Rabort
         BSR     Rclose
         MOVE    (SP)+,D7
.8       BSR     DosErr
         RTS
.9       BSR     CreateF
         BNE.S   .15
         BSR     GetInfo
         BNE.S   .15
         MOVE.L  #$54455854,32(A0)       ;"TEXT"
         MOVE.L  #$3F3F3F3F,36(A0)       ;"????"
         OST     SetFileInfo
         MOVE    16(A0),D7
         BNE.S   .15
         MOVEQ   #fsWrPerm,D0
         BSR     OpenData
         BNE.S   .15
         BSR     InitS
         BRA.S   .11
.10      BSR     Rread
         BNE.S   .14
.11      LEA     XBuf(A6),A1
         MOVEQ   #128-1,D1
.12      MOVE.B  (A1)+,D0
         BEQ.S   .13
         CMP.B   #LF,D0
         BEQ.S   .13
         CMP.B   #SUB,D0
         BEQ.S   .13
         BSR     WriteS
         BNE.S   .15
.13      DBRA    D1,.12
         BRA.S   .10
.14      CMP     #1,D7
         BNE.S   .15
         BSR     FlshS
         BNE.S   .16
         BSR     CloseF
         BNE.S   .16
         BSR     Rclose
         RTS
.15      MOVE    D7,-(SP)
         BSR     Rabort
         MOVE    (SP)+,D7
.16      MOVE    D7,-(SP)
         BSR     CloseF
         BSR     DeleteF
         BSR     Rclose
         MOVE    (SP)+,D7
         BSR     DosErr
         RTS
*--------------------------------
LdHdr    LEA     XBuf+1(A6),A0
         MOVEQ   #3,D7
         CMP.B   #63,(A0)
         BHI.S   .1
         LEA     SFR+fName(A6),A1
         BSR     CopyStr
         LEA     XBuf+65(A6),A0
         LEA     Type(A6),A1
         MOVEQ   #34-1,D0
.0       MOVE.B  (A0)+,(A1)+
         DBRA    D0,.0
         CLR     D7
.1       RTS
GetBlk   BSR     InitS
.0       TST.L   Length(A6)
         BEQ.S   .3
.1       BSR     Rread
         BNE.S   .4
         MOVE.L  #128,D1
         CMP.L   Length(A6),D1
         BLS.S   .2
         MOVE.L  Length(A6),D1
.2       BSR     WriteX
         BNE.S   .4
         SUB.L   D1,Length(A6)
         BNE.S   .1
.3       BSR     FlshS
.4       RTS
CopyStr  CLR     D0
         MOVE.B  (A0),D0
.0       MOVE.B  (A0)+,(A1)+
         DBRA    D0,.0
         RTS
MaxBin   MOVE.L  DataLen(A6),D0
         ADD.L   #127,D0
         AND.L   #$FFFFFF80,D0
         MOVE.L  RsrcLen(A6),D1
         ADD.L   #127,D1
         AND.L   #$FFFFFF80,D1
         ADD.L   D1,D0
         ADD.L   #128,D0
         LSR.L   #7,D0
         MOVE    D0,MaxBlk(A6)
         RTS
*--------------------------------
Ropen    CLR.B   F.First(A6)
         CLR.B   F.Accel(A6)
         CLR.B   F.CRC(A6)
         CLR     MaxBlk(A6)
         CLR     Block(A6)
         BSR     BegXRcv
         RTS
Rread    ADDQ    #1,Block(A6)
.0       CLR     ErrCnt(A6)
.99      TST.B   F.First(A6)
         BNE.S   .1
         BSR     WaitQ
         MOVEQ   #NAK,D0
         TST.B   F.CRC(A6)
         BNE.S   .2
         MOVEQ   #'C,D0
         BRA.S   .2
.1       MOVEQ   #ACK,D0
         TST.B   F.Accel(A6)
         BNE.S   .2
         MOVE.B  #1,F.Accel(A6)
         BSR     Snd
         BSR     Snd
         BSR     Snd
         BSR     Snd
.2       BSR     Snd
.3       BSR     DRBlk
         MOVE    #160,Srch(A6)
         MOVEQ   #2,D0
         BSR     Recv
         BCC.S   .8
         CMP.B   #EOT,D0
         BNE.S   .4
         MOVEQ   #1,D7
         RTS
.4       CMP.B   #CAN,D0
         BNE.S   .7
.5       MOVEQ   #2,D7
         RTS
.6       MOVEQ   #1,D0
         BSR     Recv
         BCC.S   .8
.7       CMP.B   #SOH,D0
         BEQ.S   .10
         SUBQ    #1,Srch(A6)
         BNE.S   .6
.8       TST.B   AbortFl(A6)
         BNE.S   .5
         CMP     #2,ErrCnt(A6)
         BNE.S   .9
         TST.B   F.First(A6)
         BNE.S   .9
         MOVE.B  #1,F.CRC(A6)
.9       ADDQ    #1,ErrCnt(A6)
         CMP     #10,ErrCnt(A6)
         BLO     .99
         BRA.S   .5
.10      MOVE.B  #1,F.First(A6)
         MOVEQ   #1,D0
         BSR     Recv
         BCC.S   .8
         MOVE.B  D0,Blk(A6)
         MOVEQ   #1,D0
         BSR     Recv
         BCC.S   .8
         NOT.B   D0
         CMP.B   Blk(A6),D0
         BNE.S   .9
         CLR     XCRC(A6)
         CLR     XBPtr(A6)
.11      MOVEQ   #1,D0
         BSR     Recv
         BCC.S   .8
         LEA     XBuf(A6),A0
         MOVE    XBPtr(A6),D1
         MOVE.B  D0,0(A0,D1)
         TST.B   F.CRC(A6)
         BEQ.S   .12
         ADD.B   D0,XCRC(A6)
         BRA.S   .13
.12      BSR.S   .17
.13      ADDQ    #1,XBPtr(A6)
         CMP     #128,XBPtr(A6)
         BLO.S   .11
         TST.B   F.CRC(A6)
         BEQ.S   .14
         MOVEQ   #1,D0
         BSR     Recv
         BCC     .8
         CMP.B   XCRC(A6),D0
         BNE     .9
         BRA.S   .15
.14      MOVEQ   #1,D0
         BSR     Recv
         BCC     .8
         BSR.S   .17
         MOVEQ   #1,D0
         BSR     Recv
         BCC     .8
         BSR.S   .17
         TST     XCRC(A6)
         BNE     .9
.15      MOVE    Block(A6),D0
         CMP.B   Blk(A6),D0
         BNE.S   .16
         MOVEQ   #0,D7
         RTS
.16      SUBQ    #1,D0
         CMP.B   Blk(A6),D0
         BEQ     .0
         BRA     .5
.17      MOVE    XCRC(A6),D2
         MOVEQ   #8-1,D1
.18      LSL.B   #1,D0
         ROXL    #1,D2
         BCC.S   .19
         EOR     #$1021,D2
.19      DBRA    D1,.18
         MOVE    D2,XCRC(A6)
         RTS
Rabort   BSR     WaitQ
         MOVEQ   #CAN,D0
         BRA     Snd
Rclose   BSR     WaitQ
         MOVEQ   #ACK,D0
         BSR     Snd
         BRA     EndXRcv
*--------------------------------
BegXRcv
         DO      Port=0
         MOVE    #-6,RefCin(A6)
         MOVE    #-7,RefCout(A6)
         ELSE
         MOVE    #-8,RefCin(A6)
         MOVE    #-9,RefCout(A6)
         FIN
         LEA     ParCom(A6),A0
         MOVEQ   #50/2-1,D0
.0       CLR     (A0)+
         DBRA    D0,.0
         CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     wBounds(PC)
         PEA     NulStr(PC)
         MOVE.B  #1,-(SP)
         MOVE    #dBoxProc,-(SP)
         MOVE.L  #-1,-(SP)
         CLR.B   -(SP)
         CLR.L   -(SP)
         TBX     NewWindow
         MOVE.L  (SP),DialPtr(A6)
         TBX     SetPort
;
         MOVE    #sysFont,-(SP)
         TBX     TextFont
         MOVE    #12,-(SP)
         TBX     TextSize
         MOVE    #srcOr,-(SP)
         TBX     TextMode
         MOVE    #06,-(SP)
         MOVE    #38,-(SP)
         TBX     MoveTo
         PEA     DskTitle(PC)
         TBX     DrawString
         BSR     DspNam
         BSR     DRBlk
;
         CLR.B   AbortFl(A6)
;
         RTS
EndXRcv  MOVE.L  DialPtr(A6),-(SP)
         TBX     DisposWindow
         RTS
DspNam   LEA     .1(PC),A2
         LEA     SFR+fName(A6),A3
         BSR     ClipStr
         PEA     .0(PC)
         TBX     FrameRect
         PEA     .1(PC)
         TBX     EraseRect
         MOVE    #06,-(SP)
         MOVE    #15,-(SP)
         TBX     MoveTo
         MOVE.L  A3,-(SP)
         TBX     DrawString
         RTS
.0       DATA    /001,/001,/020,/303
.1       DATA    /002,/002,/019,/302
DRBlk    MOVE    MaxBlk(A6),D1
         BEQ.S   .0
         SUB     Block(A6),D1
         BCC.S   .1
         CLR     D1
         BRA.S   .1
.0       MOVE    Block(A6),D1
.1       BSR     DspNum
         PEA     .2(PC)
         TBX     FrameRect
         PEA     .3(PC)
         TBX     EraseRect
         MOVE    #266,-(SP)
         MOVE    #038,-(SP)
         TBX     MoveTo
         PEA     Number(A6)
         TBX     DrawString
         RTS
.2       DATA    /024,/261,/043,/303
.3       DATA    /025,/262,/042,/302
*--------------------------------
DspNum   MOVEQ   #4,D2
         LEA     .5(PC),A0
         LEA     Number(A6),A1
         CLR.B   (A1)+
         MOVEQ   #5,D4
.0       MOVEQ   #'0,D0
.1       MOVE    D1,D3
         SUB     (A0),D3
         BCS.S   .2
         MOVE    D3,D1
         ADDQ.B  #1,D0
         BRA.S   .1
.2       CMP.B   #'0,D0
         BNE.S   .3
         CMP.B   D4,D2
         BLO.S   .4
.3       MOVEQ   #5,D2
         MOVE.B  D0,(A1)+
         ADDQ.B  #1,Number(A6)
.4       ADDQ.L  #2,A0
         SUBQ.B  #1,D4
         BNE.S   .0
         RTS
.5       DATA    /10000,/1000,/100,/10,/1
ClipStr  MOVE.L  A3,A0
         LEA     ClpNam(A6),A1
         MOVE.L  A1,A3
         BSR     CopyStr
         MOVE    6(A2),D3
         SUB     2(A2),D3
         SUBQ    #8,D3
         CLR     -(SP)
         MOVE.L  A3,-(SP)
         TBX     StringWidth
         CMP     (SP)+,D3
         BGE.S   .2
         SUBQ.B  #1,(A3)
         CLR     -(SP)
         MOVE    #'…,-(SP)
         TBX     CharWidth
         SUB     (SP)+,D3
.0       CLR     -(SP)
         MOVE.L  A3,-(SP)
         TBX     StringWidth
         CMP     (SP)+,D3
         BGE.S   .1
         SUBQ.B  #1,(A3)
         BNE.S   .0
.1       ADDQ.B  #1,(A3)
         CLR     D0
         MOVE.B  (A3),D0
         MOVE.B  #'…,0(A3,D0)
.2       RTS
*--------------------------------
WaitQ    MOVEQ   #0,D0
         BSR     Recv
         BCS.S   WaitQ
         RTS
Recv     LSL     #2,D0
         MOVE.L  Ticks,D1
         ADD.L   TblTOut(PC,D0),D1
         MOVE.L  D1,TimeOut(A6)
.0       BSR     GtLen
         BNE.S   .1
         MOVE.L  Ticks,D0
         CMP.L   TimeOut(A6),D0
         BLO.S   .0
         AND     #$FE,CCR
         RTS
.1       BSR     Get1B
         OR      #1,CCR
         RTS
Snd      MOVEM.L D0,-(SP)
         BSR     Put1B
         MOVEM.L (SP)+,D0
         RTS
TblTOut  DATA    01*60,05*60,10*60
*--------------------------------
WriteX   LEA     XBuf(A6),A0
         MOVE.L  SavPtr(A6),A1
         MOVE.L  D1,D0
         BRA.S   .1
.0       MOVE.B  (A0)+,(A1)+
.1       DBRA    D0,.0
         MOVE.L  A1,SavPtr(A6)
         ADD.L   D1,SavLen(A6)
         MOVE.L  #1024,D0
         SUB.L   SavLen(A6),D0
         CMP.L   #128,D0
         BLO.S   FlshS
         CLR     D7
         RTS
WriteS   MOVE.L  SavPtr(A6),A0
         MOVE.B  D0,(A0)
         ADDQ.L  #1,SavPtr(A6)
         ADDQ.L  #1,SavLen(A6)
         CMP.L   #1024,SavLen(A6)
         BHS.S   FlshS
         CLR     D7
         RTS
FlshS    LEA     ParaBlk(A6),A0
         CLR.L   12(A0)
         MOVE    SFR+RefNum(A6),24(A0)
         PEA     SavBuf(A6)
         MOVE.L  (SP)+,32(A0)
         MOVE.L  SavLen(A6),36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         OST     Write
         MOVE    16(A0),D7
InitS    PEA     SavBuf(A6)
         MOVE.L  (SP)+,SavPtr(A6)
         CLR.L   SavLen(A6)
         TST     D7
         RTS
*--------------------------------
GtLen    LEA     ParCom(A6),A0
         MOVE    RefCin(A6),24(A0)
         MOVE    #2,26(A0)
         CLR.L   28(A0)
         OST     Status
         MOVE.L  28(A0),D0
         RTS
Get1B    LEA     ParCom(A6),A0
         MOVE    RefCin(A6),24(A0)
         CLR.B   -(SP)
         MOVE.L  A7,32(A0)
         MOVE.L  #1,36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         OST     Read
         MOVE.B  (SP)+,D0
         MOVE    16(A0),D7
         BNE.S   SysErr
         RTS
Put1B    LEA     ParCom(A6),A0
         MOVE    RefCout(A6),24(A0)
         MOVE.B  D0,-(SP)
         MOVE.L  A7,32(A0)
         MOVE.L  #1,36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         OST     Write
         MOVE.B  (SP)+,D0
         MOVE    16(A0),D7
         BNE.S   SysErr
         RTS
SysErr   MOVE    D0,-(SP)
         MOVE    #4,-(SP)
         OST     SysBeep
         MOVE    (SP)+,D0
         RTS
*--------------------------------
SetPar   LEA     ParaBlk(A6),A0
         CLR.L   12(A0)
         PEA     SFR+fName(A6)
         MOVE.L  (SP)+,18(A0)
         MOVE    SFR+vRefNum(A6),22(A0)
         MOVE.B  SFR+version+1(A6),26(A0)
         RTS
OpenData BSR     SetPar
         MOVE.B  D0,27(A0)
         CLR.L   28(A0)
         OST     Open
         MOVE    24(A0),SFR+RefNum(A6)
         MOVE    16(A0),D7
         RTS
OpenRsrc BSR     SetPar
         MOVE.B  D0,27(A0)
         CLR.L   28(A0)
         OST     OpenRF
         MOVE    24(A0),SFR+RefNum(A6)
         MOVE    16(A0),D7
         RTS
CloseF   LEA     ParaBlk(A6),A0
         CLR.L   12(A0)
         MOVE    SFR+RefNum(A6),24(A0)
         OST     Close
         MOVE    16(A0),D7
         BNE.S   .0
         CLR.L   18(A0)
         MOVE    SFR+vRefNum(A6),22(A0)
         OST     FlushVol
         MOVE    16(A0),D7
.0       RTS
CreateF  BSR     SetPar
         OST     Create
         MOVE    16(A0),D7
         RTS
DeleteF  BSR     GetInfo
         BEQ.S   .0
         CMP     #-43,D7
         BRA.S   .1
.0       MOVE    #-45,D7
         BTST    #7,40(A0)
         BNE.S   .1
         OST     Delete
         MOVE    16(A0),D7
.1       RTS
GetInfo  BSR     SetPar
         CLR     28(A0)
         OST     GetFileInfo
         MOVE    16(A0),D7
         RTS
SetLock  BSR     SetPar
         OST     SetFilLock
         MOVE    16(A0),D7
         RTS
DosErr   CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     .97(PC)
         PEA     NulStr(PC)
         MOVE.B  #1,-(SP)
         MOVE    #dBoxProc,-(SP)
         MOVE.L  #-1,-(SP)
         CLR.B   -(SP)
         CLR.L   -(SP)
         TBX     NewWindow
         MOVE.L  (SP),DialPtr(A6)
         TBX     SetPort
         PEA     .98(PC)
         CLR.L   -(SP)
         MOVE    #stopIcon,-(SP)
         TBX     GetIcon
         TBX     PlotIcon
         MOVE    #sysFont,-(SP)
         TBX     TextFont
         MOVE    #12,-(SP)
         TBX     TextSize
         MOVE    #srcOr,-(SP)
         TBX     TextMode
         MOVE    #72,-(SP)
         MOVE    #39,-(SP)
         TBX     MoveTo
         LEA     TErr(PC),A0
.0       MOVE.B  (A0)+,D0
         BEQ.S   .1
         EXT     D0
         CMP     D0,D7
         BEQ.S   .1
         CLR     D0
         MOVE.B  (A0)+,D0
         ADD     D0,A0
         BRA.S   .0
.1       MOVE.L  A0,-(SP)
         TBX     DrawString
         PEA     .99(PC)
         TBX     DrawString
         MOVE    #4,-(SP)
         OST     SysBeep
         LINK    A6,#-16
.2       CLR.B   -(SP)
         MOVE    #$000B,-(SP)
         PEA     -16(A6)
         TBX     GetNextEvent
         TST.B   (SP)+
         BEQ.S   .2
         MOVE    -16(A6),D0
         CMP     #1,D0
         BEQ.S   .3
         CMP     #3,D0
         BNE.S   .2
.3       UNLK    A6
         MOVE.L  DialPtr(A6),-(SP)
         TBX     DisposWindow
         RTS
.97      DATA    /070,/100,/140,/404
.98      DATA    /010,/020,/042,/052
.99      STR     " error."
         ADJST
*--------------------------------
ESTR     MACRO
         DATA    #]1
         STR     "]2"
         ENDM
*--------------------------------
TErr     ESTR    -33,"Directory full"
         ESTR    -34,"Disk full"
         ESTR    -35,"No such volume"
         ESTR    -36,"Disk I/O"
         ESTR    -39,"End of file"
         ESTR    -44,"Write protected diskette"
         ESTR    -45,"File locked"
         ESTR    -46,"Volume locked"
         ESTR    -47,"File busy"
         ESTR      3,"Bad name"
         ESTR      2,"Cancel"
         ESTR      1,"End Of Text"
         ESTR      0,"File system"
         ADJST
*--------------------------------
wBounds  DATA    /070,/100,/114,/404
NulStr   STR     ""
Prompts  STR     "Save document as:"
DfltNam  STR     "?"
*--------------------------------
         ENDR
*================================
         END
