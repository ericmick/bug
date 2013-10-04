class Brain
    constructor: (@code) ->
        @data = []
        @codePointer = 0
        @dataPointer = 0
        @output = []
    step: ->
        command = @code[@codePointer]
        if typeof command is 'undefined'
            return false
        Brain.commands[command].run.apply(this)
        @codePointer++
        true
    jump: (direction) ->
        level = 1
        loop
            @codePointer += direction
            command = @code[@codePointer]
            if typeof command is 'undefined'
                @codePointer -= direction
                break
            level += switch command
                when 5 then direction # [
                when 6 then -direction # ]
                else 0
            if level is 0
                break
    run: ->
        c = 0
        while @step()
            break if ++c > 10000
        @output
    number: ->
        @code = Brain.trim @code
        sum = 0
        power = 0
        for x in @code
            sum += Math.round(Math.pow(7, power)) * x 

Brain.mod = (x, y) ->
    switch
        when x is 0 then 0
        when x > 0 then x % y
        when x < 0 then (y + x % y) % y

#trim removes noops
Brain.trim = (code) ->
    for i in [code.length..0]
        code.splice(i, 1) if !code[i]
    code

Brain.permute = (code) ->
    code = code ? []
    () ->
        i = 0
        loop
            code[i] = (code[i] ? 0) + 1
            break if code[i] < Brain.commands.length
            code[i] = 1
            i++
        code.slice(0)

Brain.commands = [{
        symbol: ' ',
        run: ->
    },{
        symbol: '>',
        run: -> @dataPointer++
    },{
        symbol: '<',
        run: -> @dataPointer-- if @dataPointer > 0
    },{
        symbol: '+',
        run: ->
            @data[@dataPointer] = @data[@dataPointer] ? 0
            @data[@dataPointer]++
            @data[@dataPointer] %= Brain.commands.length
    },{
        symbol: '-',
        run: ->
            @data[@dataPointer] = @data[@dataPointer] ? 0
            @data[@dataPointer] = @data[@dataPointer] - 1
            @data[@dataPointer] = Brain.mod(@data[@dataPointer], Brain.commands.length)
    },{
        symbol: '[',
        run: ->
            value = @data[@dataPointer] ? 0
            if value is 0
                @jump 1
            else
                @dataPointer++
    },{
        symbol: ']',
        run: ->
            value = @data[@dataPointer] ? 0
            if value is 0
                @dataPointer++
            else
                @jump -1
    },{
        symbol: '.',
        run: -> @output.push @data[@dataPointer] ? 0
    }]

Brain.commandMap = {}
for command, value in Brain.commands
    Brain.commandMap[command.symbol] = value
Brain.encode = (symbol) -> Brain.commandMap[symbol]

Brain.compare = (a, b) ->
    if a.length isnt b.length
        return false
    for i in [0..a.length]
        if a[i] isnt b[i]
            return false
    true

Brain.read = (string) ->
    Brain.encode c for c in string

Brain.print = (code) ->
    strings = new Array(code.length)
    strings.push Brain.commands[x].symbol for x in code
    strings.join ''

Brain.fromNumber = (number) ->
    code = []
    numberOfCommands = Brain.commands.length - 1 #don't include no-op
    while number > 0
        c = number % numberOfCommands
        code.push(c + 1)
        number -= c
        number /= numberOfCommands
        number = Math.round(number)
    code

Brain.toNumber = (code) ->
    Brain.trim(code)
    place = 1
    number = 0
    numberOfCommands = Brain.commands.length - 1 #don't include no-op
    for c in code
        number += (c - 1) * place
        place *= numberOfCommands
    number

Brain.insert = (code, position, command) ->
    code.splice(position, 0, command)

Brain.randomCommand = ->
    Math.floor(Math.random() * Brain.commands.length)

Brain.randomPointer = (code, inclusive) ->
    Math.floor(Math.random() * (code.length + inclusive ? 1 : 0))

Brain.findQuine = (code) ->
    p = Brain.permute(code)
    $h1 = $('h1')
    if code
        x = Brain.toNumber(code)
    else
        x = 0
    f = () ->
        x++
        $h1.html x if x % 1000 is 0
        b = new Brain p()
        q = Brain.trim b.run()
        console.log q if Brain.compare b.code, q
        b = new Brain q
        setTimeout f, 0
    f()

(exports ? this).Brain = Brain