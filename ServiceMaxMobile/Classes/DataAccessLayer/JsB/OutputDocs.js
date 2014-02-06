
var templateData = null;
var docMetaData = null;
var docData = null;
var userInfoData = null;

function GetTemplate(processIdObj, callbackFunction, context)
{
    templateData = {Input:processIdObj, Callback:callbackFunction, Context:context};
    StartOutputDocDataRetrieval();
}

function GetDocumentMetadata(processIdObj, callbackFunction, context)
{
    docMetaData = {Input:processIdObj, Callback:callbackFunction, Context:context};
    StartOutputDocDataRetrieval();
}

function GetDocumentData(inputObj, callbackFunction, context)
{
    docData = {Input:inputObj, Callback:callbackFunction, Context:context};
    StartOutputDocDataRetrieval();
}

function GetUserInfo(request, callbackFunction, context)
{
    userInfoData = {Input:request, Callback:callbackFunction, Context:context};
    StartOutputDocDataRetrieval();
}

function StartOutputDocDataRetrieval()
{
    if(userInfoData != null && templateData != null && docMetaData != null && docData != null)
    {
        OPDGetUserInfo(userInfoData.Input, userInfoData.Callback, userInfoData.Context);
    }
}

function OPDGetTemplate(processIdObj, callbackFunction, context){
  
  var processId = processIdObj.ProcessId;
  
  var objectName = "SFProcess";
  var fieldNames = [{fieldName:'process_id',fieldType:'TEXT'},{fieldName:'doc_template_id',fieldType:'TEXT'}];
  var criteria = [{fieldName:'process_id',fieldValue:processId,operator:'='}];
  
  $DAL.executeQuery(objectName,fieldNames,criteria,null,null,function(request){
    if(request.response.statusCode != '1') {
      //alert("Data base error ");
    }
    else {
      var objectData = request.response.objectData;
      if(objectData.length > 0) {
        var processObj = objectData[0];
        var templateId =  processObj.doc_template_id;
        
        
        objectName = "ATTACHMENTS";
        fieldNames = [{fieldName:'Id',fieldType:'TEXT'},{fieldName:'attachment_name',fieldType:'TEXT'},{fieldName:'body',fieldType:'BLOB'}];
        criteria = [{fieldName:'parent_id',fieldValue:templateId,operator:'='}];
        
        $DAL.executeQuery(objectName,fieldNames,criteria,null,null,function(docRequest){


          if(docRequest.response.statusCode != '1') {
            //alert("Data base error ");
          }
          else{
            //alert("Success");
            var docData = docRequest.response.objectData;
            if(docData.length > 0){

              var neededObject = docData[0];
              var bodyValue = neededObject.body;
              if(bodyValue != null && bodyValue.length > 0){

                var bodyString  = $UTILITY.base64Decode(bodyValue);
                var finalTemplate = {Template:bodyString};
                          
                          callbackFunction.call(context, finalTemplate, 'GetTemplate');
                        OPDGetDocumentMetaData(docMetaData.Input, docMetaData.Callback, docMetaData.Context);
              }
              
            }
            
          }
        });
        
      }
      
    }
  });
}
//Krishna defect 008268
function GetMediaResourceJSONArray(media_res_array,media_res_json_array,index, templateId, callbackFunction,globalObjectData)
{
    var i = index;
    var media_name = media_res_array[i];
    
    var objName = "Document";
    var fldNames = [{fieldName:'Name',fieldType:'TEXT'},{fieldName:'Type',fieldType:'TEXT'}];
    var crtria = [{fieldName:'DeveloperName',fieldValue:media_name,operator:'='}];
    var media_res_id;
    $DAL.executeQuery(objName,fldNames,crtria,null,null,function(request)
                      {
                      if(request.response.statusCode != '1')
                      {
                      //alert("Data base error ");
                      } /* if(request.response.statusCode != '1') */
                      else
                      {
                      //alert(JSON.stringify(request));
                      
                      var objectData = request.response.objectData;
                      if(objectData.length > 0)
                      {
                      var procObj = objectData[0];
                      media_res_id =  procObj.Name + "." + procObj.Type;
                      //alert(media_res_id);
                      
                      /* Once you get the Id for each media_res values, convert them into one JSON string representation */
                      var json_str = {Id:media_res_id,DeveloperName:media_name};
                      media_res_json_array[i] = json_str;
                      
                      if(media_res_array.length > (i+1))
                      {
                      index = i+1;
                      GetMediaResourceJSONArray(media_res_array,media_res_json_array,index,templateId, callbackFunction,globalObjectData);
                      }
                      else {
                      DocDetailsAfterMediaResources(media_res_array,media_res_json_array,templateId, callbackFunction,globalObjectData);
                      }
                      
                      } /* if(objectData.length > 0) */
                      else
                      {
                        if(media_res_array.length > (i+1))
                        {
                            index = i+1;
                            GetMediaResourceJSONArray(media_res_array,media_res_json_array,index,templateId, callbackFunction,globalObjectData);
                        }
                        else
                        {
                        DocDetailsAfterMediaResources(media_res_array,media_res_json_array,templateId, callbackFunction,globalObjectData);
                        }
                      }
                      } /* else if(request.response.statusCode == '1') */
                      }); /* executeQuery on Document object */
}
// krishna defect 008268
function DocDetailsAfterMediaResources(media_res_array,media_res_json_array,templateId, callbackFunction,gObjectData)
{
        gObjectData[0].media_resources = media_res_json_array;
        
        templateRecord = JSON.stringify(gObjectData);
        templateRecord=templateRecord.replace("media_resources","SVMXC__Media_Resources__c");
        //alert("new templateRecord : " + templateRecord);
    
        
        /* Retrieve the doc_template_details corresponding to the record in JSON format */
        var templateDetailsRecord;
        var dtdObj = "DOC_TEMPLATE_DETAILS";
        // var dtdfields = [{fieldName:'doc_template',fieldType:'TEXT'},{fieldName:'doc_template_detail_id',fieldType:'TEXT'},{fieldName:'header_ref_fld',fieldType:'TEXT'},{fieldName:'alias',fieldType:'TEXT'},{fieldName:'object_name',fieldType:'TEXT'},{fieldName:'soql',fieldType:'TEXT'},{fieldName:'doc_template_detail_unique_id',fieldType:'TEXT'},{fieldName:'fields',fieldType:'TEXT'},{fieldName:'type',fieldType:'TEXT'},{fieldName:'Id',fieldType:'TEXT'}];
        var dtdfields = [{fieldName:'Id',fieldType:'TEXT'},{fieldName:'fields',fieldType:'TEXT'},{fieldName:'object_name',fieldType:'TEXT'},{fieldName:'alias',fieldType:'TEXT'},{fieldName:'type',fieldType:'TEXT'}];
        var dtdcriteria = [{fieldName:'doc_template',fieldValue:templateId,operator:'='}];
        $DAL.executeQuery(dtdObj,dtdfields,dtdcriteria,null,null,function(request)
                          {
                          if(request.response.statusCode != '1')
                          {
                          //alert("Data base error ");
                          }
                          else
                          {
                          //alert(JSON.stringify(request));
                          
                          var objectData = request.response.objectData;
                          if(objectData.length > 0)
                          {
                          /* Club these details into one JSON string and pass in the response callback */
                          templateDetailsRecord = JSON.stringify(objectData);
                          
                          //alert("template detail records : " + templateDetailsRecord);
                          
                          templateDetailsRecord=templateDetailsRecord.replace(/fields/g,"SVMXC__Fields__c");
                          templateDetailsRecord=templateDetailsRecord.replace(/object_name/g,"SVMXC__Object_Name__c");
                          templateDetailsRecord=templateDetailsRecord.replace(/alias/g,"SVMXC__Alias__c");
                          templateDetailsRecord=templateDetailsRecord.replace(/type/g,"SVMXC__Type__c");
                          
                          // JSON.parse() converts json string to json object
                          var finaljson = {TemplateRecord:JSON.parse(templateRecord), AllObjectInfo:JSON.parse(templateDetailsRecord)};
                          var finalResponseString = JSON.stringify(finaljson);
                          
                          
                          callbackFunction.call(context, finaljson, 'GetDocumentMetadata');
                          OPDGetDocumentData(docData.Input, docData.Callback, docData.Context);
                          //alert(finalResponseString);
                          
                          //alert("GetDocumentMetaData : Ends");
                          }
                          }
                          });/* executeQuery for Doc_template_details */
            
}
function OPDGetDocumentMetaData(processIdObj, callbackFunction, context)
{
  /* Get doc_template_id from process_id from SFProcess table */
  
  var processId = processIdObj.ProcessId;
  
  var objectName = "SFProcess";
  var fieldNames = [{fieldName:'process_id',fieldType:'TEXT'},{fieldName:'doc_template_id',fieldType:'TEXT'}];
  var criteria = [{fieldName:'process_id',fieldValue:processId,operator:'='}];
  var templateId = 0;
  $DAL.executeQuery(objectName,fieldNames,criteria,null,null,function(request)
  {
    if(request.response.statusCode != '1')
    {
      //alert("Data base error ");
    }
    else
    {
      //alert(JSON.stringify(request));
      
      var objectData = request.response.objectData;
      if(objectData.length > 0)
      {
        var processObj = objectData[0];
        templateId =  processObj.doc_template_id;
        //alert(templateId);
        
        /* Retireve the Doc_Template record values in JSON string format */
        var objectName1 = "DOC_TEMPLATE";
        var fieldNames1 = [{fieldName:'doc_template_name',fieldType:'TEXT'},{fieldName:'Id',fieldType:'TEXT'},{fieldName:'doc_template_id',fieldType:'TEXT'},{fieldName:'is_standard',fieldType:'Boolean'},{fieldName:'media_resources',fieldType:'TEXT'}];
        var criteria1 = [{fieldName:'Id',fieldValue:templateId,operator:'='}];
        var media_res;
        $DAL.executeQuery(objectName1,fieldNames1,criteria1,null,null,function(request)
        {
          if(request.response.statusCode != '1')
          {
            //alert("Data base error ");
          }
          else
          {
            //alert(JSON.stringify(request));
            
            var objectData = request.response.objectData;
            if(objectData.length > 0)
            {
              /*  Get media_resources value from from corresponding record */
              var processObj = objectData[0];
              media_res =  processObj.media_resources;
              //alert("Media resources : " + media_res);
              //alert("ProcessObj ( ObjectData[0] ) : " + JSON.stringify(objectData[0]));
              
              var media_res_json_array = [];
              //krishna defect 008268
              if(media_res.length > 0) {
               /* media_resources will have comma separated values - Separate the values */
               var media_res_array = media_res.split(",");
               var arrayLength = media_res_array.length;
               // alert("shya" + arrayLength);
               var templateRecord;
               GetMediaResourceJSONArray(media_res_array,media_res_json_array,0, templateId, callbackFunction,objectData);
               }
               else
               {
               DocDetailsAfterMediaResources(media_res_array,media_res_json_array,templateId, callbackFunction,objectData);
               }

} /* if(objectData.length > 0) for Doc_template object execute query */
} /* else part for Doc_template record retrieval from executeQuery */
}); /* executeQuery for Doc_template record retrieval */
} /* if(objectData.length > 0) valid scenario for retrieving doc_template_id from Process_id */
} /* success scenario else condition  for retrieving doc_template_id from Process_id */
}); /* executeQuery for retrieving doc_template_id from Process_id */
} /* GetDocumentMetaData ends */
//GetDocumentMetaData({"ProcessId":"WO_ServiceReport_001"});


