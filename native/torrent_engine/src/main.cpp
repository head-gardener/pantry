#include "libtorrent/bencode.hpp"
#include "libtorrent/entry.hpp"
#include "libtorrent/session.hpp"
#include "libtorrent/torrent_info.hpp"

#include "json/json.h"

#include "io.hpp"
#include "socket.hpp"
#include <cstdio>
#include <iostream>
#include <libtorrent/error_code.hpp>
#include <sstream>
#include <string>
#include <unistd.h>

unsigned int id = 0;

int main(int argc, char *argv[]) try {
  setbuf(stdout, NULL);
  io::log(io::INFO, "started");
  lt::session s;

  auto socket = std::thread(&info_socket::listen, std::ref(s));
  socket.detach();

  while (true) {
    auto cmd = io::get();
    auto code = cmd.substr(0, 3);
    cmd = cmd.substr(4, cmd.length() - 1);

    // parse params
    Json::Value params;
    std::stringstream str(cmd);
    str >> params;

    if (code == "add") {
      lt::add_torrent_params p;
      p.save_path = params["save_path"].asString();
      p.ti =
          std::make_shared<lt::torrent_info>(params["torrent_info"].asString());

      auto handle = s.add_torrent(p);

      io::log(io::INFO, "added " + std::to_string(handle.id()));
    } else if (code == "ext") {
      break;
    } else {
      io::log(io::WARNING, "invalid command: " + cmd);
    }
  }

  io::log(io::INFO, "bye");
  return 0;
} catch (std::exception const &e) {
  io::log(io::CRITICAL, e.what());
  return 1;
}
