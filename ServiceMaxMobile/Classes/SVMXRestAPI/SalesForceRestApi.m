                                                                //
//  SalesForceRestApi.m
//  iService
//
//  Created by Sahana on 05/11/13.
//
//

#import "SalesForceRestApi.h"

#import "AppDelegate.h"
#import "RKRequest.h"
#import "SFOAuthCoordinator.h"
#import "SFAccountManager.h"
#import "SFRestRequest.h"
#import "SFRestRequest.h"
#import "RKRequestSerialization.h"
#import "SMSalesForceRestAPI.h"
#import "SMAttachmentRequestManager.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation SalesForceRestApi

@synthesize data;
@synthesize view;
@synthesize pController;
@synthesize completeTest;

- (id)init
{
    if (self = [super init]) {
    
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.completeTest = true;
    }
    return self;
}

- (void) loadPdfwithData:(NSData *)dat {
    
    NSLog(@" Loaded data : %@ ", [[NSString alloc] initWithData:dat
                                         encoding:NSUTF8StringEncoding]);
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [docPath stringByAppendingPathComponent:@"DownloadedPdfFile.pdf"];
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:dat attributes:Nil];
   // [self showAsDocument:fileName];
    //[self viewDataFileOnWebView:fileName];
    
    NSLog(@" Completed Downloading DownloadedPdfFile.pdf successfully");
}

- (void)makeRKClientCall
{
    [[RKClient sharedClient] get:[NSString stringWithFormat:@"/services/data/v23.0/sobjects/FeedItem/0D5Z000000K1XaPKAV/ContentData"]
                        delegate:self];
}

- (void)download {
    
    NSLog(@"  Making RK call again ");
   RKClient* client = [RKClient clientWithBaseURLString:appDelegate.currentServerUrl];
    
   NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Authorization", @"OAuth 00DZ0000000p7Oz!AQ4AQP0VyfVVf4p7Pvb5Pk.KGYzG_djRgtiVuTQqdnBMpMbraoPeMkl374dUuBBzRjmTWBl5Uxizu6wM6YXORc_fHAVEnoB6", nil];
    
    [client setValue:[NSString stringWithFormat:@"OAuth %@", appDelegate.session_Id]
    forHTTPHeaderField:@"Authorization"];
   
//    [client get:@"/services/data/v23.0/sobjects/FeedItem/0D5Z000000K1XaPKAV/ContentData"
//queryParameters:dict
//     delegate:self];
    
    [client get:@"/services/data/v23.0/sobjects/Attachment/00P7000000KJU0wEAH/Body"
queryParameters:dict
       delegate:self];
    
    NSLog(@"  Making RK call again ----- Request completed");
    
}

- (void)sendRequest
{
    
    //RKClient* client = [RKClient clientWithBaseURLString:@"https://cs11.salesforce.com/"];
    
    RKClient* client = [RKClient clientWithBaseURLString:[NSString stringWithFormat:@"%@", appDelegate.currentServerUrl
                                                          ]];
    
    client.cachePolicy = RKRequestCachePolicyNone;
    [client setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
  //  NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Authorization", @"OAuth 00DZ0000000p7Oz!AQ4AQP0VyfVVf4p7Pvb5Pk.KGYzG_djRgtiVuTQqdnBMpMbraoPeMkl374dUuBBzRjmTWBl5Uxizu6wM6YXORc_fHAVEnoB6", nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Authorization", [NSString stringWithFormat:@"OAuth %@", appDelegate.session_Id], nil];
    
    
    
    [client setValue:[NSString stringWithFormat:@"OAuth %@", appDelegate.session_Id] forHTTPHeaderField:@"Authorization"];
    
    NSString *soql = @"SELECT ContentFileName FROM FeedItem WHERE Id = '0D5Z000000K1XaPKAV'";
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:soql, @"q", nil];
    NSString *path = [NSString stringWithFormat:@"services/data/%@/query", @"v23.0"];
    [client get:path queryParameters:queryParams delegate:self];
    
}


+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}


