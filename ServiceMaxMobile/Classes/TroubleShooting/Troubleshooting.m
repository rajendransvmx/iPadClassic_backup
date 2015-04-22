
//
//  Troubleshooting.m
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Troubleshooting.h"
#import "TroubleshootingCell.h"
#import "Utility.h"
#import "MoviePlayer.h"
#import "YouTubeView.h"
#import "Base64.h"
#import "HTMLBrowser.h"
#import "About.h"
#import "DataBase.h"
#import "NSData-AES.h"
#import "SMXMonitor.h"

/*Accessibility changes*/
#import "AccessibilityTroubleShootConstants.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

//Radha 22nd April 2011
# import "LocalizationGlobals.h"

@implementation Troubleshooting

@synthesize delegate;
@synthesize productName, productId;
@synthesize isSessionInvalid;
@synthesize navigationBar;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
    }
    
    return self;
}

- (IBAction) displayUser:(id)sender
{
    UIButton * button = (UIButton *)sender;
    About * about = [[[About alloc] initWithNibName:@"About" bundle:nil] autorelease];
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:about];
    [popover setContentViewController:about animated:YES];
    [popover setPopoverContentSize:about.view.frame.size];
    popover.delegate = self;

    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if ([[popoverController contentViewController] isKindOfClass:[About class]])
        return YES;
    
    return YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
     /*ios7_support Trouble shooting */
    if (![Utility notIOS7]) {
        [self moveAllSubviewDown:self.view];
         self.view.backgroundColor = [UIColor colorWithRed:243.0/255 green:244/255.0 blue:247/255.0 alpha:1];
        UIImage *navImage = [UIImage imageNamed:@"navigation-bar.png"];
        [self.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    }
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//OAuth.
	[[ZKServerSwitchboard switchboard] doCheckSession];

    serviceMax = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    noMatch = [appDelegate.wsInterface.tagsDictionary objectForKey:TROUBLESHOOTING_ERROR];

    if (iOSObject == nil)
        iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];

    tableView.backgroundColor = [UIColor clearColor];

    count = 0;
    NSString * _productName;
    if (![appDelegate isInternetConnectionAvailable] )
    {
        _productName = [appDelegate.calDataBase getProductNameFromDbWithID:productId];
        
        if([_productName length] == 0 || productName == nil)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noMatch delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
            
            [alert show];
            [alert release];

        }
        else 
        {
            array = [appDelegate.calDataBase getTroubleShootingForProductName:_productName];
            
            [array retain];
            [tableView reloadData];
        }
    }

    else
    {
        //pavaman 17th Jan 2011 - added the IF condition below
        if (![productId isKindOfClass:[NSNull class]] && ![productId isEqualToString:@""])
        {
            //appDelegate.da
            [activity startAnimating];
            didRunOperation = YES;
        
            [self getProductNameForProductID:productId];
            SMLog(kLogLevelVerbose,@"%@",productName);
            //[appDelegate.calDataBase updateProductTableWithProductName:productName WithId:productId];
            didRunOperation = YES;
        
            
            [iOSObject queryTroubleshootingForProductName:productName];
            [tableView reloadData];
        }
        else
        {
            if ([appDelegate isInternetConnectionAvailable])
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noMatch delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                
                [alert show];
                [alert release];
            }		
        }
     }

    navBar.title = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_TROUBLESHOOTING];
    mSearchBar.placeholder = [appDelegate.wsInterface.tagsDictionary objectForKey:TROUBLESHOOTPLACEHOLDER];
    
    /*Accessibility changes*/
    [self setAccessibilityIdentifierForInstanceVariable];
}

/*Accessibility Changes*/
- (void) setAccessibilityIdentifierForInstanceVariable
{
    mSearchBar.isAccessibilityElement = YES;
    [mSearchBar setAccessibilityIdentifier:kAccTroubleShootSearch];
    
    backButton.isAccessibilityElement = YES;
    [backButton  setAccessibilityIdentifier:kAccBackButton];
    
    servimaxLogo.isAccessibilityElement = YES;
    [servimaxLogo setAccessibilityIdentifier:kAccServiceMaxLogo];
    
    productManual.isAccessibilityElement = YES;
    [productManual setAccessibilityIdentifier:kAccProductManual];
    
    chatter.isAccessibilityElement = YES;
    [chatter setAccessibilityIdentifier:kAccChatter];
    
    helpButton.isAccessibilityElement = YES;
    [helpButton setAccessibilityIdentifier:kAccHelpButton];
    
    webviewBack.isAccessibilityElement = YES;
    [webviewBack setAccessibilityIdentifier:kAccGoBack];
    
    webviewForward.isAccessibilityElement = YES;
    [webviewForward setAccessibilityIdentifier:kAccGoForward];

}