var GetDataForTemplateDetailsRecord = function(inputObj, templateDetailRecords, rec_Local_sf_Id, index, callbackFunction)
{
   // 8980 : need local_id and also sfid with conditional OR
    var localId = rec_Local_sf_Id.local_Id;
    var sfdcid = rec_Local_sf_Id.sf_id;
    
    var processId = inputObj.ProcessId;
    var recordId = inputObj.RecordId;
    
    var docTemplateDetailRecord = templateDetailRecords[index];
    
    var dtd_Id = docTemplateDetailRecord.Id;
    
    var dtd_alias = docTemplateDetailRecord.alias;
    
    var dtd_soql_fields = docTemplateDetailRecord.fields;

    var dtd_type = docTemplateDetailRecord.type;

    var ref_fld_Id = "";
    if(dtd_type  == "Header_Object")
        ref_fld_Id = recordId;
    else
        ref_fld_Id = localId;
    
    /* Get the soql metadata in 'fields' column from doc_template_details record  */
    
    /* Parse and get the query from the soql metadata - Integrate shravya's code */
    /* sqlFromSoql = <<fields parsed from soql metadata>> */
    
    var objName = docTemplateDetailRecord.object_name;
    
    var hdr_ref_fld = docTemplateDetailRecord.header_ref_fld;
    
    // 9032 : Header data not getting displayed
    if(dtd_type  == "Header_Object"){
        hdr_ref_fld = "local_id";
    }

    var advCriteria = [];
    var advCriteriaExpression = "";
    
    /* Get the expression  */
    /* Get the expression_id from process component table for the given process_id */
    var objectName = "SFProcessComponent";
    var fieldNames = [{fieldName:'expression_id',fieldType:'TEXT'}];
    var criteria = [{fieldName:'process_id',fieldValue:processId,operator:'='},{fieldName:'doc_template_Detail_id',fieldValue:dtd_Id,operator:'='}];
    var expression_id = 0;
   
    $DAL.executeQuery(objectName,fieldNames,criteria,null,null,function(request)
                      {
                      if(request.response.statusCode != '1')
                      {
                      //alert("Data base error ");
                      }
                      else
                      {
                      
                      
                      var processCompObj = request.response.objectData[0];
                      
                      
                      if(processCompObj.expression_id.length > 0)
                      {
                      
                      expr_id =  processCompObj.expression_id;
                     
                     
                      
                      /* Get the expression for the retrieved expression_id */
                      var exptblName = "SFExpression";
                      var fields = [{fieldName:'expression_id',fieldType:'TEXT'},{fieldName:'expression',fieldType:'TEXT'},{fieldName:'expression_name',fieldType:'TEXT'}];
                      var criterion = [{fieldName:'expression_id',fieldValue:expr_id,operator:'='}];
                      var expression_id = 0;
                      var expression = 0;
                      $DAL.executeQuery(exptblName,fields,criterion,null,null,function(request)
                                        {
                                        if(request.response.statusCode != '1')
                                        {
                                        //alert("Data base error ");
                                        }
                                        else
                                        {
                                       
                                        
                                        var expressionObj = request.response.objectData[0];
                                        if(expressionObj)
                                        {
                                        
                                        expression_id =  expressionObj.expression_id;
                                        expression = expressionObj.expression;
//                                        alert(expression_id + " : " + expression);
                                        
                                        advCriteriaExpression = expression;
                                        
                                        /* Get the expression parsed */
                                        /* Option 1: Get the expression parsed from the appdelegate->databaseInterfaceSFM object */
                                        /* Option 2: Already implemented in javascript for online team, get it from Ranga */
                                        /* Resulting string will be an expression to be used in the query */
                                       
                                        
                                        var objectName = "SFExpressionComponent";
                                        var fieldNames = [{fieldName:'component_sequence_number',fieldType:'TEXT'},{fieldName:'component_lhs',fieldType:'TEXT'},{fieldName:'component_rhs',fieldType:'TEXT'},{fieldName:'operator',fieldType:'TEXT'}];
                                        var criteria = [{fieldName:'expression_id',fieldValue:expression_id,operator:'='}];
                                        $DAL.executeQuery(objectName,fieldNames,criteria,null,'component_sequence_number',function(request)
                                                          {
                                                          if(request.response.statusCode != '1')
                                                          {
//                                                            alert("Data base error ");
                                                          }
                                                          else
                                                          {
                                                          
                                                          
                                                          var components = request.response.objectData;
                                                          if(components.length > 0)
                                                          {
                                                          
                                                         
                                                          
                                                          for(var i = 0; i < components.length; i++ )
                                                          {
                                                          var component = components[i];
                                                          
                                                          
                                                        
                                                          var com_seq_num = component.component_sequence_number;
                                                          var lhs = component.component_lhs;
                                                          var rhs = component.component_rhs;
                                                          var op = component.operator;
                                                          
                                                          var advCriterion = {fieldName:lhs,fieldValue:rhs,operator:op};
                                                         
                                                          if(com_seq_num == (i+1))
                                                          advCriteria[i] = advCriterion;
                                                          
                                                          }
                                                          
                                                          var basicCriterion = {fieldName:hdr_ref_fld,fieldValue:ref_fld_Id,operator:'='};
                                                          // 8980 : need local_id and also sfid with conditional OR
                                                          var sfdcIdCriterion = {fieldName:hdr_ref_fld,fieldValue:sfdcid,operator:'='};
                                                          
                                                          var numOfCriteriaFields = 0;
                                                          
                                                          if(advCriteria.length > 0)
                                                          {
                                                            numOfCriteriaFields = advCriteria.length + 1;
                                                            var numOfCritFldsAfterOR = numOfCriteriaFields + 1;// 8980 : Adding a OR criteria
                                                            advCriteriaExpression = advCriteriaExpression + " and " + "( " + numOfCriteriaFields + " or "+ numOfCritFldsAfterOR + " )";// 8980 : need local_id and also sfid with conditional OR
                                                          }
                                                          else
                                                          {
                                                            advCriteriaExpression = "( 1 or 2 )"; // 8980 : need local_id and also sfid with conditional OR
                                                          }
                                                          
                                                          advCriteria.push(basicCriterion);
                                                          advCriteria.push(sfdcIdCriterion);// 8980 : need local_id and also sfid with conditional OR
                                                          
                                                          /* Update template_details_record data */
                                                          templateDetailRecords[index].criteria = advCriteria; // [{fieldName:hdr_ref_fld,fieldValue:ref_fld_Id,operator:'='}];
                                                          templateDetailRecords[index].advancedExpression = advCriteriaExpression;
                                                          
                                                        
//                                                          alert(JSON.stringify(templateDetailRecords[index]));

                                                          // Temporary : To be inserted in the inner most callback function
                                                          var nextIndex = index + 1;
                                                          if(templateDetailRecords.length > nextIndex)
                                                            GetDataForTemplateDetailsRecord(inputObj, templateDetailRecords, rec_Local_sf_Id, nextIndex, callbackFunction);// 8980 : need local_id and also sfid with conditional OR
                                                          else {
                                                            
                                                           callbackFunction(templateDetailRecords);
                                                          }
                                                            
                                                          }
                                                          }
                                                          });
                                        }
                                        
                                        }
                                        });
                      }
                      else
                      {
                      
                      
                      /* Update template_details_record data */
                      // 8980 : need local_id and also sfid with conditional OR
                      templateDetailRecords[index].criteria = [{fieldName:hdr_ref_fld,fieldValue:ref_fld_Id,operator:'='},{fieldName:hdr_ref_fld,fieldValue:sfdcid,operator:'='}];
                      templateDetailRecords[index].advancedExpression = "( 1 or 2 )";

                      // Temporary : To be inserted in the inner most callback function
                      var nextIndex = index + 1;
                      if(templateDetailRecords.length > nextIndex)
                        GetDataForTemplateDetailsRecord(inputObj, templateDetailRecords, rec_Local_sf_Id, nextIndex, callbackFunction);// 8980 : need local_id and also sfid with conditional OR
                      else {
                           
                            callbackFunction(templateDetailRecords);
                      }
                       
                      }
                      }
                      });
}

