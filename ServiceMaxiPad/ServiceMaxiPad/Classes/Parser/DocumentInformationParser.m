//
//  DocumentInformationParser.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "DocumentInformationParser.h"
#import "FileManager.h"
#import "FileModel.h"
#import "DocumentModel.h"
#import "FactoryDAO.h"
#import "DocumentService.h"
#import "ParserUtility.h"


@implementation DocumentInformationParser



-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    @synchronized([self class])
    {
        @autoreleasepool
        {
            
            //Krishna
            //TODO: Handle error
            //Reason : responsedata was returning as an array with errorcode and message
            //Now just checking and proceeding only iff NSDictionary class.
        
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *responseDict = (NSDictionary*)responseData;
                
                NSArray *allRecords = [responseDict objectForKey:@"records"];
                for (NSDictionary *eachDict in allRecords) {
                    [self parseDocumentDataWithResponce:eachDict];
                }

            }
        }
    }
    return nil;
}


- (void)parseDocumentDataWithResponce:(NSDictionary*)responceDict
{
    NSDictionary *mappingDict = [DocumentModel getMappingDictionary];
    DocumentModel *documentModel = [[DocumentModel alloc] init];
    [ParserUtility parseJSON:responceDict toModelObject:documentModel withMappingDict:mappingDict];
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeDocument];
    
    if ([daoService conformsToProtocol:@protocol(DocumentDAO)]) {
        [daoService updateDocumentTableWithModelArray:@[documentModel]];
    }
}


@end
