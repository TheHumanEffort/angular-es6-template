var gulp = require('gulp'),
    connect = require('gulp-connect'),
    watch = require('gulp-watch');

gulp.task('webserver', function() {
  connect.server({
    livereload: true,
    port: 3000,
    root: ['www'],
  });
});

/*gulp.task('livereload', function() {
  gulp.src(['www/** /*'])
    .pipe(watch())
    .pipe(connect.reload());
});
*/

gulp.task('default', ['webserver']);