function OPDGetDocumentData(inputObj, callbackFunction, context)
{
    
    /* Get doc_template_id from process_id from SFProcess table */
    
    var processId = inputObj.ProcessId;
    var recordId = inputObj.RecordId;
    
    var proName = "SFProcess";
    var profieldNames = [{fieldName:'doc_template_id',fieldType:'TEXT'}];
    var procriteria = [{fieldName:'process_id',fieldValue:processId,operator:'='}];
    var templateId = 0;
    
    $DAL.executeQuery(proName,profieldNames,procriteria,null,null,function(request)
                      {
                      
                      if(request.response.statusCode != '1')
                      {
                      //alert("Data base error ");
                      }
                      else
                      {
                        var processRecord = request.response.objectData;
                        if(processRecord.length > 0)
                      {
                      
                      /* Get the doc_template_id from Process using ProcessId */
                      var processObj = processRecord[0];
                      templateId =  processObj.doc_template_id;
                     
                      
                      /* Retrieve the doc_template_details corresponding to the record in JSON format */
                      var tdObj = "DOC_TEMPLATE_DETAILS";
                      var tdfields = [{fieldName:'doc_template',fieldType:'TEXT'},{fieldName:'doc_template_detail_id',fieldType:'TEXT'},{fieldName:'header_ref_fld',fieldType:'TEXT'},{fieldName:'alias',fieldType:'TEXT'},{fieldName:'object_name',fieldType:'TEXT'},{fieldName:'soql',fieldType:'TEXT'},{fieldName:'doc_template_detail_unique_id',fieldType:'TEXT'},{fieldName:'fields',fieldType:'TEXT'},{fieldName:'type',fieldType:'TEXT'},{fieldName:'Id',fieldType:'TEXT'}];
                      var tdcriteria = [{fieldName:'doc_template',fieldValue:templateId,operator:'='}];
                      
                      var wo_local_id = "";
                      
                      $DAL.executeQuery(tdObj,tdfields,tdcriteria,null,null,function(request)
                                        {
                                        
                                        
                                        if(request.response.statusCode != '1')
                                        {
                                        //alert("Data base error ");
                                        }
                                        else
                                        {
                                       
                                        
                                        var templateDetailRecords = request.response.objectData;
                                        if(templateDetailRecords.length > 0)
                                        {
                                        /* Club these details into one JSON string and pass in the response callback */
                                        
                                        
                                        var tdRecord = {};
                                        for(var i = 0; i < templateDetailRecords.length; i++ )
                                        {
                                        
                                        tdRecord = templateDetailRecords[i];
                                       
                                        
                                        if(tdRecord.type == "Header_Object")
                                        {
//                                        alert("Found!! Now break :)");
                                        break;
                                        }
                                        }
                                        
                                        
                                        /* Getting the local ID of the work-order's Header_Object */
                                        // 8980 : need local_id and also sfid with conditional OR
                                        // because the header object reference can be stored either as a local id or as an sfid
                                        var tablename = tdRecord.object_name;
                                        var fields = [{fieldName:'local_id',fieldType:'TEXT'},{fieldName:'Id',fieldType:'TEXT'}];
                                        var criteria = [{fieldName:'local_id',fieldValue:recordId,operator:'='}];
                                        $DAL.executeQuery(tablename,fields,criteria,null,null,function(request)
                                                          {
                                                          
                                                          
                                                          if(request.response.statusCode != '1')
                                                          {
                                                          //alert("Data base error ");
                                                          }
                                                          else
                                                          {
                                                         
                                                          
                                                          var local_id_obj = request.response.objectData[0];
                                                          //krishna OPDOc offline generation
                                                          //local_id_obj = {};
                                                          
                                                          if(local_id_obj)
                                                          {
                                                          //krishna OPDOc offline generation
                                                          //The new implementation will always sends the localId in recordId parameter
                                                          //Irrespective of whether sfId is available or not
                                                          wo_local_id = recordId;//local_id_obj.local_id;
                                                          
                                                          // 8980 : need local_id and also sfid with conditional OR
                                                          var sfdcid = local_id_obj.Id;
                                                          if((sfdcid == null) || (sfdcid.length <= 0)) {
                                                            sfdcid = "handleempty";
                                                          }
                                                          
                                                          
                                                          var recordLocalAndSFID = {local_Id:wo_local_id,sf_id:sfdcid};
                                                          
                                                          // Recursive function here
                                                          // 8980 : need local_id and also sfid with conditional OR
                                                          GetDataForTemplateDetailsRecord(inputObj, templateDetailRecords, recordLocalAndSFID, 0, function(result)
                                                                                          {
                                                                                          
                                                                                          
                                                                                         // alert("GETC test");
                                                                                          var finalOutputArray = [];
                                                                                          continueGetDocumentData(finalOutputArray,result,"5272",0,function(finalResult){
                                                                                                                  
                                                                                             
                                                                                               
                                                                                            
                                                                                            var outputfinal = {DocumentData:finalResult,Status:true,Message:""};
                                                                                                                   $COMM.printLog(JSON.stringify(outputfinal));
                                                                                                                  
                                                                                                                  callbackFunction.call(context,outputfinal,'GetDocumentData');
                                                                                                                  
                                                                                        });
                                                                                          
                                                                                          });

                                                          
                                                          }
                                                          else
                                                          {
                                                          
                                                          }
                                                          }
                                                          });

                                        }
                                        else
                                        {
                                        
                                        }
                                        }
                                        });
                      }
                      else
                      {
                      
                      }
                      }
                      });

    
}



