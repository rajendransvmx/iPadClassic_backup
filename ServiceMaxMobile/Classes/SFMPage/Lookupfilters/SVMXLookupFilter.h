//
//  SVMXLookupFilter.h
//  iService
//
//  Created by Shravya shridhar on 5/28/13.
//
//

#import <Foundation/Foundation.h>

@interface SVMXLookupFilter : NSObject {
   
}

@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *identifier;
@property(nonatomic,retain) NSString *namedSearchId;
@property(nonatomic,retain) NSString *ruleType;
@property(nonatomic,retain) NSString *sourceObjectName;
@property(nonatomic,retain) NSString *fieldName;
@property(nonatomic,retain) NSString *description;
@property(nonatomic,retain) NSString *parentObjectCriteria;
@property(nonatomic,retain) NSString *advancedExpressions;
@property(nonatomic,retain) NSArray  *componentArray;
@property(nonatomic,assign) NSInteger sequence;
@property(nonatomic,assign) BOOL      isDefaultOn;
@property(nonatomic,assign) BOOL      allowOverride;
@property(nonatomic,assign) BOOL      objectPermission;

@end
