use "collections"
use "net"

actor Main
  new create(env: Env) =>
    let is_tty = try Unistd.isatty(0) else false end
    if is_tty then
      try
        _reset_tty()
      else
        env.err.print("cannot reset tty")
      end
    end
    let promptor = Promptor(env.out, is_tty)
    promptor.ok()
    let reader = StdinReader(env, consume promptor)
    env.input(consume reader)

  fun _reset_tty() ? =>
    let t = TermiosStruct
    t.set_iflag(t.get_iflag() or TermiosIFlag.ixon())
    let lflag = t.get_lflag() or TermiosLFlag.echo() or TermiosLFlag.icanon()
      or TermiosLFlag.iexten()
    t.set_lflag(lflag)
    t.set_attributes(TermiosOptionAction.tcsaflush())

trait Acknowledgable
  be ok()

actor Promptor is Acknowledgable
  let _stream: StdStream
  let _is_tty: Bool

  new create(stream: StdStream, is_tty: Bool) =>
    _stream = stream
    _is_tty = is_tty

  be ok() =>
    _prompt()

  fun _prompt() =>
    if _is_tty then
      _stream.write("$ ")
    end

class iso StdinReader is StdinNotify
  let _buf: Buffer = Buffer
  let _filter: FilterStack

  new iso create(env: Env, acknowledgable: Acknowledgable tag) =>
    _filter = FilterStack(env.out, acknowledgable)

  fun ref apply(data: Array[U8] iso) =>
    """
    Append data to a buffer then pass the lines found off to the executor and
    remove them from the buffer.
    """
    _buf.append(consume data)
    while true do
      try
        _filter(_buf.line())
      else
        break
      end
    end

  fun ref dispose() =>
    """
    Terminate the reader, first passing off any existing buffer contents to the
    executor.
    """
    while _buf.size() > 0 do
      try
        _filter(_buf.line())
      else
        _buf.append(recover Array[U8].init('\n',1) end)
      end
    end

trait Filter
  fun apply(line: String)

class Printer is Filter
  let _stream: StdStream

  new create(stream: StdStream) =>
    _stream = stream

  fun apply(line: String) =>
    _stream.print(line)

class CommentRemover is Filter
  let _next: Filter

  new create(next: Filter) =>
    _next = next

  fun apply(line: String) =>
    let eol = try
      line.find("#")
    else
      line.size().isize()
    end
    if eol != 0 then
      _next(line.substring(0, eol))
    end

class Separator is Filter
  let _next: Filter

  new create(next: Filter) =>
    _next = next

  fun apply(line: String) =>
    let array: Array[String] = line.split(";")
    for cmd in array.values() do
      if cmd.size() > 0 then
        _next(cmd)
      end
    end

actor FilterStack
  let _filter: Filter
  let _ack: Acknowledgable tag

  new create(output: StdStream, acknowledgable: Acknowledgable tag) =>
    _filter = CommentRemover( Separator( Printer(output) ) )
    _ack = acknowledgable

  be apply(line: String) =>
    _filter(line)
    _ack.ok()
