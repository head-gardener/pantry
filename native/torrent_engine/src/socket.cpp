#include "socket.hpp"
#include "io.hpp"

#include <unistd.h>

void info_socket::listen(lt::session &session) {
  while (true) {

    std::vector<lt::alert *> alerts;
    session.pop_alerts(&alerts);

    for (lt::alert const *a : alerts) {
      /* log(io::INFO, a->message()); */
      /* if (lt::alert_cast<lt::torrent_finished_alert>(a)) { */
      /* } */
      /* if (lt::alert_cast<lt::torrent_error_alert>(a)) { */
      /* } */
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(200));
  }
}
