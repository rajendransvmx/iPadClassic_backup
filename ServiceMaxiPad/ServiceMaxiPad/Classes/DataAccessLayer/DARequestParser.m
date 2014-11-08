//
//  DARequestParser.m
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import "DARequestParser.h"
#import "Utility.h"
#import "SFMPageHelper.h"

#import "DBRequestSelect.h"
#import "DatabaseManager.h"

#import "SVMXDatabaseMaster.h"
#import "SFExpression.h"
#import "SFExpressionComponentModel.h"
#import "SFExpressionParser.h"

#define kDARelation @"relation"
#define kFN         @"FN"
#define kRFN        @"RFN"
#define kRFN2       @"RFN2"

#define kTYP        @"TYP"
#define kRTYP       @"RTYP"
#define kRTYP2      @"RTYP2"

#define kOBJ        @"OBJ"
#define kROBJ       @"ROBJ"
#define kROBJ2      @"ROBJ2"

#define kRLN        @"RLN"
#define kRLN2       @"RLN2"



@interface DARequestParser()

- (NSString *)getExpressionForCriteriaObject:(NSDictionary *)criteriaDict andObjectName:(NSString *)objectName;
- (NSArray *)getWhereClauseForQuery:(DARequest *)requestObject;
@end

@implementation DARequestParser

@synthesize numberArray;


- (id)init {
    self = [super init];
    if (self != nil) {
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (int counter = 0; counter < 10; counter++) {
            NSString *someString = [NSString stringWithFormat:@"%d",counter];
            [tempArr addObject:someString];
        }
        self.numberArray = tempArr;
        tempArr = nil;
    }
    return self;
}
- (NSString *)selectSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject {
    
    /* Parse the fields and create sqlite query */
//    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:@"SELECT "];
//    
//    
//    if ([requestObject.objectName isEqualToString:@"SFExpressionComponent"])
//    {
//        [finalQuery appendFormat:@" DISTINCT "];
//    }
    
    /* Adding FIELDS TO BE SELECTED */
    NSArray *fieldsArray = requestObject.fieldsArray;
    NSMutableArray *fieldsArrayNew = nil;
    if ([fieldsArray count] > 0) {
        fieldsArrayNew = [[NSMutableArray alloc] init];
        for (int counter = 0; counter < [fieldsArray count]; counter++) {
            
            NSDictionary *fieldDictionary = [fieldsArray objectAtIndex:counter];
            NSString *fieldName =  [fieldDictionary objectForKey:kDAFieldName];
            if (![Utility isStringEmpty:fieldName]) {
                [fieldsArrayNew addObject:fieldName];
            }
        }
    }
    else{
        fieldsArrayNew = nil;
    }
    

    /* Adding CRTIERIA PART and Parsing advance expression */
 //   NSArray *whereClause =  [self getWhereClauseForQuery:requestObject];
//    if (whereClause != nil) {
//        [finalQuery appendFormat:@" WHERE %@ ",whereClause];
//    }
    
    NSArray *whereCriteria = [self getWhereClauseForQuery:requestObject];;
    NSString *advancedExpression = requestObject.advanceExpression;
    
    DBRequestSelect *selectObject = [[DBRequestSelect alloc] initWithTableName:requestObject.objectName andFieldNames:fieldsArrayNew whereCriterias:whereCriteria andAdvanceExpression:advancedExpression];
    if (![Utility isStringEmpty:requestObject.orderBy]) {
        [selectObject addOrderByFields:@[requestObject.orderBy]];
    }
    
    return [selectObject query];
}


