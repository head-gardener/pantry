SOURCES = $(wildcard src/*.cpp)
OBJECTS = $(patsubst src/%.cpp, bin/%.o, $(SOURCES))
IMPORTS = -ltorrent-rasterbar -ljsoncpp
CPPFLAGS ?= -Werror -O3

.PHONY: clean build

build: $(OBJECTS)
	g++ $(IMPORTS) $(CPPFLAGS) $(OBJECTS) -o bin/torrent_engine

bin/main.o: src/main.cpp
	g++ $(CPPFLAGS) -c $< -o $@

bin/%.o: src/%.cpp src/%.hpp
	g++ $(CPPFLAGS) -c $< -o $@

clean:
	rm -rf bin/*

