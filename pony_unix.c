#include "pony_unix.h"

size_t
sizeof_termios()
{
  return sizeof(struct termios);
}

tcflag_t
get_iflag(struct termios *termios_p)
{
  return termios_p->c_iflag;
}

tcflag_t
set_iflag(struct termios *termios_p, tcflag_t flags)
{
  unsigned int old = termios_p->c_iflag;
  termios_p->c_iflag = flags;
  return old;
}

tcflag_t
get_cflag(struct termios *termios_p)
{
  return termios_p->c_cflag;
}

tcflag_t
set_cflag(struct termios *termios_p, tcflag_t flags)
{
  unsigned int old = termios_p->c_iflag;
  termios_p->c_iflag = flags;
  return old;
}

tcflag_t
get_lflag(struct termios *termios_p)
{
  return termios_p->c_lflag;
}

tcflag_t
set_lflag(struct termios *termios_p, tcflag_t flags)
{
  unsigned int old = termios_p->c_lflag;
  termios_p->c_lflag = flags;
  return old;
}