- (NSArray *)getWhereClauseForQuery:(DARequest *)requestObject {
    
    if ([requestObject.criteriaArray count] <= 0) {
        return nil;
    }
    BOOL expressionNeed = NO;
    if ([Utility isStringEmpty:requestObject.advanceExpression]) {
        expressionNeed = YES;
    }
    NSMutableArray *expressionArray = [[NSMutableArray alloc] init];
    NSMutableString *finalString = [[NSMutableString alloc] init];
    NSInteger arrayCount = [requestObject.criteriaArray count];
    for (int counter = 0; counter < arrayCount; counter++) {
        
        NSDictionary *criteriaDict = [requestObject.criteriaArray objectAtIndex:counter];
        NSString *fieldName =       [criteriaDict objectForKey:kDAFieldName];
        NSString *fieldValue =      [criteriaDict objectForKey:kDAFieldValue];
        NSString *operatorValue =   [criteriaDict objectForKey:kDAOperator];
       // NSString *fieldType     =   [criteriaDict objectForKey:kDAFieldType];
        
        SFExpressionComponentModel *expression = [[SFExpressionComponentModel alloc] init];
        expression.componentLHS = fieldName;
        expression.componentRHS = fieldValue;
        expression.operatorValue = operatorValue;
        expression.fieldType = @"TEXT";
    //    [expression replaceExpressionValues];
        
        [expressionArray addObject:expression];
        if (expressionNeed) {
            if (counter == 0) {
                [finalString appendFormat:@" %d ",(counter +1)];
            }
            else {
                [finalString appendFormat:@" AND %d",(counter +1)];
            }
        }
    }
    if (expressionNeed) {
        requestObject.advanceExpression = finalString;
    }
    
    SFExpressionParser *parser = [[SFExpressionParser alloc] initWithExpressionId:nil objectName:requestObject.objectName];
    //NSString *finalExpression = @""; // [parser decodeExpression:requestObject.advanceExpression components:expressionArray];
    
    NSArray *criteriaArray = [parser expressionCriteriaObjectsForComponents:expressionArray];
    return criteriaArray;
}
//8906
- (NSString *)getExpressionForCriteriaObject:(NSDictionary *)criteriaDict andObjectName:(NSString *)objectName {
    
     criteriaDict = [self getOperatorForString:criteriaDict ];
    
    NSString *fieldName = [criteriaDict objectForKey:kDAFieldName];
    NSString *fieldValue = [criteriaDict objectForKey:kDAFieldValue];
    NSString *operatorValue = [criteriaDict objectForKey:kDAOperator];
    
    //8906
    NSDictionary *fieldInfo = [[SVMXDatabaseMaster sharedDataBaseMaterObject] getFieldTypeForFieldName:fieldName Object:objectName];
    NSString *fieldType = [fieldInfo objectForKey:@"type"];
    
   
    if (![Utility isStringEmpty:fieldName] && ![Utility isStringEmpty:operatorValue]) {
       
        NSString *expression = nil;
        
        if([operatorValue isEqualToString:@"is not null"])
        {
            expression = [NSString stringWithFormat:@" ( %@ is not null and  ( trim(%@) != '') ) ",fieldName,fieldName];
        }
        else if ([operatorValue isEqualToString:@"null"])
        {
            expression = [NSString stringWithFormat:@" ( %@ = ' ' OR  trim(%@) = '' OR %@ is null ) ",fieldName,fieldName,fieldName];
        }
        else if ([fieldType isEqualToString:@"reference"]) {
            
            if ([fieldName isEqualToString:@"RecordTypeId"]) {
                expression = [NSString stringWithFormat:@" %@   in   (select  record_type_id  from SFRecordType where record_type %@ '%@' )" ,fieldName, operatorValue,fieldValue];
                if ([operatorValue isEqualToString: @"!="] || [operatorValue isEqualToString: @" NOT LIKE "]){
                    expression = [NSString stringWithFormat:@"( %@  OR %@ = \"\" OR %@ isnull)",expression,fieldName,fieldName];
                }
                
            }
            else{
                NSString *referenceToTable = [fieldInfo objectForKey:@"object"];
                NSString *nameFieldValue = [[SVMXDatabaseMaster sharedDataBaseMaterObject] getNameFieldForObject:objectName];
                
                
                if (![Utility isStringEmpty:referenceToTable]) {
                    expression = [NSString stringWithFormat:@" ( %@   in   (select  Id  from '%@' where ( %@ %@ '%@')) OR %@   in   (select  localId  from '%@' where (%@ %@ '%@')))" , fieldName,referenceToTable ,nameFieldValue, operatorValue ,fieldValue,fieldName,referenceToTable ,nameFieldValue, operatorValue ,fieldValue];
                    
                }
                
                if ([operatorValue isEqualToString: @"!="] || [operatorValue isEqualToString: @" NOT LIKE "]){
                    expression = [NSString stringWithFormat:@"( %@  OR %@ = \"\" OR %@ isnull)",expression,fieldName,fieldName];
                }
                else{
                    expression = [NSString stringWithFormat:@" ( ( %@ %@ '%@' ) OR %@ )",fieldName,operatorValue,fieldValue,expression];
                }
            }
        }
        else{
            if([fieldType isEqualToString:@"boolean"]) {
                
                //010425
                NSString *boolValue = [NSString stringWithFormat:@"%d",[fieldValue boolValue]];
                expression = [NSString stringWithFormat:@"( %@ %@ '%@' OR %@ %@ '%@') ",fieldName,operatorValue,fieldValue,fieldName,operatorValue,boolValue];
            }
            else {
                expression = [NSString stringWithFormat:@" %@ %@ '%@'",fieldName,operatorValue,fieldValue];
            }
            if ([operatorValue isEqualToString: @"!="] || [operatorValue isEqualToString: @" NOT LIKE "]){
                expression = [NSString stringWithFormat:@"( %@  OR %@ = \"\" OR %@ is null)",expression,fieldName,fieldName];
            }
        }
        
        return expression  ;
    }
    return nil;
}



