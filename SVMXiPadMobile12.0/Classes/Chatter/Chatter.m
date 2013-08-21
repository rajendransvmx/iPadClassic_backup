    //
//  Chatter.m
//  iService
//
//  Created by Samman Banerjee on 28/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Chatter.h"
#import "Base64.h"
#import "HTMLBrowser.h"
#import "LocalizationGlobals.h"
extern void SVMXLog(NSString *format, ...);

@implementation ChatterURLConnection

@synthesize userName;

@end

@implementation Chatter

@synthesize delegate;
@synthesize selfId;
@synthesize productId, productName;
@synthesize userRecordArray;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [activity startAnimating];
    
    imageCache = [[ImageCacheClass alloc] init];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Shrinivas : OAuth
    [[ZKServerSwitchboard switchboard] doCheckSession];
	
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ( ![appDelegate isInternetConnectionAvailable] )
    { 
        NSData *data; 
        data = [appDelegate.calDataBase getProductPictureForProductId:productId];
        
        if ( data != NULL )
        {
            UIImage *productImage = [[[UIImage alloc] initWithData:data] autorelease];
            productPicture.image = productImage;
            
            chatterArray = nil;
            chatterArray = [[NSMutableArray alloc]initWithCapacity:0];
            
            chatterArray = [appDelegate.calDataBase retrieveChatterPostsFromDBForId:productId];
        }
        
        if ( [chatterArray count] == 0 )
        {
            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:chatter_no_posts];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
            
            UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
            [_alert show];
            [_alert release];
        }
        
        SMLog(@"%@", chatterArray);
        
        [self loadChatter];
    }

    
    chatTable.backgroundColor = [UIColor clearColor];
    
    iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
    
    didRunOperation = YES;
    [iOSObject getProductPictureForId:productId];
    
    isChatterAlive = YES;
    
    // Set up keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSString * share = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CHATTER_SHARE_BUTTON];
    [shareButton setTitle:share forState:UIControlStateNormal];
    UIImage * shareImage = [UIImage imageNamed:@"iService-Share.png"];
    shareImage = [shareImage stretchableImageWithLeftCapWidth:11 topCapHeight:11];
    [shareButton setBackgroundImage:shareImage forState:UIControlStateNormal];
    navChatterBar.title = [appDelegate.wsInterface.tagsDictionary objectForKey:CHATTER_TITLE];
    newPostText.placeholder = [appDelegate.wsInterface.tagsDictionary objectForKey:CHATTERPLACEHOLDER];
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(@"Chatter Internet Reachable");
    }
    else
    {
        SMLog(@"Chatter Internet Not Reachable");
        if (didRunOperation)
        {
            [activity stopAnimating];
            //[appDelegate displayNoInternetAvailable];
            didRunOperation = NO;
        }
    }
}

- (IBAction) Help;
{    
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSString *lang=[appDelegate.dataBase checkUserLanguage];
    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"chatter_%@",lang] ofType:@"html"];
    
    if( (isfileExists ==NULL)|| [lang isEqualToString:@"en_US"] || !([lang length]>0))
    {
         help.helpString=@"chatter.html";
    }
    else
    {
    help.helpString = [NSString stringWithFormat:@"chatter_%@.html",lang];
    }
    [self presentViewController:help animated:YES completion:nil];
    [help release];
}

- (void) didGetProductPictureForId:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    didRunOperation = NO;
    NSArray * array = [result records];
    
    if ([array count] == 0)
    {
        [self fetchPosts];
        return;
    }
    
    NSString * dataString = [[[array objectAtIndex:0] fields] objectForKey:@"Body"];
    [appDelegate.calDataBase insertProductPicture:dataString ForId:productId];
    
    NSData * data = [Base64 decode:dataString];
    
    // Decode data from Base64
    UIImage * image = [[[UIImage alloc] initWithData:data] autorelease];
    
    productPicture.image = image;
    productNameLabel.text = productName;
    
    if ([appDelegate isInternetConnectionAvailable])
        [self fetchPosts];
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    @try
    {
    NSDictionary *info = [notification userInfo];
    NSValue *keyBounds = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    CGRect boundRect;
    [keyBounds getValue:&boundRect];
    
	[UIView beginAnimations:@"Begin" context:notification];
	[UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(honeyIShrunkTheTable:finished:context:)];
    CGRect frame = chatTable.frame;
    originalRect = frame;
	frame = CGRectMake(chatTable.frame.origin.x, chatTable.frame.origin.y, chatTable.frame.size.width, chatTable.frame.size.height - boundRect.size.width);
    chatTable.frame = frame;
	[UIView commitAnimations];
    
    isKeyboardShowing = YES;
}@catch (NSException *exp) {
        SMLog(@"Exception Name Chatter :keyboardWillShow %@",exp.name);
        SMLog(@"Exception Reason Chatter :keyboardWillShow %@",exp.reason);
    [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}

- (void) honeyIShrunkTheTable:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    if (currentEditRow == nil)
        return;
    CGRect rowRect = [chatTable rectForRowAtIndexPath:currentEditRow];
    [chatTable scrollRectToVisible:rowRect animated:YES];
    currentEditRow = nil;
}