function continueGetDocumentData(finalOutputArray,docTemplateDetailArray,recordId,index,callBackFunction){
   
    var detailLength = docTemplateDetailArray.length;
    
    if(index < detailLength){
        var detailObject = docTemplateDetailArray[index];
        var jsonString = detailObject.fields;
        var objectName = detailObject.object_name;
        
        var criteriaArray = detailObject.criteria;
        
        var advnExpr = detailObject.advancedExpression;
        var aliasName = detailObject.alias;
       
        var fieldNames = [];
        
        $DAL.parseSoqlJSOnObject(objectName, fieldNames, criteriaArray, advnExpr,jsonString,function(request){
                                 
                                 if(request.response.statusCode == "1"){
                                        var templateDict = {};
                                        var recordsArray = [];
                                        var objectData = request.response.objectData;
                                 
                                        var specialfieldNames = [];
                                        var fieldNames = request.fieldNames;
                                        for(var jj = 0; jj< fieldNames.length;jj++) {
                                                var aField = fieldNames[jj];
                                                var aFiledName = aField.fieldName;
                                                var aFieldtype = aField.fieldType;
                                                if(aFieldtype ==  'datetime' || aFieldtype == 'date'){
                                                        specialfieldNames.push({fn:aFiledName,ft:aFieldtype});
                                                }
                                        }
                                 
                                        /* Shravya-7594*/
                                 //defect 7913 : loading prob opdoc shravya.
                                        var metaDataJSON = null;;
                                        var metaDataArray = [];
                                 
                                        if(jsonString.length > 3) {
                                            metaDataJSON =  JSON.parse(jsonString);
                                            metaDataArray = metaDataJSON['Metadata'];
                                        }
                                                                            
                                        
                                      
                                        var secondLevelSpecialFields = [];
                                 
                                        for(var newCounter = 0; newCounter < metaDataArray.length;newCounter++){
                                            var metaDataObject = metaDataArray[newCounter];
                                            var newTyp  = metaDataObject.TYP;
                                            var newRTyp = metaDataObject.RTYP;
                                            var newRLN = metaDataObject.RLN;
                                            var newFn = metaDataObject.FN;
                                            var newRFN = metaDataObject.RFN;
                                            if(newTyp == 'reference' && newRLN != null && (newRTyp == 'datetime' ||  newRTyp == 'date')){
                                 
                                                var finalRLN = newRLN;
                                                finalRLN = finalRLN.replace("__r","__c");
                                                finalRLN = finalRLN+'.'+newRFN;
                                                var secondField = {};
                                                secondField.rln  = newRLN;
                                                secondField.frln = finalRLN;
                                                secondField.rfn = newRFN;
                                                secondField.rtyp = newRTyp;
                                                secondLevelSpecialFields.push(secondField);
                                            }
                                 
                                        }
                                 
                                 /* Shravya-7594*/
                                 
                                        var specialFieldsArray = [];
                                        for(var counter = 0;counter < objectData.length;counter++) {
                                                var record = objectData[counter];
                                                recordsArray[counter] = record;
                                 
                                                var aSpecialField = {};
                                                var fieldsTobeAdded = [];
                                                for(var ii = 0;ii <specialfieldNames.length;ii++ ){
                                                        var fName = specialfieldNames[ii].fn;
                                                        var fType = specialfieldNames[ii].ft;
                                                        var fValue = record[''+fName];
                                 
                                                        //7594 defect - krishna
                                                        //changes:Only to make local
                                                        if(fValue != null && fValue.length > 2){
                                                                fValue = $UTILITY.dateAndTimeForGMTString(fValue);
                                                        }
                                 
                                                        if(fValue != null && fValue.length > 2){
                                                                fieldsTobeAdded.push({Key:fName,Value:fValue,Info:fType});
                                                        }
                                                }
                                 
                                                /*secondLevel Special fields 7594*/
                                            for(var newCounter = 0; newCounter < secondLevelSpecialFields.length;newCounter++){
                                                    var secondLevelObject = secondLevelSpecialFields[newCounter];
                                                    var newRLN = secondLevelObject.rln;
                                                    var newRfn = secondLevelObject.rfn;
                                                    var newFrln = secondLevelObject.frln;
                                                    var newRtyp = secondLevelObject.rtyp;
                                 
                                                    var secondDictionary = record[''+newRLN];
                                                    var newRFnValue = secondDictionary[''+newRfn];
                                                    if(newRFnValue == null || newRFnValue.length < 2){
                                                            continue;
                                                    }
                                                    //7594 defect - krishna
                                                    //changes:Only to make local
                                                    if(newRFnValue != null && newRFnValue.length > 2){
                                                            newRFnValue = $UTILITY.dateAndTimeForGMTString(newRFnValue);
                                                    }
                                 
                                                    if(newRFnValue != null && newRFnValue.length > 2){
                                                            fieldsTobeAdded.push({Key:newFrln,Value:newRFnValue,Info:newRtyp});
                                                    }
                                            }
                                           /* Shravya-7594*/
                                 
                                                var recSpeKey = record['Id'];
                                                if(fieldsTobeAdded.length > 0 && recSpeKey != null  ){
                                                            aSpecialField.Value = fieldsTobeAdded;
                                                            aSpecialField.Key = record['Id'];
                                                            specialFieldsArray.push(aSpecialField);
                                                }
                                        }
                                        templateDict.Records = recordsArray;
                                        templateDict.Key = aliasName;
                                        templateDict.SpecialFields = specialFieldsArray;
                                        finalOutputArray.push(templateDict);
                                        index++;
                                        if(index < docTemplateDetailArray.length) {
                                                 continueGetDocumentData(finalOutputArray,docTemplateDetailArray,recordId,index,callBackFunction);
                                                  
                                        }
                                        else {
                                             
                                              callBackFunction(finalOutputArray);
                                        }
                                 
                                 }
                                 else {
                                        callBackFunction(finalOutputArray);
                                 }
        });

    }
    else {
         callBackFunction(finalOutputArray);
    }
    return;
}