- (void)moveAllSubviewDown:(UIView *)parentView {
    
    NSArray *allSubViews = [parentView subviews];
    for (int counter = 0; counter < [allSubViews count]; counter++) {
        
        UIView *childView = [allSubViews objectAtIndex:counter];
        CGRect childFrame = childView.frame;
        childFrame.origin.y = childFrame.origin.y+20;
        childView.frame = childFrame;
    }
}
- (void) didInternetConnectionChange:(NSNotification *)notification
{
    /*appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(kLogLevelVerbose,@"Troubleshooting Internet Reachable");
     
    }
    else
    {
        SMLog(kLogLevelVerbose,@"Troubleshooting Internet Not Reachable");
        if (didRunOperation)
        {
            [activity stopAnimating];
            [appDelegate displayNoInternetAvailable];
            didRunOperation = NO;
        }
    }*/
}


//Radha 20th August
- (void) getProductNameForProductID:(NSString *)productTd
{
    NSString * _query = [NSString stringWithFormat:@"SELECT Name From Product2 WHERE Id = '%@'", productId];
	SMLog(kLogLevelVerbose,@"getProductNameForProductID = %@", _query);
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetProductName:error:context:) context:nil];
    
    didGetProductName = FALSE;
    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[Troubleshooting getProductNameForProductID]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        SMLog(kLogLevelVerbose,@"Troubleshooting getProductNameForProductId in while loop");
        if (didGetProductName)
            break;
        if (appDelegate.connection_error)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
    }
    [monitor monitorSMMessageWithName:@"[Troubleshooting getProductNameForProductID]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
}

- (void) didGetProductName:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{    
    NSArray * records = [result records];
    @try{
    if([records count] > 0)
    {
        ZKSObject * obj = [records objectAtIndex:0];
        NSDictionary * fields = [obj fields];
        productName = [[fields objectForKey:@"Name"] retain];
    }   
     }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Troubleshooting :didGetProductName %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Troubleshooting :didGetProductName %@",exp.reason);
    }
    @finally { 
    didGetProductName = TRUE;
	}
}

- (void) didSelectProductName:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * records = [result records];
    @try{
    if([records count] > 0)
    {
        array = [[result records] retain];
        subject.text = [[[array objectAtIndex:0] fields] objectForKey:@"Name"];
        
        ZKSObject * obj = [records objectAtIndex:0];
        NSDictionary * fields = [obj fields];
        productName = navBar.title = [fields objectForKey:@"Name"];
        [tableView reloadData];
    }
     }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Troubleshooting :didSelectProductName %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Troubleshooting :didSelectProductName %@",exp.reason);
    }
    @finally {
    [activity stopAnimating];
	}
}

- (IBAction) Help;
{    
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSString *lang=[appDelegate.dataBase checkUserLanguage];
    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"troubleshooting_%@",lang] ofType:@"html"];
    if((isfileExists == NULL) || [lang isEqualToString:@"en_US"] ||  !([lang length]>0))
    {
        help.helpString=@"troubleshooting.html";
    }
    else
    {
        help.helpString = [NSString stringWithFormat:@"troubleshooting_%@.html",lang];
    }
    [self presentModalViewController:help animated:YES];
    [help release];
}

// queryTroubleshootingForProductName Callback
- (void) didQueryTroubleshootingForProductName:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    //Shrinivas
    NSArray *_array;
    _array = [[result records] retain];  //Check leak here
    SMLog(kLogLevelVerbose,@"%d", [_array count]);
    
    array = [[NSMutableArray alloc]initWithCapacity:0];
    NSArray *keys = [[[NSArray alloc]initWithObjects:@"DocId", @"Name",@"Keywords",nil] autorelease];
    @try{
    for (int i = 0; i < [_array count]; i++ )
    {
        NSArray *objects = [[NSArray alloc]initWithObjects:[[[_array objectAtIndex:i] fields]objectForKey:@"Id"],[[[_array objectAtIndex:i] fields]objectForKey:@"Name"],[[[_array objectAtIndex:i] fields]objectForKey:@"Keywords"], nil]; 
        SMLog(kLogLevelVerbose,@"%@", objects);
        NSDictionary * _dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        [array addObject:_dict];
        
        [_dict release];
        [objects release];
    }
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Troubleshooting :didQueryTroubleshootingForProductName %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Troubleshooting :didQueryTroubleshootingForProductName %@",exp.reason);
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /*didRunOperation = NO;
    [activity stopAnimating];
    
    array = [[result records] retain];
    SMLog(kLogLevelVerbose,@"%@", array);
    if ([array count] > 0)
    {
        subject.text = [[[array objectAtIndex:0] fields] objectForKey:@"Name"];
        SMLog(kLogLevelVerbose,@"%@", subject.text);
    }
    else
    {
        subject.text = @"";
        if ([appDelegate isInternetConnectionAvailable])
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noMatch delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [webView loadHTMLString:@"" baseURL:nil];
        }
        return;
    }*/
    @finally {
        [activity stopAnimating];
        [tableView reloadData];
    }
}

