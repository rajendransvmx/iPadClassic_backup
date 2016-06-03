//
//  CustomXMLParser.h
//  ServiceMaxiPad
//
//  Created by Admin on 27/07/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol xmlParserProtocolDelegate <NSObject>

-(void)customErrorResponse:(NSMutableDictionary *)theErrorMessage andError:(NSError *)error andOperation:(id)operation;

@end
@interface CustomXMLParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) id <xmlParserProtocolDelegate> customDelegate;

-(instancetype)initwithNSXMLParserObject:(NSXMLParser *)responseData andError:(NSError *)error andOperation:(id)operation;
-(void)parse;

@end
