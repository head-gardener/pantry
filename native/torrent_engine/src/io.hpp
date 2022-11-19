#include <iostream>
#include <stdint.h>

namespace io {

enum priority { CRITICAL, WARNING, INFO };
enum priority1 { CRITICAL1, WARNING1, INFO1 };

void log(const priority p, const std::string &msg);
std::string get();

} // namespace io
