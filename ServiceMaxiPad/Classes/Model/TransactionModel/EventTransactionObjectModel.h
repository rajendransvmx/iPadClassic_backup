//
//  EventTransactionObjectModel.h
//  ServiceMaxiPad
//
//  Created by Admin on 23/02/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "TransactionObjectModel.h"
@interface EventTransactionObjectModel : TransactionObjectModel

@property(nonatomic, strong) NSMutableArray *jsonEventArray;
@property(nonatomic, assign) BOOL isMultiDay;

-(void)splittingTheEvent;
-(BOOL)isItMultiDay;
-(NSString *)convertToJsonString;
-(BOOL)hasTimeZoneChanged;


@end
