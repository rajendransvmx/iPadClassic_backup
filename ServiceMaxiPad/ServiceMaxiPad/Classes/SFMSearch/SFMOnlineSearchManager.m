//
//  SFMOnlineSearchManager.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMOnlineSearchManager.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "TaskGenerator.h"
#import "RequestParamModel.h"
#import "SFMSearchObjectModel.h"

@implementation SFMOnlineSearchManager

- (id)initWithSFMSearchProcessModel:(SFMSearchProcessModel*)searchProcessModel andSearchText:(NSString*)searchText
{
    self = [super init];
    if (self) {
        
        self.searchProcessModel = searchProcessModel;
        self.searchText = searchText;
    }
    return self;
}

- (void)initiateSearchResultWebServiceInBackground:(id)sender
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeSFMSearch
                                             requestParam:[self getRequestParameterForSearchResult]
                                           callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
    
}

- (RequestParamModel*)getRequestParameterForSearchResult
{
    NSMutableArray *valueMapArray = [[NSMutableArray alloc]init];
    RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
    NSDictionary *searchProcessIdDict = [[NSDictionary alloc]init];
    [searchProcessIdDict setValue:@"SearchProcessId" forKey:@"key"];
    [searchProcessIdDict setValue:self.searchProcessModel.localId forKey:@"value"];
    [valueMapArray addObject:searchProcessIdDict];
    
    NSDictionary *searchOperatorDict = [[NSDictionary alloc]init];
    [searchOperatorDict setValue:@"SEARCH_OPERATOR" forKey:@"key"];
    [searchOperatorDict setValue:@"Contains" forKey:@"value"];
    [valueMapArray addObject:searchOperatorDict];
    
    NSDictionary *keyWordDict = [[NSDictionary alloc]init];
    [keyWordDict setValue:@"KeyWord" forKey:@"key"];
    [keyWordDict setValue:self.searchText forKey:@"value"];
    [valueMapArray addObject:keyWordDict];
    
    for (SFMSearchObjectModel *searchObjectmodel in self.searchProcessModel.searchObjects) {
        NSDictionary *searchObjectDict = [[NSDictionary alloc]init];
        [searchObjectDict setValue:@"ObjectId" forKey:@"key"];
        [searchObjectDict setValue:searchObjectmodel.moduleId forKey:@"value"];
        [valueMapArray addObject:searchObjectDict];
    }
    
    NSDictionary *recordLimitDict = [[NSDictionary alloc]init];
    [recordLimitDict setValue:@"RecordLimit" forKey:@"key"];
    [recordLimitDict setValue:@"100" forKey:@"value"];
    [valueMapArray addObject:recordLimitDict];
    
    requestParamModel.valueMap = [NSArray arrayWithArray:valueMapArray];
    return requestParamModel;
}
@end
