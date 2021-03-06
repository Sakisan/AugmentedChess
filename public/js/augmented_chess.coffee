# CoffeeScript
(($) ->

  all_pieces = ['no_piece', 'pawn', 'rook', 'knight', 'bishop', 'queen', 'king']

  piece_values = {}
  piece_values['no_piece'] = 0
  piece_values['pawn'] = 1
  piece_values['knight'] = 3
  piece_values['bishop'] = 3
  piece_values['rook'] = 5
  piece_values['queen'] = 9
  piece_values['king'] = 100

  fen_to_piece = {}
  fen_to_piece['p'] = 'black pawn'
  fen_to_piece['r'] = 'black rook'
  fen_to_piece['n'] = 'black knight'
  fen_to_piece['b'] = 'black bishop'
  fen_to_piece['q'] = 'black queen'
  fen_to_piece['k'] = 'black king'
  fen_to_piece['P'] = 'white pawn'
  fen_to_piece['R'] = 'white rook'
  fen_to_piece['N'] = 'white knight'
  fen_to_piece['B'] = 'white bishop'
  fen_to_piece['Q'] = 'white queen'
  fen_to_piece['K'] = 'white king'
  fen_to_piece['-'] = 'no_piece'

  $(document).ready ->
    style('#board tr:even td:odd, #pieces tr:even td:odd', 'darksquare')
    style('#board tr:even td:even, #pieces tr:even td:even', 'lightsquare')
    style('#board tr:odd td:even, #pieces tr:odd td:even', 'darksquare')
    style('#board tr:odd td:odd, #pieces tr:odd td:odd', 'lightsquare')
    load_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    resize()

  $(window).resize ->
    resize()

  resize = ->
    cells = $('td')
    $(cell).width($(cell).height()) for cell in cells

  # s = the jquery selector
  # c = the class to add
  style = (s, c) ->
    cells = $(s)
    $(cell).addClass(c) for cell in cells

  unstyle = (s, c) ->
    cells = $(s)
    $(cell).removeClass(c) for cell in cells

  disable_style = (c) ->
    cells = $('td.'+c)
    i = c.indexOf('-disabled')
    if i < 0
      for cell in cells
        $(cell).removeClass(c)
        $(cell).addClass(c+'-disabled')

  enable_style = (c) ->
    c = c+'-disabled'
    cells = $('td.'+c)
    i = c.indexOf('-disabled')
    if i > 0
      for cell in cells
        $(cell).removeClass(c)
        $(cell).addClass(c.substr(0,i))

  remove_all_pieces = ->
    unstyle('td.'+piece, piece) for piece in all_pieces
    unstyle('td.white', 'white')
    unstyle('td.black', 'black')
    unstyle('td.pinned', 'pinned')
    unstyle('td.unprotected', 'unprotected')
    unstyle('td.threat', 'threat')
    unstyle('td.check', 'check')
    $('#colors').find('input').each ->
      $(this).val(0)
    '?'

  current_fen = ""
  fen_back = new Array
  fen_forward = new Array

  $('#reset').click ->
    load_fen()

  $('#back').click ->
    if(fen_back.length > 0)
      fen = fen_back.pop()
      fen_forward.push(current_fen)
      current_fen = fen
      load_fen_no_history(fen)

  $('#forward').click ->
    if(fen_forward.length > 0)
      fen = fen_forward.pop()
      fen_back.push(current_fen)
      current_fen = fen
      load_fen_no_history(fen)

  load_fen = (fen) ->
    load_fen_no_history(fen)
    fen_back.push(current_fen)
    current_fen = fen

  load_fen_no_history = (fen) ->
    pattern = /\s*([rnbqkpRNBQKP12345678]+\/){7}([rnbqkpRNBQKP12345678]+)\s[bw-]\s(([kqKQ]{1,4})|(-))\s(([a-h][1-8])|(-))\s\d+\s\d+\s*/
    if !pattern.test(fen)
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    remove_all_pieces()
    fen_parts = fen.replace(/^\s*/, "").replace(/\s*$/, "").split(/\/|\s/)
    for j in [1..8]
      row = fen_parts[8-j].replace(/\d/g, replaceNumberWithDashes)
      for i in [1..8]
        style('#pieces .'+j+' .'+s('abcdefgh',i-1), fen_to_piece[s(row, i-1)])
    analyse()
    fen_input.val(generate_fen())
    process_preferences()

  # str is a number in string format
  replaceNumberWithDashes = (str) ->
    new_str = ''
    new_str+='-' for i in [1..parseInt(str)]
    new_str

  replaceDashesWithNumbers = (fen) ->
    replaced = ''
    n = 0
    for i in [0..fen.length]
      if s(fen, i) == '-'
        n++
      else
        if n > 0
          replaced += n
          n = 0
        replaced += s(fen, i)
    replaced

  s = (str, i) ->
    str.substr(i,1)

  analyse = ->
    for i in [1..8]
      for j in [1..8]
        a = s('abcdefgh',j-1)
        cell = $('#pieces .'+i+' .'+a)
        pinned = cell.hasClass('pinned') or cell.hasClass('pinned-disabled')
        if not pinned
          piece = get_piece_on(a, i)
          white = cell.hasClass('white')
          x = 'abcdefgh'.indexOf(a)+1
          eval(piece+'('+x+','+ i+','+ white+')')
    pinned_pieces()
    obvious_threats()
    colorize()

  obvious_threats = ->
    for i in [1..8]
      for j in [1..8]
        a = s('abcdefgh',j-1)
        color_cell = $('#colors .'+i+' .'+a)
        value_white = color_cell.find('.times > input.white').val()
        value_black = color_cell.find('.times > input.black').val()
        balance = parseInt(value_white) - parseInt(value_black)
        piece_cell = $('#pieces .'+i+' .'+a)
        # console.log(''+a+i+balance)
        if piece_cell.hasClass('white') && balance < 0
          color_cell.addClass('threat')
        if piece_cell.hasClass('black') && balance > 0
          color_cell.addClass('threat')

  colorize = ->
    unstyle('td.white1', 'white1')
    unstyle('td.white2', 'white2')
    unstyle('td.white3', 'white3')
    unstyle('td.black1', 'black1')
    unstyle('td.black2', 'black2')
    unstyle('td.black3', 'black3')
    for i in [1..8]
      for j in [1..8]
        a = s('abcdefgh',j-1)
        cell = $('#colors .'+i+' .'+a)
        piece_cell = $('#pieces .'+i+' .'+a)
        value_white = cell.find('.times > input.white').val()
        value_black = cell.find('.times > input.black').val()
        value = parseInt(value_white) - parseInt(value_black)
        cell.addClass(valueColor(value))
        if value is 0 and get_piece_on(a,i) != 'no_piece'
          style('#pieces .'+i+' td.'+a,'unprotected')
          style('#colors .'+i+' td.'+a,'unprotected')


  valueColor = (x) ->
    color = ''
    x = parseInt(x)
    if(x <= -3)
      color = 'black3'
    else if(x == -2)
      color = 'black2'
    else if(x == -1)
      color = 'black1'
    else if(x == 1)
      color = 'white1'
    else if(x == 2)
      color = 'white2'
    else if(x >= 3)
      color = 'white3'
    color

  get_piece_on = (a, i) ->
    cell = $('#pieces .'+i+' .'+a)
    myPiece = 'no_piece'
    for piece in all_pieces
      if cell.hasClass(piece)
        myPiece = piece
    myPiece

  get_color_piece_on = (a,i) ->
    cell = $('#pieces .'+i+' .'+a)
    color = "no_piece"
    if cell.hasClass "white"
      color = "white"
    if cell.hasClass "black"
      color = "black"
    color

  pawn = (x,i, white) ->
    y = if white then 1 else -1
    plus_one(x-1,i+y, white, 'pawn') if x-1 >= 1
    plus_one(x+1,i+y, white, 'pawn') if x+1 <= 8

  rook = (x,i,white) ->
    straight_plus(x, i, 1, 0, white, 'rook')
    straight_plus(x, i, -1, 0, white, 'rook')
    straight_plus(x, i, 0, 1, white, 'rook')
    straight_plus(x, i, 0, -1, white, 'rook')

  knight = (x,i,white) ->
    for q in [-1,1]
      for k in [-2,2]
        plus_one(x+q,i+k, white, 'knight') if valid_xy(x+q, i+k)
    for q in [-2,2]
      for k in [-1,1]
        plus_one(x+q,i+k, white, 'knight') if valid_xy(x+q, i+k)

  bishop = (x,i,white) ->
    straight_plus(x, i, 1, 1, white, 'bishop')
    straight_plus(x, i, -1, 1, white, 'bishop')
    straight_plus(x, i, 1, -1, white, 'bishop')
    straight_plus(x, i, -1, -1, white, 'bishop')

  queen = (x,i,white) ->
    straight_plus(x, i, 1, 0, white, 'queen')
    straight_plus(x, i, -1, 0, white, 'queen')
    straight_plus(x, i, 0, 1, white, 'queen')
    straight_plus(x, i, 0, -1, white, 'queen')
    straight_plus(x, i, 1, 1, white, 'queen')
    straight_plus(x, i, -1, 1, white, 'queen')
    straight_plus(x, i, 1, -1, white, 'queen')
    straight_plus(x, i, -1, -1, white, 'queen')

  king = (x,i,white) ->
    for q in [-1..1]
      for k in [-1..1]
        if valid_xy(x+q, i+k) and !(q == 0 and k ==0)
          plus_one(x+q,i+k, white, 'king')

  no_piece = (a,i,white) ->
    ''

  plus_one = (a,i,white, attacking_piece) ->
    # info
    a = s('abcdefgh',a-1)
    cell = $('#colors .'+i+' .'+a)
    color = if white then "white" else "black"
    other_color = if white then "black" else "white"
    # store how many times attacked
    times = cell.find('.times > input.'+color)
    times_value = times.val()
    times_value++
    times.val(times_value)
    # store trade potential
    trade = cell.find('.trade > input.'+color)
    trade_value = parseInt(trade.val())
    trade_value+=piece_values[attacking_piece]
    trade.val(trade_value)
    # report checks or threats
    attacked_piece = get_piece_on(a,i)
    piece_cell = $('#pieces .'+i+' .'+a)
    if attacked_piece is 'king'
      if(piece_cell.hasClass(other_color))
        cell.addClass('check')
    threat = piece_values[attacking_piece] < piece_values[attacked_piece]
    if threat && piece_cell.hasClass(other_color)
      cell.addClass('threat')

  straight_plus = (x, i, dx, di, white, piece) ->
    one_more = valid_xy(x+dx, i+di)
    while one_more
      x+=dx
      i+=di
      plus_one(x,i, white, piece)
      a = s('abcdefgh',x-1)
      one_more = valid_xy(x+dx, i+di) and continue_straight(a,i, white)

  continue_straight = (a, i, white) ->
    piece = get_piece_on(a, i)
    result = true
    if piece == 'king'
      cell = $('#pieces .'+i+' .'+a)
      white_king = cell.hasClass('white')
      result = (white_king and !white) or (!white_king and white)
    else result = piece == 'no_piece'
    result

  valid_xy = (x,y) ->
    x >= 1 and x <= 8 and y >= 1 and y <= 8

  getLetter = (cell) ->
    a = ""
    letters = ["a","b","c","d","e","f","g","h"]
    for letter in letters
      a = letter if $(cell).hasClass(letter)
    a


  getNumber = (cell) ->
    i = ""
    numbers = ["1","2","3","4","5","6","7","8"]
    for number in numbers
      i = number if $(cell).parent().hasClass(number)
    i

  pinned_pieces = ->
    black_cell = $('td.black.king')
    a = getLetter(black_cell)
    i = getNumber(black_cell)
    pinned_to_king(a,i, false)

    white_cell = $('td.white.king')
    a = getLetter(white_cell)
    i = getNumber(white_cell)
    pinned_to_king(a,i, true)

  pinned_to_king = (a,i, white) ->
    x = 'abcdefgh'.indexOf(a)+1
    i = parseInt(i)
    straight_pin(x, i, 1, 0, white, "rook")
    straight_pin(x, i, -1, 0, white, "rook")
    straight_pin(x, i, 0, 1, white, "rook")
    straight_pin(x, i, 0, -1, white, "rook")
    straight_pin(x, i, 1, 1, white, "bishop")
    straight_pin(x, i, -1, 1, white, "bishop")
    straight_pin(x, i, 1, -1, white, "bishop")
    straight_pin(x, i, -1, -1, white, "bishop")

  straight_pin = (x, i, dx, di, white_target, piece) ->
    second = 0
    one_more = valid_xy(x+dx, i+di)
    while one_more
      x+=dx
      i+=di
      if !continue_straight(s('abcdefgh',x-1),i, white_target)
        second++
        if second is 1
          pin_a = s('abcdefgh',x-1)
          pin_i = i
        pinned_color = get_color_piece_on(pin_a, pin_i)
        if pinned_color == "white" && !white_target
          second = 3
        if pinned_color == "black" && white_target
          second = 3

      one_more = valid_xy(x+dx, i+di) and second < 2

    if second is 2
      attacker = get_piece_on(s('abcdefgh',x-1),i)
      if attacker is piece or attacker is 'queen'
        cell = $('#pieces .'+i+' .'+s('abcdefgh',x-1))
        white_attacker = cell.hasClass('white')
        if white_attacker ^ white_target
          # (white_attacker and !white_target)
          # or (!white_attacker and white_target)
          pin(pin_a, pin_i)

  pin = (a,i) ->
    style('#pieces .'+i+' td.'+ a, 'pinned')

  fen_input = $('input#FEN')
  fen_input.keypress (e) ->
    if e.which is 13
      load_fen(fen_input.val())

  generate_fen = ->
    fen = ''
    # pieces
    for y in [0..7]
      i = 8 - y
      for x in [0..7]
        a = s("abcdefgh", x)
        fen+=piece_to_fen(a, i)
      fen += '/' if i != 1
    fen = replaceDashesWithNumbers(fen)
    # whose turn to play
    # don't care about this yet
    fen += ' w'
    # castling rights
    # don't care about this yet
    fen += ' -'
    # En passant
    # don't care about this yet
    fen += ' -'
    # halfmove clock
    # don't care about this yet
    fen += ' 1'
    # fullmove number
    # don't care about this yet
    fen += ' 1'
    fen

  piece_to_fen = (a, i) ->
    fen = ''
    cell = $('#pieces .'+i+' td.'+a)
    if(cell.hasClass('no_piece'))
      fen = '-'
    else
      if cell.hasClass('rook')
        fen = "r"
      if cell.hasClass('knight')
        fen = "n"
      if cell.hasClass('bishop')
        fen = "b"
      if cell.hasClass('queen')
        fen = "q"
      if cell.hasClass('king')
        fen = "k"
      if cell.hasClass('pawn')
        fen = "p"
      if cell.hasClass('white')
        fen = fen.toUpperCase()
    fen

  # Moving the pieces

  moving_a_piece = false
  moving_cell = null

  $('#pieces td').click ->
    if not moving_a_piece
      letter = getLetter(this)
      number = getNumber(this)
      piece = get_piece_on(letter,number)
      if piece != "no_piece" #and !$(this).hasClass("pinned")
        x = "abcdefgh".indexOf(letter)+1
        $(this).addClass("moving")
        moving_a_piece = true
        moving_cell = $(this)
    else #moving a piece
      if $(this).hasClass("moving")
        $(this).removeClass("moving")
        moving_a_piece = false
      else
        destination = $(this)
        moving_letter = getLetter(moving_cell)
        moving_number = getNumber(moving_cell)
        piece = get_piece_on(moving_letter, moving_number)
        color = if $(moving_cell).hasClass("white") then 'white' else 'black'
        remove_piece_on(moving_cell)
        moving_cell.addClass('no_piece')
        remove_piece_on(destination)
        destination.addClass(piece)
        destination.addClass(color)
        load_fen(generate_fen())
        moving_cell.removeClass('moving')
        moving_a_piece = false

  remove_piece_on = (cell) ->
    cell.removeClass(piece) for piece in all_pieces
    cell.removeClass('white')
    cell.removeClass('black')
    cell.removeClass('pinned')
    cell.removeClass('unprotected')

  # preference checkboxes
  white_influence = $('#white_influence')
  black_influence = $('#black_influence')
  highlight_unprotected = $('#highlight_unprotected')
  highlight_pinned = $('#highlight_pinned')
  highlight_checks = $('#highlight_checks')
  highlight_threats = $('#highlight_threats')

  white_influence.change ->
    preference_change()

  black_influence.change ->
    preference_change()

  highlight_unprotected.change ->
    preference_change()

  highlight_pinned.change ->
    preference_change()

  highlight_checks.change ->
    preference_change()

  highlight_threats.change ->
    preference_change()

  preference_change = ->
    load_fen_no_history(current_fen)

  process_preferences = ->
    if !white_influence.is(':checked')
      disable_style('white1')
      disable_style('white2')
      disable_style('white3')
    else
      enable_style('white1')
      enable_style('white2')
      enable_style('white3')
    if !black_influence.is(':checked')
      disable_style('black1')
      disable_style('black2')
      disable_style('black3')
    else
      enable_style('black1')
      enable_style('black2')
      enable_style('black3')
    if !highlight_unprotected.is(':checked')
      disable_style('unprotected')
    else
      enable_style('unprotected')
    if !highlight_pinned.is(':checked')
      disable_style('pinned')
    else
      enable_style('pinned')
    if !highlight_checks.is(':checked')
      disable_style('check')
    else
      enable_style('check')
    if !highlight_threats.is(':checked')
      disable_style('threat')
    else
      enable_style('threat')

  # List of saved FEN

  list_saved = $('#saved')
  save_name = $('#save_name')

  $('#save').click ->
    add_saved_fen(fen_input.val())

  add_saved_fen = (fen) ->
    n = 1
    while list_saved.find('#fen_'+n).length
      n++
    span = $('<span id="fen_'+n+'">')
    b = make_button(n)
    a = make_link(fen)
    span.append(a).append(b)
    list_saved.append(span)
    save_name.val('position '+n)

  make_button = (n) ->
    b = $('<button class="btn btn-default">')
    i = $('<span class="glyphicon glyphicon-remove">')
    b.append(i)
    b.click ->
      unsave(n)
    b

  make_link = (fen) ->
    a = $('<a class="fen" target="'+fen+'">').append(save_name.val())
    a.click ->
      load_fen($(this).attr('target'))
    a

  unsave = (n) ->
    list_saved.find('#fen_'+n).remove()

  $(document).ready ->
    $('#pgn-form').submit (event) ->
      event.preventDefault()
      pgn = $('#pgn-text').val()
      parsePGN(pgn)

  parsePGN = (pgn) ->
    pgn = $.trim(pgn).replace(/\n|\r/g, ' ').replace(/\s+/g, ' ')
    pgn = pgn.replace(/\{((\\})|([^}]))+}/g, '')
    pgn = /(1\. ?(N[acfh]3|[abcdefgh][34]).*)/m.exec(pgn)[1]
    pgn = pgn.replace(new RegExp("1-0|1/2-1/2|0-1"), '')
    pgn = pgn.replace(/^\d+\.+/, '')
    pgn = pgn.replace(/\s\d+\.+/g, ' ')
    moves = $.trim(pgn).split(/\s+/)
    fen_back = new Array
    fen_forward = new Array
    chess = new Chess()
    for move in moves
      chess.move move
      save_name.val move
      fen = chess.fen()
      add_saved_fen fen
      fen_forward.push fen
    fen_forward.reverse()
    $("#load-pgn-button").click()

  the_end = 'end'
) jQuery
