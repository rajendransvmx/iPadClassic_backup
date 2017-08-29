
var templateData = null;
var docMetaData = null;
var docData = null;
var userInfoData = null;
var displayTagsData = null;
var processSfid = "";
var current_org_name_space = iPAD_ORG_NAME_SPACE;

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

function GetDisplayTags(request, callbackFunction, context)
{
    displayTagsData = {Input:request, Callback:callbackFunction, Context:context};
    StartOutputDocDataRetrieval();
}

function StartOutputDocDataRetrieval()
{
    if(userInfoData != null && templateData != null && docMetaData != null && docData != null && displayTagsData != null)
    {
        OPDGetDisplayTags(displayTagsData.Input, displayTagsData.Callback, displayTagsData.Context);
    }
}

function OPDGetTemplate(processIdObj, callbackFunction, context){
    
    var processId = processIdObj.ProcessId;
    
    var objectName = "SFProcess";
    var fieldNames = [{fieldName:'processId',fieldType:'TEXT'},{fieldName:'docTemplateId',fieldType:'TEXT'},{fieldName:'sfID',fieldType:'TEXT'}];
    var criteria = [{fieldName:'processId',fieldValue:processId,operator:'='}];
    
    $DAL.executeQuery(objectName,fieldNames,criteria,null,null,function(request){
                      if(request.response.statusCode != '1') {
                      //alert("Data base error ");
                      }
                      else {
                      var objectData = request.response.objectData;
                      if(objectData.length > 0) {
                      var processObj = objectData[0];
                      var templateId =  processObj.docTemplateId;
                      processSfid = processObj.sfID;
                      
                      objectName = "Attachments";
                      fieldNames = [{fieldName:'attachmentId',fieldType:'TEXT'},{fieldName:'attachmentName',fieldType:'TEXT'},{fieldName:'attachmentBody',fieldType:'BLOB'}];
                      criteria = [{fieldName:'parentId',fieldValue:templateId,operator:'='}];
                      
                      
                      $DAL.executeQuery(objectName,fieldNames,criteria,null,null,function(docRequest){
                                        
                                        
                                        if(docRequest.response.statusCode != '1') {
                                        //alert("Data base error ");
                                        }
                                        else{
                                        var docData = docRequest.response.objectData;
                                        if(docData.length > 0){
                                        
                                        var neededObject = docData[0];
                                        var bodyValue = neededObject.attachmentBody;
                                        if(bodyValue != null){
                                        
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
    var fldNames = [{fieldName:'name',fieldType:'TEXT'},{fieldName:'type',fieldType:'TEXT'}];
    var crtria = [{fieldName:'developerName',fieldValue:media_name,operator:'='}];
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
                      media_res_id =  procObj.name + "." + procObj.type;
                      
                      /* Once you get the Id for each media_res values, convert them into one JSON string representation */
                      var json_str = {Id:media_res_id,DeveloperName:media_name};
                      
                      media_res_json_array.push(json_str);
                      
                      if(media_res_array.length > (i+1))
                      {
                      index = i+1;
                      
                      
                      GetMediaResourceJSONArray(media_res_array,media_res_json_array,index,templateId, callbackFunction,globalObjectData);
                      }
                      else {
                      //                      alert ("DocDetailsAfterMediaResources1");
                      DocDetailsAfterMediaResources(media_res_array,media_res_json_array,templateId, callbackFunction,globalObjectData);
                      }
                      
                      } /* if(objectData.length > 0) */
                      else
                      {
                      if(media_res_array.length > (i+1))
                      {
                      index = i+1;
                      //                      alert ("GetMediaResourceJSONArray2");
                      GetMediaResourceJSONArray(media_res_array,media_res_json_array,index,templateId, callbackFunction,globalObjectData);
                      }
                      else
                      {
                      //                      alert ("DocDetailsAfterMediaResources2");
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
    templateRecord=templateRecord.replace("media_resources",current_org_name_space+"__Media_Resources__c");
    //alert("new templateRecord : " + templateRecord);
    
    /* Retrieve the doc_template_details corresponding to the record in JSON format */
    var templateDetailsRecord;
    var dtdObj = "DocTemplateDetails";
    // var dtdfields = [{fieldName:'doc_template',fieldType:'TEXT'},{fieldName:'doc_template_detail_id',fieldType:'TEXT'},{fieldName:'header_ref_fld',fieldType:'TEXT'},{fieldName:'alias',fieldType:'TEXT'},{fieldName:'object_name',fieldType:'TEXT'},{fieldName:'soql',fieldType:'TEXT'},{fieldName:'doc_template_detail_unique_id',fieldType:'TEXT'},{fieldName:'fields',fieldType:'TEXT'},{fieldName:'type',fieldType:'TEXT'},{fieldName:'Id',fieldType:'TEXT'}];
    
    var dtdfields = [{fieldName:'idTable',fieldType:'TEXT'},{fieldName:'fields',fieldType:'TEXT'},{fieldName:'objectName',fieldType:'TEXT'},{fieldName:'alias',fieldType:'TEXT'},{fieldName:'type',fieldType:'TEXT'}];
    var dtdcriteria = [{fieldName:'docTemplate',fieldValue:templateId,operator:'='}];
    
    $DAL.executeQuery(dtdObj,dtdfields,dtdcriteria,null,null,function(request)
                      {
                      if(request.response.statusCode != '1')
                      {
                      //alert("Data base error ");
                      }
                      else
                      {
                      var objectData = request.response.objectData;
                      
                      if(objectData.length > 0)
                      {
                      /* Club these details into one JSON string and pass in the response callback */
                      templateDetailsRecord = JSON.stringify(objectData);
                      //                          alert("DocDetailsAfterMediaResources check 2"+templateDetailsRecord);
                      //alert("template detail records : " + templateDetailsRecord);
                      
                      templateDetailsRecord=templateDetailsRecord.replace(/fields/g,current_org_name_space+"__Fields__c");
                      templateDetailsRecord=templateDetailsRecord.replace(/objectName/g,current_org_name_space+"__Object_Name__c");
                      templateDetailsRecord=templateDetailsRecord.replace(/alias/g,current_org_name_space+"__Alias__c");
                      templateDetailsRecord=templateDetailsRecord.replace(/type/g,current_org_name_space+"__Type__c");
                      
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
    var fieldNames = [{fieldName:'processId',fieldType:'TEXT'},{fieldName:'docTemplateId',fieldType:'TEXT'}];
    var criteria = [{fieldName:'processId',fieldValue:processId,operator:'='}];
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
                      templateId =  processObj.docTemplateId;
                      //alert(templateId);
                      
                      /* Retireve the Doc_Template record values in JSON string format */
                      var objectName1 = "DocTemplate";
                      var fieldNames1 = [{fieldName:'docTemplateName',fieldType:'TEXT'},{fieldName:'idTable',fieldType:'TEXT'},{fieldName:'docTemplateId',fieldType:'TEXT'},{fieldName:'isStandard',fieldType:'Boolean'},{fieldName:'mediaResources',fieldType:'TEXT'}];
                      var criteria1 = [{fieldName:'idTable',fieldValue:templateId,operator:'='}];
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
                                        media_res =  processObj.mediaResources;
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
                                        //               alert("calling GetMediaResourceJSONArray !");
                                        GetMediaResourceJSONArray(media_res_array,media_res_json_array,0, templateId, callbackFunction,objectData);
                                        }
                                        else
                                        {
                                        //                          alert("calling DocDetailsAfterMediaResources !");
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
    //    alert("GetDataForTemplateDetailsRecord");
    // 8980 : need local_id and also sfid with conditional OR
    var localId = rec_Local_sf_Id.local_Id;
    var sfdcid = rec_Local_sf_Id.sf_id;
    
    var processId = inputObj.ProcessId;
    var recordId = inputObj.RecordId;
    
    var docTemplateDetailRecord = templateDetailRecords[index];
    
    var dtd_Id = docTemplateDetailRecord.idTable;
    
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
    
    var objName = docTemplateDetailRecord.objectName;
    
    var hdr_ref_fld = docTemplateDetailRecord.headerReferenceField;
    
    // 9032 : Header data not getting displayed
    if(dtd_type  == "Header_Object"){
        hdr_ref_fld = "localId";
    }
    
    var advCriteria = [];
    var advCriteriaExpression = "";
    
    
    /* Get the expression  */
    /* Get the expression_id from process component table for the given process_id */
    var objectName = "SFProcessComponent";
    
    // 012895 - opdoc sort order - added sortingOrder, objectName params
    var fieldNames = [{fieldName:'expressionId',fieldType:'TEXT'},{fieldName:'sortingOrder',fieldType:'TEXT'}, {fieldName:'objectName',fieldType:'TEXT'}];
    var criteria = [{fieldName:'processId',fieldValue:processSfid,operator:'='},{fieldName:'docTemplateDetailId',fieldValue:dtd_Id,operator:'='}];
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
                      
                      // 012895 - get inner join and sortOrder string
                      var innerJoin = processCompObj.innerJoin;
                      var sortingOrder = processCompObj.sortingOrder;
                      
                      
                      // 012895 - setting inner join and sorting order
                      // 040513 - assigning sorting order and innerjoin to template detail record
                      templateDetailRecords[index].innerJoin = innerJoin;
                      templateDetailRecords[index].sortingOrder = sortingOrder;
                      
                      
                      if(processCompObj.expressionId.length > 0)
                      {
                      
                      expr_id =  processCompObj.expressionId;
                      

                      
                      /* Get the expression for the retrieved expression_id */
                      var exptblName = "SFExpression";
                      var fields = [{fieldName:'expressionId',fieldType:'TEXT'},{fieldName:'expression',fieldType:'TEXT'},{fieldName:'expressionName',fieldType:'TEXT'}];
                      var criterion = [{fieldName:'expressionId',fieldValue:expr_id,operator:'='}];
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
                                        
                                        expression_id =  expressionObj.expressionId;
                                        expression = expressionObj.expression;
                                        
                                        
                                        advCriteriaExpression = expression;
                                        
                                        /* Get the expression parsed */
                                        /* Option 1: Get the expression parsed from the appdelegate->databaseInterfaceSFM object */
                                        /* Option 2: Already implemented in javascript for online team, get it from Ranga */
                                        /* Resulting string will be an expression to be used in the query */
                                        
                                        
                                        var objectName = "SFExpressionComponent";
                                        var fieldNames = [{fieldName:'componentSequenceNumber',fieldType:'TEXT'},{fieldName:'componentLHS',fieldType:'TEXT'},{fieldName:'componentRHS',fieldType:'TEXT'},{fieldName:'operatorValue',fieldType:'TEXT'},{fieldName:'fieldType',fieldType:'TEXT'}];
                                        var criteria = [{fieldName:'expressionId',fieldValue:expression_id,operator:'='}];
                                        $DAL.executeQuery(objectName,fieldNames,criteria,null,'componentSequenceNumber',function(request)
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
                                                          
                                                          var componentCount = components.length;
                                                          if(advCriteriaExpression == null || advCriteriaExpression.length < 2) {
                                                          advCriteriaExpression = "( 1 ";
                                                          for(var counterIn = 2;  counterIn <= componentCount; counterIn++){
                                                          advCriteriaExpression = advCriteriaExpression + " AND " + counterIn;
                                                          }
                                                          
                                                          advCriteriaExpression = advCriteriaExpression + " ) ";
                                                          }
                                                          
                                                          
                                                          for(var i = 0; i < components.length; i++ )
                                                          {
                                                          var component = components[i];
                                                          
                                                          var com_seq_num = component.componentSequenceNumber;
                                                          var lhs = component.componentLHS;
                                                          var rhs = component.componentRHS;
                                                          var op = component.operatorValue;
                                                          var fT = component.fieldType;
                                                          var fieldTyp = fT.toLowerCase();
                                                          
                                                          var advCriterion = {fieldName:lhs,fieldValue:rhs,operator:op,fieldType:fieldTyp};
                                                          
                                                          if(com_seq_num == (i+1))
                                                          advCriteria[i] = advCriterion;
                                                          
                                                          }
                                                          
                                                          var basicCriterion = {fieldName:hdr_ref_fld,fieldValue:ref_fld_Id,operator:'='};
                                                          // 8980 : need localId and also sfid with conditional OR
                                                          var sfdcIdCriterion = {fieldName:hdr_ref_fld,fieldValue:sfdcid,operator:'='};
                                                          
                                                          var numOfCriteriaFields = 0;
                                                          
                                                          /* 11285*/
                                                          if(advCriteria.length > 0)
                                                          {
                                                          numOfCriteriaFields = advCriteria.length + 1;
                                                          var numOfCritFldsAfterOR = numOfCriteriaFields + 1;// 8980 : Adding a OR criteria
                                                          advCriteriaExpression = "("  + advCriteriaExpression + ") and " + "( " + numOfCriteriaFields + " or "+ numOfCritFldsAfterOR + " )";// 8980 : need localId and also sfid with conditional OR
                                                          }
                                                          else
                                                          {
                                                          advCriteriaExpression = "( 1 or 2 )"; // 8980 : need localId and also sfid with conditional OR
                                                          }
                                                          
                                                          advCriteria.push(basicCriterion);
                                                          advCriteria.push(sfdcIdCriterion);// 8980 : need localId and also sfid with conditional OR
                                                          
                                                          /* Update template_details_record data */
                                                          templateDetailRecords[index].criteria = advCriteria; // [{fieldName:hdr_ref_fld,fieldValue:ref_fld_Id,operator:'='}];
                                                          templateDetailRecords[index].advancedExpression = advCriteriaExpression;
                                                          

                                                          
                                                          
                                                          
                                                          //                                                          alert(JSON.stringify(templateDetailRecords[index]));
                                                          
                                                          // Temporary : To be inserted in the inner most callback function
                                                          var nextIndex = index + 1;
                                                          if(templateDetailRecords.length > nextIndex)
                                                          GetDataForTemplateDetailsRecord(inputObj, templateDetailRecords, rec_Local_sf_Id, nextIndex, callbackFunction);// 8980 : need localId and also sfid with conditional OR
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
                      // 8980 : need localId and also sfid with conditional OR
                      templateDetailRecords[index].criteria = [{fieldName:hdr_ref_fld,fieldValue:ref_fld_Id,operator:'='},{fieldName:hdr_ref_fld,fieldValue:sfdcid,operator:'='}];
                      templateDetailRecords[index].advancedExpression = "( 1 or 2 )";
                      
                      // Temporary : To be inserted in the inner most callback function
                      var nextIndex = index + 1;
                      if(templateDetailRecords.length > nextIndex)
                      GetDataForTemplateDetailsRecord(inputObj, templateDetailRecords, rec_Local_sf_Id, nextIndex, callbackFunction);// 8980 : need localId and also sfid with conditional OR
                      else {
                      
                      callbackFunction(templateDetailRecords);
                      }
                      
                      }
                      }
                      });
}

function OPDGetDocumentData(inputObj, callbackFunction, context)
{
    //    alert("Calling OPDGetDocumentData !");
    /* Get doc_template_id from process_id from SFProcess table */
    
    var processId = inputObj.ProcessId;
    var recordId = inputObj.RecordId;
    
    var proName = "SFProcess";
    var profieldNames = [{fieldName:'docTemplateId',fieldType:'TEXT'},{fieldName:'sfID',fieldType:'TEXT'}];
    var procriteria = [{fieldName:'processId',fieldValue:processId,operator:'='}];
    var templateId = 0;
    
    //    alert("Fetch from SFProcess !");
    $DAL.executeQuery(proName,profieldNames,procriteria,null,null,function(request)
                      {
                      
                      if(request.response.statusCode != '1')
                      {
                      //alert("Data base error ");
                      }
                      else
                      {
                      
                      
                      var processRecord = request.response.objectData;
                      //                      alert("SFProcess record " + JSON.stringify(processRecord));
                      if(processRecord.length > 0)
                      {
                      
                      /* Get the doc_template_id from Process using ProcessId */
                      var processObj = processRecord[0];
                      templateId =  processObj.docTemplateId;
                      processSfid = processObj.sfID;
                      
                      /* Retrieve the doc_template_details corresponding to the record in JSON format */
                      var tdObj = "DocTemplateDetails";
                      var tdfields = [{fieldName:'docTemplate',fieldType:'TEXT'},{fieldName:'docTemplateDetailId',fieldType:'TEXT'},{fieldName:'headerReferenceField',fieldType:'TEXT'},{fieldName:'alias',fieldType:'TEXT'},{fieldName:'objectName',fieldType:'TEXT'},{fieldName:'soql',fieldType:'TEXT'},{fieldName:'docTemplateDetailUniqueId',fieldType:'TEXT'},{fieldName:'fields',fieldType:'TEXT'},{fieldName:'type',fieldType:'TEXT'},{fieldName:'idTable',fieldType:'TEXT'}];
                      var tdcriteria = [{fieldName:'docTemplate',fieldValue:templateId,operator:'='}];
                      
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
                                        // 8980 : need localId and also sfid with conditional OR
                                        // because the header object reference can be stored either as a local id or as an sfid
                                        var tablename = tdRecord.objectName;
                                        var fields = [{fieldName:'localId',fieldType:'TEXT'},{fieldName:'Id',fieldType:'TEXT'}];
                                        var criteria = [{fieldName:'localId',fieldValue:recordId,operator:'='}];
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
        var objectName = detailObject.objectName;
        
        var criteriaArray = detailObject.criteria;
        
        var advnExpr = detailObject.advancedExpression;
        var aliasName = detailObject.alias;
        
        var fieldNames = [];
        
        // 012895 - passing sortingOrder, innerJoin to native
        var sortingOrder = detailObject.sortingOrder;
        var innerJoin = detailObject.innerJoin;
        
        $DAL.parseSoqlJSOnObject(objectName, fieldNames, criteriaArray, advnExpr,jsonString, sortingOrder, innerJoin, function(request){
                                 
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
                                 
                                 //defect 11934
                                 if(fType ==  'datetime' ){
                                 fValue = $UTILITY.dateAndTimeForGMTString(fValue);
                                 
                                 }
                                 else if (fType == 'date'){
                                 fValue = $UTILITY.dateForGMTString(fValue);
                                 }
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
                                 //defect 11934
                                 if(newRtyp ==  'datetime' ){
                                 newRFnValue = $UTILITY.dateAndTimeForGMTString(newRFnValue);
                                 }
                                 else if (newRtyp == 'date'){
                                 newRFnValue = $UTILITY.dateForGMTString(newRFnValue);
                                 }
                                 
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
//Krishna : Last logo displayed : 9300
//There was no serialisation made for images, hence the last logo or image replaced all id's.

var callbackHolderForSubmitQuery = [];
var currentRequestOfSubmitQuery = null;

function SubmitQuery(queryParam, callbackFunction, context){
    
    if(queryParam.Query == null){
        return;
    }
    debugger;
    var qParams = {query:queryParam.Query,callback:callbackFunction};
    callbackHolderForSubmitQuery.push(qParams);
    
    
    if(currentRequestOfSubmitQuery == null) {
        
        currentRequestOfSubmitQuery = callbackHolderForSubmitQuery.shift();
        continueSubmitQuery(qParams.query);
    }
}

function continueSubmitQuery(query){
    
    if(query != null && query.length > 0){
        $DAL.submitQuery(query, function(request){
                         var resultArray  =request.response.objectData;
                         var currentRequest = currentRequestOfSubmitQuery;
                         var callbkFuntion = currentRequest.callback;
                         callbkFuntion.call({}, resultArray, 'SubmitQuery');
                         if(callbackHolderForSubmitQuery.length > 0) {
                         
                         currentRequestOfSubmitQuery = callbackHolderForSubmitQuery.shift();
                         continueSubmitQuery(currentRequestOfSubmitQuery.query);
                         }
                         else{
                         currentRequestOfSubmitQuery = null;
                         }
                         
                         });
    }
    
}

/* capture html content with data */
function captureData() {
    
    var capturedDat = document.documentElement.innerHTML;
    return capturedDat;
}

/* Fetch tags from local DB specific to OPDoc. Currently only for Finalize button. */
function OPDGetDisplayTags(request, callbackFunction, context)
{
    $COMM.requestDataForType("fetchdisplaytags","",function(responseObject) {
                             
                             // alert("Display tags " + JSON.stringify(responseObject));
                             callbackFunction.call(context, responseObject, 'GetDisplayTags');
                             OPDGetUserInfo(userInfoData.Input, userInfoData.Callback, userInfoData.Context);
                             
                             });
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
    var orgAddress = ""; // IPAD-4599
    
    $COMM.requestDataForType("relateduserinput","",function(dateString) {
                             
                             dateFrmt = dateString.dateformat;
                             //7594 defect - krishna
                             dateFrmt = dateFrmt.toUpperCase();
                             timeFrmt = dateString.timeformat;
                             amTxt = dateString.amtext;
                             pmTxt = dateString.pmtext;
                             userFullName = dateString.username;
                             orgAddress = dateString.orgAddress; // IPAD-4599
                             
                             var fieldNames = [{fieldName:'Id',fieldType:'TEXT'},{fieldName:'Name',fieldType:'TEXT'},{fieldName:'LocaleSidKey',fieldType:'TEXT'},{fieldName:'LanguageLocaleKey',fieldType:'TEXT'},{fieldName:'Street',fieldType:'TEXT'},{fieldName:'City',fieldType:'TEXT'},{fieldName:'State',fieldType:'TEXT'},{fieldName:'Country',fieldType:'TEXT'},{fieldName:'PostalCode',fieldType:'TEXT'}];
                             
                             var criteria = [{fieldName:'Name',fieldValue:userFullName,operator:'='}];
                             
                             $DAL.executeQuery(objectName,fieldNames,criteria,null,null,function(request){
                                               if(request.response.statusCode != '1')
                                               {
                                               //alert("Data base error ");
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
                                               
                                               var address = orgAddress; // // IPAD-4599 addressForData(streetString,cityString,stateString,postalCode,countryString);
                                               
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
                             
                             // 9733 -Ability to configure Signature Size for OutPut Document.
                             //Responding to request with width and height.
                             
                             var response = {uniqueName:request.UniqueName,path:signaturepath.Path,height:request.ImgHeight,width:request.ImgWidth};
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
