// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .

function displayArticleList(jqXHR, textStatus, origURL) {
    if (textStatus != "success") {
        alert("failed to get articles: status: " + textStatus);
        return;
    }
    if (jqXHR.readyState < 4) {
        alert("jqXHR.readyState .. wait");
        return;
    }
    var s = [];
    
    var articles = jqXHR.responseJSON;
    var contentNode = document.getElementById("feedListContent");
    while (contentNode.lastChild) {
        contentNode.removeChild(contentNode.lastChild);
    }
    
    var ulElement = document.createElement("li");
    ulElement.setAttribute("class", "articles");
    var feed_id;
    var len = articles.length;
    if (len > 0) {
        var feed_id = articles[0].feed_id;
    }
    var lastSlash = origURL.lastIndexOf("/");
    baseURL = origURL.substring(0, lastSlash);
    for (var i = 0; i < len; i++) {
        var article = articles[i];
        
        var article_parts = ['getArticleContent(event, "',
                             baseURL + "/getArticleContent?guid=" + article.guid + "&feed_id=" + feed_id,
                             '");'];
        var linkElement = document.createElement("a");
        linkElement.setAttribute("href", article.link);
        linkElement.setAttribute("onclick", article_parts.join(''))
        linkElement.innerText = article.title;

        var boldElement = document.createElement("b");
        boldElement.appendChild(linkElement);

        var spanElement = document.createElement("span");
        spanElement.innerText = article.pubDate + ": ";

        var liElement = document.createElement("li");
        liElement.setAttribute("class", "article");
        liElement.appendChild(spanElement);
        liElement.appendChild(boldElement);
        ulElement.appendChild(liElement);
    }
    contentNode.appendChild(ulElement);
}

function getArticleList(event, url) {
    // alert("getArticleList for " + url);
    event.preventDefault();
    $.ajax(url, { complete: function(jqXHR, textStatus) { return displayArticleList(jqXHR, textStatus, url); } })
}

function goGetArticleContent(jqXHR, textStatus) {
    if (textStatus != "success") {
        alert("failed to get article content: status: " + textStatus);
        return;
    }
    if (jqXHR.readyState < 4) {
        alert("jqXHR.readyState .. wait");
        return;
    }
    var s = [];
    for (var p in jqXHR.responseJSON) {
        s.push(p);
    }
    if (jqXHR.responseJSON.content) {
        document.getElementById("currentArticleContent").innerHTML = jqXHR.responseJSON.content;
    } else {
        document.getElementById("currentArticleContent").innerHTML = "";
    }
}

function getArticleContent(event, url) {
    event.preventDefault();
    $.ajax(url, { complete: function(jqXHR, textStatus) { return goGetArticleContent(jqXHR, textStatus); } })
}
