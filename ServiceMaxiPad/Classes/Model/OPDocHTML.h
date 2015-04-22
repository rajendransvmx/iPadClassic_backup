//
//  OPDocHTML.h
//  ServiceMaxiPad
//
//  Created by Damodar on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPDocHTML : NSObject

@property (nonatomic, strong) NSString *local_id;
@property (nonatomic, strong) NSString *process_id;
@property (nonatomic, strong) NSString *record_id;
@property (nonatomic, strong) NSString *objectName;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *sfid;

//Used for Attachments
@property (nonatomic, strong) NSString *lastModifiedDate;
@property (nonatomic, readwrite) NSInteger bodyLength;

@end
