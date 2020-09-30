# compile with:
# nim c -d:release --opt:speed -d:danger -r "more.nim"
import memfiles

template `[]`(mem: pointer, pos: uint): char =
  cast[ptr char](cast[ByteAddress](mem) + pos.ByteAddress)[]

proc cnt*(fhm: Memfile): uint =
  ## fastest way (i found) to count sequences in a fasta file
  result = 0
  var lastWasNl = true
  var pos: uint = 0
  while true:
    if pos > fhm.size.uint: break
    case fhm.mem[pos]
    of '\n':
      lastWasNl = true
    of '>':
      if lastWasNl: result.inc
    else:
      lastWasNl = false
    pos.inc

proc toString(fhm: MemFile, startPos, endPos: uint): string =
  result = ""
  for idx in startPos..endPos:
    result.add fhm.mem[idx]

proc cntReport*(fhm: MemFile): uint =
  ## Reports sequences that contains a '>' somewhere in description.
  result = 0
  var lastWasNl = true
  var pos: uint = 0
  var line = 0
  var start: uint = 0
  var isWrong = false
  while true:
    if pos > fhm.size.uint: break
    case cast[ptr char](cast[ByteAddress](fhm.mem) + pos.ByteAddress)[]
    of '\n':
      if isWrong:
        echo "[wrong] line:" , line, "\tpos:", pos , "\tstring:", fhm.toString(start, pos-1)
        isWrong = false
      lastWasNl = true
      start = pos + 1
      line.inc
    of '>':
      if lastWasNl: result.inc
      else:
        isWrong = true
    else:
      lastWasNl = false
    pos.inc

proc cnt*(path: string): uint =
  var memfile = memfiles.open(path)
  result = memfile.cnt()
  memfile.close()

proc cntReport*(path: string): uint =
  var memfile = memfiles.open(path)
  result = memfile.cntReport()
  memfile.close()

when isMainModule:
  import cligen
  import os

  proc count(paths: string) =
    ## Counts sequences in fasta files:
    ## Usage:
    ##  cntfasta mycnt -p myFastaFile.fasta
    ##  cntfasta mycnt -p *.fasta
    for path in walkPattern(paths):
      var memfile = memfiles.open(path)
      echo cnt(memfile) , "\t", path
      memfiles.close(memfile)

  proc report(paths: string) =
    ## Reports sequences that contains a '>' somewhere in description.
    for path in walkPattern(paths):
      var memfile = memfiles.open(path)
      echo cntReport(memfile) , "\t", path
      memfiles.close(memfile)

  dispatchMulti([count], [report])