- (void) keyboardDidHide:(NSNotification *)notification
{
	[UIImageView beginAnimations:@"Begin" context:nil];
	[UIImageView setAnimationDuration:0.5];
    chatTable.frame = originalRect;
	[UIImageView commitAnimations];
    
    currentCell.postComment.text = @"";
    currentCell.postComment.enabled = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:TIMERINTERVAL target:self selector:@selector(fetchPosts) userInfo:nil repeats:NO];
    didEditRow = NO;
    isKeyboardShowing = NO;
}

- (void) fetchPosts
{
    if (chatterArray != nil)
    {
        [chatterArray release];
        chatterArray = nil;
    }
    
    if (isKeyboardShowing)
        return;

    if ([appDelegate isInternetConnectionAvailable])
        [iOSObject queryChatterForProductId:productId];
}

- (void) didQueryChatterForProductId:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (chatterQueryArray != nil)
    {
        [chatterQueryArray release];
        chatterQueryArray = nil;
    }
    
    if ([[result records] count] == 0)
    {
        [activity stopAnimating];
        return;
    }
    
    chatterQueryArray = [[result records] retain];
    
    int count = [chatterQueryArray count];

    for (int i = 0; i < count; i++)
    {
        ZKSObject * obj = [[result records] objectAtIndex:i];
        
        // Obtain name of user bearing Id CreatedById
        NSString * usrString = [[[obj fields] objectForKey:POSTCREATEDBYID] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:POSTCREATEDBYID]:@"";
        
        if (usrStringArray == nil)
            usrStringArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        [usrStringArray addObject:usrString];
    }
    [self processUsrStringArray];
}

- (void) processUsrStringArray
{
    if ([appDelegate isInternetConnectionAvailable])
        [iOSObject getUserNameFromId:usrStringArray];
}