//  Unused Methods
//- (void) showFirstTroubleshooting
//{
//    if ([array count] > 0)
//        [self showTroubleshootingForIndex:0];
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        /*##Offline Search##*/
        
        array = [appDelegate.calDataBase getTroubleShootingForProductName:searchBar.text];
        
        self.productId = [[array objectAtIndex:_index] objectForKey:DOCUMENTS_ID];
        self.productName = [[array objectAtIndex:_index] objectForKey:DOCUMENTS_NAME];
        [array retain];
        [tableView reloadData];
    }
    
    else
    {
        [searchBar resignFirstResponder];
    
        if (array != nil)
            [array release];
    
        array = nil;
    
        if (searchBar.text.length > 0)
        {
            didRunOperation = YES;
            [iOSObject queryTroubleshootingForProductName:searchBar.text];
            
            [tableView reloadData];
            
        }
    }
}

//Shrinivas 02/12/2011
/*- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ( [searchText length] == 0 )
        return;
    else
    {
        array = nil;
        array = [[appDelegate.calDataBase getTroubleShootingForProductName:searchText]retain];
        
        [tableView reloadData];
    }
}*/

//  Unused Methods
//- (void) showResults
//{
//    
//}


- (NSString *) showTroubleshootingForIndex:(NSUInteger)index
{
    //Shrinivas
    NSData *data;
    
    SMLog(kLogLevelVerbose,@"%@", array);
    self.productId = [appDelegate.calDataBase getProductIdForName:self.productName];
    
    _index = index;
	@try{
	//Change for Troubleshooting  22/07/2012.
	if (![appDelegate isInternetConnectionAvailable])
	{
		data = [appDelegate.calDataBase selectTroubleShootingDataFromDBwithID:[[array objectAtIndex:index]objectForKey:@"DocId"] andName:[[array objectAtIndex:index]objectForKey:@"Name"]];
		
		if ( data != NULL)
		{
			TroubleshootingCell * cell = (TroubleshootingCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
			cell.isClicked = NO;
			[cell stopActivity];
			
			//Shrinivas
			NSFileManager * fileManager = [NSFileManager defaultManager];
			NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString * documentsDirectoryPath = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
			
			SMLog(kLogLevelVerbose,@"%@", array);
			SMLog(kLogLevelVerbose,@"%@",[[array objectAtIndex:index]objectForKey:@"DocId"]);
			
			NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[[array objectAtIndex:index]objectForKey:@"DocId"], @".zip"]];
			
			NSString * folderPath = [documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"DocId"]];
			
			SMLog(kLogLevelVerbose,@"%@, %@", folderPath, filePath);
			
			[fileManager createFileAtPath:filePath contents:data attributes:nil];
			
			[self unzipAndViewFile:[folderPath stringByAppendingString:@".zip"]];
			
			NSString * actualFilePath = [documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"Name"]];
			actualFilePath = [actualFilePath stringByAppendingPathComponent:@"index.html"];
			
			SMLog(kLogLevelVerbose,@"%@", actualFilePath);
			
			NSURL * baseURL = [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"Name"]]];
			NSError * error;
			
			NSString * fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
			
			SMLog(kLogLevelVerbose,@"%@", fileContents);
			
			if (fileContents == nil)
			{
				NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [[array objectAtIndex:index]objectForKey:@"DocId"], @".zip"]];
				[self unzipAndViewFile:filePath];
				fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
				
				SMLog(kLogLevelVerbose,@"%@", fileContents);
			}
			
			[webView loadHTMLString:fileContents baseURL:baseURL];
		}
		
	}
	
    else
    {
        NSArray * keys = [[NSArray alloc] initWithObjects:FILEID, FILENAME, nil];
        NSArray * objects = [[NSArray alloc] initWithObjects:[[array objectAtIndex:index]objectForKey:@"DocId"] ,[[array objectAtIndex:index]objectForKey:@"Name"],nil];
		
        NSDictionary * _dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        SMLog(kLogLevelVerbose,@"%@", _dict);
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            [activity stopAnimating];
            
            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:toubleshoot_offline_error];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_connection_error];
            NSString * ok = [appDelegate.wsInterface.tagsDictionary objectForKey: ALERT_ERROR_OK ];
            
            UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
			
            [_alert show];
            [_alert release];
        }
        
        [activity startAnimating];
        downloadInProgress = YES;
        didRunOperation = YES;
        connection = [iOSObject queryTroubleshootingBodyForDocument:_dict]; 
        
        [keys release];
        [_dict release];
        [objects release];
    }
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name Troubleshooting :showTroubleshootingForIndex %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason Troubleshooting :showTroubleshootingForIndex %@",exp.reason);
    }