- (NSString *)insertSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject {
    
    /* Parse the fields and create sqlite query */
    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:@"INSERT INTO  "];
    [finalQuery appendFormat:@"%@ ",requestObject.objectName];
    
    /* Adding FIELDS TO BE SELECTED */
    NSArray *fieldsArray = requestObject.fieldsArray;
    if ([fieldsArray count] > 0) {
        NSMutableArray *fieldsArrayNew = [[NSMutableArray alloc] init];
        NSMutableArray *valueArray = [[NSMutableArray alloc] init];
        for (int counter = 0; counter < [fieldsArray count]; counter++) {
            
            NSDictionary *fieldDictionary = [fieldsArray objectAtIndex:counter];
            NSString *fieldName =  [fieldDictionary objectForKey:kDAFieldName];
            if (![Utility isStringEmpty:fieldName]) {
                [fieldsArrayNew addObject:fieldName];
            }
            
            NSString *fieldValue =  [fieldDictionary objectForKey:kDAFieldValue];
            if (![Utility isStringEmpty:fieldValue]) {
                [valueArray addObject:fieldValue];
            }
            else {
                [valueArray addObject:@""];
            }
            
        }
        NSString *secondPartOfQuery = [Utility getConcatenatedStringFromArray:fieldsArrayNew withSingleQuotesAndBraces:NO];
        
        NSString *valuePartOfQuery = [Utility getConcatenatedStringFromArray:valueArray withSingleQuotesAndBraces:YES];
        
        if (secondPartOfQuery != nil) {
            [finalQuery appendFormat:@" ( %@ ) ",secondPartOfQuery];
        }
        
        if (valuePartOfQuery != nil) {
            [finalQuery appendFormat:@" VALUES  %@  ",valuePartOfQuery];
        }
        
        fieldsArrayNew = nil;
        valueArray = nil;
    }
        
   return finalQuery;
}

- (NSString *)updateSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject {
    
    /* Parse the fields and create sqlite query */
    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:@"UPDATE "];
    
    [finalQuery appendFormat:@"%@ SET ",requestObject.objectName];
    
    /* Adding FIELDS TO BE SELECTED */
    NSArray *fieldsArray = requestObject.fieldsArray;
    if ([fieldsArray count] > 0) {
        NSMutableArray *fieldsArrayNew = [[NSMutableArray alloc] init];
        for (int counter = 0; counter < [fieldsArray count]; counter++) {
            
            NSDictionary *fieldDictionary = [fieldsArray objectAtIndex:counter];
            NSString *fieldName =  [fieldDictionary objectForKey:kDAFieldName];
            if (![Utility isStringEmpty:fieldName]) {
                
                NSString *fieldValue =  [fieldDictionary objectForKey:kDAFieldValue];
                if ([Utility isStringEmpty:fieldValue]) {
                     fieldValue = @"";
                }
                
                if (counter == 0) {
                    [finalQuery appendFormat:@" %@ = '%@'",fieldName,fieldValue];
                }
                else {
                    [finalQuery appendFormat:@", %@ = '%@'",fieldName,fieldValue];
                }
                
            }
        }
        fieldsArrayNew = nil;
    }
    
    /* Adding CRTIERIA PART and Parsing advance expression */
    NSArray *whereClause =  [self getWhereClauseForQuery:requestObject];
    if (whereClause != nil) {
        [finalQuery appendFormat:@" WHERE %@ ",whereClause];
    }
    
    return finalQuery;
}

