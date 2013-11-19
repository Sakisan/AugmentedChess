# CoffeeScript
(($) ->
  test = ->
    format_cells('.row1 td, .row2 td', 'white3')
    format_cells('.row3 td', 'white2')
    format_cells('.row4 td', 'white1')
    format_cells('.row5 td', 'black1')
    format_cells('.row6 td', 'black2')
    format_cells('.row7 td, .row8 td', 'black3')

  $(document).ready ->
    resize()
    test()
  $(window).resize ->
    resize()

  resize = ->
    cells = $('td')
    $(cell).height($(cell).width()) for cell in cells

  format_cells = (s, c) ->
    cells = $(s)
    $(cell).addClass(c) for cell in cells

) jQuery