//    else
//    {
//        //Display data here
//        TroubleshootingCell * cell = (TroubleshootingCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//        cell.isClicked = NO;
//        [cell stopActivity];
//        
//        //Shrinivas
//        NSFileManager * fileManager = [NSFileManager defaultManager];
//        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString * documentsDirectoryPath = [paths objectAtIndex:0]; 
//        
//        SMLog(kLogLevelVerbose,@"%@", array);
//        SMLog(kLogLevelVerbose,@"%@",[[array objectAtIndex:index]objectForKey:@"DocId"]);
//        
//        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[[array objectAtIndex:index]objectForKey:@"DocId"], @".zip"]];
//
//        NSString * folderPath = [documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"DocId"]];
//        
//        //[fileManager createFileAtPath:filePath contents:data attributes:nil];
//        
//        SMLog(kLogLevelVerbose,@"%@, %@", folderPath, filePath);
//        
//        [fileManager createFileAtPath:filePath contents:data attributes:nil];
//        
//        [self unzipAndViewFile:[folderPath stringByAppendingString:@".zip"]];
//        
//        NSString * actualFilePath = [documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"Name"]];
//        actualFilePath = [actualFilePath stringByAppendingPathComponent:@"index.html"];
//        
//        SMLog(kLogLevelVerbose,@"%@", actualFilePath);
//        
//        NSURL * baseURL = [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"Name"]]];
//        NSError * error;
//        
//        NSString * fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
//        
//        SMLog(kLogLevelVerbose,@"%@", fileContents);
//        
//        if (fileContents == nil)
//        {
//            NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [[array objectAtIndex:index]objectForKey:@"DocId"], @".zip"]];
//            [self unzipAndViewFile:filePath];
//            fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
//            
//            SMLog(kLogLevelVerbose,@"%@", fileContents);
//        }
//        
//        [webView loadHTMLString:fileContents baseURL:baseURL];
//        
//    }
    
    return [[array objectAtIndex:index]objectForKey:@"DocId"];
    
}

