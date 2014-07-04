//
//  SMADVDownoadCriteriaResponse.h
//  iService
//
//  Created by keerti bhatnagar on 03/07/13.
//
//

#import <Foundation/Foundation.h>
#import "WSResponseParser.h"
@interface SMADVDownoadCriteriaResponse : WSResponseParser
@property (nonatomic,retain) NSMutableDictionary * partialExecutedObjects;
@end
