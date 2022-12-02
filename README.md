# Pantry

Distributed torrent client with asyncrhonous UI.

## Dependencies

Currently project only targets Linux systems.
BitTorrent sockets are powered by libtorrent-rasterbar library.
Make and g++ are needed to build C++ code.

## Usage

Pantry is split into servers and clients. Both can have multiple 
instances running and distributed over multiple physical machines. 
  - `Pantry.Server.Core.start_link/0` and `Pantry.Client.Core.start_link/0`
    are used to start instances. 
  - Clients and servers synchronize automatically once they see each other.
  - `Pantry.Server.Socket` can be used to controll a server.