- (NSString *)deleteSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject {
    
    /* Parse the fields and create sqlite query */
    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:@"DELETE FROM "];
    
    [finalQuery appendFormat:@" %@ ",requestObject.objectName];
    
   /* Adding CRTIERIA PART and Parsing advance expression */
    NSArray *whereClause =  [self getWhereClauseForQuery:requestObject];
    if (whereClause != nil) {
        [finalQuery appendFormat:@" WHERE %@ ",whereClause];
    }
    return finalQuery;
}



- (NSMutableDictionary *)parseJsonToSqlFunction:(NSArray *)allObjects
                                    andRecordId:(NSString *)recordIdentifier
                            andRecordDictionary:(NSDictionary *)recordDictionary {
    
    NSMutableDictionary *mainObjectDictionary = [[NSMutableDictionary alloc] init];
     /* Shravya - 7805*/
    NSMutableDictionary *nameFieldValueDictionary = [[NSMutableDictionary alloc] init];
    
    for (int counter = 0; counter < [allObjects count]; counter++) {
        
        
        /*  each object has FN, RLN, OBJ etc */
        NSDictionary *tableFields = [allObjects objectAtIndex:counter];
        NSString *firstRecordValue = nil;
        NSString *secondRecordValue = nil;
        
        for (int i = 0; i < 3; i++) {
            
            if (i == 0) {
                
                NSString *fieldName = [tableFields objectForKey:kFN];
                NSString *fieldTypeName = [tableFields objectForKey:kTYP];
                NSString *fieldValue =  [recordDictionary objectForKey:fieldName];
                if (fieldValue == nil) {
                    fieldValue = @"";
                }
                [mainObjectDictionary setObject:fieldValue forKey:fieldName];
                 firstRecordValue = fieldValue;
                if (![fieldTypeName isEqualToString:@"reference"]) {
                   
                        break;
                }
           } else if(i == 1){
                NSString *relationship = [tableFields objectForKey:kRLN];
                NSString *fieldName = [tableFields objectForKey:kRFN];
                NSString *objectName = [tableFields objectForKey:kROBJ];
                NSString *fieldTypeName = [tableFields objectForKey:kRTYP];
                NSString *fieldValue = [[SVMXDatabaseMaster sharedDataBaseMaterObject] executeQuery:fieldName andObjectName:objectName andCriria:[NSString stringWithFormat:@" ( localId = '%@' OR Id = '%@' )",firstRecordValue,firstRecordValue]];//8980
               
               /* Shravya - 7805*/
               if ([Utility isStringEmpty:fieldValue] && ![fieldTypeName isEqualToString:@"reference"]) {
                   NSString  *nameField = [nameFieldValueDictionary objectForKey:objectName];
                   if (nameField == nil) {
                       nameField = [[SVMXDatabaseMaster sharedDataBaseMaterObject] getNameFieldForObject:objectName];
                       if (nameField != nil && objectName != nil) {
                           [nameFieldValueDictionary setObject:nameField forKey:objectName];
                       }
                   }
                   if ([fieldName isEqualToString:nameField]) {
                       fieldValue = [[SVMXDatabaseMaster sharedDataBaseMaterObject] getNameValueForId:firstRecordValue];
                   }
               }
               /* Shravya - 7805*/
               
                if (fieldValue == nil) {
                    fieldValue = @"";
                }
               //defect 7744 : shravya converting 1/0 to true/false [OPDOC3]
               NSString *lowerFieldType = [fieldTypeName lowercaseString];
               if ([lowerFieldType isEqualToString:@"boolean"] || [lowerFieldType isEqualToString:@"bool"] ){
                   if ([Utility isItTrue:fieldValue]) {
                       fieldValue = @"true";
                   }
                   else{
                       fieldValue = @"false";
                   }
               }

//               NSString *lowerFieldType = [fieldTypeName lowercaseString];
//               if ([lowerFieldType isEqualToString:@"date"] || [lowerFieldType isEqualToString:@"datetime"] ) {
//                   NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:fieldName,@"fn", nil];
//               }
                if (relationship != nil)
                {
                    NSMutableDictionary *relationShipDict = [mainObjectDictionary objectForKey:relationship];
                    if (relationShipDict == nil) {
                        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                        [mainObjectDictionary setObject:tempDict forKey:relationship];
                        
                        tempDict = nil;
                        relationShipDict = [mainObjectDictionary objectForKey:relationship];
                    }
                    
                    [relationShipDict setObject:fieldValue forKey:fieldName];
                    secondRecordValue = fieldValue;
                    NSString *relationship2 = [tableFields objectForKey:kRLN2];
                    if (![fieldTypeName isEqualToString:@"reference"] || relationship2 == nil) {
                        
                        break;
                    }

                }
                else {
                    break;
                }
                
            }else if (i == 2) {
                NSString *relationship2 = [tableFields objectForKey:kRLN2];
                NSString *relationship1 = [tableFields objectForKey:kRLN];
                NSString *fieldName = [tableFields objectForKey:kRFN2];
                NSString *objectName = [tableFields objectForKey:kROBJ2];
                NSString *fieldValue = [[SVMXDatabaseMaster sharedDataBaseMaterObject] executeQuery:fieldName andObjectName:objectName andCriria:[NSString stringWithFormat:@" ( localId = '%@' OR Id = '%@' )",secondRecordValue,secondRecordValue]];//8980
                
                /* Shravya - 7805*/
                if ([Utility isStringEmpty:fieldValue]) {
                    NSString  *nameField = [nameFieldValueDictionary objectForKey:objectName];
                    if (nameField == nil && objectName != nil) {
                        nameField = [[SVMXDatabaseMaster sharedDataBaseMaterObject] getNameFieldForObject:objectName];
                        if (nameField != nil) {
                            [nameFieldValueDictionary setObject:nameField forKey:objectName];
                        }
                    }
                    if ([fieldName isEqualToString:nameField]) {
                        fieldValue = [[SVMXDatabaseMaster sharedDataBaseMaterObject] getNameValueForId:secondRecordValue];
                    }
                }
                /* Shravya - 7805*/
                
                if (fieldValue == nil) {
                    fieldValue = @"";
                }
                NSMutableDictionary *relationshipDict1 = [mainObjectDictionary objectForKey:relationship1];
                if (relationshipDict1 != nil) {
                    
                    NSMutableDictionary *relationShipDict2 = [relationshipDict1 objectForKey:relationship2];
                    if (relationShipDict2 == nil) {
                        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                        [relationshipDict1 setObject:tempDict forKey:relationship2];
                        tempDict = nil;
                        relationShipDict2 = [relationshipDict1 objectForKey:relationship2]; // 9450 : Corrected the misplaced variable name.
                    }
                    
                     [relationShipDict2 setObject:fieldValue forKey:fieldName];
                    
                    break;
                }
            }
        }
    }
    /* Shravya - 7805*/
    nameFieldValueDictionary = nil;
    return mainObjectDictionary;
}

