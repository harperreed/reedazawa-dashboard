class Dashing.Airnow extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.icon
      # reset classes
      $('i.icon').attr 'class', "icon icon-background #{data.icon}"

