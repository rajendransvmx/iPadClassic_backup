//
//  TimeLogParser.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceParser.h"
#import "TimeLogModel.h"

@interface TimeLogParser : WebServiceParser

-(TimeLogModel *)parseTimeLogIdForResponse:(id)responseData;

@end
