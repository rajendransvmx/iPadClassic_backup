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

@end


#define kSearchObjectFields         @"SRCH_Object_Fields"
#define kLookUpReference            @"REFERENCE"