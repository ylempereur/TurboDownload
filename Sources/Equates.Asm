;SAVE"Equates.Asm"
*================================
* Version 1.0          (11/05/86)
*================================
* Event Record
*--------------------------------
evtNum           .EQU 0
evtMessage       .EQU 2
evtTicks         .EQU 6
evtMouse         .EQU $A
evtMeta          .EQU $E
evtMBut          .EQU $F
evtBlkSize       .EQU $10
*--------------------------------
* I/O Record
*--------------------------------
ioQElSize        .EQU $32
ioVQElSize       .EQU $40
ioFQElSize       .EQU $50
;
ioLink           .EQU $0
ioType           .EQU $4
ioTrap           .EQU $6
ioCmdAddr        .EQU $8
ioCompletion     .EQU $C
ioResult         .EQU $10
ioFileName       .EQU $12
ioNamePtr        .EQU $12
ioVRefNum        .EQU $16
ioDrvNum         .EQU $16
ioRefNum         .EQU $18
ioFileType       .EQU $1A
ioVersNum        .EQU $1A
;
ioBuffer         .EQU $20
ioByteCount      .EQU $24
ioNumDone        .EQU $28
ioPosMode        .EQU $2C
ioPosOffset      .EQU $2E
;
ioReqCount       .EQU $24
ioActCount       .EQU $28
;
ioPermssn        .EQU $1B
ioOwnBuf         .EQU $1C
ioMisc           .EQU $1C
;
ioNewName        .EQU $1C
;
ioFDirIndex      .EQU $1C
ioFlAttrib       .EQU $1E
ioFFlType        .EQU $1F
ioFlUsrWds       .EQU $20
ioFlFndrInfo     .EQU $20
ioFFlNum         .EQU $30
ioDirID          .EQU $30
ioFlStBlk        .EQU $34
ioFlLgLen        .EQU $36
ioFlPyLen        .EQU $3A
ioFlRStBlk       .EQU $3E
ioFlRLgLen       .EQU $40
ioFlRPyLen       .EQU $44
ioFlCrDat        .EQU $48
ioFlMdDat        .EQU $4C
;
ioLEOF           .EQU $1C
;
ioNewType        .EQU $1C
;
ioVNPtr          .EQU $12
ioVDrvNum        .EQU $16
ioVolIndex       .EQU $1C
ioVCrDate        .EQU $1E
ioVLsBkUp        .EQU $22
ioVAtrb          .EQU $26
ioVNmFls         .EQU $28
ioVDirSt         .EQU $2A
ioVBlLn          .EQU $2C
ioVNmAlBlks      .EQU $2E
ioVAlBlkSiz      .EQU $30
ioVClpSiz        .EQU $34
ioAlBlSt         .EQU $38
ioVNxtFNum       .EQU $3A
ioVFrBlk         .EQU $3E
;
csCode           .EQU $1A
csParam          .EQU $1C
;
fdType           .EQU $0
fdCreator        .EQU $4
fdFlags          .EQU $8
fdLocation       .EQU $A
fdFldr           .EQU $E
*--------------------------------
fsAtMark         .EQU 0
fsFromStart      .EQU 1
fsFromLEOF       .EQU 2
fsFromMark       .EQU 3
rdVerify         .EQU $40
*--------------------------------
fsCurPerm        .EQU 0
fsRdPerm         .EQU 1
fsWrPerm         .EQU 2
fsRdWrPerm       .EQU 3
fsRdWrShPerm     .EQU 4
*--------------------------------
* Date-Time Record
*--------------------------------
dtYear           .EQU $0
dtMonth          .EQU $2
dtDay            .EQU $4
dtHour           .EQU $6
dtMinute         .EQU $8
dtSecond         .EQU $A
dtDayOfWeek      .EQU $C
*--------------------------------
* Resource Attributes
*--------------------------------
resSysRef        .EQU 128
resSysHeap       .EQU 64
resPurgeable     .EQU 32
resLocked        .EQU 16
resProtected     .EQU 8
resPreLoad       .EQU 4
resChanged       .EQU 2
*--------------------------------
* Standard Font ID's
*--------------------------------
sysFont          .EQU 0
applFont         .EQU 1
newYork          .EQU 2
geneva           .EQU 3
monaco           .EQU 4
venice           .EQU 5
london           .EQU 6
athens           .EQU 7
sanFran          .EQU 8
toronto          .EQU 9
cairo            .EQU 11
losAngeles       .EQU 12
times            .EQU 20
helvetica        .EQU 21
courier          .EQU 22
symbol           .EQU 23
mobile           .EQU 24
*--------------------------------
* Standard Window ID's
*--------------------------------
documentProc     .EQU 0
dBoxProc         .EQU 1
plainDBox        .EQU 2
altDBoxProc      .EQU 3
noGrowDocProc    .EQU 4
zoomDocProc      .EQU 8
zoomNoGrow       .EQU 12
rDocProc         .EQU 16
*--------------------------------
* Window Record
*--------------------------------
windowPort       .EQU 0
windowKind       .EQU $6C
wVisible         .EQU $6E
wHilited         .EQU $6F
wGoAway          .EQU $70
wZoom            .EQU $71
structRgn        .EQU $72
contRgn          .EQU $76
updateRgn        .EQU $7A
windowDef        .EQU $7E
wDataHandle      .EQU $82
wTitleHandle     .EQU $86
wTitleWidth      .EQU $8A
wControlList     .EQU $8C
nextWindow       .EQU $90
windowPic        .EQU $94
wRefCon          .EQU $98
windowSize       .EQU $9C
*--------------------------------
* Control Record
*--------------------------------
nextControl      .EQU $0
contrlOwner      .EQU $4
contrlRect       .EQU $8
contrlVis        .EQU $10
contrlHilite     .EQU $11
contrlValue      .EQU $12
contrlMin        .EQU $14
contrlMax        .EQU $16
contrlDefHandle  .EQU $18
contrlData       .EQU $1C
contrlAction     .EQU $20
contrlRFcon      .EQU $24
contrlTitle      .EQU $28
contrlSize       .EQU $28
*--------------------------------
* Text Edit Record
*--------------------------------
teDestRect       .EQU $0
teViewRect       .EQU $8
teSelRect        .EQU $10
teLineHite       .EQU $18
teAscent         .EQU $1A
teSelPoint       .EQU $1C
teSelStart       .EQU $20
teSelEnd         .EQU $22
teActive         .EQU $24
teWordBreak      .EQU $26
teClikProc       .EQU $2A
teClikTime       .EQU $2E
teClikLoc        .EQU $32
teCarTime        .EQU $34
teCarOn          .EQU $38
teCarAct         .EQU $39
teJust           .EQU $3A
teLength         .EQU $3C
teTextH          .EQU $3E
teRecBack        .EQU $42
teFlags          .EQU $42
teRecLine        .EQU $44
teLftClick       .EQU $46
teLftCaret       .EQU $47
teCROnly         .EQU $48
teFontStuff      .EQU $4A
teFont           .EQU $4A
teFace           .EQU $4C
teMode           .EQU $4E
teSize           .EQU $50
teGrafPort       .EQU $52
teHiHook         .EQU $56
teCarHook        .EQU $5A
teNLines         .EQU $5E
teLines          .EQU $60
teRecSize        .EQU $68
*--------------------------------
* Dialog/Alert Record
*--------------------------------
dWindow          .EQU $0
items            .EQU $9C
teHandle         .EQU $A0
editField        .EQU $A4
editOpen         .EQU $A6
aDefItem         .EQU $A8
dWindLen         .EQU $AA
*--------------------------------
* Item Record
*--------------------------------
itmHndl          .EQU $0
itmRect          .EQU $4
itmType          .EQU $C
itmData          .EQU $D
*--------------------------------
* Point Record
*--------------------------------
v                .EQU 0
h                .EQU 2
*--------------------------------
* Rectangle Record
*--------------------------------
topLeft          .EQU 0
botRight         .EQU 4
top              .EQU 0
left             .EQU 2
bottom           .EQU 4
right            .EQU 6
*--------------------------------
* Bitmap Record
*--------------------------------
baseAddr         .EQU 0
rowBytes         .EQU 4
bounds           .EQU 6
bitmapRec        .EQU 14
*--------------------------------
* Cursor Record
*--------------------------------
data             .EQU 0
mask             .EQU $20
hotSpot          .EQU $40
cursRec          .EQU 68
*--------------------------------
iBeamCursor      .EQU 1
crossCursor      .EQU 2
plusCursor       .EQU 3
watchCursor      .EQU 4
*--------------------------------
* PenState Record
*--------------------------------
psLoc            .EQU 0
psSize           .EQU 4
psMode           .EQU 8
psPat            .EQU 10
psRec            .EQU 18
*--------------------------------
* Polygon Record
*--------------------------------
polySize         .EQU 0
polyBBox         .EQU 2
polyPoints       .EQU 10
*--------------------------------
* Region Record
*--------------------------------
rgnSize          .EQU 0
rgnBBox          .EQU 2
rgnData          .EQU 10
*--------------------------------
* Picture Record
*--------------------------------
picSize          .EQU 0
picFrame         .EQU 2
picData          .EQU 10
*--------------------------------
* GrafPort Record
*--------------------------------
;device           .EQU $0
portBits         .EQU $2
portBounds       .EQU $8
portRect         .EQU $10
visRgn           .EQU $18
clipRgn          .EQU $1C
bkPat            .EQU $20
fillPat          .EQU $28
pnLoc            .EQU $30
pnSize           .EQU $34
pnMode           .EQU $38
pnPat            .EQU $3A
pnVis            .EQU $42
txFont           .EQU $44
txFace           .EQU $46
txMode           .EQU $48
txSize           .EQU $4A
spExtra          .EQU $4C
fgColor          .EQU $50
bkColor          .EQU $54
colrBit          .EQU $58
patStretch       .EQU $5A
picSave          .EQU $5C
rgnSave          .EQU $60
polySave         .EQU $64
grafProcs        .EQU $68
portRec          .EQU $6C
*--------------------------------
* QuickDraw Globals
*--------------------------------
GrafGlobals      .EQU 0
;
thePort          .EQU $0
white            .EQU $FFFFFFF8
black            .EQU $FFFFFFF0
gray             .EQU $FFFFFFE8
ltGray           .EQU $FFFFFFE0
dkGray           .EQU $FFFFFFD8
arrow            .EQU $FFFFFF94
screenBits       .EQU $FFFFFF86
randSeed         .EQU $FFFFFF82
grafSize         .EQU $CE
*--------------------------------
* Standard File Record
*--------------------------------
rGood            .EQU 0
rType            .EQU 2
rVolume          .EQU 6
rVersion         .EQU 8
rName            .EQU 10
*--------------------------------
* List Manager Record
*--------------------------------
rView            .EQU 0
;port             .EQU 8
indent           .EQU 12
cellSize         .EQU 16
visible          .EQU 20
vScroll          .EQU 28
hScroll          .EQU 32
selFlags         .EQU 36
lActive          .EQU 37
lReserved        .EQU 38
listFlags        .EQU 39
clikTime         .EQU 40
clikLoc          .EQU 44
mouseLoc         .EQU 48
lClikLoop        .EQU 52
lastClick        .EQU 56
refCon           .EQU 60
listDefHandle    .EQU 64
userHandle       .EQU 68
dataBounds       .EQU 72
cells            .EQU 80
maxIndex         .EQU 84
cellArray        .EQU 86
sizeList         .EQU 86
*--------------------------------
         END
