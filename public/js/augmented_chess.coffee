# CoffeeScript
(($) ->

  all_pieces = ['pawn', 'rook', 'knight', 'bishop', 'queen', 'king', 'no_piece']

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
    #$(cell).height($(cell).width()) for cell in cells
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
    pinned_pieces()
    colorize()
    $('#FEN').val(generate_fen())
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

  colorize = ->
    for i in [1..8]
      for j in [1..8]
        a = s('abcdefgh',j-1)
        cell = $('#pieces .'+i+' .'+a)
        pinned = cell.hasClass('pinned')
        if not pinned
          piece = get_piece_on(a, i)
          white = cell.hasClass('white')
          x = 'abcdefgh'.indexOf(a)+1
          eval(piece+'('+x+','+ i+','+ white+')')
    recolorize()

  recolorize = ->
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
        value_white = cell.find('input.white').val()
        value_black = cell.find('input.black').val()
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

  pawn = (x,i, white) ->
    y = if white then 1 else -1
    plus_one(x-1,i+y, white) if x-1 >= 1
    plus_one(x+1,i+y, white) if x+1 <= 8

  rook = (x,i,white) ->
    straight_plus(x, i, 1, 0, white)
    straight_plus(x, i, -1, 0, white)
    straight_plus(x, i, 0, 1, white)
    straight_plus(x, i, 0, -1, white)

  knight = (x,i,white) ->
    for q in [-1,1]
      for k in [-2,2]
        plus_one(x+q,i+k, white) if valid_xy(x+q, i+k)
    for q in [-2,2]
      for k in [-1,1]
        plus_one(x+q,i+k, white) if valid_xy(x+q, i+k)

  bishop = (x,i,white) ->
    straight_plus(x, i, 1, 1, white)
    straight_plus(x, i, -1, 1, white)
    straight_plus(x, i, 1, -1, white)
    straight_plus(x, i, -1, -1, white)

  queen = (x,i,white) ->
    straight_plus(x, i, 1, 0, white)
    straight_plus(x, i, -1, 0, white)
    straight_plus(x, i, 0, 1, white)
    straight_plus(x, i, 0, -1, white)
    straight_plus(x, i, 1, 1, white)
    straight_plus(x, i, -1, 1, white)
    straight_plus(x, i, 1, -1, white)
    straight_plus(x, i, -1, -1, white)

  king = (x,i,white) ->
    for q in [-1..1]
      for k in [-1..1]
        plus_one(x+q,i+k, white) if valid_xy(x+q, i+k) and !(q == 0 and k ==0)

  no_piece = (a,i,white) ->
    ''

  plus_one = (a,i,white) ->
    a = s('abcdefgh',a-1)
    cell = $('#colors .'+i+' .'+a)
    color = if white then "white" else "black"
    input = cell.find('input.'+color)
    cell_value = input.val()
    cell_value++
    input.val(cell_value)

  straight_plus = (x, i, dx, di, white) ->
    one_more = valid_xy(x+dx, i+di)
    while one_more
      x+=dx
      i+=di
      plus_one(x,i, white)
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

  # preferences checkboxes
  white_influence = $('#white_influence')
  black_influence = $('#black_influence')
  highlight_unprotected = $('#highlight_unprotected')

  white_influence.change ->
    process_preferences()

  black_influence.change ->
    process_preferences()

  highlight_unprotected.change ->
    process_preferences()

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

  the_end = 'end'
) jQuery