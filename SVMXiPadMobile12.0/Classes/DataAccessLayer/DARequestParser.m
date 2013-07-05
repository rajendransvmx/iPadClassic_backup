//
//  DARequestParser.m
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import "DARequestParser.h"
#import "Utility.h"
#import "SVMXDatabaseMaster.h"

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
- (NSString *)getExpressionForCriteriaObject:(NSDictionary *)criteriaDict;
- (NSString *)getWhereClauseForQuery:(DARequest *)requestObject;
@end

@implementation DARequestParser

@synthesize numberArray;

- (void)dealloc {
    [numberArray release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (int counter = 0; counter < 10; counter++) {
            NSString *someString = [NSString stringWithFormat:@"%d",counter];
            [tempArr addObject:someString];
        }
        self.numberArray = tempArr;
        [tempArr release];
        tempArr = nil;
    }
    return self;
}
- (NSString *)selectSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject {
    
    /* Parse the fields and create sqlite query */
    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:@"SELECT "];
    
    /* Adding FIELDS TO BE SELECTED */
    NSArray *fieldsArray = requestObject.fieldsArray;
    if ([fieldsArray count] > 0) {
        NSMutableArray *fieldsArrayNew = [[NSMutableArray alloc] init];
        for (int counter = 0; counter < [fieldsArray count]; counter++) {
            
            NSDictionary *fieldDictionary = [fieldsArray objectAtIndex:counter];
            NSString *fieldName =  [fieldDictionary objectForKey:kDAFieldName];
            if (![Utility isStringEmpty:fieldName]) {
                [fieldsArrayNew addObject:fieldName];
            }
        }
        NSString *secondPartOfQuery = [Utility getConcatenatedStringFromArray:fieldsArrayNew withSingleQuotesAndBraces:NO];
        
        if (secondPartOfQuery != nil) {
            [finalQuery appendFormat:@" %@ ",secondPartOfQuery];
        }
        [fieldsArrayNew release];
        fieldsArrayNew = nil;
    }
    else {
        [finalQuery appendFormat:@" * "];
    }
    
    
    /* Adding FROM OBJECT */
    [finalQuery appendFormat:@" FROM %@ ",requestObject.objectName];
    
    
    /* Adding CRTIERIA PART and Parsing advance expression */
    NSString *whereClause =  [self getWhereClauseForQuery:requestObject];
    if (whereClause != nil) {
        [finalQuery appendFormat:@" WHERE %@ ",whereClause];
    }
    
    /* Adding order by clause */
    if (![Utility isStringEmpty:requestObject.orderBy]) {
        [finalQuery appendFormat:@" ORDER BY %@ ",requestObject.orderBy];
    }
    
    return [finalQuery autorelease];
}

- (NSString *)getWhereClauseForQuery:(DARequest *)requestObject {
    
    if ([requestObject.criteriaArray count] <= 0) {
        return nil;
    }
    
    NSMutableString *finalString = [[NSMutableString alloc] init];

    if ([Utility isStringEmpty:requestObject.advanceExpression]) {
        NSInteger someCount = [requestObject.criteriaArray count];
        if ([requestObject.criteriaArray count] > 0) {
            for (int counter = 0; counter < someCount; counter++) {
                NSDictionary *criteriaDict  = [requestObject.criteriaArray objectAtIndex:counter];
                if (criteriaDict == nil || [criteriaDict count] <= 0) {
                    continue;
                }
                NSString *criteria = [self getExpressionForCriteriaObject:criteriaDict];
                if (![Utility  isStringEmpty:criteria]) {
                    
                    if (counter == 0) {
                        [finalString appendFormat:@" %@ ",criteria];
                    }
                    else {
                        [finalString appendFormat:@" AND %@",criteria];
                    }

                }
            }
        }
    }
    else {
        
        /* Adding advanced expression */
       NSString *advanceExpressionNew = [self decodeAdvanceExpression:requestObject.advanceExpression andExpressionArray:requestObject.criteriaArray];
        if (![Utility isStringEmpty:advanceExpressionNew]) {
            [finalString appendFormat:@" %@ ",advanceExpressionNew];
        }
    }
    return [finalString autorelease];
}

- (NSString *)getExpressionForCriteriaObject:(NSDictionary *)criteriaDict {
    
    
    criteriaDict = [self getOperatorForString:criteriaDict];
    
    NSString *fieldName = [criteriaDict objectForKey:kDAFieldName];
    NSString *fieldValue = [criteriaDict objectForKey:kDAFieldValue];
    NSString *operatorValue = [criteriaDict objectForKey:kDAOperator];
    
   
    if (![Utility isStringEmpty:fieldName] && ![Utility isStringEmpty:operatorValue]) {
        NSString *expression = [NSString stringWithFormat:@" %@ %@ '%@' ",fieldName,operatorValue,fieldValue];
        return expression  ;
    }
    return nil;
}

