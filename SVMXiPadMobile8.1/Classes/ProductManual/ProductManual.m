//
//  Troubleshooting.m
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "ProductManual.h"
#import "ProductManualCell.h"
#import "MoviePlayer.h"
#import "HTMLBrowser.h"

@implementation ProductManual

@synthesize delegate;
@synthesize productName, productId;

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
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate goOnlineIfRequired];
    navigationBar.title = [appDelegate.wsInterface.tagsDictionary objectForKey:PRODUCT_MANUAL_TITLE];
    serviceMax = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    productManual = [appDelegate.wsInterface.tagsDictionary objectForKey:PRODUCT_MANUAL_NOT_PRESENT];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    lastIndex = 0;
    
    if ( !appDelegate.isInternetConnectionAvailable )
    {
        array = [appDelegate.calDataBase retrieveManualsForProductWithId:productId];
        if ([array count] == 0)
        {
        
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:productManual delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }

        
        [array retain];
        [tableView reloadData];
    }
    
    else
    {
        if (iOSObject == nil)
        {
            iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
            didRunOperation = YES;
            [iOSObject queryManualForProductName:productId];
        }
        else
        {
            [self showManualForIndex:lastIndex];
        }
    
    }
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        NSLog(@"Product Manual Internet Reachable");
    }
    else
    {
        NSLog(@"Product Manual Internet Not Reachable");
        if (didRunOperation)
        {
            [activity stopAnimating];
            [appDelegate displayNoInternetAvailable];
            didRunOperation = NO;
        }
    }
}

- (void) didQueryManualForProductName:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    //Shrinivas
    NSArray *_array;
    _array = [[result records] retain];  //Check leak here
    NSLog(@"%d", [_array count]);
    
    array = [[NSMutableArray alloc]initWithCapacity:0];
    NSArray *keys = [[[NSArray alloc]initWithObjects:@"ManId", @"ManName",nil] autorelease];
    
    if ([_array count] == 0)
    {
        if (appDelegate.isInternetConnectionAvailable)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:productManual delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        return;
    }
    
    for (int i = 0; i < [_array count]; i++ )
    {
        NSArray *objects = [[NSArray alloc]initWithObjects:[[[_array objectAtIndex:i] fields]objectForKey:@"Id"],[[[_array objectAtIndex:i] fields]objectForKey:@"Name"], nil]; 
        NSDictionary * _dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        [array addObject:_dict];
        
        [_dict release];
        [objects release];
    }

    //[array retain];         //Check For leak here
    
    /*[activity stopAnimating];
    didRunOperation = NO;
    array = [[result records] retain];
        
    if ([array count] == 0)
    {
        if (appDelegate.isInternetConnectionAvailable)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:productManual delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        return;
    }*/
    
    [tableView reloadData];
}

- (void) didQueryBodyProductName:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    didRunOperation = NO;
    if ([[result records] count] == 0)
    {
        if (appDelegate.isInternetConnectionAvailable)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:productManual delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        return;
    }
    
    connection = nil;
    
    bodyArray = [result records];
    
    for (int i = 0; i < [bodyArray count]; i++)
    {
        NSLog(@"%@", array);
        //ZKSObject * obj = [array objectAtIndex:i];
        //NSDictionary * dict = [obj fields];
        
        NSString * fileId = [[array objectAtIndex:i]objectForKey:@"ManId"];
        NSString * fileName = [[array objectAtIndex:i]objectForKey:@"ManName"];
        
        folderNameToCreate = [fileName stringByAppendingString:fileId];

        NSString * fileBinary = [[[bodyArray objectAtIndex:i] fields] objectForKey:@"Body"];
        
        // Need to decode data from Base64
        NSData * data = [Base64 decode:fileBinary];
        
        if ( data != nil )
        {
            [appDelegate.calDataBase insertProductManualNameInDB:[array objectAtIndex:_index] WithID:productId];
            [appDelegate.calDataBase insertProductManualBody:fileBinary WithId:[[array objectAtIndex:_index]objectForKey:@"ManId"] WithName:[[array objectAtIndex:_index]objectForKey:@"ManName"]];
        }
        
        // Save the data in application sandbox' Document folder by the name in dataName
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectoryPath = [paths objectAtIndex:0];
        
       topic .text = [fileName substringToIndex:[fileName length]-4];
        
        NSString * extension = [fileName substringFromIndex:[fileName length]-4];
        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileId];
        filePath = [filePath stringByAppendingString:extension];
        //NSFileManager * fileManager = [NSFileManager defaultManager];
        //[fileManager createFileAtPath:filePath contents:data attributes:nil];
    }
    
    [self showManualForIndex:lastIndex];
}

// UIAlertView Delegate Method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismissModalViewControllerAnimated:YES];
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

