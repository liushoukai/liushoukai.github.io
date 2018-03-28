const path = require('path');

module.exports = {
  entry: "./webpack/entry.js",
  output: {
	// output the generated files under the js folder so jekyll will grab it.
    path: path.resolve(__dirname, 'assets/js/'),
   	filename: 'bundle.js'
  }
};
