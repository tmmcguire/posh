use "lib:pony_unix"

use @isatty[Int](fd: Int) if posix
use @tcgetattr[Int](fd: Int, buf: Pointer[U8] tag) if posix
use @tcsetattr[Int](fd: Int, option_actions: Int, buf: Pointer[U8] tag)

use @sizeof_termios[SizeT]()
use @get_iflag[TcflagT](struct_termios: Pointer[U8] tag)
use @set_iflag[TcflagT](struct_termios: Pointer[U8] tag, flags: TcflagT)

type Int is I32
type UInt is U32
type SizeT is U64
type TcflagT is UInt

primitive Unistd
  fun isatty(fd: Int): Bool ? =>
    ifdef posix then
      return if @isatty[Int](fd) > 0 then true else false end
    else
      error
    end

primitive Termios
  fun sizeof_termios(): USize => @sizeof_termios[SizeT]().usize()

class TermiosStruct
  let _fd: Int
  let _struct: Array[U8]

  new create(fd: Int = 0) ? =>
    _fd = fd
    _struct = Array[U8].init(0, @sizeof_termios[SizeT]().usize())
    ifdef posix then
      if @tcgetattr[Int](_fd, _struct.cstring()) != 0 then
        error
      end
    else
      error
    end

  fun set_attributes(optional_actions: USize) ? =>
    ifdef posix then
      if @tcsetattr[Int](_fd, optional_actions.i32(), _struct.cstring())
          != 0 then
        error
      end
    else
      error
    end

  fun get_iflag(): USize =>
    @get_iflag[UInt](_struct.cstring()).usize()

  fun set_iflag(flags: USize): USize =>
    @set_iflag[UInt](_struct.cstring(), flags.u32()).usize()

  fun get_cflag(): USize =>
    @get_cflag[UInt](_struct.cstring()).usize()

  fun set_cflag(flags: USize): USize =>
    @set_cflag[UInt](_struct.cstring(), flags.u32()).usize()

  fun get_lflag(): USize =>
    @get_lflag[UInt](_struct.cstring()).usize()

  fun set_lflag(flags: USize): USize =>
    @set_lflag[UInt](_struct.cstring(), flags.u32()).usize()

primitive TermiosIFlag
  fun ignbrk(): USize => 0x0001
  fun brkint(): USize => 0x0002
  fun inpck():  USize => 0x0010
  fun istrip(): USize => 0x0020
  fun ixon():   USize => 0x0400
  // #define IGNPAR  0000004
  // #define PARMRK  0000010
  // #define INLCR   0000100
  // #define IGNCR   0000200
  // #define ICRNL   0000400
  // #define IUCLC   0001000
  // #define IXANY   0004000
  // #define IXOFF   0010000
  // #define IMAXBEL 0020000
  // #define IUTF8   0040000

primitive TermiosCFlag
  fun csize(): USize => 0x30
  fun cs5():   USize => 0x00
  fun cs6():   USize => 0x10
  fun cs7():   USize => 0x20
  fun cs8():   USize => 0x30

primitive TermiosLFlag
  fun icanon(): USize => 0x0002
  fun echo():   USize => 0x0008
  fun iexten(): USize => 0x8000
  // #define ISIG    0000001
  // #define ECHOE   0000020
  // #define ECHOK   0000040
  // #define ECHONL  0000100
  // #define NOFLSH  0000200
  // #define TOSTOP  0000400

primitive TermiosOptionAction
  fun tcsanow():   USize => 0x00
  fun tcsadrain(): USize => 0x01
  fun tcsaflush(): USize => 0x02
