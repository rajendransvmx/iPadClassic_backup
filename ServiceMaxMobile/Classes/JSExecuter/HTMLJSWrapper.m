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
    NSString *finalJSString =  [NSString stringWithFormat:@"<!DOCTYPE html ><html><head><script  type=\"text/javascript\" src=\"svmx_client_api.js\"></script><script  type=\"text/javascript\" src=\"iOStoJsBridge.js\"></script><script  type=\"text/javascript\">$EXPR.initializeWithExpression(\"%@\");</script></head><body></body></html>" ,codeSnippet];
    
    
    return finalJSString;
}
+ (NSString *)getWrapperForOPDocs:(NSString *)codeSnippet forRecord:(NSString *)recordId andProcessId:(NSString *)processId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[[UIApplication sharedApplication] delegate] getAppCustomSubDirectory]; // [paths objectAtIndex:0]; // Get documents folder

    NSString *bootstrapPath = [documentsDirectory stringByAppendingPathComponent:@"com.servicemax.client.lib/src/bootstrap.js"];
    
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"OPDoc" ofType:@"html"];
    NSString *htmlContent = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];

    NSString *htmlString = @"";
    //Generation of OPDoc in latest SUM 14 has to be included with one more static library.
    // 11595 Unicode support
    htmlString = [NSString stringWithFormat:@"<html> <head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-16\"></head><script src=\"http://localhost:8080/target/target-script-min.js\"></script> <script  type=\"text/javascript\" src=\"CommunicationBridgeJS.js\"> </script><script  type=\"text/javascript\" src=\"DataAcessLayer.js\"></script> <script  type=\"text/javascript\" src=\"Utility.js\"></script> <script  type=\"text/javascript\" src=\"OutputDocs.js\"></script> <script  type=\"text/javascript\" src=\"svmx_client_api.js\"></script><script  type=\"text/javascript\" src=\"iOStoJsBridge.js\"></script><script type=\"text/javascript\" src=\"%@\"></script><script> /* function initiatejs() { alert(\"initiatejs\");*/  jQuery(document).ready(function(){  addParameters('%@','%@'); var client_runtime=\"%@\"; var client_console=\"%@\"; var client_mvc=\"%@\"; var client_opdocdelivery= \"%@\"; var client_opdocdelivery_model= \"%@\"; var client_sfmconsole_model = \"%@\";",bootstrapPath,recordId,processId, documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory];
    
    NSString *finalString = [htmlString stringByAppendingString:htmlContent];
    
    return finalString;
}

@end
