var webpack = require('webpack');
var glob = require('glob');
var _ = require('lodash');

var entries = glob.sync('./src/+(containers|components|app|services)/**/*.js');
entries = _.reject(entries, function(entry) { return entry.match(/.*_tests?.js$/); });

module.exports = {
  entry: ['./src/app.js'].concat(entries),
  resolve: ['', '.json', '.jsx', '.js'],
  module: {
    loaders: [
      {
        test: /\.json$/,
        loaders: ['json-loader'],
      },
      {
        test: /\.(js|es6)$/,
        exclude: [/(node_modules)/],
        loader: 'babel',
        query: {
          presets: ['es2015','stage-0'],
        },
      },
    ],
  },
};
