
//
//  Troubleshooting.m
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Troubleshooting.h"
#import "TroubleshootingCell.h"

#import "MoviePlayer.h"
#import "YouTubeView.h"
#import "Base64.h"
#import "HTMLBrowser.h"
#import "About.h"
#import "DataBase.h"
#import "NSData-AES.h"

//Radha 22nd April 2011
# import "LocalizationGlobals.h"

@implementation Troubleshooting

@synthesize delegate;
@synthesize productName, productId;
@synthesize isSessionInvalid;

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
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate goOnlineIfRequired];
    serviceMax = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    noMatch = [appDelegate.wsInterface.tagsDictionary objectForKey:TROUBLESHOOTING_ERROR];

    if (iOSObject == nil)
        iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];

    tableView.backgroundColor = [UIColor clearColor];

    count = 0;
    NSString * _productName;
    if (!appDelegate.isInternetConnectionAvailable )
    {
        _productName = [appDelegate.calDataBase getProductNameFromDbWithID:productId];
        
        array = [appDelegate.calDataBase getTroubleShootingForProductName:_productName];
        
        [array retain];
        [tableView reloadData];
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
            NSLog(@"%@",productName);
            [appDelegate.calDataBase updateProductTableWithProductName:productName WithId:productId];
            didRunOperation = YES;
        
            
            [iOSObject queryTroubleshootingForProductName:productName];
            [tableView reloadData];
        }
        else
        {
            if (appDelegate.isInternetConnectionAvailable)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noMatch delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                
                [alert show];
                [alert release];
            }		
        }
     }

    navBar.title = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_TROUBLESHOOTING];
    mSearchBar.placeholder = [appDelegate.wsInterface.tagsDictionary objectForKey:TROUBLESHOOTPLACEHOLDER];
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    /*appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        NSLog(@"Troubleshooting Internet Reachable");
    }
    else
    {
        NSLog(@"Troubleshooting Internet Not Reachable");
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
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetProductName:error:context:) context:nil];
    
    didGetProductName = FALSE;
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, FALSE))
    {
        NSLog(@"Troubleshooting getProductNameForProductId in while loop");
        if (didGetProductName)
            break;
    }
}

- (void) didGetProductName:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{    
    NSArray * records = [result records];
    if([records count] > 0)
    {
        ZKSObject * obj = [records objectAtIndex:0];
        NSDictionary * fields = [obj fields];
        productName = [[fields objectForKey:@"Name"] retain];
    }   
    didGetProductName = TRUE;
}

- (void) didSelectProductName:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * records = [result records];
    if([records count] > 0)
    {
        array = [[result records] retain];
        subject.text = [[[array objectAtIndex:0] fields] objectForKey:@"Name"];
        
        ZKSObject * obj = [records objectAtIndex:0];
        NSDictionary * fields = [obj fields];
        productName = navBar.title = [fields objectForKey:@"Name"];
        [tableView reloadData];
    }
    [activity stopAnimating];
}

- (IBAction) Help;
{
    //Abinash fix for defect 3350
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        //[appDelegate displayNoInternetAvailable];
        return;
    }
    
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"troubleshooting.html";
    [self presentModalViewController:help animated:YES];
    [help release];
}

// queryTroubleshootingForProductName Callback
- (void) didQueryTroubleshootingForProductName:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    //Shrinivas
    NSArray *_array;
    _array = [[result records] retain];  //Check leak here
    NSLog(@"%d", [_array count]);
    
    array = [[NSMutableArray alloc]initWithCapacity:0];
    NSArray *keys = [[[NSArray alloc]initWithObjects:@"DocId", @"Name",@"Keywords",nil] autorelease];
    
    for (int i = 0; i < [_array count]; i++ )
    {
        NSArray *objects = [[NSArray alloc]initWithObjects:[[[_array objectAtIndex:i] fields]objectForKey:@"Id"],[[[_array objectAtIndex:i] fields]objectForKey:@"Name"],[[[_array objectAtIndex:i] fields]objectForKey:@"Keywords"], nil]; 
        NSLog(@"%@", objects);
        NSDictionary * _dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        [array addObject:_dict];
        
        [_dict release];
        [objects release];
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /*didRunOperation = NO;
    [activity stopAnimating];
    
    array = [[result records] retain];
    NSLog(@"%@", array);
    if ([array count] > 0)
    {
        subject.text = [[[array objectAtIndex:0] fields] objectForKey:@"Name"];
        NSLog(@"%@", subject.text);
    }
    else
    {
        subject.text = @"";
        if (appDelegate.isInternetConnectionAvailable)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noMatch delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [webView loadHTMLString:@"" baseURL:nil];
        }
        return;
    }*/
    
    [activity stopAnimating];
    
    [tableView reloadData];
}

