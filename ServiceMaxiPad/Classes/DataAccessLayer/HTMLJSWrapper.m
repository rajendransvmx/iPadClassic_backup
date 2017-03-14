//
//  HTMLJSWrapper.m
//  iService
//
//  Created by Shravya shridhar on 2/26/13.
//
//

#import "HTMLJSWrapper.h"
#import "FileManager.h"

const BOOL DEBUG_JAVASCRIPT = FALSE;

@implementation HTMLJSWrapper

+ (NSString *)getWrapperForCodeSnippet:(NSString *)codeSnippet {
    NSString *finalJSString =  [NSString stringWithFormat:@"<!DOCTYPE html ><html><head><script  type=\"text/javascript\" >var iPAD_GLOBAL_NAME_SPACE = \"%@\"</script><script  type=\"text/javascript\" src=\"svmx_client_api.js\"></script><script  type=\"text/javascript\" src=\"iOStoJsBridge.js\"></script><script  type=\"text/javascript\">$EXPR.initializeWithExpression(\"%@\");</script></head><body></body></html>" ,ORG_NAME_SPACE,codeSnippet];
    
    
    return finalJSString;
}
+ (NSString *)getWrapperForOPDocs:(NSString *)codeSnippet forRecord:(NSString *)recordId andProcessId:(NSString *)processId
{
    NSString *documentsDirectory = [FileManager getCoreLibSubDirectoryPath]; // [paths objectAtIndex:0]; // Get documents folder

    NSString *bootstrapPath = [[FileManager getRootPath] stringByAppendingPathComponent:@"com.servicemax.client.lib/src/bootstrap.js"];
    
    NSString *htmlFileName =@"OPDoc" ;
    if(DEBUG_JAVASCRIPT)
        htmlFileName =@"OPDoc_DEBUG";
    
    NSString *htmlContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:htmlFileName ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];

    NSString *htmlString = @"";
    
    if(DEBUG_JAVASCRIPT)
        htmlString = [NSString stringWithFormat:@"<html>  <head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-16\"></head> <script  type=\"text/javascript\" > var iPAD_ORG_NAME_SPACE = \"%@\"; </script> <script src=\"http://localhost:8080/target/target-script-min.js\"></script> <script  type=\"text/javascript\" src=\"CommunicationBridgeJS.js\"> </script><script  type=\"text/javascript\" src=\"DataAcessLayer.js\"></script> <script  type=\"text/javascript\" src=\"Utility.js\"></script> <script  type=\"text/javascript\" src=\"OutputDocs.js\"></script> <script  type=\"text/javascript\" src=\"svmx_client_api.js\"></script><script  type=\"text/javascript\" src=\"iOStoJsBridge.js\"></script><script type=\"text/javascript\" src=\"%@\"></script><script>  function initiatejs() { alert(\"initiatejs\"); /* jQuery(document).ready(function(){ */ addParameters('%@','%@'); var client_runtime=\"%@\"; var client_console=\"%@\"; var client_mvc=\"%@\"; var client_opdocdelivery= \"%@\"; var client_opdocdelivery_model= \"%@\"; var client_sfmconsole_model = \"%@\"; var client_console_ui_web = \"%@\"; ",ORG_NAME_SPACE, bootstrapPath,recordId,processId, documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory];
    else
        htmlString = [NSString stringWithFormat:@"<html>  <head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-16\"></head> <script  type=\"text/javascript\" > var iPAD_ORG_NAME_SPACE = \"%@\"; </script> <script src=\"http://localhost:8080/target/target-script-min.js\"></script> <script  type=\"text/javascript\" src=\"CommunicationBridgeJS.js\"> </script><script  type=\"text/javascript\" src=\"DataAcessLayer.js\"></script> <script  type=\"text/javascript\" src=\"Utility.js\"></script> <script  type=\"text/javascript\" src=\"OutputDocs.js\"></script> <script  type=\"text/javascript\" src=\"svmx_client_api.js\"></script><script  type=\"text/javascript\" src=\"iOStoJsBridge.js\"></script><script type=\"text/javascript\" src=\"%@\"></script><script> /* function initiatejs() { alert(\"initiatejs\"); */ jQuery(document).ready(function(){ addParameters('%@','%@'); var client_runtime=\"%@\"; var client_console=\"%@\"; var client_mvc=\"%@\"; var client_opdocdelivery= \"%@\"; var client_opdocdelivery_model= \"%@\"; var client_sfmconsole_model = \"%@\"; var client_console_ui_web = \"%@\"; ",ORG_NAME_SPACE, bootstrapPath,recordId,processId, documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory,documentsDirectory];
    
    NSString *finalString = [htmlString stringByAppendingString:htmlContent];
    
    return finalString;
}

@end
