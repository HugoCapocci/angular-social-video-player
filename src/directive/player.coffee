app = angular.module('socialVideoPlayer', [])
YOUTUBE_API = 'https://www.youtube.com/iframe_api'
DAILYMOTION_API = 'https://api.dmcdn.net/all.js'

videoPlayer = ($document, $window, $timeout, $compile, $q) ->
  document = $document[0]
  player = {}
  isVimeoListener=false
  loadExternalAPIs = ->
    promise = null
    if typeof YT is 'undefined'
      promise = loadExternalAPI(YOUTUBE_API)
    if typeof DM is 'undefined'
      if not promise
        promise = loadExternalAPI(DAILYMOTION_API)
      else
        promise = promise.then(->
          loadExternalAPI(DAILYMOTION_API)
        )
    if not promise
      deferred = $q.defer()
      deferred.resolve()
      promise= deferred.promise
    promise

  loadExternalAPI = (src) ->
    deferred = $q.defer()
    element = null
    element = createElement(src)
    element.onload = element.onreadystatechange = (e) ->
      if element.readyState && element.readyState isnt 'complete' && element.readyState isnt 'loaded'
        return false
      $timeout ->
        deferred.resolve(e)
        return
      return
    element.onerror = (e) ->
      deferred.reject(e)
      return
    deferred.promise

  createElement = (src) ->
    script = document.createElement('script')
    script.src = src
    document.body.appendChild(script)
    console.log "script added: ", script
    script

  {
    restrict : 'AE'
    scope :
      videoId : '@videoId'
      videoProvider : '@videoProvider'
      autoPlay : '@autoPlay'
      width : '='
      height : '='
      pause : '@pause'

    link : (scope, element) ->

      createDailymotionPlayer = ->
        el = angular.element('<div id="videoPlayer"/>')
        $compile(el)(scope)
        element.children().remove()
        element.append(el)
        delete player.google
        if not DM
          console.log('DM playerNotLoaded')
        else
          player.dailymotion = DM.player document.getElementById("videoPlayer"),
            video: scope.videoId,
            width: scope.width,
            height: scope.height,
            params:
              autoplay: scope.autoPlay is 'true'
              mute: false
              api : '1'
          player.dailymotion.addEventListener "ended", ->
            scope.$emit('videoFinished')
          player.dailymotion.addEventListener "apiready", ->
            console.log("dailymotion player ready for API")
          player.dailymotion.addEventListener "playing", ->
            scope.$emit('videoStarted')
          player.dailymotion.addEventListener "pause", ->
            scope.$emit('videoPaused')
          if(scope.autoPlay isnt 'true')
            scope.$emit('videoPaused')

      createYoutubePlayer = ->
        el = angular.element('<div id="videoPlayer"/>')
        $compile(el)(scope)
        element.children().remove()
        element.append(el)
        delete player.dailymotion
        console.log("YT.loaded? ",YT.loaded)
        if not YT
          console.log('YT playerNotLoaded')
          $window.onYouTubePlayerAPIReady = onYouTubePlayerAPIReady
        else if YT.loaded
          onYouTubePlayerAPIReady()
        else
          YT.ready(onYouTubePlayerAPIReady)

      onYouTubePlayerAPIReady = ->
        player.google = new YT.Player document.getElementById("videoPlayer"),
          height : scope.height
          width : scope.width
          videoId : scope.videoId
          events :
            'onReady': (event) ->
              if scope.autoPlay is 'true'
                event.target.playVideo()
                scope.$emit('videoStarted')
              else
                scope.$emit('videoPaused')
            'onStateChange' : (event) ->
              switch (event.data)
                when 0 then scope.$emit('videoFinished')
                when 1 then scope.$emit('videoStarted')
                when 2 then scope.$emit('videoPaused')

      createVimeoPlayer = ->

        playerOrigin = '*'
        el = angular.element '<iframe id="videoPlayer" src="https://player.vimeo.com/video/'+scope.videoId+'?api=1&player_id=videoPlayer" width="'+scope.width+'" height="'+scope.height+'" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen/>'
        $compile(el)(scope)
        element.children().remove()
        element.append(el)
        player.vimeo = document.getElementById('videoPlayer')

        onMessageReceived = (event) ->
          #Handle messages for the vimeo player only
          if not(/^https?:\/\/player.vimeo.com/).test(event.origin)
            return false
          if playerOrigin is '*'
            playerOrigin = event.origin
          data = JSON.parse(event.data)
          switch (data.event)
            when 'ready' then onReady()
            when 'play' then scope.$emit('videoStarted')
            when 'pause' then scope.$emit('videoPaused')
            when 'finish' then scope.$emit('videoFinished')

        # Listen for messages from the player
        if not isVimeoListener
          if window.addEventListener
            window.addEventListener('message', onMessageReceived, false)
            isVimeoListener=true
          else
            window.attachEvent('onmessage', onMessageReceived, false)

        # Helper function for sending a message to the player
        post = (action, value) ->
          data =
            method: action
          if value
            data.value = value
          message = JSON.stringify(data);
          player.vimeo.contentWindow.postMessage(message, playerOrigin)

        player.vimeo.post = post

        onReady = ->
          post('addEventListener', 'pause')
          post('addEventListener', 'finish')
          post('addEventListener', 'play')
          #autoplay
          if scope.autoPlay is 'true'
            console.log 'autoplay is true'
            post('play')
          else
            scope.$emit('videoPaused')

        return

      loadExternalAPIs().then ->
        console.log("external script added and loaded")
        el = angular.element('<div id="videoPlayer"/>')
        $compile(el)(scope)
        element.append(el)
        switch scope.videoProvider
          when 'google', 'youtube' then createYoutubePlayer()
          when 'dailymotion' then createDailymotionPlayer()
          when 'vimeo' then createVimeoPlayer()

      scope.$watch 'videoProvider', (newValue, oldValue) ->
        if newValue is oldValue
          return
        switch newValue
          when 'google', 'youtube' then createYoutubePlayer()
          when 'dailymotion' then createDailymotionPlayer()
          when 'vimeo' then createVimeoPlayer()

      scope.$watch 'videoId', (newValue, oldValue) ->

        if newValue is oldValue
          return
        if scope.videoProvider is 'google' or scope.videoProvider is 'youtube'
          #console.log("load new google video")
          if not player.google or not player.google.loadVideoById
            createYoutubePlayer()
          else
            if scope.autoPlay is 'true'
              console.log("google autoplay TRUE")
              player.google.loadVideoById(scope.videoId)
            else
              console.log("google autoplay FALSE")
              player.google.cueVideoById(scope.videoId)
        else if scope.videoProvider is 'dailymotion'
          if not player.dailymotion
            createDailymotionPlayer()
          else
            player.dailymotion.load scope.videoId , {autoplay: scope.autoPlay is 'true'}
        else if scope.videoProvider is 'vimeo'
          createVimeoPlayer()
        else
          console.error(scope.videoProvider+" player not set ")

        if scope.autoPlay isnt 'true'
          $timeout ->
            scope.$emit('videoPaused')

      scope.$watch 'pause', (newValue, oldValue) ->
        if newValue is oldValue
          return
        switch scope.videoProvider
          when 'google','youtube'
            if newValue is 'true'
              player.google.pauseVideo()
            else
              player.google.playVideo()
          when 'dailymotion'
            if newValue is 'true'
              player.dailymotion.pause()
            else
              player.dailymotion.play()
          when 'vimeo'
            if newValue is 'true'
              player.vimeo.post('pause')
            else
              player.vimeo.post('play')

      scope.$on '$destroy', ->
        player = {}

      return
  }

app.directive 'svPlayer', ['$document', '$window', '$timeout', '$compile', '$q', videoPlayer]