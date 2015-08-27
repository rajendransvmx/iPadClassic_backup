var DBAL = {};
(function(){
	var __db;
	DBAL.init = function(){
		try{
			__db = window.openDatabase("svmx", "1.0", "SVMX DB", 50000000);
			SVMX.getLoggingService().getLogger().info("Database opened successfully!");
		}catch(e){
			alert(e);
		}
	};
	
	DBAL.query = function(params){
		var params = params || {};
		var context = params.context || window;
		var query = params.query || "";
		var query2 = null;
		if(params.queryParams){
			query = SVMX.string.substitute(query, params.queryParams);
		}
	
		// multiple statements are not supported!
		if(query.indexOf("DROP TABLE") == 0){
			var index = query.indexOf(";");
			if(index > 0){
				query2 = query.substring(index + 1, query.length);
				query = query.substring(0, index);
			}
		}
	
		function onSuccess(tx, results){
			if(query2){
				runQuery(tx, query2);
				query2 = null;
				return;
			}
	
			var res = results;
			params.onSuccess.call(context, res);
		}
	
		function onTransaction(tx){
			runQuery(tx, query);
		}
	
		function runQuery(tx, query){
			tx.executeSql(query, [], onSuccess, onError);
		}
	
		function onError(err) {
			err.query = query;
			if(params.onError){
				params.onError.call(context, err);
			}else{
				alert("DBAL Error: "+err.code);
			}
			return false;
		}
		
		__db.transaction(onTransaction, onError);
	};
})();

DBAL.init();
