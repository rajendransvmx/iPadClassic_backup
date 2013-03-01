//
//  HTMLJSWrapper.m
//  iService
//
//  Created by Shravya shridhar on 2/26/13.
//
//

#import "HTMLJSWrapper.h"

@implementation HTMLJSWrapper

+ (NSString *)getWrapperForCodeSnippet:(NSString *)codeSnippet {
    NSString *finalJSString =  [NSString stringWithFormat:@"<!DOCTYPE html ><html><head><script  src=\"jquery-1.8.2.min.js\"></script><script  type=\"text/javascript\" src=\"svmx_client_api.js\"></script><script  type=\"text/javascript\" src=\"iOStoJsBridge.js\"></script><script  type=\"text/javascript\">$EXPR.initializeWithExpression(\"%@\");</script></head><body></body></html>" ,codeSnippet];
    
    
    return finalJSString;
}

@end