function SubmitQuery(queryParam, callbackFunction, context){

  var query = queryParam.Query;
  if(query != null && query.length > 0){
    $DAL.submitQuery(query, function(request){
     //alert(JSON.stringify(request));
        var resultArray  =request.response.objectData;
        callbackFunction.call(context, resultArray, 'SubmitQuery');
   });
  }
  
}

/* capture html content with data */ 
function captureData() {
    
    var capturedDat = document.documentElement.innerHTML;
    return capturedDat;
}
/* get logged in user's information. basic details are taken from User table. */
function OPDGetUserInfo(request, callbackFunction, context)
{
    
    var objectName = "User";
 
        var userFullName = "";

    var dateFrmt = "";
    var timeFrmt = "";

    var amTxt = "";
    var pmTxt = "";

    $COMM.requestDataForType("relateduserinput","",function(dateString) {
                             
                             dateFrmt = dateString.dateformat;
                             //7594 defect - krishna
                             dateFrmt = dateFrmt.toUpperCase();
                             timeFrmt = dateString.timeformat;
                             amTxt = dateString.amtext;
                             pmTxt = dateString.pmtext;
                             userFullName = dateString.username;

    var fieldNames = [{fieldName:'Id',fieldType:'TEXT'},{fieldName:'Name',fieldType:'TEXT'},{fieldName:'LocaleSidKey',fieldType:'TEXT'},{fieldName:'LanguageLocaleKey',fieldType:'TEXT'},{fieldName:'Street',fieldType:'TEXT'},{fieldName:'City',fieldType:'TEXT'},{fieldName:'State',fieldType:'TEXT'},{fieldName:'Country',fieldType:'TEXT'},{fieldName:'PostalCode',fieldType:'TEXT'}];
    
    var criteria = [{fieldName:'Name',fieldValue:userFullName,operator:'='}];

    $DAL.executeQuery(objectName,fieldNames,criteria,null,null,function(request){
                      
                      if(request.response.statusCode != '1')
                      {
                      alert("Data base error ");
                      }
                      else
                      {
                      
                      var objectData = request.response.objectData;
                      if(objectData.length > 0)
                      {
                      
                      var userObj = objectData[0];
                      
                      var usrTimeZone = userObj.LocaleSidKey;
                      var locale = userObj.LanguageLocaleKey;
                      var userID = userObj.Id;
                      var userName = userObj.Name;
                      
                      var cityString = userObj.City;
                      var streetString = userObj.Street;
                      var stateString = userObj.State;
                      var countryString = userObj.Country;
                      var postalCode = userObj.PostalCode;
                      
                      var address = addressForData(streetString,cityString,stateString,postalCode,countryString);
           
                      var d = new Date();
                      var today = $UTILITY.dateWithTimeStringForDate(d);
                      var yesterday = $UTILITY.previousDateForDate(d);
                      var tomorrow = $UTILITY.nextDateForDate(d);
                      var tod = $UTILITY.dateStringFordate(d);

                      var jsonObj = {Yesterday:yesterday,UserTimeZone:usrTimeZone,UserName:userName,UserId:userID,Tomorrow:tomorrow,Today:tod,Now:today,DateFormat:dateFrmt,Address:address,TimeFormat:timeFrmt,amText:amTxt,pmText:pmTxt,Locale:locale};
//                      alert(JSON.stringify(jsonObj));
                      
                      callbackFunction.call(context, jsonObj, 'GetUserInfo');
                      OPDGetTemplate(templateData.Input, templateData.Callback, templateData.Context);
                      
                                            }
                      }
                      });

        });
}

