var dependents=["verifayaandroid","verifayageneric","getelement"],_verifayaDeviceType=1,checkIfIncluded=function(b){for(var a=document.getElementsByTagName("link"),d=0;d<a.length;d++)if(a[d].href.substr(-b.length)==b)return!0;a=document.getElementsByTagName("script");for(d=0;d<a.length;d++)if(a[d].src.substr(-b.length)==b)return!0;return!1},installDependents=function(b){try{console.log("NdiVerifaya-VTE inside execJSOnVerifayaElement installation ");var a=document.createElement("script");a.setAttribute("type",
"text/javascript");a.setAttribute("src",b);a.setAttribute("id","verifaya"+b);document.getElementsByTagName("head")[0].appendChild(a);console.log("Completed NdiVerifaya-VTE execJSOnVerifayaElement installation ")}catch(d){console.log("NdiVerifaya-VTE execJSOnVerifayaElement installation err "+d.toString())}},setVerifayaDeviceType=function(b){_verifayaDeviceType=b},getVerifayaDeviceType=function(){return _verifayaDeviceType},getDependents=function(){return dependents.toString()},installJS=function(){for(var b=
"",a=0;a<dependents.length;a++)b=verifayaScriptBase+dependents[a]+".js",checkIfIncluded(b)||installDependents(b)},verifayaClearHelper=function(b){var a={status:!0};switch(getVerifayaElementType(b)){case "text":case "email":case "month":case "number":case "password":case "range":case "search":case "number":case "tel":case "time":case "url":case "week":case "textarea":try{b.get(0).value="",a.output="Clear successful"}catch(d){a.output=d.message,a.status=!1}break;case "select":try{var e=b.get(0);""==
e[0].textContent.trim()?e.selectedIndex=0:e.selectedIndex=-1;a.output="Clear successful"}catch(h){a.output="Action unsuccessful.",a.status=!1}break;default:a.output="Action not supported",a.status=!1}return a},clearVerifayaElement=function(b,a,d,e,h,l,m,n,p,q,r,s){var c={},f;c.tokenId=b;c.method="postCommandResult";c.status=!0;try{var g=getElement(a,d,e,h,l,m,n,p,q,r,s,!0);console.log(g);void 0==g?(console.log("element not found"),c.commandResponse="Object not found!",c.commandStatus=!1):g.is(":disabled")?
(c.commandResponse="Element is disable.",c.commandStatus=!1,console.log("Element is disable.")):(console.log("Element found to click"),f=verifayaClearHelper(g),f.status?(c.commandResponse=f.output,c.commandStatus=!0):(c.commandStatus=!1,c.commandResponse=f.output))}catch(k){console.log(k),c.commandStatus=!1,c.commandResponse="clearVerifayaElement not perform well. Exeception "+k}b=JSON.stringify(c);if(0==getVerifayaDeviceType())jQuery.ajax({type:"post",crossDomain:!0,url:verifayaResponseURL,contentType:"application/x-www-form-urlencoded",
data:b});else return b};
