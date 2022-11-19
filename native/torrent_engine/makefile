SOURCES = $(wildcard src/*.cpp)
OBJECTS = $(patsubst src/%.cpp, bin/%.o, $(SOURCES))
IMPORTS = -ltorrent-rasterbar
FLAGS = -Wall

build: $(OBJECTS) 
	g++ $(IMPORTS) $(FLAGS) $(OBJECTS) -o bin/torrent_engine

bin/main.o: src/main.cpp
	g++ -O3 -c $< -o $@

bin/%.o: src/%.cpp src/%.hpp
	g++ -O3 -c $< -o $@

clean:
	rm -rf bin/*

