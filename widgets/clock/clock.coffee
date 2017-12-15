class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today    = new Date()
    seconds = @formatTime(today.getSeconds())
    hours    = @getHours(today.getHours())
    minutes  = @formatTime(today.getMinutes())

    meridiem = @getMeridiem(today.getHours())
    @set('longtime', hours + ":" + minutes + ":" + seconds)

    @set('time', hours + ":" + minutes )
    @set('date', today.toDateString())


  getHours: (i) ->
    ((i + 11) %% 12) + 1

  getMeridiem: (i) ->
    if i < 12 then "AM" else "PM"

  formatTime: (i) ->
    if i < 10 then "0" + i else i