/* GetUserInfo related code, which takes all the required fields and creates an address string */

function addressForData(streetString,cityString,stateString,postalCode,countryString) {
    
    var completeAddress = "";
    
    if (streetString != null && streetString.length>0) {
        completeAddress = streetString + ",";
    }
    if (cityString != null && cityString.length > 0) {
        completeAddress = completeAddress + cityString + ",";
    }
    if (stateString != null && stateString.length > 0) {
        completeAddress = completeAddress + stateString + " ";
    }
    if (postalCode != null && postalCode.length > 0) {
        completeAddress = completeAddress + postalCode + ",";
    }
    if (countryString != null && countryString.length > 0) {
        completeAddress = completeAddress + countryString;
    }
    return completeAddress;
    
}

var objectNamesArray = [];
function DescribeObject(objectNameJson, callbackFunction, context) {
                var objectName = objectNameJson.objectName;
    objectNamesArray[objectName] = callbackFunction;
                $DAL.describeObject(objectName,function(data){
                     objectNamesArray[data.response.objectData[0].name].call(context,data.response.objectData[0],'DescribeObject');
                });
}

function CaptureSignature(request, callbackFunction, context)
{
    var id = request.ProcessId + "_" + request.RecordId + "_" + request.UniqueName;
    $COMM.requestDataForType("capturesignature",id,function(signaturepath) {
                             /*
                              response.uniqueName
                              response.path
                              */
                             var response = {uniqueName:request.UniqueName,path:signaturepath.Path};
                             callbackFunction.call(context, response, 'CaptureSignature');
                             
                             });
}


