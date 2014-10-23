//
//  DependentPickListParser.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/**
 *  @file   DependentPickListParser.h
 *  @class  DependentPickListParser
 *
 *  @brief
 *
 *   This class is used to parse dependent picklist responce
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "DependentPickListParser.h"
#import "SFPicklistModel.h"
#import "SFObjectFieldModel.h"
#import "FactoryDAO.h"
#import "SFPicklistService.h"
#import "SFPicklistDAO.h"
#import "SFObjectFieldService.h"
#import "DatabaseConstant.h"

@implementation DependentPickListParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData
{
    @synchronized([self class]){
        @autoreleasepool {
            
            // NSArray *callBackObjects = (NSArray *)callBkData;
            ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
            
            [self parseDatAndInsertIntoPicklistTable:responseData];
            
            NSDictionary *requestInformationDict = requestParamModel.requestInformation;
            
            NSMutableArray *remainingObjects = [requestInformationDict objectForKey:@"remainingObjects"];
            
            if (remainingObjects != nil && [remainingObjects count] > 0) {
                
                callBackObj.callBack = YES;
            }
            
            if ([remainingObjects count] > 0) {
                [requestParamModel.requestInformation setValue:[remainingObjects objectAtIndex:0] forKey:@"currentObject"];
                [remainingObjects removeObjectAtIndex:0];
            }
            [requestParamModel.requestInformation setValue:remainingObjects forKey:@"remainingObjects"];
            callBackObj.callBackData = requestParamModel;
            return callBackObj;
        }
        return nil;
    }
}


-(void)parseDatAndInsertIntoPicklistTable:(id)pickListDict
{
    NSMutableArray * validForArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * controllerArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * objectName = [pickListDict objectForKey:kPickListName];
    NSArray * fields = [pickListDict objectForKey:kPICKLISTFIELDS];
    
    for (NSDictionary * fieldDescribe in fields)
    {
        NSString * fieldApiName = [fieldDescribe objectForKey:kPickListName];
        NSString * type = [fieldDescribe objectForKey:kDependentPickListType];
        
        if([type isEqualToString:kPicklist] || [type isEqualToString:kMultiPicklist])
        {
            NSString   *controllerName = [fieldDescribe objectForKey:kControllerName];
            NSArray    *pickListEntryArray = [fieldDescribe objectForKey:kPICKLISTVALUES];
            NSString   *dependent =  [fieldDescribe  objectForKey:kDependentPicklist];
            NSInteger  isdependentPicklist = [dependent intValue];
            
            //if(isdependentPicklist)
            {
                
                SFObjectFieldModel *sfObjectFieldModel = [[SFObjectFieldModel alloc]init];
                
                for (int k = 0; k < [pickListEntryArray count]; k++)
                {
                    SFPicklistModel *sfPickListModel = [[SFPicklistModel alloc]init];
                    
                    NSDictionary * picklistDict = [pickListEntryArray objectAtIndex:k];
                    NSString * value = [picklistDict objectForKey:kPickListValue];
                    NSString * validFor = [picklistDict  objectForKey: kvalidFor];
                    if (([validFor isKindOfClass:[NSNull class]]) || (validFor == nil) || (validFor == NULL))
                    {
                        validFor = @"";
                    }
                    
                    sfPickListModel.objectName = objectName;
                    sfPickListModel.fieldName = fieldApiName;
                    sfPickListModel.value = value;
                    sfPickListModel.validFor = validFor;
                    sfPickListModel.indexValue = k;
                    [validForArray addObject:sfPickListModel];
                }
                
                sfObjectFieldModel.objectName = objectName;
                sfObjectFieldModel.fieldName = fieldApiName;
                
                if (([controllerName isKindOfClass:[NSNull class]]) || (controllerName == nil) || (controllerName == NULL))
                {
                    controllerName = @"";
                }
                
                sfObjectFieldModel.controlerField = controllerName;
                
                //update the controller type for the object anf field_name
                [controllerArray addObject:sfObjectFieldModel];
                
            }
        }
    }
    if([validForArray count] > 0)
    {
        id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
        
        if ([daoService conformsToProtocol:@protocol(SFPicklistDAO)]) {
            [daoService updateSFPicklistTable:validForArray];
        }
    }
    if([controllerArray count] > 0)
    {
        id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
        
        if ([daoService conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
            [daoService updateSFObjectField:controllerArray];
        }
    }
}



@end
