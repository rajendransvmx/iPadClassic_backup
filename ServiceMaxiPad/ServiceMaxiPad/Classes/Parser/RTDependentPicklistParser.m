//
//  RTDependentPicklistParser.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "RTDependentPicklistParser.h"
#import "ZKRecordTypeMapping.h"
#import "ZKDescribeLayoutResult.h"
#import "ZKPicklistForRecordType.h"
#import "ZKPicklistEntry.h"
#import "ResponseConstants.h"
#import "DatabaseConstant.h"
#import "SFRTPicklistModel.h"
#import "FactoryDAO.h"
#import "SFRTPicklistDAO.h"
#import "ResponseCallback.h"

@implementation RTDependentPicklistParser
-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    @autoreleasepool {
        
        NSMutableArray *rtPickListModelArray = [[NSMutableArray alloc]init];

        NSArray * recordTypeMappings = [(ZKDescribeLayoutResult*)responseData recordTypeMappings];
        for(ZKRecordTypeMapping *recordType in recordTypeMappings)
        {
            BOOL availabe = [recordType available];
            if (availabe)
            {
                NSString * recordTypeName = [recordType name];
                NSString * recordTypeLayoutId = [recordType layoutId];
                NSString * recordTypeID = [recordType recordTypeId];
                
                NSArray *pickLists = [recordType picklistsForRecordType];
                
                for(ZKPicklistForRecordType *pickList in pickLists)
                {
                    NSArray *pickListValueArray = [pickList picklistValues];
                    NSString *defaultLabel = @"";
                    NSString *defaultValue = @"";
                    for(ZKPicklistEntry *pickListValue in pickListValueArray)
                    {
                        SFRTPicklistModel *model = [[SFRTPicklistModel alloc]init];
                        model.recordTypeName = recordTypeName;
                        model.recordTypeLayoutID = recordTypeLayoutId;
                        model.recordTypeID = recordTypeID;
                        model.label = [pickListValue label];
                        model.value = [pickListValue value];
                        if([pickListValue defaultValue])
                        {
                            defaultLabel = [pickListValue label];
                            defaultValue = [pickListValue value];
                        }
                        model.defaultLabel = defaultLabel;
                        model.defaultValue = defaultValue;
                        model.fieldAPIName = [pickList picklistName];
                        model.objectAPIName = requestParamModel.value;
                        
                        [rtPickListModelArray addObject:model];
                    }
                }
            }
        }
        
        id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFRTPicklist];
        
        if ([daoService conformsToProtocol:@protocol(SFRTPicklistDAO)]) {
            BOOL resultStatus = [daoService saveRecordModels:rtPickListModelArray];
            if (resultStatus) {
                NSLog(@"inserted successfully");
            }
        }
        
        ResponseCallback *callBack = [[ResponseCallback alloc]init];
        callBack.callBack = NO;
        if ([requestParamModel.values count] > 0) {
            
            callBack.callBack = YES;
            RequestParamModel *reqModel = [[RequestParamModel alloc]init];
            reqModel.value = [requestParamModel.values objectAtIndex:0];
            NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:requestParamModel.values];
            [tempArray removeObject:reqModel.value];
            reqModel.values = tempArray;
            callBack.callBackData = reqModel;
        }
        return callBack;
    }
}

@end
