var connect = require('connect');
var path = require('path');
var tinyLr = require('tiny-lr');
var _ = require('lodash');

var serveStatic = require('serve-static');
var serveIndex = require('serve-index');

// Serve the compiled directory:
var base = 'www';

// and also the src directory:
var src = 'src';

var port = port || 3005;
var lrPort = lrPort || 31234;

connect()
  .use(require('connect-disable-304')())
  .use(require('connect-livereload')({ port: lrPort }))
  .use(serveStatic(path.resolve(base)))
  .use(serveStatic(path.resolve(src)))
  .use(serveIndex(path.resolve(base)))
  .listen(port);

lrServer = tinyLr();
lrServer.listen(lrPort);

function livereload(file) {
  lrServer.changed({ body: { files: [file] }});
  return _.size(lrServer.clients);
};

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

