//
//  SFMPageLookUpHelper.h
//  ServiceMaxMobile
//
//  Created by Sahana on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMLookUp.h"
#import "SFNamedSearchModel.h"
#import "SFNamedSearchComponentModel.h"
#import "SFMRecordFieldData.h"


@interface SFMPageLookUpHelper : NSObject

@property (nonatomic, weak) id viewControllerdelegate;

-(void)loadLookUpConfigarationForLookUpObject:(SFMLookUp *)lookUpObj;
-(void)fillDataForLookUpObject:(SFMLookUp *)lookUpObj;
-(NSString *)getObjectLabel:(NSString *)objectName;

/*LookUp Filter*/
-(NSArray *)getLookupSearchFiltersForId:(NSString *)searchId forType:(NSString *)searchType;

- (NSArray *) getCriteriaArrayForContextLookUp:(SFMLookUp *)lookup ;


- (void)fillOnlineLookupData:(NSMutableArray*)onlineDataArray forLookupObject:(SFMLookUp*)lookUpObj;

//Needed for Online LookUpPrefilter.
-(NSString *)advanceExpression:(SFMLookUp *)lookUpObj;
- (NSArray *)getCriteriaObjectForfilter:(SFMLookUpFilter *)filter;

// Below methods are used to lookup display field issue.023314 and 023783
-(void)fillLookUpMetaDataLookUp:(SFMLookUp *)lookUpObj;
-(NSDictionary*)getDefaultColumnNameDataForLookup:(SFMLookUp*)lookupObject withSfId:(NSString*)sfId;

@end


#define kSearchObjectFields         @"SRCH_Object_Fields"
#define kLookUpReference            @"REFERENCE"