- (NSArray *)parseFieldsFromQuery:(NSString *)query {
   
    query = [query stringByReplacingOccurrencesOfString:@"select " withString:@""];
    query = [query stringByReplacingOccurrencesOfString:@"SELECT " withString:@""];
    query = [query stringByReplacingOccurrencesOfString:@"Select " withString:@""];
    query = [query stringByReplacingOccurrencesOfString:@"DISTINCT " withString:@""];
     
    
    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:query];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @"FROM.*" options:0 error:nil];
    
    [regex replaceMatchesInString:finalQuery options:0 range:NSMakeRange(0, [finalQuery length]) withTemplate:@""];
    
    
    query = [finalQuery stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *fieldNames = [query componentsSeparatedByString:@","];
    if ([fieldNames count] <= 0) {
        //Modified shravya - OPDOC-CR
        finalQuery = nil;
        return nil;
    }
    NSMutableArray *finalArray = [[NSMutableArray alloc] init ];
    for (int counter = 0; counter < [fieldNames count]; counter++) {
        NSString *fieldName = [fieldNames objectAtIndex:counter];
        fieldName = [fieldName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSMutableDictionary *fieldDict = [[NSMutableDictionary alloc] init];
        [fieldDict setObject:fieldName forKey:kDAFieldName];
        [fieldDict setObject:@"TEXT" forKey:kDAFieldType];
        [finalArray addObject:fieldDict];
        fieldDict = nil;
    }
    finalQuery = nil;
    return finalArray;
}

- (NSDictionary *)getOperatorForString:(NSDictionary *)criterion  {
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:criterion];
    NSString *operator = [tempDict objectForKey:kDAOperator];
    
    //Modified shravya - OPDOC-CR
    //NSString *lhs = [tempDict objectForKey:kDAFieldName]; //uncoment this if we need lhs

    
    NSString *rhs = [tempDict objectForKey:kDAFieldValue];
    NSString *operator_ = operator;
    
    if([operator isEqualToString:@"eq"])
    {
        operator_  = @"=";
    }
    else if([operator isEqualToString:@"gt"])
    {
        operator_  = @">";
    }
    else if([operator isEqualToString:@"lt"])
    {
        operator_  = @"<";
    }
    else if([operator isEqualToString:@"Less or Equal To"])
    {
         operator_  = @"<=";
    }
    else if ([operator isEqualToString:@"ne"])
    {
        operator_  = @"!=";
    }
    else if ([operator isEqualToString:@"ge"])
    {
        operator_  = @">=";
    }
    else if ([operator isEqualToString:@"le"])
    {
        operator_  = @"<=";
    }
    else if([operator isEqualToString:@"isnotnull"])
    {
           
           operator_ = @"is not null";
           rhs = @"";
    }
    else if([operator isEqualToString:@"contains"])
    {
           operator_ = @" LIKE ";
           NSString * temp = [NSString stringWithFormat:@"%%%@%%",rhs];
           rhs = temp;
    }
    else if([operator isEqualToString:@"notcontain"])
       {
           operator_ =  @" NOT LIKE ";
           NSString * temp = [NSString stringWithFormat:@"%%%@%%",rhs];
           rhs = temp;
       }
       else if ([operator isEqualToString:@"in"])
       {
           
           operator_ = @" LIKE ";
           NSString * temp = [NSString stringWithFormat:@"%%%@%%",rhs];
           rhs = temp;
       }
       else if ([operator isEqualToString:@"notin"])
       {
           operator_ =  @" NOT LIKE ";
           NSString * temp = [NSString stringWithFormat:@"%%%@%%",rhs];
           rhs = temp;
       }
       else if ([operator  isEqualToString:@"starts"])
       {
           operator_ = @" LIKE ";
           //8906
           NSString * temp = [NSString stringWithFormat:@"%@%%",rhs];
           rhs = temp;
       }
       else if([operator  isEqualToString:@"isnull"])
       {
         
           operator_ = @"is null";
           rhs = @"";
       }
    
    [tempDict setObject:rhs forKey:kDAFieldValue];
    [tempDict setObject:operator_ forKey:kDAOperator];
    return tempDict;
}

