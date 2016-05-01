#ifndef PONY_UNIX_H
#define PONY_UNIX_H

#include <termios.h>
#include <unistd.h>

size_t sizeof_termios();
tcflag_t get_iflag(struct termios *termios_p);
tcflag_t set_iflag(struct termios *termios_p, tcflag_t flags);

tcflag_t get_cflag(struct termios *termios_p);
tcflag_t set_cflag(struct termios *termios_p, tcflag_t flags);

tcflag_t get_lflag(struct termios *termios_p);
tcflag_t set_lflag(struct termios *termios_p, tcflag_t flags);

#endif /* PONY_UNIX_H */