- (void) didGetUserNameFromId:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    [usrStringArray removeAllObjects];

    // by now we have both chatter array and username list (with corresponding Ids)
    NSArray * userArray = [result records];
    //sahana 19th Aug 2011
    userRecordArray = [userArray retain];
    if (chatterArray == nil)
        chatterArray = [[NSMutableArray alloc] initWithCapacity:0];
    else
        [chatterArray removeAllObjects];
    //sahana 16th Aug 2011
    NSArray * postKeys = [NSArray arrayWithObjects:POSTTYPE, FEEDPOSTID, POSTDATESTAMP, POSTCREATEDBYID, FEEDPOSTBODY, USERNAME_CHATTER, PRODUCT2FEEDID, CHATTEREMAIL,FULLPHOTOURL, nil];
    
    NSString * product2FeedId;
    
    int count = [chatterQueryArray count];
    @try
    {
    for (int i = 0; i < count; i++)
    {
        ZKSObject * obj = [chatterQueryArray objectAtIndex:i];
        SMLog(@"%dth Object \r %@", i, [obj fields]);
        
        NSArray * postObjects;
        NSDictionary * postDict;
        
        product2FeedId = [[[obj fields] objectForKey:PRODUCT2FEEDID] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:PRODUCT2FEEDID]:@"";
        
        // For every post, assign created date to prev, and then compare new dates with prev.
        // For every different date add a seperator cell
        NSString * currentDateString = [[[obj fields] objectForKey:POSTDATESTAMP] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:POSTDATESTAMP]:@"1970-01-01T00:00:00Z";
        currentDateString = [currentDateString substringToIndex:10];
        if (prevDateString == nil)
        {
            prevDateString = [[[obj fields] objectForKey:POSTDATESTAMP] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:POSTDATESTAMP]:@"1970-01-01T00:00:00Z";
            prevDateString = [prevDateString substringToIndex:10];
            NSString * day = [iOSObject dayByComparingTodayWithDate:prevDateString];
            // Add seperator to chatterArray
            postObjects = [NSArray arrayWithObjects:TYPECHATSEPERATOR, @"", @"", @"", day, @"", @"", @"", @"", nil];
            postDict = [NSDictionary dictionaryWithObjects:postObjects forKeys:postKeys];
            [chatterArray addObject:postDict];
        }
        else if (![currentDateString isEqualToString:prevDateString])
        {
            prevDateString = [[[obj fields] objectForKey:POSTDATESTAMP] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:POSTDATESTAMP]:@"1970-01-01T00:00:00Z";
            prevDateString = [prevDateString substringToIndex:10];
            NSString * day = [iOSObject dayByComparingTodayWithDate:prevDateString];
            // Add seperator to chatterArray
            postObjects = [NSArray arrayWithObjects:TYPECHATSEPERATOR, @"", @"", @"", day, @"", @"", @"", @"", nil];
            postDict = [NSDictionary dictionaryWithObjects:postObjects forKeys:postKeys];
            [chatterArray addObject:postDict];

            prevDateString = currentDateString;
        }
    
        // Obtain name of user bearing Id CreatedById
        NSString * usrString = [[[obj fields] objectForKey:POSTCREATEDBYID] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:POSTCREATEDBYID]:@"";
    
        NSString * userName = [self getUserNameFromArray:userArray WithId:usrString];
        if (userName == nil)
            userName = @"";
        NSString * email = [self getUserEmailFromArray:userArray WithId:usrString];
        NSString * fullPhotoUrl = [self getFullPhotoUrlFromArray:userArray WithId:usrString];
        
        
        postObjects = [NSArray arrayWithObjects:TYPEFEED,
                    [[[obj fields] objectForKey:FEEDPOSTID] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:FEEDPOSTID]:@"",
                    [[[obj fields] objectForKey:POSTDATESTAMP] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:POSTDATESTAMP]:@"1970-01-01T00:00:00Z",
                    [[[obj fields] objectForKey:POSTCREATEDBYID] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:POSTCREATEDBYID]:@"", 
                    [[[[[obj fields] objectForKey:FEEDPOST] fields] objectForKey:FEEDPOSTBODY] isKindOfClass:[NSString class]]?[[[[obj fields] objectForKey:FEEDPOST] fields] objectForKey:FEEDPOSTBODY]:@"",
                    userName,
                    [[[obj fields] objectForKey:PRODUCT2FEEDID] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:PRODUCT2FEEDID]:@"",
                    email,
                    fullPhotoUrl,
                    nil];
        postDict = [NSDictionary dictionaryWithObjects:postObjects forKeys:postKeys];
    
        [chatterArray addObject:postDict];
    
        ZKQueryResult * qResult = [[obj fields] objectForKey:FEEDCOMMENTFIELD];
        if (![qResult isKindOfClass:[NSNull class]])
        {
            for (int j = 0; j < [[qResult records] count]; j++)
            {
                // ########################### ATTENTION REQUIRED HERE ########################### //
                NSString * currentId = [[[[qResult records] objectAtIndex:j] fields] objectForKey:POSTCREATEDBYID];
                userName = [self getUserNameFromArray:userArray WithId:currentId];
                if (userName == nil)
                    userName = @"";
                email = [self getUserEmailFromArray:userArray WithId:currentId];
                fullPhotoUrl = [self getFullPhotoUrlFromArray:userArray WithId:currentId];
                ZKSObject * obj = [[qResult records] objectAtIndex:j];
                postObjects = [NSArray arrayWithObjects:TYPECOMMENT,
                           @"",
                           [[[obj fields] objectForKey:COMMENTDATESTAMP] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:COMMENTDATESTAMP]:@"1970-01-01T00:00:00Z",
                           [[[obj fields] objectForKey:COMMENTCREATEDBYID] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:COMMENTCREATEDBYID]:@"",
                           [[[obj fields] objectForKey:COMMENTBODY] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:COMMENTBODY]:@"",
                           userName,
                           @"",
                           email,
                           fullPhotoUrl,   
                           nil];
                postDict = [NSDictionary dictionaryWithObjects:postObjects forKeys:postKeys];
            
                [chatterArray addObject:postDict];
            }
        }
    
        if ([qResult isKindOfClass:[NSNull class]])
            postObjects = [NSArray arrayWithObjects:TYPECOMMENTPOST, @"", @"", @"", @"", @"", product2FeedId, @"", @"", nil];
        else		
            postObjects = [NSArray arrayWithObjects:TYPECOMMENTPOST, @"", @"", @"", @"", @"", [[[[qResult records] objectAtIndex:0] fields] objectForKey:@"FeedItemId"], @"", @"", nil];
        postDict = [NSDictionary dictionaryWithObjects:postObjects forKeys:postKeys];
        [chatterArray addObject:postDict];
    }
    
    prevDateString = nil;
    
    // Query for all user user ids
    userIdCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    // Form the user Ids first
    for (int i = 0; i < [chatterArray count]; i++)
    {
        NSDictionary * postDict = [chatterArray objectAtIndex:i];
        // NSString * createdById = [postDict objectForKey:POSTCREATEDBYID];
        NSString * fullPhotoUrl = [postDict objectForKey:FULLPHOTOURL];
        NSString * userName = [postDict objectForKey:USERNAME_CHATTER];
        
        if (userNameImageList == nil)
            userNameImageList = [[NSMutableArray alloc] initWithCapacity:0];
        if (![userNameImageList containsObject:userName])
            [userNameImageList addObject:userName];
        
        appDelegate.userNameImageList = userNameImageList;
        
        NSString * fullPhotoUrlRequest = [NSString stringWithFormat:@"%@?oauth_token=%@", fullPhotoUrl, [[ZKServerSwitchboard switchboard]sessionId]];
        
        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fullPhotoUrlRequest]];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectoryPath = [paths objectAtIndex:0];
        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", userName, @".png"]];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:filePath])
            continue;
        else
        {
            // Create the file first
            [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        
        ChatterURLConnection * urlConnection = [[[ChatterURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
        urlConnection.userName = userName;
    }

    SMLog(@"%@  %d", chatterArray, [chatterArray count]);
    [appDelegate.calDataBase insertChatterDetailsIntoDBForWithId:productId andChatterDetails:chatterArray];
    
    [self loadChatter];
}@catch (NSException *exp)
    {
        SMLog(@"Exception Name Chatter :didGetUserNameFromId %@",exp.name);
        SMLog(@"Exception Reason Chatter :didGetUserNameFromId %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}
//sahana 17th Aug 2011
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
@try{
    ChatterURLConnection * curlConnection = (ChatterURLConnection *)connection;
    NSString * userName = curlConnection.userName;
    SMLog(@"didReceiveData %@", userName);
    
    // Save the image data
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths objectAtIndex:0];
    NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", userName, @".png"]];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:filePath])
    {
        NSMutableData * fileData = [NSMutableData dataWithContentsOfFile:filePath];
        [fileData appendData:data];
        [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
    }
    else
    {
        // Create file
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
    }
}@catch (NSException *exp) {
        SMLog(@"Exception Name Chatter :connection %@",exp.name);
        SMLog(@"Exception Reason Chatter :connection %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data - for e.g. save it
    SMLog(@"connectionDidFinishLoading %@", ((ChatterURLConnection*)connection).userName);
    
    NSString *userName = ((ChatterURLConnection*)connection).userName;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths objectAtIndex:0];
    NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", userName, @".png"]];
    
    SMLog(@"%@", filePath);
    
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    SMLog(@"%@", chatterArray);
    
    [appDelegate.calDataBase insertImageDataInChatterDetailsForUserName:userName WithData:data];
}

//  Unused Methods
//- (void) didGetImagesForIds:(ZKQueryResult *)result error:(NSError *)error context:(id)context
//{
//    userRecordArray = (NSArray *)context;
//    [userRecordArray retain];
//    @try
//    {
//    NSArray * array = [result records];
//    for (int i = 0; i < [array count]; i++)
//    {
//        ZKSObject * obj = [array objectAtIndex:i];
//        NSString * imageDataString = [[obj fields] objectForKey:@"Body"];
//        NSData * imageData = [Base64 decode:imageDataString];
//        NSString * username = [[obj fields] objectForKey:@"Name"];
//        // Save the image data
//        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString * documentsDirectoryPath = [paths objectAtIndex:0];
//        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", username, @".png"]];
//        NSFileManager * fileManager = [NSFileManager defaultManager];
//        // Create file
//        [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
//    }
//     }@catch (NSException *exp) {
//        SMLog(@"Exception Name Chatter :didGetImagesForIds %@",exp.name);
//        SMLog(@"Exception Reason Chatter :didGetImagesForIds %@",exp.reason);
//         [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
//    }
//    if (chatterArray != nil)
//        [self loadChatter];
//}

- (NSString *) getUserNameFromArray:(NSArray *)userArray WithId:(NSString *)usrString
{
    for (int i = 0; i < [userArray count]; i++)
    {
     @try
        {
            NSDictionary * dict = [[userArray objectAtIndex:i] fields];
            if ([[dict objectForKey:@"Id"] isEqualToString:usrString])
            {
                return [dict objectForKey:USERNAME_CHATTER]; // USERNAME
            }
        }@catch (NSException *exp) {
            SMLog(@"Exception Name Chatter :getUserNameFromArray %@",exp.name);
            SMLog(@"Exception Reason Chatter :getUserNameFromArray %@",exp.reason);
            [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
        }
    }
    return @"";
}

- (NSString *) getUserEmailFromArray:(NSArray *)userArray WithId:(NSString *)usrString
{
    for (int i = 0; i < [userArray count]; i++)
    {
        NSDictionary * dict = [[userArray objectAtIndex:i] fields];
        if ([[dict objectForKey:@"Id"] isEqualToString:usrString])
            return [dict objectForKey:CHATTEREMAIL];
    }
    return @"";
}

// #$#$#$#$#$#$$#$#$#$#$#$#$#$#$#$#$#$$##$#$#$#$#$#$#$#$#$#$#$#$#$#$
- (void) loadChatter
{
    [activity stopAnimating];
    
    
    if (chatterArray != nil)
    {
        if (chatterArrayForTable)
            [chatterArrayForTable release];
        chatterArrayForTable = [chatterArray retain];
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            [chatterArrayForTable retain];
        }
        
        SMLog(@"%@", chatterArrayForTable);
        if (isChatterAlive && !didEditRow)
            if (!isKeyboardShowing)
                [chatTable reloadData];
    }
    
    
    if ([appDelegate isInternetConnectionAvailable])
    {
        [self resetAndStartTimer];
    }
}

- (void) resetAndStartTimer
{
    if ([appDelegate isInternetConnectionAvailable])
        if (isChatterAlive && !didEditRow)
            if (!isKeyboardShowing)
               [NSTimer scheduledTimerWithTimeInterval:TIMERINTERVAL target:self selector:@selector(fetchPosts) userInfo:nil repeats:NO];
}

//  Unused methods
//- (IBAction) postNewChat
//{
//    if (![appDelegate isInternetConnectionAvailable])
//    {
//        [activity stopAnimating];
//        appDelegate.shouldShowConnectivityStatus = TRUE;
//        [appDelegate displayNoInternetAvailable];
//        return;
//    }
//    
//    didEditRow = NO;
//    
//    [newPostText resignFirstResponder];
//
//    ZKSObject * cObj = [[ZKSObject alloc] initWithType:@"FeedPost"];
//
//    [cObj setFieldValue:newPostText.text field:@"Body"];
//    [cObj setFieldValue:productId field:@"ParentId"];
//
//    NSArray *objects = [[NSArray alloc] initWithObjects:cObj, nil];
//
//    didRunOperation = YES;
//    [iOSObject create:objects];
//    
//    // Analyser
//    [objects release];
//    [cObj release];
//    
//    newPostText.text = @"";
//}

- (void) didCreateObjects:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
    didRunOperation = NO;
    SMLog(@"Created objects");
    
    // Need to fetch post result first and then call fetchPosts
    
    [self fetchPosts];
}

#pragma mark -
#pragma mark ChatterCell Delegate
- (void) postComment:(NSString *)_comment forFeedCommentId:(NSString *)_feedCommentId;
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
    didEditRow = NO;
    
    ZKSObject * cObj = [[ZKSObject alloc] initWithType:@"FeedComment"];
    
    [cObj setFieldValue:_feedCommentId field:@"FeedItemId"];

    [cObj setFieldValue:_comment field:@"CommentBody"];

    NSArray *objects = [[NSArray alloc] initWithObjects:cObj, nil];
    
    didRunOperation = YES;
    [iOSObject create:objects];
    
    [objects release];
    [cObj release];
}

- (IBAction) ShowMap
{
    willShowMap = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) Done
{
    
    if ( ![appDelegate isInternetConnectionAvailable] )
    {
        NSError * error = nil;
        
        SMLog(@"%@", chatterArrayForTable);
        for ( int i = 0; i < [chatterArrayForTable count]; i++ )
        {
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * documentsDirectoryPath = [paths objectAtIndex:0];
            NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[[chatterArrayForTable objectAtIndex:i]objectForKey:@"Username"], @".png"]];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:filePath error:&error]; 
        }
    }
    
    SMLog(@"%@", userNameImageList);
    NSError * error = nil;
    for (NSString * userName in userNameImageList)
    {
        // delete the image file if it already exists
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectoryPath = [paths objectAtIndex:0];
        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", userName, @".png"]];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    [userNameImageList removeAllObjects];
    
    isChatterAlive = NO;
    
    if ([delegate respondsToSelector:@selector(closeChatter)])
        [delegate closeChatter];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }
    else
        if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
            
        }
        else
            return NO;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [chatTable release];
    chatTable = nil;
    [activity release];
    activity = nil;
    [doneButton release];
    doneButton = nil;
    [calendarButton release];
    calendarButton = nil;
    [productPicture release];
    productPicture = nil;
    [productNameLabel release];
    productNameLabel = nil;
    [productDateLabel release];
    productDateLabel = nil;
    [newPostText release];
    newPostText = nil;
    [shareButton release];
    shareButton = nil;
    [backButton release];
    backButton = nil;
    [navChatterBar release];
    navChatterBar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [backButton release];
    [shareButton release];
    [navChatterBar release];
    [super dealloc];
    
    delegate = nil;
    
    [chatTable release];
    iOSObject.caller = nil;
    
    [selfId release];
    [productId release];
    [productName release];
    [chatterArray release];
    
    // Need to disable Done and Calendar button while query is being fired
    [doneButton release];
    [calendarButton release];
    
    [productPicture release];
    [productNameLabel release];
    [productDateLabel release];
    [newPostText release];
    [imageCache release];
    [userRecordArray release];
    [prevDateString release];
    [usrStringArray release];
    [chatterQueryArray release];
    [chatterArrayForTable release];
}

