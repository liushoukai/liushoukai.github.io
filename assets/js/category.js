/**
 * 页面ready方法
 */
$(document).ready(function() {
    categoryDisplay();
});

/**
 * 分类展示
 * 点击右侧的分类展示时
 * 左侧的相关裂变展开或者收起
 * @return {[type]} [description]
 */
function categoryDisplay() {
    selectCategory();
    $('.categories-item').click(function() {
        window.location.hash = "#" + $(this).attr("cate");
        selectCategory();
    });
}

function selectCategory(){
    var cate = window.location.hash.substring(1);
    $("section[post-cate!='" + cate + "']").hide(200);
    $("section[post-cate='" + cate + "']").show(200);
    if (cate === 'All') {
        $("section[post-cate='all']").show(200);
        $("article").show(200);
    } else {
        $("article[curr-cate!='" + cate + "']").hide(200);
        $("article[curr-cate='" + cate + "']").show(200);
    }
}
