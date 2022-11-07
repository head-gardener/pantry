TARGETS =  src/main.cpp
IMPORTS = -ltorrent -I:/usr/lib/erlang/erts-13.0.4/include/

build: $(TARGETS)
	g++ -O3 -shared -fPIC $(IMPORTS) $(TARGETS) -o lib/libtorrent_nif.so

clean:
	rm -rf {bin,lib}/*

