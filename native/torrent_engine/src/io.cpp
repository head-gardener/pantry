#include "io.hpp"
#include <iostream>
#include <stdint.h>

int is_big_endian(void) {
  union {
    uint32_t i;
    char c[4];
  } bint = {0x01020304};

  return bint.c[0] == 1;
}

uint32_t swapByteOrder(uint32_t ui) {
  ui = (ui >> 24) | ((ui << 8) & 0x00FF0000) | ((ui >> 8) & 0x0000FF00) |
       (ui << 24);
  return ui;
}

uint32_t read_packet_length(std::istream &s) {
  uint32_t len;
  s.read(reinterpret_cast<char *>(&len), sizeof(len));
  if (!is_big_endian())
    len = swapByteOrder(len);
  return len;
}

std::ostream &write_packet_length(std::ostream &s, uint32_t len) {
  if (!is_big_endian())
    len = swapByteOrder(len);
  s.write(reinterpret_cast<char *>(&len), sizeof(len));
  return s;
}

/*
 * Accepts message and it's priority, formats it and
 * prints to the standart output withouth buffering.
 */
void io::log(const io::priority p, const std::string &msg) {
  write_packet_length(std::cout, 4 + msg.length());
  /* fprintf(stderr, "\n(%i) %s\n", p, msg.c_str()); */
  printf("(%i) %s", p, msg.c_str());
  std::cout.flush();
}

std::string io::get() {
  uint32_t len = read_packet_length(std::cin);

  // read data, len bytes
  char *buf = new char[len];
  std::cin.read(buf, len);

  return std::string(buf);
}
