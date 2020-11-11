# compile with:
# nim c -d:release --opt:speed -d:danger -r "more.nim"
import memfiles

template `[]`(mem: pointer, pos: uint32): char =
  cast[ptr char](cast[ByteAddress](mem) + pos.ByteAddress)[]

proc cnt*(fhm: Memfile): uint32 =
  ## fastest way (i found) to count sequences in a fasta file
  result = 0
  var lastWasNl = true
  var pos: uint32 = 0
  while true:
    if pos > fhm.size.uint32: break
    case fhm.mem[pos]
    of '\n':
      lastWasNl = true
    of '>':
      if lastWasNl: result.inc
    else:
      lastWasNl = false
    pos.inc

proc toString(fhm: MemFile, startPos, endPos: uint32): string {.inline.} =
  result = ""
  for idx in startPos..endPos:
    result.add fhm.mem[idx]

proc cntReport*(fhm: MemFile): uint32 =
  ## Reports sequences that contains a '>' somewhere in description.
  result = 0
  var lastWasNl = true
  var pos: uint32 = 0
  var line = 0
  var start: uint32 = 0
  var isWrong = false
  while true:
    if pos > fhm.size.uint32: break
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

proc cnt*(path: string): uint32 =
  var memfile = memfiles.open(path)
  result = memfile.cnt()
  memfile.close()

proc cntReport*(path: string): uint32 =
  var memfile = memfiles.open(path)
  result = memfile.cntReport()
  memfile.close()

type
  ReportChan = Channel[tuple[path: string, cnt: uint32]]
  ThreadParam = object
    path: string
    chan: ptr ReportChan

proc countThread(params: ThreadParam) = # {.thread, gcsafe.} =
  var memfile = memfiles.open(params.path)
  let nums = cnt(memfile)
  params.chan[].send (params.path, nums)
  # memfiles.close(memfile) # excepts SOMETIMES wtf

when isMainModule:
  import cligen
  import os
  import threadpool
  import cpuinfo
  var reportChan: ReportChan
  import json
  reportChan.open()

  proc count(paths: string, jsonl = false) =
    ## Counts sequences in fasta files,
    ## In contrast to "report" this is threaded and very fast.
    ## Usage:
    ##  fastalib count -p myFastaFile.fasta
    ##  fastalib count -p *.fasta
    var idx = 0
    for path in walkPattern(paths):
      spawn(countThread(ThreadParam(path: path, chan: addr reportChan)))
      idx.inc

    while idx > 0:
      let msg = reportChan.recv()
      if jsonl:
        let js = %* {
          "path": % msg.path.normalizedPath(),
          "cnt": % msg.cnt.int
        }
        echo ($ js)
      else:
        echo msg.cnt, "\t", msg.path.normalizedPath()
      idx.dec

  proc report(paths: string) =
    ## Reports sequences that contains a '>' somewhere in description.
    ## Usage:
    ##  fastalib report -p myFastaFile.fasta
    ##  fastalib report -p *.fasta
    for path in walkPattern(paths):
      var memfile = memfiles.open(path)
      echo cntReport(memfile) , "\t", path.normalizedPath()
      memfiles.close(memfile)

  dispatchMulti([count, help = {"jsonl": "Prints results as json line by line"}], [report])