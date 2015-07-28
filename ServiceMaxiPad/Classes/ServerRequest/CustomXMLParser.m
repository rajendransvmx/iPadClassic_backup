//
//  CustomXMLParser.m
//  ServiceMaxiPad
//
//  Created by Admin on 27/07/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomXMLParser.h"

@interface CustomXMLParser ()
@property(nonatomic, strong) NSMutableDictionary *something;
@property(nonatomic, strong) NSMutableDictionary *currentDictionary;

@property (nonatomic, strong) NSString *elementName;
@property (nonatomic, strong) NSMutableString *outstring;
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id operation;
@end

@implementation CustomXMLParser
@synthesize customDelegate;

-(instancetype)initwithNSXMLParserObject:(NSXMLParser *)responseData andError:(NSError *)error andOperation:(id)operation;
{
    if(self == [super init]) {
        self.parser = responseData;
        [self.parser setDelegate:self];
        self.error = error;
        self.operation = operation;
    }      
    return self;
}

-(void)parse
{
    [self.parser parse];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.something = [NSMutableDictionary dictionary];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
    NSLog(@"self.something :%@", self.something);
    
    if ([customDelegate respondsToSelector:@selector(customErrorResponse:andError:andOperation:)]) {
        [customDelegate customErrorResponse:self.something andError:self.error andOperation:self.operation];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.elementName = elementName;
    
    if ([elementName isEqualToString:@"faultcode"] ||
        [elementName isEqualToString:@"faultstring"]) {
        self.currentDictionary = [NSMutableDictionary dictionary];
    }
    
    self.outstring = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!self.elementName)
        return;
    
    [self.outstring appendFormat:@"%@", string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // 1
    if ([elementName isEqualToString:@"faultcode"] ||
        [elementName isEqualToString:@"faultstring"]) {
        self.currentDictionary[elementName] = self.outstring;
        self.something[elementName] = self.outstring;//@[self.currentDictionary];
        self.currentDictionary = nil;
    }
    /*
    // 2
    else if ([qName isEqualToString:@"weather"]) {
        
        // Initialize the list of weather items if it doesn't exist
        NSMutableArray *array = self.something[@"weather"] ?: [NSMutableArray array];
        
        // Add the current weather object
        [array addObject:self.currentDictionary];
        
        // Set the new array to the "weather" key on something dictionary
        self.something[@"weather"] = array;
        
        self.currentDictionary = nil;
    }
    // 3
    else if ([qName isEqualToString:@"value"]) {
        // Ignore value tags, they only appear in the two conditions below
    }
    // 4
    else if ([qName isEqualToString:@"weatherDesc"] ||
             [qName isEqualToString:@"weatherIconUrl"]) {
        NSDictionary *dictionary = @{@"value": self.outstring};
        NSArray *array = @[dictionary];
        self.currentDictionary[qName] = array;
    }
     */
    // 5
//    else
//        if (elementName) {
    self.currentDictionary[elementName] = self.outstring;
//    }
    
    self.elementName = nil;
}

@end