#pragma mark -
#pragma mark UITableView Protocol Methods

- (ChatterCell *) createCustomCellWithId:(NSString *) cellIdentifier
{
	NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"ChatterCell" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	ChatterCell * customCell = nil;
	
    NSObject* nibItem = nil;
	
    while ( (nibItem = [nibEnumerator nextObject]) != nil)
	{
		if ( [nibItem isKindOfClass: [ChatterCell class]])
		{
			customCell = (ChatterCell *) nibItem;
			if ([customCell.reuseIdentifier isEqualToString:cellIdentifier ])
				break; // OneTeamUS We have a winner
			else
				customCell = nil;
		}
	}
    //Radha 25th April 2011
    NSString * str = [appDelegate.wsInterface.tagsDictionary objectForKey:CHATTER_POST];
    [customCell setText:str];

    NSString * post = [appDelegate.wsInterface.tagsDictionary objectForKey:CHATTER_POST];
    [customCell setPlaceholder:post];

    
    return customCell;
}

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentEditRow = [indexPath retain];
    currentCell = (ChatterCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    if ([currentCell.reuseIdentifier isEqualToString:@"ChatterPostCommentCell"])
    {
        // Enable the textfield and make it first responder
        didEditRow = YES;
        currentCell.postComment.enabled = YES;
        [currentCell.postComment becomeFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * postType = [[chatterArray objectAtIndex:indexPath.row] objectForKey:POSTTYPE];
    if ([postType isEqualToString:TYPEFEED] || [postType isEqualToString:TYPECOMMENT])
        return 102;
    else if ([postType isEqualToString:TYPECOMMENTPOST])
        return 51;
    else
        return 37;
    return 44;
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//  Unused methods
//- (NSMutableArray *) getTableDataFromChatterArray:(NSMutableArray *)_chatterArray
//{
//    NSMutableArray * tableArray = [[[NSMutableArray alloc] initWithCapacity:[chatterArray count]] autorelease];
//    for (int i = 0; i < [chatterArray count]; i++)
//    {
//        // Analyser
//        [tableArray addObject:[chatterArray objectAtIndex:i]];
//        // [tableArray addObject:[[chatterArray objectAtIndex:i] retain]];
//    }
//    return tableArray;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    ChatterCell * cell = nil;
    @try
    {
        NSDictionary * postDict = [chatterArrayForTable objectAtIndex:row];
        // Find out type of post
        NSString * postType = [postDict objectForKey:POSTTYPE];
        
        if ([postType isEqualToString:TYPEFEED])
        {
            cell = (ChatterCell *) [tableView dequeueReusableCellWithIdentifier:@"ChatterPostCell"];
            if (cell == nil)
            {
                cell = [self createCustomCellWithId:@"ChatterPostCell"];
            }

            [cell resetImages];
            
            NSString * dateTime = [postDict objectForKey:POSTDATESTAMP];
            dateTime = [iOSInterfaceObject getLocalTimeFromGMT:dateTime];
            
            dateTime = [dateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            dateTime = [dateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];

            // Cell data
            cell.CreatedById = [postDict objectForKey:POSTCREATEDBYID];
            SMLog(@"%@", cell.CreatedById);
            cell.FeedPostId = [postDict objectForKey:FEEDPOSTID];
            // match userrecord with id
            NSString * username;
            UIImage * image = nil;
            
            if ( ![appDelegate isInternetConnectionAvailable] )
            {
                SMLog(@"%@", [[chatterArrayForTable objectAtIndex:indexPath.row]objectForKey:@"Username"]);
                
                image = [imageCache getImage:[NSString stringWithFormat:@"%@.png", [[chatterArrayForTable objectAtIndex:indexPath.row]objectForKey:@"Username"]]];
                
                if (image == nil)
                {
                    NSData *imageData = [appDelegate.calDataBase getImageDataForUserName:[[chatterArrayForTable objectAtIndex:indexPath.row]objectForKey:@"Username"]];
                    SMLog(@"%d", [imageData length]);
                    
                    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString * documentsDirectoryPath = [paths objectAtIndex:0];
                    NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [[chatterArrayForTable objectAtIndex:indexPath.row]objectForKey:@"Username"], @".png"]];
                    NSFileManager * fileManager = [NSFileManager defaultManager];
                    
                    [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
                    
                    image = [imageCache getImage:[NSString stringWithFormat:@"%@.png", [[chatterArrayForTable objectAtIndex:indexPath.row]objectForKey:@"Username"]]];
                }
            }

            for (int i = 0; i < [userRecordArray count]; i++)
            {
                if ([[[[userRecordArray objectAtIndex:i] fields] objectForKey:@"Id"] isEqualToString:cell.CreatedById])
                {
                    username = [[[userRecordArray objectAtIndex:i] fields] objectForKey:@"Username"];
                    image = [imageCache getImage:[NSString stringWithFormat:@"%@.png", username]];
                    break;
                }
            }
            [cell setPostUserName:[postDict objectForKey:USERNAME_CHATTER] 
                  ChatText:[postDict objectForKey:FEEDPOSTBODY] 
                  DateTime:dateTime
                  UserImage:image];
            cell.email = [postDict objectForKey:CHATTEREMAIL];
        }
        
        if ([postType isEqualToString:TYPECOMMENT])
        {
            cell = (ChatterCell *) [tableView dequeueReusableCellWithIdentifier:@"ChatterCommentCell"];
            if (cell == nil)
            {
                cell = [self createCustomCellWithId:@"ChatterCommentCell"];
            }
            
            [cell resetImages];
            
            NSString * dateTime = [postDict objectForKey:POSTDATESTAMP];
            dateTime = [iOSInterfaceObject getLocalTimeFromGMT:dateTime];
            
            dateTime = [dateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            dateTime = [dateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            
            // Cell data
            cell.CreatedById = [postDict objectForKey:POSTCREATEDBYID];
            // cell.feedCommentId = [postDict objectForKey:FEEDPOSTID];
            // match userrecord with id
            NSString * username;
            UIImage * image = nil;
            
            if ( ![appDelegate isInternetConnectionAvailable] )
            {
                NSData *imageData = [appDelegate.calDataBase getImageDataForUserName:[[chatterArrayForTable objectAtIndex:indexPath.row]objectForKey:@"Username"]];
                SMLog(@"%d", [imageData length]);
                
                NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString * documentsDirectoryPath = [paths objectAtIndex:0];
                NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [[chatterArrayForTable objectAtIndex:indexPath.row]objectForKey:@"Username"], @".png"]];
                NSFileManager * fileManager = [NSFileManager defaultManager];
                
                // Create file
                [fileManager createFileAtPath:filePath contents:imageData attributes:nil]; 
                image = [imageCache getImage:[NSString stringWithFormat:@"%@.png", [[chatterArrayForTable objectAtIndex:indexPath.row]objectForKey:@"Username"]]];
            }

            for (int i = 0; i < [userRecordArray count]; i++)
            {
                if ([[[[userRecordArray objectAtIndex:i] fields] objectForKey:@"Id"] isEqualToString:cell.CreatedById])
                {
                    username = [[[userRecordArray objectAtIndex:i] fields] objectForKey:@"Username"];
                    image = [imageCache getImage:[NSString stringWithFormat:@"%@.png", username]];
                    break;
                }
            }
            [cell setCommentUserName:[postDict objectForKey:USERNAME_CHATTER] 
                  ChatText:[postDict objectForKey:FEEDPOSTBODY] 
                  DateTime:dateTime 
                  UserImage:image];
            cell.email = [postDict objectForKey:CHATTEREMAIL];
        }
        
        if ([postType isEqualToString:TYPECOMMENTPOST])
        {
            cell = (ChatterCell *) [tableView dequeueReusableCellWithIdentifier:@"ChatterPostCommentCell"];
            if (cell == nil)
            {
                cell = [self createCustomCellWithId:@"ChatterPostCommentCell"];
            }
            cell.delegate = self;
            cell.feedCommentId = [postDict objectForKey:PRODUCT2FEEDID];
            // SMLog(@"%@", [postDict objectForKey:PRODUCT2FEEDID]);
        }
        
        if ([postType isEqualToString:TYPECHATSEPERATOR])
        {
            cell = (ChatterCell *) [tableView dequeueReusableCellWithIdentifier:@"ChatterSeperatorCell"];
            if (cell == nil)
            {
                cell = [self createCustomCellWithId:@"ChatterSeperatorCell"];
            }
           cell.dayLabel.text = [[postDict objectForKey:FEEDPOSTBODY] isKindOfClass:[NSString class]]?[postDict objectForKey:FEEDPOSTBODY]:@"";
        }
    }@catch (NSException *exp) {
        SMLog(@"Exception Name Chatter :cellForRowAtIndexPath %@",exp.name);
        SMLog(@"Exception Reason Chatter :cellForRowAtIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    if (cell == nil)
    SMLog(@"%@", cell);
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (chatterArray == nil)
        return 0;
    return [chatterArray count];
}

#pragma mark - Launch SmartVan

- (IBAction) launchSmartVan
{
    HTMLBrowser * htmlBrowser = [[HTMLBrowser alloc] initWithURLString:@"http://www.thesmartvan.com"];
    htmlBrowser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    htmlBrowser.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:htmlBrowser animated:YES completion:nil];
//    [self presentViewController:htmlBrowser animated:YES completion:nil completion:nil];
    [htmlBrowser release];
}

//sahana Aug 17th 2011
- (NSString *) getFullPhotoUrlFromArray:userArray WithId:usrString
{
    for (int i = 0; i < [userArray count]; i++)
    {
        @try
        {
            NSDictionary * dict = [[userArray objectAtIndex:i] fields];
            if ([[dict objectForKey:@"Id"] isEqualToString:usrString])
                return [dict objectForKey:FULLPHOTOURL];
        }@catch (NSException *exp) {
            SMLog(@"Exception Name Chatter :getFullPhotoUrlFromArray %@",exp.name);
            SMLog(@"Exception Reason Chatter :getFullPhotoUrlFromArray %@",exp.reason);
            [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
        }
    }
    return @"";
}

@end