- (BOOL) unzipAndViewFile:(NSString *)_file;
{
    if (zip == nil)
        zip = [[ZipArchive alloc] init];
    
    BOOL retVal = [zip UnzipOpenFile:_file];
    
    if (!retVal)
    {
        // NSLog(@"UnzipOpenFile encountered an error.");
        return NO;
    }
    
    // Directory Path to unzip file to...
    NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Create "dataName" directory in Documents
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;

    [fm createDirectoryAtPath:[docDir stringByAppendingPathComponent:folderNameToCreate] 
  withIntermediateDirectories:YES 
                   attributes:(NSDictionary *)nil 
                        error:&error];
    
    NSString * unzipPath = [docDir stringByAppendingPathComponent:folderNameToCreate];

    retVal = [zip UnzipFileTo:unzipPath overWrite:YES];
    
    if (!retVal)
    {
        // NSLog(@"Unzip encountered an error.");
        return NO;
    }
    
    return YES;
}


- (void) showManualForIndex:(NSUInteger)index;
{
    _index = index;
    NSData *data;  
    
    data = [appDelegate.calDataBase retrieveProductManualWithManID:[[array objectAtIndex:index]objectForKey:@"ManId"] andManName:[[array objectAtIndex:index]objectForKey:@"ManName"]];
    
    if ( data == nil )
    {
        [activity startAnimating];
        didRunOperation = YES;
        connection = [iOSObject queryManualBodyForDocument:productId];
        
        return;
    }
    
    else
    {
        NSString * fileId  = [[array objectAtIndex:index]objectForKey:@"ManId"];
        NSString * fileName = [[array objectAtIndex:index]objectForKey:@"ManName"];
        
        //Save the data in application sandbox' Document folder by the name in dataName
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectoryPath = [paths objectAtIndex:0];
        
        NSString * extension = [fileName substringFromIndex:[fileName length]-4];
        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileId];
        filePath = [filePath stringByAppendingString:extension];
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        topic .text = [fileName substringToIndex:[fileName length]-4];
                
        //Create a URL object.
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        //Load the request in the UIWebView.
        [webView loadRequest:requestObj];
        
        [activity stopAnimating];
     }
    
    /*ZKSObject * obj = [array objectAtIndex:index];
    NSDictionary * dict = [obj fields];
    
    NSString * fileId = [dict objectForKey:@"Id"];
    NSString * fileName = [dict objectForKey:@"Name"];

    // Save the data in application sandbox' Document folder by the name in dataName
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSString * extension = [fileName substringFromIndex:[fileName length]-4];
    NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileId];
    filePath = [filePath stringByAppendingString:extension];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL retVal = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    // check if folderNameToCreate already exists
    if (!retVal)
    {
        [activity startAnimating];
        didRunOperation = YES;
        connection = [iOSObject queryManualBodyForDocument:productId];
        
        return;
    }
    
    //Create a URL object.
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
    [activity stopAnimating];*/
}

- (IBAction) Help;
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"Product Manual Help";
    [self presentModalViewController:help animated:YES];
    [help release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [connection cancel];
}


- (void)viewDidUnload
{
    [tableView release];
    tableView = nil;
    [topic release];
    topic = nil;
    [webView release];
    webView = nil;
    [mSearchBar release];
    mSearchBar = nil;
    [activity release];
    activity = nil;
    [navigationBar release];
    navigationBar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction) Done
{
    [connection cancel];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) GoToMap
{
    willGoToMap = YES;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) showChatter
{
    NSString * productInfo = [appDelegate.wsInterface.tagsDictionary objectForKey:TROUBLESHOOTING_NO_PROD_INFO_ERROR];
//    NSString * chatterInfo = [appDelegate.wsInterface.tagsDictionary objectForKey:CHATTER_DISABLED_ERROR];

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
#pragma mark ProductManualDelegate Methods
- (void) showMap
{
    willGoToMap = YES;
    [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:@"1" afterDelay:0.1];
}

- (void)dealloc
{
    if (willGoToMap)
        [delegate showMap];
    [navigationBar release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [array count];
}

- (ProductManualCell *) createCustomCellWithId:(NSString *) cellIdentifier
{
	NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"ProductManualCell" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	ProductManualCell * customCell = nil;
	
    NSObject* nibItem = nil;
	
    while ( (nibItem = [nibEnumerator nextObject]) != nil)
	{
		if ( [nibItem isKindOfClass: [ProductManualCell class]])
		{
			customCell = (ProductManualCell *) nibItem;
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
    
    static NSString *CellIdentifier = @"ProductManualCell";
    
    ProductManualCell * cell = (ProductManualCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createCustomCellWithId:CellIdentifier];
    }
    
    NSLog(@"%@", array);
    //Shrinivas
    if ( [[[array objectAtIndex:indexPath.row]objectForKey:@"ManName"] isKindOfClass:[NSString class]] )
    {
        [cell setCellLabel:[[array objectAtIndex:indexPath.row]objectForKey:@"ManName"] Image:@"troubleshooting-possibility-searchresult-button.png"];
    }
    
    else
    {
        ZKSObject * obj = [array objectAtIndex:indexPath.row];
        [cell setCellLabel:[[obj fields] objectForKey:@"Name"] Image:@"troubleshooting-possibility-searchresult-button.png"];
    }
    
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
*/


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	/*
	 DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.1
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
    
    [activity startAnimating];
    
    lastIndex = indexPath.row;
    
    [self showManualForIndex:[indexPath row]];
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
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
