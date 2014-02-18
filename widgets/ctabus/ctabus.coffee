class Dashing.ctabus extends Dashing.Widget

  ready: ->
    Dashing.debugMode = true
    # This is fired when the widget is done being rendered

  onData: (data) ->
    #console.log('yay cta')
    #console.log(data)
    #$(@node).fadeOut().fadeIn()
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.