- (void) didQueryTroubleshootingBodyForDocument:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    connection = nil;
    downloadInProgress = NO;
    didRunOperation = NO;
    NSString * _fileId = nil, * _fileName = nil;
    NSDictionary * dict = (NSDictionary *)context;
    @try{
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        _fileId = [dict objectForKey:FILEID];
        _fileName = [dict objectForKey:FILENAME];

        NSNumber * indexNum = [dict objectForKey:CELLINDEX];
        TroubleshootingCell * cell = (TroubleshootingCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[indexNum intValue] inSection:0]];
        cell.isClicked = NO;
        [cell stopActivity];
        
        referenceCount--;
    
        NSArray * _array = [result records];
        if ([_array count] == 0)
        {
            [activity stopAnimating];
            return;
        }
    
        NSData * data;
      
        NSString * fileBinary = [[[_array objectAtIndex:0] fields] objectForKey:@"Body"];
        // Need to decode data from Base64
        data = [Base64 decode:fileBinary];
        
        SMLog(kLogLevelVerbose,@"%@", data);
        
        if ( data != nil )
        {
            [appDelegate.calDataBase insertTroubleshootingIntoDB:[NSMutableArray arrayWithObject:[array objectAtIndex:_index]]];
            [appDelegate.calDataBase insertTroubleShoot:[NSMutableArray arrayWithObject:[array objectAtIndex:_index]] Body:fileBinary];
        }
        
        if (referenceCount == 0)
            [activity stopAnimating];
    
    
        if ([lastClickedFile isEqualToString:_fileName])   //Change for troubleshooting Date : 22/06/2012
		{
			//[self showTroubleshootingForIndex:lastClickedIndex];
			
			TroubleshootingCell * cell = (TroubleshootingCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastClickedIndex inSection:0]];
			
			cell.isClicked = NO;
			[cell stopActivity];
			
			//Shrinivas
			NSFileManager * fileManager = [NSFileManager defaultManager];
			NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString * documentsDirectoryPath = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
			
			SMLog(kLogLevelVerbose,@"%@", array);
			SMLog(kLogLevelVerbose,@"%@",[[array objectAtIndex:lastClickedIndex]objectForKey:@"DocId"]);
			
			NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[[array objectAtIndex:lastClickedIndex]objectForKey:@"DocId"], @".zip"]];
			
			NSString * folderPath = [documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:lastClickedIndex]objectForKey:@"DocId"]];
			
			SMLog(kLogLevelVerbose,@"%@, %@", folderPath, filePath);
			
			[fileManager createFileAtPath:filePath contents:data attributes:nil];
			
			[self unzipAndViewFile:[folderPath stringByAppendingString:@".zip"]];
			
			NSString * actualFilePath = [documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:lastClickedIndex]objectForKey:@"Name"]];
			actualFilePath = [actualFilePath stringByAppendingPathComponent:@"index.html"];
			
			SMLog(kLogLevelVerbose,@"%@", actualFilePath);
			
			NSURL * baseURL = [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:lastClickedIndex]objectForKey:@"Name"]]];
			NSError * error;
			
			NSString * fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
			
			SMLog(kLogLevelVerbose,@"%@", fileContents);
			
			if (fileContents == nil)
			{
				NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [[array objectAtIndex:lastClickedIndex]objectForKey:@"DocId"], @".zip"]];
				
				[self unzipAndViewFile:filePath];
				fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
				
				SMLog(kLogLevelVerbose,@"%@", fileContents);
			}
			
			[webView loadHTMLString:fileContents baseURL:baseURL];
		}            
    }
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name Troubleshooting :didQueryTroubleshootingBodyForDocument %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason Troubleshooting :didQueryTroubleshootingBodyForDocument %@",exp.reason);
    }

}

- (IBAction) goPrev;
{
    
}

- (IBAction) goNext;
{
    
}

- (BOOL) unzipAndViewFile:(NSString *)_file
{
    if (zip == nil)
        zip = [[ZipArchive alloc] init];
    
    SMLog(kLogLevelVerbose,@"%@", _file);
    BOOL retVal = [zip UnzipOpenFile:_file];
    
    if (!retVal)
    {
        return NO;
    }
    
    // Directory Path to unzip file to...
    NSString * docDir = [appDelegate getAppCustomSubDirectory]; // [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    SMLog(kLogLevelVerbose,@"%@", docDir);
    
    // Create "dataName" directory in Documents
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    
    SMLog(kLogLevelVerbose,@"%@", folderNameToCreate);
    
    [fm createDirectoryAtPath:[docDir stringByAppendingPathComponent:folderNameToCreate]
  withIntermediateDirectories:YES 
                   attributes:(NSDictionary *)nil
                        error:(NSError **)&error];

    NSString * unzipPath = [docDir stringByAppendingPathComponent:folderNameToCreate];

    retVal = [zip UnzipFileTo:unzipPath overWrite:YES];
    
    if (!retVal)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
            
    }
    else
        return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    SMLog(kLogLevelWarning,@"didReceiveMemoryWarning");
}


- (void)viewDidUnload
{
    [tableView release];
    tableView = nil;
    [mSearchBar release];
    mSearchBar = nil;
    [activity release];
    activity = nil;
    [subject release];
    subject = nil;
    [webView release];
    webView = nil;
    [back release];
    back = nil;
    [forward release];
    forward = nil;
    [backButton release];
    backButton = nil;
    [navBar release];
    navBar = nil;
    [backButton release];
    backButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    appDelegate.didTroubleshootingUnload = YES;
   
}

- (IBAction) Done
{
    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    isLoaded = NO;
    [connection cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) GoToMap
{
    willGoToMap = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) showProductManual
{
    ProductManual * pManual = [[ProductManual alloc] initWithNibName:@"ProductManual" bundle:nil];
    pManual.delegate = self;
    pManual.productId = self.productId;
    pManual.productName = self.productName;
    pManual.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    pManual.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pManual animated:YES completion:nil];
    [pManual release];
}

