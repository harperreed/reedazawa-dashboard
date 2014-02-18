class Dashing.BigImage extends Dashing.Widget

    resizeImage = ($img, maxWidth, maxHeight, maximize) ->
        width = $img.width()
        height = $img.height()

        if maximize or (width > maxWidth) or (height > maxHeight)
            if width > height
                ratio = maxWidth / width
                $img.css("width", maxWidth)
                $img.css("height", height * ratio)
            else
                ratio = maxHeight / height
                $img.css("width", width * ratio)
                $img.css("height", maxHeight)

    getImageSize = ($img, done) ->
        loadedHandler = ->
            $img.off 'load', loadedHandler
            done $img.width(), $img.height()

        img = $img[0]
        if !img.complete
            # Wait for the image to load
            $img.on 'load', loadedHandler
        else
            # Image is already loaded.  Call the loadedHandler.
            sleep 0, loadedHandler

    sleep = (timeInMs, fn) -> setTimeout fn, timeInMs

    ready: ->
        container = $(@node).parent()
        @maxWidth = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
        @maxHeight = (Dashing.widget_base_dimensions[1] * container.data("sizey"))
        draw this

    onData: (data) ->
        return if !@maxWidth or !@maxHeight
        draw this

    draw = (self) ->
        $el = $(self.node)
        $img = $(self.node).find('img')

        # Load the image
        $img.remove()
        $img = $('<img src="' + self.get("image") + '"/>')
        $el.append $img

        # Resize the image
        getImageSize $img, (width, height) =>
            resizeImage $img, self.maxWidth, self.maxHeight, self.get 'max'
