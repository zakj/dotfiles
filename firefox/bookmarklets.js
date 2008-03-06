// Display current images.
(function() {
    out = '';
    for (i = 0; img = document.images[i]; i++) {
        if (img.src) {
            out += '<img src="' + encodeURI(img.src) + '">';
        }
    }
    document.write(out);
    document.close();
})();
javascript:(function(){out='';for(i=0;img=document.images[i];i++){if(img.src){out+='<img src="'+encodeURI(img.src)+'">';}}document.write(out);document.close();})();


// Display linked images.
(function() {
    ext = {gif:1, jpg:1, jpeg:1, png:1, mng:1};
    out = '';
    for (i = 0; link = document.links[i]; ++i) {
        h = link.href;
        if (h && ext[h.substr(h.lastIndexOf('.') + 1).toLowerCase()]) {
            out += '<img src="' + encodeURI(h) + '">';
        }
    }
    document.write(out);
    document.close();
})();
javascript:(function(){ext={gif:1,jpg:1,jpeg:1,png:1,mng:1};out='';for(i=0;link=document.links[i];++i){h=link.href;if(h&&ext[h.substr(h.lastIndexOf('.')+1).toLowerCase()]){out+='<img src="'+encodeURI(h)+'">';}}document.write(out);document.close();})();


// Open linked images in tabs.
(function() {
    ext = {gif:1, jpg:1, jpeg:1, png:1, mng:1};
    for (i = 0; link = document.links[i]; ++i) {
        h = link.href;
        if (h && ext[h.substr(h.lastIndexOf('.') + 1).toLowerCase()]) {
            window.open(h, '_blank');
        }
    }
})();
(function(){ext={gif:1,jpg:1,jpeg:1,png:1,mng:1};for(i=0;link=document.links[i];++i){h=link.href;if(h&&ext[h.substr(h.lastIndexOf('.')+1).toLowerCase()]){window.open(h,'_blank');}}})();


// Google site search current site.
(function() {
    location.href = 'http://www.google.com/search?q=%s+site:' +
        location.hostname.split('.').slice(-2).join('.');
})();
javascript:(function(){location.href='http://www.google.com/search?q=%s+site:'+location.hostname.split('.').slice(-2).join('.');})();