- (IBAction) showChatter
{
    NSString * productInfo = [appDelegate.wsInterface.tagsDictionary objectForKey:TROUBLESHOOTING_NO_PROD_INFO_ERROR];
    
    Chatter * chatter = [[Chatter alloc] initWithNibName:@"Chatter" bundle:nil];
    chatter.delegate = self;
    chatter.modalPresentationStyle = UIModalPresentationFullScreen;
    chatter.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    chatter.productId = self.productId;
    chatter.productName = self.productName;
    
    if ((chatter.productId != nil) && ([chatter.productId isKindOfClass:[NSString class]]) && ([chatter.productId length] > 0))
        [self presentViewController:chatter animated:YES completion:nil];
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:productInfo delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

    [chatter release];
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activity stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activity stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webViewer
{
    if ([webViewer canGoBack])
    {
        [back setEnabled:YES];
        [back setImage:[UIImage imageNamed:@"back_enabled.png"] forState:UIControlStateNormal];
    }
    else
    {
        [back setEnabled:NO];
        [back setImage:[UIImage imageNamed:@"back_disabled.png"] forState:UIControlStateDisabled];
    }
    
    if ([webViewer canGoForward])
    {
        [forward setEnabled:YES];
        [forward setImage:[UIImage imageNamed:@"forward_enabled.png"] forState:UIControlStateNormal];
    }
    else
    {
        [forward setEnabled:NO];
        [forward setImage:[UIImage imageNamed:@"forward_disabled.png"] forState:UIControlStateNormal];
    }

    [activity startAnimating];
}

#pragma mark -
#pragma mark ProductManualDelegate Methods
- (void) showMap
{
    willGoToMap = YES;
    [self performSelector:@selector(dismissViewControllerAnimated:completion:) withObject:@"1" afterDelay:0.1];
}

- (void)dealloc
{
    isLoaded = NO;
    [backButton release];
    [navigationBar release];
    [servimaxLogo release];
    [productManual release];
    [chatter release];
    [helpButton release];
    [webviewBack release];
    [webviewForward release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
	if (array != nil && [array count] > 0)
	{
		rowCount = [array count];
	}
    return rowCount;

}

- (TroubleshootingCell *) createCustomCellWithId:(NSString *) cellIdentifier
{
	NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"TroubleshootingCell" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	TroubleshootingCell * customCell = nil;

    NSObject* nibItem = nil;

    while ( (nibItem = [nibEnumerator nextObject]) != nil)
	{
		if ( [nibItem isKindOfClass: [TroubleshootingCell class]])
		{
			customCell = (TroubleshootingCell *) nibItem;
			if ([customCell.reuseIdentifier isEqualToString:cellIdentifier ])
				break; // OneTeamUS We have a winner
			else
				customCell = nil;
		}
	}
	return customCell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TroubleshootingCell";
    
    TroubleshootingCell * cell = (TroubleshootingCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createCustomCellWithId:CellIdentifier];
    }
    
    // Configure the cell...
    
    //Shrinivas
    if ( [[[array objectAtIndex:indexPath.row]objectForKey:@"Name"] isKindOfClass:[NSString class]] )
    {
        [cell setCellLabel:[[array objectAtIndex:indexPath.row]objectForKey:@"Name"] Image:@"troubleshooting-possibility-searchresult-button.png"];
    }
    
    else
    {
        ZKSObject * obj = [array objectAtIndex:indexPath.row];
        [cell setCellLabel:[[obj fields] objectForKey:@"Name"] Image:@"troubleshooting-possibility-searchresult-button.png"];
    }
   
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    
    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    TroubleshootingCell * cell = (TroubleshootingCell *) [_tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell.isClicked && !downloadInProgress)
    {
        subject.text = [cell getCellLabel];
        cell.isClicked = YES;
        referenceCount++;
        [cell startActivity];
        [self showTroubleshootingForIndex:indexPath.row];
    }
    
    lastClickedFile = [cell getCellLabel];
    lastClickedIndex = indexPath.row;
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    didRunOperation = YES;
}

#pragma mark - Launch SmartVan

- (IBAction) launchSmartVan
{
    HTMLBrowser * htmlBrowser = [[HTMLBrowser alloc] initWithURLString:@"http://www.thesmartvan.com"];
    htmlBrowser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    htmlBrowser.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:htmlBrowser animated:YES completion:nil];
    [htmlBrowser release];
}

@end
