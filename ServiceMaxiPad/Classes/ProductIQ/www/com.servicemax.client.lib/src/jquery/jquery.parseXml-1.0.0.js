/**
 * Parse XML plugin
 *
 * Copyright (c) 2011 Indresh M S (indresh.ms@gmail.com)
 * 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * @version 1.0.0
 */

(function($) {

/**
 * The parseXml extension
 * 
 * @returns an instance of XML wrapper object
 */
$.parseXml = function(data, bHandleNamespaces) {
	var xmlDoc = new XMLObj(data, bHandleNamespaces);
	return xmlDoc;
};

/**
 * The wrapper XML Object
 * 
 * @param data the xml data either a string or xml document
 * @param bHandleNamespaces set this to true to manually identify the namespaces especially with I.E.
 */
function XMLObj(data, bHandleNamespaces) {
	this.xmlDoc = null;
	this.xmlData = data;
	this.namespaces = {};
	
	/**
	 * @private
	 */
	this.extractNamespaces = function (element){
		var nsURI = element.namespaceURI;
		var nsPrefix = element.prefix;
		
		if(nsPrefix && nsPrefix != "")
		this.namespaces[nsPrefix] = nsURI;
		
		var cn = element.childNodes;
		for(var cni=0; cni <cn.length; cni++){
			this.extractNamespaces(cn[cni]);
		}
	};
	
	/**
	 * returns the name of the element
	 * 
	 * @param element the xml element
	 * @returns the element's name
	 */
	this.getElementName = function(element){
		return element.nodeName;
	};
	
	/**
	 * Returns the first child element of this element
	 * 
	 * @param element the parent element
	 * @returns the first child if present, null otherwise
	 */
	this.getFirstChildElement = function(element){
		var ret  = null;
		var children = this.getChildElements(element);
		if(children && children.length > 0)
			ret = children[0];
		
		return ret;
	};
	
	/**
	 * Returns all the child nodes of type ELEMENT
	 * 
	 *  @param element the parent element
	 *  @returns all the child elements
	 */
	this.getChildElements = function(element){
		var ret = [];
		var cn = element.childNodes;
		
		// filter out only element nodes
		for(var i = 0; i < cn.length; i++){
			if(cn[i].nodeType == 1)		// 1 means Node.ELEMENT_NODE
				ret[ret.length] = cn[i];
		}
		return ret;
	};
	
	/**
	 * Returns the first element with a given name
	 * 
	 * @param tagName name of the element
	 * @param nameSpace the namespace, null if there is none
	 * @param parentElement the parent element
	 * @returns the first child matching the name if present, null otherwise
	 */
	this.getFirstElementByTagName = function(tagName, nameSpace, parentElement){
		var ret = this.getElementsByTagName(tagName, nameSpace, parentElement);
		if(ret && ret.length > 0)
			return ret[0];
		else
			return null;
	};
	
	/**
	 * Returns the all the elements with a given name
	 * 
	 * @param tagName name of the element
	 * @param nameSpace the namespace, null if there is none
	 * @param parentElement the parent element
	 * @returns all the child elements matching the name if present, null otherwise
	 */
	this.getElementsByTagName = function(tagName, nameSpace, parentElement){
		var ret = null;
		
		if(!parentElement)
			parentElement = this.documentElement;
		
		if ($.browser.msie) {
			var nsp = this.getPrefix4NS(nameSpace);
			if(nsp != "")
				tagName = nsp + ":" + tagName;
				
			ret = parentElement.getElementsByTagName(tagName);
		}
		else {
			if (!nameSpace) {
				ret = parentElement.getElementsByTagName(tagName);
			}
			else 
				ret = parentElement.getElementsByTagNameNS(nameSpace, tagName);
		}
		return ret;
	};
	
	/**
	 * Returns the attribute value as integer
	 * 
	 * @param name name of the attribute
	 * @param nameSpace the namespace, null if there is none
	 * @param element the parent element
	 * @return value of attribute if present, 0 otherwise
	 */
	this.getAttributeValueAsInt = function(name, nameSpace, element){
		var ret = this.getAttributeValue(name, nameSpace, element);
		if(ret)
			ret = parseInt(ret);
		else
			ret = 0;
		
		return ret;
	};
	
	/**
	 * Returns the attribute value as string
	 * 
	 * @param name name of the attribute
	 * @param nameSpace the namespace, null if there is none
	 * @param element the parent element
	 * @return value of attribute if present, null otherwise
	 */
	this.getAttributeValue = function(name, nameSpace, element){
		var ret = null;
		
		if(element){
			if($.browser.msie){
				var nsp = this.getPrefix4NS(nameSpace);
				if(nsp != "")
					name = nsp + ":" + name;
				
				ret = element.getAttribute(name);
			}else{
				if (!nameSpace) {
					ret = element.getAttribute(name);
				}
				else 
					ret = element.getAttributeNS(nameSpace, name);
			}
		}
		return ret;
	};
	
	// this will be used only when running in IE.
	/**
	 * @private
	 */
	this.getPrefix4NS = function(nameSpace){
		var ret = "";
		
		if(nameSpace && nameSpace != ""){
			for (var nsp in this.namespaces) {
				if (this.namespaces[nsp] == nameSpace) {
					ret = nsp;
					break;
				}
			}
		}
		return ret;
	};
	
	//TODO: Need a better way to identify the input - XML OR String
	var type = typeof(this.xmlData);
	if (type == "string") {
		if ($.browser.msie) {
			this.xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
			this.xmlDoc.async = "false";
			this.xmlDoc.loadXML(txt);
		}
		else {
			parser = new DOMParser();
			this.xmlDoc = parser.parseFromString(txt, "text/xml");
		}
	}else{
		this.xmlDoc = this.xmlData;
	}
	
	this.documentElement = this.xmlDoc.documentElement;
	
	if(!bHandleNamespaces)
		return;
	
	// IE has a problem that it does not support XML with namespaces. So, doing it manually
	this.extractNamespaces(this.xmlDoc.documentElement);
}

})(jQuery);