/*- (NSString *)decodeAdvanceExpression:(NSString *)newAdvanceExpression andExpressionArray:(NSArray *)expressionArray {
    
    NSInteger totalCharactersAdded = 0;
    NSMutableString *decodedString = [[NSMutableString alloc] initWithString:newAdvanceExpression];
    for (int counter = 0; counter < [newAdvanceExpression length]; counter++) {
        
        NSRange range = NSMakeRange(counter, 1);
        NSString *aCharacter = [newAdvanceExpression substringWithRange:range];
        if (![aCharacter isEqualToString:@""] && ![aCharacter isEqualToString:@" "]) {
            
            NSInteger someIntValue = [aCharacter intValue];
            if (someIntValue > 0 && [expressionArray count] > (someIntValue - 1)  ) {
                
                NSDictionary *expressionDict = [expressionArray objectAtIndex:someIntValue - 1];
                NSString *expression = [self getExpressionForCriteriaObject:expressionDict];
                if (![Utility isStringEmpty:expression]) {
                    
                    NSString *finalExpr = [NSString stringWithFormat:@" %@ ",expression];
                   
                    range.location = range.location + totalCharactersAdded;
                    [decodedString replaceOccurrencesOfString:aCharacter withString:finalExpr options:NSLiteralSearch range:range];
                     totalCharactersAdded = totalCharactersAdded + finalExpr.length - 1;
                }
            }
        }
    }
    
    return [decodedString autorelease];
}*/

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
        
        [fieldsArrayNew release];
        fieldsArrayNew = nil;
        [valueArray release];
        valueArray = nil;
    }
        
   return [finalQuery autorelease];
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
        [fieldsArrayNew release];
        fieldsArrayNew = nil;
    }
    
    /* Adding CRTIERIA PART and Parsing advance expression */
    NSString *whereClause =  [self getWhereClauseForQuery:requestObject];
    if (whereClause != nil) {
        [finalQuery appendFormat:@" WHERE %@ ",whereClause];
    }
    
    return [finalQuery autorelease];
}

- (NSString *)deleteSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject {
    
    /* Parse the fields and create sqlite query */
    NSMutableString *finalQuery = [[NSMutableString alloc] initWithString:@"DELETE FROM "];
    
    [finalQuery appendFormat:@" %@ ",requestObject.objectName];
    
   /* Adding CRTIERIA PART and Parsing advance expression */
    NSString *whereClause =  [self getWhereClauseForQuery:requestObject];
    if (whereClause != nil) {
        [finalQuery appendFormat:@" WHERE %@ ",whereClause];
    }
    return [finalQuery autorelease];
}



- (NSMutableDictionary *)parseJsonToSqlFunction:(NSArray *)allObjects
                                    andRecordId:(NSString *)recordIdentifier
                            andRecordDictionary:(NSDictionary *)recordDictionary {
    
    NSMutableDictionary *mainObjectDictionary = [[NSMutableDictionary alloc] init];
    
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
                NSString *fieldValue = [[SVMXDatabaseMaster sharedDataBaseMaterObject] executeQuery:fieldName andObjectName:objectName andCriria:[NSString stringWithFormat:@" Id = '%@'",firstRecordValue]];
                if (fieldValue == nil) {
                    fieldValue = @"";
                }
                if (relationship != nil) {
                    NSMutableDictionary *relationShipDict = [mainObjectDictionary objectForKey:relationship];
                    if (relationShipDict == nil) {
                        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                        [mainObjectDictionary setObject:tempDict forKey:relationship];
                        [tempDict release];
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
                NSString *fieldValue = [[SVMXDatabaseMaster sharedDataBaseMaterObject] executeQuery:fieldName andObjectName:objectName andCriria:[NSString stringWithFormat:@" Id = '%@'",secondRecordValue]];
                if (fieldValue == nil) {
                    fieldValue = @"";
                }
                NSMutableDictionary *relationshipDict1 = [mainObjectDictionary objectForKey:relationship1];
                if (relationshipDict1 != nil) {
                    
                    NSMutableDictionary *relationShipDict2 = [relationshipDict1 objectForKey:relationship2];
                    if (relationShipDict2 == nil) {
                        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                        [relationshipDict1 setObject:tempDict forKey:relationship2];
                        [tempDict release];
                        tempDict = nil;
                        relationShipDict2 = [mainObjectDictionary objectForKey:relationship2];
                    }
                    
                     [relationShipDict2 setObject:fieldValue forKey:fieldName];
                    
                    break;
                }
            }
        }
    }
    return [mainObjectDictionary autorelease];
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
        [fieldDict release];
        fieldDict = nil;
    }
    [finalQuery release];
    finalQuery = nil;
    return [finalArray autorelease];
}

- (NSDictionary *)getOperatorForString:(NSDictionary *)criterion  {
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:criterion];
    NSString *operator = [tempDict objectForKey:kDAOperator];
    NSString *lhs = [tempDict objectForKey:kDAFieldName];
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
           NSString * temp = [NSString stringWithFormat:@"%%%@%%",rhs];
           rhs = temp;
       }
       else if([operator  isEqualToString:@"isnull"])
       {
         
           operator_ = @"is null";
           rhs = @"";
       }
    
    [tempDict setObject:rhs forKey:kDAFieldValue];
    [tempDict setObject:operator_ forKey:kDAOperator];
    return [tempDict autorelease];
}


- (NSString *)decodeAdvanceExpression:(NSString *)newAdvanceExpression andExpressionArray:(NSArray *)expressionArray {
    
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
                NSString *expression = [self getExpressionForCriteriaObject:expressionDict];
                if (![Utility isStringEmpty:expression]) {
                    
                    NSString *finalExpr = [NSString stringWithFormat:@" %@ ",expression];
                    
                    range.location = range.location + totalCharactersAdded;
                    [decodedString replaceOccurrencesOfString:aCharacter withString:finalExpr options:NSLiteralSearch range:range];
                    totalCharactersAdded = totalCharactersAdded + finalExpr.length - aCharacter.length;
                }
            }
        }
    }
    
    return [decodedString autorelease];
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
