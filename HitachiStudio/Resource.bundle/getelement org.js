jQuery.expr[":"].verifayawithoutregex=function(c,b,a){b=a[3].split(",");var d=/^(data|css):/;a=b[0].match(d)?b[0].split(":")[0]:"attr";d=b.shift().replace(d,"");b.join("").replace(/^\s+|\s+$/g,"");return jQuery(c)[a](d)==b?!0:!1};jQuery.expr[":"].verifayawithregex=function(c,b,a){b=a[3].split(",");var d=/^(data|css):/;a=b[0].match(d)?b[0].split(":")[0]:"attr";d=b.shift().replace(d,"");return RegExp(b.join("").replace(/^\s+|\s+$/g,""),"ig").test(jQuery(c)[a](d))};
function isValueWithRegex(c){return void 0==c?!1:0<=c.toLowerCase().indexOf("regex:")?!0:!1}function getVerifayaValuePatterToFind(c){var b=c;try{!0==isValueWithRegex(c)&&(b=c.substring(6))}catch(a){}return b}
function scrollVEle(c,b,a,d){var h=a.get(0);if(verifayaNeedToScroll)try{0==getVerifayaDeviceType()?scrollVEleForAndi(c,b,a,d):scrollVEleForiOS(c,b,a,d)}catch(n){}else try{if(!1==elementInViewport(h)){try{a.get(0).focus()}catch(p){}try{a.get(0).scrollIntoView(!0)}catch(f){}if(!1==elementInViewport(h))try{0==getVerifayaDeviceType()?scrollVEleForAndi(c,b,a,d):scrollVEleForiOS(c,b,a,d)}catch(l){}}}catch(g){}try{sleep(1E3)}catch(m){}}
function scrollVEleForAndi(c,b,a,d){for(var h=0,h=0;2>h;h++){if(void 0!=b){try{b.focus()}catch(n){}try{c.find("html, body").animate({scrollTop:b.offset().top},100),c.find("html, body").animate({scrollLeft:b.offset().left},100)}catch(p){}try{c.find("html, body").delay(100).animate({scrollTop:b.offset().top},100),c.find("html, body").delay(100).animate({scrollLeft:b.offset().left},100)}catch(f){}}if(void 0!=a){try{a.focus()}catch(l){}try{d.find("html, body").animate({scrollTop:a.offset().top},100),
d.find("html, body").animate({scrollLeft:a.offset().left},100)}catch(g){}}try{sleep(500)}catch(m){}}}function scrollVEleForiOS(c,b,a,d){try{a.get(0).focus()}catch(h){}try{a.get(0).scrollIntoView(!0)}catch(n){}}
function isVerifayaElementFound(c,b,a){console.log("inside isVerifayaElementFound "+b+"  "+a);var d=void 0==b?!1:!0,h=void 0==a?!1:!0,n=!1,p=!1,f=!1,l=void 0,g=void 0;if(d)try{0<=b.toLowerCase().indexOf("regex:")&&(n=!0)}catch(m){}if(h)try{0<=a.toLowerCase().indexOf("regex:")&&(p=!0)}catch(r){}try{l=c.attr("name")}catch(s){l=void 0}try{var u=c.get(0).tagName,g=getElementTextByType(c,u),g=replaceSpecialChar(g,!1);a=replaceSpecialChar(a,!1)}catch(v){g=void 0}d?n?void 0!=l?(b=b.replace(/regex:/g,""),
RegExp(b,"m").test(l)&&(f=!0)):f=!1:f=void 0!=l?l==b?!0:!1:!1:f=!0;f&&(h?p?void 0!=g?(a=a.trim(),a=a.replace(/\\\\n/g,""),a=a.replace(/\\\\r/g,""),a=a.replace(/\\n/g,""),a=a.replace(/\\r/g,""),a=a.replace(/\[/g,"\\["),a=a.replace(/\]/g,"\\]"),a=a.replace(/\(/g,"\\("),a=a.replace(/\)/g,"\\)"),a=a.replace(/\{/g,"\\{"),a=a.replace(/\}/g,"\\}"),a=a.replace(/\./g,"."),a=a.replace(/\^/g,"^"),a=a.replace(/\$/g,"\\$"),a=a.replace(/\?/g,"\\?"),a=a.replace(/\*/g,"*"),a=a.replace(/\+/g,"\\+"),a=a.replace(/\\\\t/g,
""),a=a.replace(/\\\\f/g,""),a=a.replace(/\\\\v/g,""),a=a.replace(/\\\\b/g,""),a=a.replace(/\\\\B/g,""),a=a.replace(/\s/g,""),a=a.replace("????????","???"),a=a.replace("????","??"),console.log("Comparing actual text ######### elementTextValue "+g),c=a.toString().substring(6),console.log("Comparing Expecteddddddd text >>>>>>> expectedValue "+c),null!=g.match(RegExp(c))?(console.log("Element foundddddddddddd-------------------"),f=!0):(console.log("Element Nottttttttttttttt foundddddddddddd-------------------"),
f=!1)):f=!1:f=void 0!=g?g==a?!0:!1:!1:f=!0);return f}function isVerifayaElementMatchedByIndex(c,b,a){console.log("      isVerifayaElementMatchedByIndex regex: "+a+" expectedIndex: "+b+"  currentIndex: "+c);var d=!1;a?RegExp(b,"m").test(c)&&(d=!0):c==b&&(d=!0);console.log("isVerifayaElementMatchedByIndex isElementFound "+d);return d}
function getElement(c,b,a,d,h,n,p,f,l,g,m,r,s){try{if("webpage"==c)return isVerifayaTempObjectWebPage=!0,jQuery(document);isVerifayaTempObjectWebPage=!1;var u=null;verifayaParentObject=jQuery(document);initiatFindElementFromTop=!0;if(findElementByCustomTree()){var v,D,w,x;for(i=0;i<verifayaCommand.totalParents;i++){D=verifayaCommand["parent"+i].totalParams;v=verifayaCommand["parent"+i];w="";x=void 0;for(j=0;j<D;j++)try{w=w+'"'+v["p"+j]+'",'}catch(z){}w="getElementHelper("+w+"undefined)";console.log("Temp Command String "+
i+"  "+w);x=eval(w);if(void 0==x){console.log("element not found "+i);break}}void 0!=x&&(u=getElementHelper(c,b,a,d,h,n,p,f,l,g,m,r,s))}else console.log("finding element without custom tree"),u=getElementHelper(c,b,a,d,h,n,p,f,l,g,m,r,s),void 0!=u&&console.log("found element without custom tree");return u}catch(A){console.log("error in getElement "+A.toString())}}
function getElementHelper(c,b,a,d,h,n,p,f,l,g,m,r,s){try{var u=void 0==r||"vef"==r||!1==r?!1:!0,v=void 0==s||"vef"==s||!1==s?!1:!0,D=getVerifayaParentElement();console.log("in getElementHelper with parent "+D.get(0).tagName+"  targetElementScroll "+u+" getXY "+v);c=parseVerifayaParam(c);if("webpage"==c)return verifayaTempObject=jQuery(document),isVerifayaTempObjectWebPage=!0,setVerifayaParentEement(jQuery(document)),jQuery(document);b=parseVerifayaParam(b);a=parseVerifayaParam(a);d=parseVerifayaParam(d);
h=parseVerifayaParam(h);n=parseVerifayaParam(n);f=parseVerifayaParam(f);g=parseVerifayaParam(g);p=parseVerifayaParam(p);l=parseVerifayaParam(l);m=parseVerifayaParam(m);var w=!1,x=void 0==m?!1:!0;x&&(!0==isValueWithRegex(m)?(w=!0,m=getVerifayaValuePatterToFind(m)):m=isNaN(m)?-1:parseInt(m));x=x?-1==m?!1:!0:!1;c="webtable"==c||"webctable"==c?"table":c;isVerifayaTempObjectWebPage=!1;var z=0,A=s=r=!1,H=void 0==b?!1:!0,I=void 0==a?!1:!0;r=void 0==h?!1:!0;s=void 0==p?!1:!0;A=void 0==l?!1:!0;void 0==n&&
(r=!1);void 0==f&&(s=!1);void 0==g&&(A=!1);console.log(n+"   "+r+"  "+f+"  "+s+"  "+A);var e=void 0==d?!1:!0,J=I?isValueWithRegex(a):!1,K=r?isValueWithRegex(n):!1,L=s?isValueWithRegex(f):!1,M=A?isValueWithRegex(g):!1,N=H?isValueWithRegex(b):!1;"button"==c&&!0==e&&isValueWithRegex(d);isInputTypeText(c,h,n,p,f,l,g);var F=e="",t=null,y=!1,B,q=null,E,e=I?J?":verifayawithregex(id,"+getVerifayaValuePatterToFind(a)+")":":verifayawithoutregex(id,"+a+")":e,e=r?K?e+":verifayawithregex("+h+","+getVerifayaValuePatterToFind(n)+
")":e+":verifayawithoutregex("+h+","+n+")":e,e=s?L?e+":verifayawithregex("+p+","+getVerifayaValuePatterToFind(f)+")":e+":verifayawithoutregex("+p+","+f+")":e,e=A?M?e+":verifayawithregex("+l+","+getVerifayaValuePatterToFind(g)+")":e+":verifayawithoutregex("+l+","+g+")":e,e=H?N?e+":verifayawithregex(name,"+getVerifayaValuePatterToFind(b)+")":e+":verifayawithoutregex(name,"+b+")":e,e=""==e?"*":e;console.log("queryString "+e);var G=window.frames.length,k;if(0<G)try{var C=0;jQuery(document).find("iframe").each(function(){jQuery(this).contents().attr("verifayatracker",
"iframe"+C);jQuery(this).attr("verifayatracker","iframe"+C);C++});jQuery(document).find("frame").each(function(){jQuery(this).contents().attr("verifayatracker","frame"+C);jQuery(this).attr("verifayatracker","frame"+C);C++})}catch(P){G=0}F="button"==c?"input:button, input:submit, input:reset, input:button, input:file, button":"img"==c?"input:image, img":c;console.log("getElementHelper type="+F+" queryString="+e);D.find(F).filter(e).each(function(a){!y&&isVerifayaElementFound(jQuery(this),void 0,d)&&
(!0==x?isVerifayaElementMatchedByIndex(z,m,w)?(t=jQuery(this),y=!0,u&&scrollVEle(void 0,void 0,jQuery(this),jQuery(document)),v&&(sleep(100),k=t.get(0).getBoundingClientRect(),E=[Math.round(k.left),Math.round(k.top),Math.round(k.height),Math.round(k.width)])):z+=1:(t=jQuery(this),y=!0,u&&scrollVEle(void 0,void 0,jQuery(this),jQuery(jQuery(this).context)),v&&(sleep(100),k=t.get(0).getBoundingClientRect(),E=[Math.round(k.left),Math.round(k.top),Math.round(k.height),Math.round(k.width)])))});if(initiatFindElementFromTop&&
0<G&&!y)for(jframe=0;jframe<=G-1;jframe++){tempDoc=jQuery(window.frames[jframe].document);tempWindow=window.frames[jframe].window;if(y)break;tempDoc.find(F).filter(e).each(function(a){if(!y&&isVerifayaElementFound(jQuery(this),void 0,d))if(!0==x)if(m==z){t=jQuery(this);y=!0;B=tempDoc.attr("verifayatracker");q=jQuery(document).find('iframe[verifayatracker="'+B+'"]');try{0==q.size()&&(q=jQuery(document).find('frame[verifayatracker="'+B+'"]'))}catch(b){}u&&null!=q&&scrollVEle(jQuery(document),q,jQuery(this),
jQuery(jQuery(this).context));v&&(sleep(100),k=t.get(0).getBoundingClientRect(),E=[Math.round(k.left+q.get(0).getBoundingClientRect().left),Math.round(k.top+q.get(0).getBoundingClientRect().top),Math.round(k.height),Math.round(k.width)])}else z+=1;else{t=jQuery(this);y=!0;B=tempDoc.attr("verifayatracker");q=jQuery(document).find('iframe[verifayatracker="'+B+'"]');try{0==q.size()&&(q=jQuery(document).find('frame[verifayatracker="'+B+'"]'))}catch(c){}u&&null!=q&&scrollVEle(jQuery(document),q,jQuery(this),
jQuery(jQuery(this).context));v&&(sleep(100),k=t.get(0).getBoundingClientRect(),E=[Math.round(k.left+q.get(0).getBoundingClientRect().left),Math.round(k.top+q.get(0).getBoundingClientRect().top),Math.round(k.height),Math.round(k.width)])}})}void 0!=t&&setVerifayaParentEement(t);if(v)return console.log("returning getXYCoordOnly "+v+"  with positon "),E;console.log("\tgetElementHelper found "+t.get(0).tagName);console.log("\tgetElementHelper found "+t.text());return t}catch(O){console.log("error in getElement "+
O.toString())}};
