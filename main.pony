use "collections"
use "net"

use @isatty[ISize](fd: ISize) if posix

actor Main
  new create(env: Env) =>
    env.out.print("hello, world")
    env.input(StdinReader(env))
    ifdef posix then
      env.out.print(@isatty[ISize](ISize(0)).string())
    end

class iso StdinReader is StdinNotify
  let _env: Env
  let _buf: Buffer = Buffer
  var _closed: Bool = false

  new iso create(env: Env) =>
    _env = env

  fun ref apply(data: Array[U8] iso) =>
    """
    Append data to a buffer until a legitimate eol is seen, then pass the line
    off to the executor and start a new buffer.
    """
    _env.out.write("apply " + data.size().string())
    try
      for i in Range(0, data.size()) do
        _env.out.write(" " + data(i).string())
      end
    end
    _env.out.print("")
    if _closed then
      return
    end
    // let data': Array[U8] val = consume data
    // let eol = _has_char(data', '\n')
    // _buf.append(data')
    // if eol then
    //   try
    //     _env.out.print(_buf.line())
    //   end
    // end
    // if _has_char(data', 4) then
    //   _env.input.dispose()
    //   _closed = true
    // end

  fun ref dispose() =>
    """
    Terminate the reader.
    """
    _env.out.print("dispose")
    while _buf.size() > 0 do
      try
        _env.out.print(_buf.line())
      end
    end
    None

  fun _has_char(data: Array[U8] box, ch: U8): Bool =>
    try
      for i in Range(0, data.size()) do
        if data(i) == ch then
          return true
        end
      end
    end
    false
