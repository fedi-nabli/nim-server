import asynchttpserver, asyncdispatch, os

import std/strutils

proc serveStaticFile*(req: Request, dir, filename: string) {.async.} =
  # exist -> have access -> can open
  let path = dir / filename

  # whether file exists
  if not fileExists(path):
    await req.respond(Http404, "File doesn't exist", newHttpHeaders())

  # whether has access to file
  var filePermission = getFilePermissions(path)
  if fpOthersRead notin filePermission:
    await req.respond(Http403, "You have no access to this file.", newHttpHeaders())

  # whether can open file
  try:
    let content = readFile(path)
    await req.respond(Http200, content, newHttpHeaders())
  except IOError:
    await req.respond(Http404, "404 Not Found", newHttpHeaders())

proc home(req: Request) {.async.} =
  await req.respond(Http200, "Hello World", newHttpHeaders())

proc printData() =
  echo "--- Memory Stats ---"
  echo "Occupied Mem (Heap): ", getOccupiedMem() div 1024, " KB"
  echo "Total Mem (Managed): ", getTotalMem() div 1024, " KB"
  echo "Free Mem (Reserved): ", getFreeMem() div 1024, " KB"
  echo "--------------------"

proc handler(req: Request) {.async.} =
  if req.url.path == "/":
    printData()
    await home(req)
  elif req.url.path == "/file":
    printData()
    await serveStaticFile(req, "docs", "file.txt")


var server = newAsyncHttpServer(maxBody = 131072)

waitFor server.serve(Port(8080), handler)
