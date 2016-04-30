use "term"
use "promises"

actor Main
  new create(env: Env) =>
    env.out.print("Use 'quit' to exit.")
    let handler = recover ReadlineHandler end
    handler.set_linehandler(LineHandler(env))
    let term = ANSITerm(Readline(consume handler, env.out), env.input)
    term.prompt("0 $ ")
    let notify = object iso
      let term: ANSITerm = term
      fun ref apply(data: Array[U8] iso) => term(consume data)
      fun ref dispose() => term.dispose()
    end
    env.input(consume notify)

class ReadlineHandler is ReadlineNotify
  let _commands: Array[String] = _commands.create()
  var _handler: (LineHandler tag | None) = None
  var _i: U64 = 0

  new create() =>
    _commands.push("quit")
    _commands.push("happy")
    _commands.push("hello")

  fun ref apply(line: String, prompt: Promise[String]) =>
    if line == "quit" then
      prompt.reject()
    else
      _i = _i + 1
      prompt(_i.string() + " $ ")
    end
    _update_commands(line)
    try
      (_handler as LineHandler)(line)
    end

  fun ref set_linehandler(handler: LineHandler tag) =>
    _handler = handler

  fun ref _update_commands(line: String) =>
    for command in _commands.values() do
      if command.at(line, 0) then
        return
      end
    end
    _commands.push(line)

  fun ref tab(line: String): Seq[String] box =>
    let r = Array[String]
    for command in _commands.values() do
      if command.at(line, 0) then
        r.push(command)
      end
    end

    r

actor LineHandler
  let _env: Env

  new create(env: Env) =>
    _env = env

  be apply(line: String) =>
    _env.out.print(line)
