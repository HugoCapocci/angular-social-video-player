var gulp = require("gulp");
var coffee = require("gulp-coffee");
var uglify = require('gulp-uglify');
var rename = require("gulp-rename");
var stripDebug = require('gulp-strip-debug')
gulp.task("compileCoffee", function() {
  gulp.src(["./src/directive/*.coffee"]) // Read the files
    .pipe(
      coffee({bare:true}) // Compile coffeescript
        .on("error",  function(err) {
          console.error(err);
        })
      )
    .pipe(gulp.dest("./temp"));// Write complied to disk
    gulp.start("minify");
});

gulp.task("minify", function() {
  gulp.src(["./temp/*.js"])// Read the files
    .pipe(stripDebug()) // remove logs
    .pipe(uglify())                     // Minify
    .pipe(rename({extname: ".min.js"})) // Rename to ng-quick-date.min.js
    .pipe(gulp.dest("./dist")); // Write minified to disk
});

gulp.task("default", function() {
  gulp.start("compileCoffee");
});
