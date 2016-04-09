var server = require('livereload-static-server');
var livereload = server('www', 3005, 31235);

var watch = require('watch');

watch.watchTree('www', function(f, curr, prev) {
  if (typeof f == 'object' && prev === null && curr === null) {
    // Finished walking the tree
  } else {
    var file = f;// f.substring(4);
    livereload(file);
  } /*if (prev === null) {
    // f is a new file
  } else if (curr.nlink === 0) {
    // f was removed
  } else {
    // f was changed
  }*/
});

