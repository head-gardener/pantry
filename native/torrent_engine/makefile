SOURCES = $(wildcard src/*.cpp)
OBJECTS = $(patsubst src/%.cpp, bin/%.o, $(SOURCES))
IMPORTS = -ltorrent-rasterbar -ljsoncpp
FLAGS = -Wall

build: $(OBJECTS) bin
	g++ $(IMPORTS) $(FLAGS) $(OBJECTS) -o bin/torrent_engine

bin/main.o: src/main.cpp bin
	g++ -O3 -c $< -o $@

bin/%.o: src/%.cpp src/%.hpp bin
	g++ -O3 -c $< -o $@

bin:
	mkdir bin

clean:
	rm -rf bin/*

