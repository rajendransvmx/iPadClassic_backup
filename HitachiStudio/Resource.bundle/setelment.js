var dependents=["verifayaandroid","verifayageneric","getelement"],_verifayaDeviceType=1,checkIfIncluded=function(a){for(var b=document.getElementsByTagName("link"),c=0;c<b.length;c++)if(b[c].href.substr(-a.length)==a)return!0;b=document.getElementsByTagName("script");for(c=0;c<b.length;c++)if(b[c].src.substr(-a.length)==a)return!0;return!1},setVerifayaDeviceType=function(a){_verifayaDeviceType=a},getVerifayaDeviceType=function(){return _verifayaDeviceType},getDependents=function(){return dependents.toString()},
installDependents=function(a){try{console.log("NdiVerifaya-VTE inside execJSOnVerifayaElement installation ");var b=document.createElement("script");b.setAttribute("type","text/javascript");b.setAttribute("src",a);b.setAttribute("id","verifaya"+a);document.getElementsByTagName("head")[0].appendChild(b);console.log("Completed NdiVerifaya-VTE execJSOnVerifayaElement installation ")}catch(c){console.log("NdiVerifaya-VTE execJSOnVerifayaElement installation err "+c.toString())}},installJS=function(){for(var a=
"",b=0;b<dependents.length;b++)a=verifayaScriptBase+dependents[b]+".js",checkIfIncluded(a)||(installDependents(a),console.log("Installinggg  Verifaya Script  >> "+a))},setProperty=function(a,b,c,e,f,g,h,k,l,m,n,p,q){var d={};b=getElement(b,c,e,f,g,h,k,l,m,n,p);if(void 0!=b){c=[];try{c=q.split(","),b.attr(c[0],c[1]),d.commandResponse="Set Property Successfull",d.commandStatus=!0}catch(r){d.commandResponse=r,d.commandStatus=!1}}else d.commandResponse="Element not found",d.commandStatus=!1;d.method=
"postCommandResult";d.status=!0;d.tokenId=a;a=JSON.stringify(d);if(0==getVerifayaDeviceType())jQuery.ajax({type:"post",crossDomain:!0,url:verifayaResponseURL,contentType:"application/x-www-form-urlencoded",data:a});else return a};