+ (NSString*) mimeTypeForFileAtPath: (NSString *) path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return [NSMakeCollectable((NSString *)mimeType) autorelease];
}

- (void)sendDataRequest1
{
    /*

     // Simple params
     ! NSDictionary* paramsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
     ! ! ! ! ! ! ! ! ! @"JoeBlow",@"name",
     ! ! ! ! ! ! ! ! ! @"Acme, Inc", @"company", nil];
     ! [[RKClient sharedClient] post:@"/contacts" params:paramsDictionary delegate:self];
     !
     ! // Multi-part params via RKParams!
     ! RKParams* params = [RKParams paramsWithDictionary:paramsDictionary];
     ! NSData* imageData = UIImagePNGRepresentation([UIImage imageNamed:@"picture.jpg"]);
     ! [params setData:imageData MIMEType:@"image/png" forParam:@"photo"];
     ! [params setFile:@"bio.txt" forParam:@"attachment"];
     ! [[RKClient sharedClient] post:@"/contacts" params:params delegate:self];
     */
    
    
     //Vipin Code
    
    RKClient* client = [RKClient clientWithBaseURLString:[NSString stringWithFormat:@"%@", appDelegate.currentServerUrl
                                                          ]];
    [client setValue:[NSString stringWithFormat:@"OAuth %@", appDelegate.session_Id] forHTTPHeaderField:@"Authorization"];
    client.cachePolicy = RKRequestCachePolicyNone;
    NSString *path = [NSString stringWithFormat:@"services/data/%@/sobjects/%@/", @"v23.0", @"Attachment"];
    
    
    //[client setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [client setValue:@"form-data; name=\"entity_document\"" forHTTPHeaderField:@"Content-Disposition"];
 //   [client setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    NSString *file = @"Query_anlysis.txt";
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [docPath stringByAppendingPathComponent:file];
    NSData* imageData = [NSData dataWithContentsOfFile:fileName];
    
    
    NSDictionary* paramsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"Ocean",@"Name",
                                      @"a0q70000003JkB2AAK", @"ParentId",
                                      @"False", @"isPrivate",
                                      imageData, @"Body",
                                      nil];
    
    
   RKParams* params = [RKParams paramsWithDictionary:paramsDictionary];
    
    // RKParams* params = [RKParams params];
    
//    [params setValue:@"" forParam:@""];
//    [params setValue:@"" forParam:@""];
//    [params setValue:@"" forParam:@""];
    
    
    
//    // Attach an Image from the App Bundle
//    UIImage* image = [UIImage imageWithContentsOfFile:fileName]; //[UIImage imageNamed:@"another_image.png"];
//    NSData* imageData = UIImagePNGRepresentation(image);
//    [params setData:imageData MIMEType:@"image/png" forParam:@"Body"];
    
    
    NSLog(@"Exist  fileName  %@", fileName);

     
     
     // Attach an Image from the App Bundle
     //UIImage* image = [UIImage imageWithContentsOfFile:fileName]; //[UIImage imageNamed:@"another_image.png"];
   // NSData* imageData = [NSData dataWithContentsOfFile:fileName];//UIImagePNGRepresentation(image);
    
    NSLog(@"file exist on the path  %@", fileName);
     //[params setData:imageData MIMEType:@"image/png" forParam:@"Body"];
     
     
//     // Create an Attachment
//     RKParamsAttachment* attachment = [params setData:imageData forParam:@"Body"];
//     attachment.MIMEType = @"application/text";
//     attachment.fileName = @"SYNC_HISTORY.plist";

    
    
    //NSData* imageData = UIImagePNGRepresentation([UIImage imageNamed:@"SYNC_HISTORY.plist"]);
   // [params setData:imageData MIMEType:@"image/png" forParam:@"Body"];
    //RKParamsAttachment* attachment1  =  [params setData:imageData MIMEType:@"application/text" forParam:@"Body"];

    //RKParamsAttachment* attachment2 = [params setFile:fileName forParam:@"Body2"];
    
    //[params setFile:file forParam:@"attachment"];
    
    
    // Let's examine the RKRequestSerializable info...
    NSLog(@"RKParams HTTPHeaderValueForContentType = %@", [params HTTPHeaderValueForContentType]);
    NSLog(@"RKParams HTTPHeaderValueForContentLength = %d", [params HTTPHeaderValueForContentLength]);

     

    [client post:path params:params delegate:self];
    
}




