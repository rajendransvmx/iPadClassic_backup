//
//  HTMLJSWrapper.h
//  iService
//
//  Created by Shravya shridhar on 2/26/13.
//
//

#import <Foundation/Foundation.h>

@interface HTMLJSWrapper : NSObject

+(NSString *)getWrapperForCodeSnippet:(NSString *)codeSnippet;

+ (NSString *)getWrapperForOPDocs:(NSString *)codeSnippet forRecord:(NSString *)recordId andProcessId:(NSString *)processId;

@end
