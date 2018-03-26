import marked from 'marked';


var resume = require("html-loader!./resume.md");
function render(markdown) {
    //return marked('# Marked in browser\n\nRendered by **marked**.');
    return marked(markdown);
}
document.getElementById('content').innerHTML = render(resume);
