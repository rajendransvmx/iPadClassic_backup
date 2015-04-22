//
//  ZKURLConnection.h
//  SplitForce
//
//  Created by Dave Carroll on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



@interface ZKURLConnection : NSURLConnection {
	id responseDelegate;
	SEL responseSelector;
	NSString *operationName;
	NSString *layoutObjectName;
	id clientDelegate;
	NSMutableData *receivedData;
}
@property (strong, nonatomic) id responseDelegate;
@property (assign, nonatomic) SEL responseSelector;
@property (strong, nonatomic) NSString *operationName;
@property (strong, nonatomic) NSString *layoutObjectName;
@property (strong, nonatomic) id clientDelegate;
@property (strong, nonatomic) NSMutableData *receivedData;

-(id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate 
withResponseDelegate:(id)responseDelegate 
withResponseSelector:(SEL)responseSelector
  withClientDelegate:(id)clientDelegate 
withLayoutObjectName:(NSString *)layoutObjectName 
   withOperationName:(NSString *)operationName;
@end
