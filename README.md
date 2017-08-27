# angular-social-video-player
AngularJS directive that allow to display video player for youtube, dailymotion &amp; vimeo (maybe more to come)

## Table of contents

- [About](#about)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Documentation](#documentation)
- [Demo](#demo)
- [Build](#build)
- [License](#licence)

## About

This directive for AngularJS allow to use dynamically a webplayer for youtube, dailymotion or vimeo videos. Only specify provider and video id
When a video is played, paused, finished, the directive broadcast an event

## Dependencies

* [AngularJS](https://angularjs.org/) >= 1.4.9

## Installation

Install with bower:

```
bower install --save angular-social-video-player
```

Then add the source to your project

```html
<script src="bower_components/angular-social-video-player/dist/player.min.js" type="text/javascript"></script>
```

Add the module dependency in your AngularJS app

```javascript
angular.module('myApp', ['socialVideoPlayer']);
```

Then use the directive sv-player
```html
<div sv-player auto-play="false" height="530" width="830" pause="false" video-provider="youtube" video-id="DmFImtgjoWE"></div>
```

## Documentation

- An explanation of the properties:

  **height, width (required attributes)**
  - Size of the generated iFrame

  **video-provider (required attribute)**
  - can be 'youtube'/'google', 'daylimotion' or 'vimeo'

  **video-id (required attribute)**
  - id of the video, not the url

  **auto-play (optional attribute)**
  - if set to true, video will play automatically. Default to false

  **pause (optional attribute)**
  - if set to true, current video will stop (if running). Default to false
  - if the current video is paused and 'pause' is set to false, then the video will play


- Events emitted by the directive:

  **videoStarted** emitted when a video start and when a pause is finished
  ```javascript
  $scope.$on('videoStarted', function(event, currentTime) { ... });
  ```

  **videoPaused**
  ```javascript
  $scope.$on('videoPaused', function(event, currentTime) { ... });
  ```

  **videoFinished** usefull to load another video programmatically
  ```javascript
  $scope.$on('videoFinished', function(event, currentTime) { ... });
  ```

## Demo

Test it on jsfiddle!
* Youtube: https://jsfiddle.net/DrHelmut/n31y95ez/
* Dailymotion: https://jsfiddle.net/DrHelmut/2w6mycxy/

### Build
Use command `npm run build` to build (gulp) the project files in the dist folder

## License

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
