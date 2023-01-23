# Pantry

Distributed torrent client with asyncrhonous UI.

- **works**: kind of but not yet really
- **overengineered**: beyond belief 🔥
- **features**: no
- **async**: yes

## Dependencies

Currently project only targets Linux systems.
BitTorrent sockets are powered by libtorrent-rasterbar library.
Make and g++ are needed to build C++ code.

## Usage

Pantry is split into servers and clients. Both can have multiple 
instances running and distributed over multiple physical machines. 
  - `PantryServer.Application.start/0` and `PantryClient.Application.start/0`
    are used to start instances. 
  - Clients and servers synchronize automatically once they see each other.
  - `PantryServer.Socket` can be used to controll a server.

