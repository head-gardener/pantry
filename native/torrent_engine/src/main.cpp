#include "libtorrent/bencode.hpp"
#include "libtorrent/entry.hpp"
#include "libtorrent/session.hpp"
#include "libtorrent/torrent_info.hpp"

#include "io.hpp"
#include <cstdio>
#include <iostream>
#include <libtorrent/error_code.hpp>
#include <string>
#include <unistd.h>

unsigned int id = 0;

int main(int argc, char *argv[]) try {
  setbuf(stdout, NULL);
  io::log(io::INFO, "hi");
  lt::session s;

  while (true) {
    auto cmd = io::get();
    auto code = cmd.substr(0, 3);
    cmd = cmd.substr(4, cmd.length() - 1);
    if (code == "add") {
      lt::add_torrent_params p;
      p.save_path = ".";
      p.ti = std::make_shared<lt::torrent_info>(cmd);

      s.add_torrent(p);

      io::log(io::INFO, "new torrent");
    /* } else if (code == "sts" ) { */
    /*   io::log(io::INFO) */
    } else if (code == "ext" ) {
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