//8906
- (NSString *)decodeAdvanceExpression:(NSString *)newAdvanceExpression andExpressionArray:(NSArray *)expressionArray withObjectName:(NSString *)objectName{
    
    NSInteger totalCharactersAdded = 0;
    NSMutableString *decodedString = [[NSMutableString alloc] initWithString:newAdvanceExpression];
    for (int counter = 0; counter < [newAdvanceExpression length]; counter++) {
        
        NSRange range = NSMakeRange(counter, 1);
        NSString *aCharacter = [newAdvanceExpression substringWithRange:range];
       if (![aCharacter isEqualToString:@""] && ![aCharacter isEqualToString:@" "]) {
            
            NSInteger someIntValue = [aCharacter intValue];
            if (someIntValue > 0 && (counter + 1) < [newAdvanceExpression length]) {
                NSRange rangeSecond = NSMakeRange(counter+1, 1);
                NSString *aSecCharacter = [newAdvanceExpression substringWithRange:rangeSecond];
                if ([self isNumber:aSecCharacter]) {
                    NSString *finChar =  [aCharacter stringByAppendingFormat:@"%@",aSecCharacter];
                    someIntValue = [finChar intValue];
                    aCharacter = finChar;
                    range.length = 2;
                    counter++;
                }
            }
            if (someIntValue > 0 && [expressionArray count] > (someIntValue - 1)  ) {
                
                NSDictionary *expressionDict = [expressionArray objectAtIndex:someIntValue - 1];
                //8906
                NSString *expression = [self getExpressionForCriteriaObject:expressionDict andObjectName:objectName];
                if (![Utility isStringEmpty:expression]) {
                    
                    NSString *finalExpr = [NSString stringWithFormat:@" %@ ",expression];
                    
                    range.location = range.location + totalCharactersAdded;
                    [decodedString replaceOccurrencesOfString:aCharacter withString:finalExpr options:NSLiteralSearch range:range];
                    totalCharactersAdded = totalCharactersAdded + finalExpr.length - aCharacter.length;
                }
            }
        }
    }
    
    return decodedString;
}

- (BOOL)isNumber:(NSString *)string {
    
    for (int counter = 0; counter < [self.numberArray count]; counter++) {
        if ([string isEqualToString:[self.numberArray objectAtIndex:counter]]) {
            return YES;
        }
    }
    return NO;
}

@end