- (void)sendDataRequest
{
    RKClient* client = [RKClient clientWithBaseURLString:[NSString stringWithFormat:@"%@", appDelegate.currentServerUrl
                                                          ]];
    
    client.cachePolicy = RKRequestCachePolicyNone;
    [client setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    //[client setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [client setValue:@"form-data; name=\"entity_document\"" forHTTPHeaderField:@"Content-Disposition"];
    
    [client setValue:[NSString stringWithFormat:@"OAuth %@", appDelegate.session_Id] forHTTPHeaderField:@"Authorization"];

    
    
    //v23.0/sobjects/Document/
   
    //https://na1.salesforce.com/services/data/v23.0/sobjects/Document/
   
    NSString *path = [NSString stringWithFormat:@"services/data/%@/sobjects/%@/", @"v26.0", @"Attachment"];
   

    //----------------------------------------------
    
    /*
     Attachment
     "Name"
     "Body"
     "ParentId"
     "isPrivate"
     */
    
    //NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *fileName = [docPath stringByAppendingPathComponent:@"Ocean.jpg"];
    
    //NSLog(@" File Path  ->  %@", fileName);
    
    //NSLog(@" MimeType-path    %@  - %@ ", [SalesForceRestApi mimeTypeForFileAtPath:fileName], fileName);
    //NSLog(@" MimeType-content %@  - %@ ", [SalesForceRestApi contentTypeForImageData:[NSData dataWithContentsOfFile:fileName]], fileName);
    
   // NSString* myFilePath = @"/some/path/to/picture.gif";
    RKParams* params = [RKParams params];
    
    NSString *json = [NSString stringWithFormat:@"{\"Name\":\"%@\",\"ParentId\":\"%@\",\"isPrivate\":\"%@\"}", @"Ocean", @"a0q70000003JkB2AAK", @"False"];
     [params setData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"application/json" forParam:@"Attachment"];
    
    // Set some simple values -- just like we would with NSDictionary
    //[params setValue:@"Ocean" forParam:@"Name"];
    //[params setValue:@"a0q70000003JkB2AAK" forParam:@"ParentId"];
    //[params setValue:@"False" forParam:@"isPrivate"];
    
    //NSString *mimeType = @"image/jpeg";
    //NSData* fileData = [NSData dataWithContentsOfFile:fileName];
    //[params setValue:mimeType forParam:@"Content-Type"];
    //[params setData:fileData MIMEType:mimeType forParam:@"Body"];
    
    /*
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] init];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    
   NSObject<RKRequestSerializable> *dataForPosting  = [RKRequestSerialization serializationWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"application/json"];
    /*
    RKParamsAttachment* attachment = [params setFile:fileName forParam:@"Body"];
    attachment.MIMEType = mimeType;
    attachment.fileName = @"Ocean.jpg";
    
    // Create an Attachment
    /*
    RKParamsAttachment* attachment = [params setFile:fileName forParam:@"Body"];
    attachment.MIMEType = @"image/gif";
    attachment.fileName = @"picture.gif";
    
//    // Attach an Image from the App Bundle
//    UIImage* image = [UIImage imageNamed:@"another_image.png"];
//    NSData* imageData = UIImagePNGRepresentation(image);
//    [params setData:imageData MIMEType:@"image/png" forParam:@"image2"];
//  
     */
    // Let's examine the RKRequestSerializable info...
    NSLog(@"RKParams HTTPHeaderValueForContentType = %@", [params HTTPHeaderValueForContentType]);
    NSLog(@"RKParams HTTPHeaderValueForContentLength = %d", [params HTTPHeaderValueForContentLength]);
    
    
    
    // Send a Request!
   // [[RKClient sharedClient] post:path params:dataForPosting delegate:self];
    [[RKClient sharedClient] post:path params:params delegate:self];
}



-(void)makeRequest
{
    
    [[SMAttachmentRequestManager sharedInstance] downloadAttachment:@"00P7000000KJU0wEAH"
                                                       withFileName:@"TestDoc.pdf" andLocalId:@"TestDoc"];
    
    
    
    //[self sendDataRequest1];// Failed
    //[self sendRequest];  // Pass
    //[self download];     // Pass
    
//   // if (! self.completeTest)
//    {
//        NSLog(@"  Making RK call again ");
//        [self makeRKClientCall];
//    }
    
    return;
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *loginDomain = [ZKServerSwitchboard baseURL];
    NSString *accountIdentifier = @"user";
    
    //here we use the login domain as part of the identifier
    //to distinguish between eg  sandbox and production credentials
    NSString *fullKeychainIdentifier = [NSString stringWithFormat:@"%@-%@-%@",appName,accountIdentifier,loginDomain];
    
    
    SFAccountManager *manager = [SFAccountManager sharedInstanceForAccount:accountIdentifier];

    
    SFOAuthCoordinator * coor = [[SFRestAPI sharedInstance] coordinator];
    SFOAuthCredentials *creds = coor.credentials;
    
    //if (coor == nil)
    {
        SFOAuthCredentials *creds = [[SFOAuthCredentials alloc] initWithIdentifier:fullKeychainIdentifier
                                                                          clientId:CLIENT_ID
                                                                         encrypted:NO];
        [creds setDomain:loginDomain];
        [creds setRedirectUri:REDIRECT_URL];
        creds.accessToken = appDelegate.session_Id;
        creds.domain = @"test.salesforce.com";//[ZKServerSwitchboard baseURL];
        creds.identifier = fullKeychainIdentifier;
        creds.clientId = CLIENT_ID;
        creds.redirectUri = REDIRECT_URL;
        creds.refreshToken = appDelegate.refresh_token;
        creds.organizationId = appDelegate.organization_Id;
        creds.instanceUrl = [NSURL URLWithString:appDelegate.currentServerUrl];
        creds.userId = appDelegate.userProfileId;
        
        coor = [[SFOAuthCoordinator alloc] initWithCredentials:creds];
        [coor setScopes:[NSSet setWithObjects:@"web",@"api",nil]];
        [coor setDelegate:nil];
    }

    manager.credentials = creds;
    [manager setCoordinator:coor];

    [[SFRestAPI sharedInstance] setCoordinator:coor];
    [SFAccountManager sharedInstance].credentials = creds;
    
    SFRestRequest *_request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT ContentData,ContentFileName FROM FeedItem WHERE Id = '0D5Z000000K1XaPKAV'"];
    
    SFRestAPI *api = [SFRestAPI sharedInstance];
    
    [api send:_request delegate:self];
    
    NSLog(@"  SFRestRequest : %d\n%@\n%@\n%@",[_request method], [_request endpoint],
          [_request path], [[_request queryParams] description]);

    
    NSLog(@" Made  rest api request ...... with Delegate ");
    
    if ([_request delegate] != nil)
    {
        NSLog(@"Request ...... with Valid Delegate ");
    }
}


/**
 * Sent when a request has finished loading
 */

//- (void)request:(RKRequest *)request didLoadResponse:(id )response;
//{
//    NSLog(@"testSahana");
//}

/**
 * Sent when a request has failed due to an error
 */
//- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error;
//{
  //   NSLog(@"testSahana");
//}
/**
 * Sent when a request has started loading
 */
- (void)requestDidStartLoad:(RKRequest *)request
{
  
  NSLog(@"--------------- requestDidStartLoad Rest API ----------------------");
    
   NSData *dat =  [request HTTPBody];
   NSString *bodyString =  [request HTTPBodyString];
    
   NSLog(@" Request Body data   : %@ ", [[NSString alloc] initWithData:dat
                                                       encoding:NSUTF8StringEncoding]);
   NSLog(@" Request Body String : %@ ", bodyString);
   NSLog(@" Request method      : %@ ", [request HTTPMethod]);
}
/**
 * Sent when a request has uploaded data to the remote site
 */

- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
{
     NSLog(@"didSendBodyData - bytesWritten = %d, totalBytesWritten = %d",bytesWritten,totalBytesWritten);
}
 
/**
 * Sent when request has received data from remote site
 */

- (void)request:(RKRequest*)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive;
{
    
   long long int  x = (bytesReceived/1024);
   long long int  y = (totalBytesReceived/1024);
   long long int  z = (totalBytesExpectedToReceive/1024);
    
  // NSLog(@"didReceiveData -    %lld - %lld - %lld", x, y, z);
    
//    if ((11000 < y) && (self.completeTest))
//    {
//        //[request cancel];
//        [request reset];
//        self.completeTest = false;
//        NSLog(@"Cancelling the request .......");
//    }
}




/**
 * Sent to the delegate when a request was cancelled
 */
//- (void)requestDidCancelLoad:(RKRequest *)request;
//{
//     NSLog(@"testSahana");
//}



/**
 * Sent when a request has finished loading.
 * @param request The request that was loaded.
 * @param dataResponse The data from the response.  By default, this will be an object
 * containing the parsed JSON response.  However, if `request.parseResponse` was set
 * to `NO`, the data will be contained in a binary `NSData` object.
 */
- (void)request:(id)req didLoadResponse:(id)response
{
    if (data == nil) {
        self.data = [NSMutableData data];
    }
    
    if([req isKindOfClass:[SFRestRequest class]])
    {
        NSLog(@"  request : %@ - %@   - %@", [req endpoint], [req path], [[req queryParams] description]);
        
        NSLog(@"download start time : %@",[NSDate date]);
        
        NSLog(@"  response : %@ ", [response description]);
        
        [self makeRKClientCall];
    }
    
    if ([req isKindOfClass:[RKRequest class]]) {
    
        
        NSLog(@"  request : %@ - %@ \n additionalHTTPHeaders - %@ \n  HTTPBodyString - %@ \n  resourcePath - %@ \n  OAuth1ConsumerKey - %@ \n  OAuth1ConsumerSecret - %@ \n  OAuth1AccessToken - %@ \n  OAuth2AccessToken - %@ \n  OAuth2RefreshToken - %@ \n  OAuth1ConsumerKey - %@ \n",
              [req username],
              [req password],
              [[req additionalHTTPHeaders] description],
              [req HTTPBodyString],
              [req resourcePath],
              [req OAuth1ConsumerKey],
              [req OAuth1ConsumerSecret],
              [req OAuth1AccessToken],
              [req OAuth2AccessToken],
              [req OAuth2RefreshToken],
              [req OAuth1ConsumerKey]);
        
        
        RKResponse *respon = response;
        [self.data appendData:respon.body];
        [self loadPdfwithData:self.data];
    }
    
}

/**
 * Sent when a request has failed due to an error.
 * This includes HTTP network errors, as well as Salesforce errors
 * (for example, passing an invalid SOQL string when doing a query).
 * @param request The attempted request.
 * @param error The error associated with the failed request.
 */
- (void)request:(SFRestRequest *)request didFailLoadWithError:(NSError*)error
{
    NSLog(@"didFailLoadWithError - 2");
}

/**
 * Sent to the delegate when a request was cancelled.
 * @param request The canceled request.
 */
- (void)requestDidCancelLoad:(SFRestRequest *)request {
    
    NSLog(@"requestDidCancelLoad - 2");
}

/**
 * Sent to the delegate when a request has timed out. This is sent when a
 * backgrounded request expired before completion.
 * @param request The request that timed out.
 */
- (void)requestDidTimeout:(SFRestRequest *)request {
    
    NSLog(@"requestDidTimeout - 2");
}


//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    
//}
//
//
//
//- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
//{
//    [controller autorelease];
//}
//
//- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
//    return pController;
//}
//
//- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller{
//    return self.view.frame;
//}
//
//- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
//    return self.view;
//}
//
@end