- (void) showFirstTroubleshooting
{
    if ([array count] > 0)
        [self showTroubleshootingForIndex:0];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (!appDelegate.isInternetConnectionAvailable)
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

- (void) showResults
{
    
}


- (NSString *) showTroubleshootingForIndex:(NSUInteger)index
{
    //Shrinivas
    NSData *data;
    
    NSLog(@"%@", array);
    
   // self.productName = [[array objectAtIndex:index] objectForKey:DOCUMENTS_NAME];
    
    self.productId = [appDelegate.calDataBase getProductIdForName:self.productName];
    
    _index = index;
    data = [appDelegate.calDataBase selectTroubleShootingDataFromDBwithID:[[array objectAtIndex:index]objectForKey:@"DocId"] andName:[[array objectAtIndex:index]objectForKey:@"Name"]];
    
    if ( data == NULL )
    {
        NSArray * keys = [[NSArray alloc] initWithObjects:FILEID, FILENAME, nil];
        NSArray * objects = [[NSArray alloc] initWithObjects:[[array objectAtIndex:index]objectForKey:@"DocId"] ,[[array objectAtIndex:index]objectForKey:@"Name"],nil];
        NSDictionary * _dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        
        NSLog(@"%@", _dict);
        
        if (!appDelegate.isInternetConnectionAvailable)
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
    
    else
    {
        //Display data here
        TroubleshootingCell * cell = (TroubleshootingCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.isClicked = NO;
        [cell stopActivity];
        
        //Shrinivas
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectoryPath = [paths objectAtIndex:0]; 
        
        NSLog(@"%@", array);
        NSLog(@"%@",[[array objectAtIndex:index]objectForKey:@"DocId"]);
        
        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[[array objectAtIndex:index]objectForKey:@"DocId"], @".zip"]];

        NSString * folderPath = [documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"DocId"]];
        
        //[fileManager createFileAtPath:filePath contents:data attributes:nil];
        
        NSLog(@"%@, %@", folderPath, filePath);
        
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        
        [self unzipAndViewFile:[folderPath stringByAppendingString:@".zip"]];
        
        NSString * actualFilePath = [documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"Name"]];
        actualFilePath = [actualFilePath stringByAppendingPathComponent:@"index.html"];
        
        NSLog(@"%@", actualFilePath);
        
        NSURL * baseURL = [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:[[array objectAtIndex:index]objectForKey:@"Name"]]];
        NSError * error;
        
        NSString * fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
        
        NSLog(@"%@", fileContents);
        
        if (fileContents == nil)
        {
            NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [[array objectAtIndex:index]objectForKey:@"DocId"], @".zip"]];
            [self unzipAndViewFile:filePath];
            fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
            
            NSLog(@"%@", fileContents);
        }
        
        [webView loadHTMLString:fileContents baseURL:baseURL];
        
    }
    
    return [[array objectAtIndex:index]objectForKey:@"DocId"];
    
}

- (void) didQueryTroubleshootingBodyForDocument:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    connection = nil;
    downloadInProgress = NO;
    didRunOperation = NO;
    NSString * _fileId = nil, * _fileName = nil;
    NSDictionary * dict = (NSDictionary *)context;
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
        //NSFileManager * fileManager = [NSFileManager defaultManager];

        //NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString * documentsDirectoryPath = [paths objectAtIndex:0];
        //NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", _fileId, @".zip"]];
    
        NSString * fileBinary = [[[_array objectAtIndex:0] fields] objectForKey:@"Body"];
        // Need to decode data from Base64
        data = [Base64 decode:fileBinary];
        
        NSLog(@"%@", data);
        
        if ( data != nil )
        {
            [appDelegate.calDataBase insertTroubleshootingIntoDB:[NSMutableArray arrayWithObject:[array objectAtIndex:_index]]];
            [appDelegate.calDataBase insertTroubleShoot:[NSMutableArray arrayWithObject:[array objectAtIndex:_index]] Body:fileBinary];
        }
        
        if (referenceCount == 0)
            [activity stopAnimating];
    
        // Save the data in application sandbox' Document folder by the name in dataName
        //[fileManager createFileAtPath:filePath contents:data attributes:nil];
    
        if ([lastClickedFile isEqualToString:_fileName])
            [self showTroubleshootingForIndex:lastClickedIndex];
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
    
    NSLog(@"%@", _file);
    BOOL retVal = [zip UnzipOpenFile:_file];
    
    if (!retVal)
    {
        return NO;
    }
    
    // Directory Path to unzip file to...
    NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSLog(@"%@", docDir);
    
    // Create "dataName" directory in Documents
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    
    NSLog(@"%@", folderNameToCreate);
    
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


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    NSLog(@"didReceiveMemoryWarning");
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
    /*if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    isLoaded = NO;
    [connection cancel];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) GoToMap
{
    willGoToMap = YES;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) showProductManual
{
    ProductManual * pManual = [[ProductManual alloc] initWithNibName:@"ProductManual" bundle:nil];
    pManual.delegate = self;
    pManual.productId = self.productId;
    pManual.productName = self.productName;
    pManual.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    pManual.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentModalViewController:pManual animated:YES];
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
        [self presentModalViewController:chatter animated:YES];
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
    [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:@"1" afterDelay:0.1];
}

- (void)dealloc
{
    isLoaded = NO;
    [backButton release];
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
    return [array count];
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
    
    
    /*if (!appDelegate.isInternetConnectionAvailable)
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
    [self presentModalViewController:htmlBrowser animated:YES];
    [htmlBrowser release];
}

@end