function Finalize(request, callbackFunction, context)
{
    debugger;
    
    /*
     
     request.ProcessId
     request.RecordId
     request.HTMLContent
     
     */
    
    var customRequest = {ProcessId:request.ProcessId,RecordId:request.RecordId};
    document.documentElement.innerHTML = "";
    document.documentElement.innerHTML = request.HTMLContent;
    $COMM.requestDataForType("finalize",JSON.stringify(customRequest),null);
 
}

//GetDocumentData({"ProcessId":"WO_ServiceReport_001","RecordId":"a1K70000001975VEAQ"});

/*
var docTemplateDetailArray = [];
var doc1 = {};
doc1.object_name = "SVMXC__Service_Order__c";
doc1.alias = "Work_order";
doc1.criteria = [{fieldName:"Id",operator:"=",fieldValue:"a1K70000001975VEAQ"}];
doc1.fields = "";
docTemplateDetailArray.push(doc1);

var doc2 = {};
doc2.object_name = "SVMXC__Service_Order__c";
doc2.alias = "Work_order_line";
doc2.criteria = [{fieldName:"Id",operator:"=",fieldValue:"a1K700000018iMcEAI"}];
doc2.fields = "";
doc2.advancedExpression = "(1 and 1)";
docTemplateDetailArray.push(doc2);


var ss = [];

continueGetDocumentData(ss,docTemplateDetailArray,"a1K70000001975VEAQ",0,function(result){
                        alert("Success");
                         $COMM.printLog(JSON.stringify(result));
                        
});

//DescribeObject({objectName:"Account"});
//GetUserInfo();
 
 var isCaptureUnderProcess = false;
 var captureSignatureArray = [];
 function xyzCaptureSignature(request, callbackFunction, context)
 {
 if(isCaptureUnderProcess == true)
 {
 var signObject = {request:request,callback:callbackFunction,context:context};
 captureSignatureArray.push(signObject);
 }
 else
 {
 setTimeout(OPDCaptureSignature(request, callbackFunction, context),300);
 }
 }
 
 function OPDCaptureSignature(request, callbackFunction, context)
 {
 isCaptureUnderProcess = true;
 
// request.ProcessId : String
// request.RecordId : String
// request.UniqueName : String
// request.CaptureSignature : true/false
 

var id = request.ProcessId + "_" + request.RecordId + "_" + request.UniqueName;
if((request.CaptureSignature != undefined) && (request.CaptureSignature == true))
{
    $COMM.requestDataForType("capturesignature",id,function(signaturepath) {
                             
//                              response.uniqueName
//                              response.path
                             
                             var response = {uniqueName:request.UniqueName,path:signaturepath.Path};
                             callbackFunction.call(context, response, 'CaptureSignature');
                             
                             isCaptureUnderProcess = false;
                             
                             if(captureSignatureArray.length > 0)
                             {
                             var signObj = captureSignatureArray[0];
                             OPDCaptureSignature(signObj.request, signObj.callback, signObj.context);
                             }
                             
                             });
}
else
{
    $COMM.requestDataForType("issignatureavailable",id,function(signaturepath) {
                             
//                              response.uniqueName
//                              response.path
                             
                             var response = {uniqueName:request.UniqueName,path:signaturepath.Path};
                             callbackFunction.call(context, response, 'CaptureSignature');
                             
                             isCaptureUnderProcess = false;
                             if(captureSignatureArray.length > 0)
                             {
                             var signObj = captureSignatureArray[0];
                             OPDCaptureSignature(signObj.request,signObj.callback,signObj.context);
                             captureSignatureArray.shift();
                             }
                             
                             
                             });
}
}


*/
