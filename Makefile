
.PHONY = all

all: server.nim
	nim c -d:release -d:lto -d:strip --mm:orc server.nim
