//
//  AttachmentViewController.m
//  TabView
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "AttachmentViewController.h"
#import "CustomTableViewCell.h"
#import "ImageViewController.h"
#import "PDFViewController.h"
#import "iServiceAppDelegate.h"

#define kImageViewWidth     550
#define kImageViewHeight    500
#define kImageViewX         440
#define kImageViewY         70

@interface AttachmentViewController ()

@end

@implementation AttachmentViewController
@synthesize dataDict;
@synthesize itemsArray;
@synthesize webView;
@synthesize imageView;
@synthesize webActivityIndicator;
@synthesize moviePlayer;
@synthesize attachmentsTable;
@synthesize navItem;
@synthesize folderName;
@synthesize imageName;
@synthesize pdfPath;
@synthesize videoPath;
@synthesize recordId;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.navItem.title = NSLocalizedString(@"Attachment", @"Attachment");
        //self.tabBarItem.image = [UIImage imageNamed:@"attachment"];        
    }
    return self;
}
- (void) dealloc
{
    [attachmentsTable release];
    [webView release];
    [imageView release];
    [webActivityIndicator release];
    [moviePlayer release];
    [itemsArray release];
    [dataDict release];
    [navItem release];     
    [folderName release];
    [imageName release];
    [pdfPath release];
    [videoPath release];
    [recordId release];
    [super dealloc];
}
- (void)DismissModalViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *titleName = [NSString stringWithFormat:@"%@ %@",[appDelegate.wsInterface.tagsDictionary objectForKey:CAM_AttachmentModule_Name],[appDelegate.wsInterface.tagsDictionary objectForKey:CAM_View_Name]];
    //self.navItem.title = @"Attachments View";
    self.navItem.title = titleName;
    
    //Left Navigation Bar buttons
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissModalViewController:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[self.navigationController.view addSubview:backButton];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navItem.leftBarButtonItem = backBarButtonItem;

    //Add Right Bar Buttons
    NSMutableArray * buttons = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    //Sync Image View
    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
    syncBarButton.width =26;
    [syncBarButton release];
    
    //Help Button
    UIButton * helpButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    UIImage * helpImage = [UIImage imageNamed:@"iService-Screen-Help.png"];
    //[helpImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
    [helpButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [helpButton setBackgroundImage:helpImage forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    [buttons addObject:helpBarButton];
    
    UIToolbar* toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 86, 44)] autorelease];
    [toolbar setItems:buttons];
    self.navItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
        
}
- (void) showHelp
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Show Help" message:@"Show the Help File" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
    self.imageView = nil;
    self.webActivityIndicator = nil;
    self.moviePlayer = nil;
    self.itemsArray = nil;
    self.dataDict = nil;
    self.attachmentsTable = nil;
    self.navItem = nil;
    self.folderName = nil;
    self.imageName = nil;
    self.pdfPath = nil;
    self.videoPath = nil;
    self.recordId = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    dataDict = [[NSMutableDictionary alloc] init];
    //[dataDict setObject:[self getPDF]       forKey:@"Attachments"];
    [dataDict setObject:[self getImages]    forKey:@"Pictures"];
    [dataDict setObject:[self getVideos]    forKey:@"Videos"];
    itemsArray = [[NSMutableArray alloc] init];
    //[itemsArray addObject:@"Attachments"];
    [itemsArray addObject:@"Pictures"];
    [itemsArray addObject:@"Videos"];
    [attachmentsTable reloadData];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [itemsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataDict objectForKey:[itemsArray objectAtIndex:section]] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //return [itemsArray objectAtIndex:section];
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *titleForHeader;
    if(section == 0)
    {
        titleForHeader = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_PicturesSection_Name];
    }
    else if (section == 1)
    {
        titleForHeader = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_VideosSection_Name];
    }
    return titleForHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    
    CustomTableViewCell *cell =(CustomTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (CustomTableViewCell *)[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell = [[[NSBundle mainBundle] loadNibNamed:
                 @"CustomTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    NSArray *dataArrayForSelectedSection = [dataDict objectForKey:[itemsArray objectAtIndex:indexPath.section]];
    NSDictionary *cellDict = [dataArrayForSelectedSection objectAtIndex:indexPath.row];

    cell.nameField.text = [cellDict objectForKey:@"Name"];
    cell.sizeField.text = [cellDict objectForKey:@"Size"];
    /*
    if(indexPath.section == 0)
        cell.imageField.image =  [UIImage imageNamed:@"attachment.png"];
    else    
     */
    if(indexPath.section == 0)
    {
        cell.imageField.image =  [UIImage imageNamed:@"camera.png"];
        //cell.imageField.image =  [UIImage imageWithContentsOfFile:filePath];
    }
    else    
    if(indexPath.section == 1)
    {
        cell.imageField.image =  [UIImage imageNamed:@"video.png"];
        /*
        MPMoviePlayerController *mPlayer = [[MPMoviePlayerController alloc]
                       initWithContentURL:[NSURL fileURLWithPath:filePath]];
        cell.imageField.image =  [UIImage imageNamed:@"video.png"];
        cell.imageField.image = [mPlayer thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        [mPlayer stop];
        [mPlayer release];*/
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *saveDirectory = [paths objectAtIndex:0];	
        if(folderName)
            saveDirectory = [saveDirectory stringByAppendingFormat:@"/%@",folderName];
        /*
        if(indexPath.section == 0)
        {
//            NSString *fileName = [NSString stringWithFormat:@"%d.pdf",indexPath.row+1];
//            NSString * filePath = [saveDirectory stringByAppendingPathComponent:fileName];
        }
        else
         */
        if(indexPath.section == 0)
        {
            NSArray *dataArrayForSelectedSection = [dataDict objectForKey:[itemsArray objectAtIndex:indexPath.section]];
            NSDictionary *imageDataDict = [dataArrayForSelectedSection objectAtIndex:indexPath.row];
            NSString *fileName = [imageDataDict objectForKey:@"Name"];
            iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
            if([appDelegate.dataBase deleteAttachmentFromTableWithName:fileName withRecordId:recordId])
            {
                NSMutableArray *_objects = [dataDict objectForKey:@"Pictures"];
                [_objects removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        else
        if(indexPath.section == 1)
        {

            NSArray *dataArrayForSelectedSection = [dataDict objectForKey:[itemsArray objectAtIndex:indexPath.section]];
            NSDictionary *videoDataDict = [dataArrayForSelectedSection objectAtIndex:indexPath.row];
            NSString *fileName = [videoDataDict objectForKey:@"Name"];
            iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
            if([appDelegate.dataBase deleteAttachmentFromTableWithName:fileName withRecordId:recordId])
            {
                NSMutableArray *_objects = [dataDict objectForKey:@"Videos"];
                [_objects removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                //Delete the file From the Documents Folder
                [appDelegate.calDataBase deleteFromDocumentsWithVideoFileName:fileName];
                /*
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *destinationVideoPath = [documentsDirectory stringByAppendingFormat:@"/videos/%@",fileName];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error = nil;
                if([fileManager fileExistsAtPath:destinationVideoPath])
                {
                    [fileManager removeItemAtPath:destinationVideoPath error:&error];
                    if(error != nil)
                    {
                        NSLog(@"Unable to delete the file from documents folder");
                    }
                }
                 */
            }

        }

        NSLog(@"Delete the object For Section = %d and Row = %d",indexPath.section,indexPath.row);
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
    [self releaseAllViews];
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];	
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(folderName)
        saveDirectory = [saveDirectory stringByAppendingFormat:@"/%@",folderName];

    /*
    if(indexPath.section == 0)
    {
        NSString *fileName = [NSString stringWithFormat:@"%d.pdf",indexPath.row+1];
        NSString * filePath = [saveDirectory stringByAppendingPathComponent:fileName];
        [self loadPDFAtPath:filePath];         
    }
    else
     */
    if(indexPath.section == 0)
    {
        NSArray *dataArrayForSelectedSection = [dataDict objectForKey:[itemsArray objectAtIndex:indexPath.section]];
        NSDictionary *fileDict = [dataArrayForSelectedSection objectAtIndex:indexPath.row];
        imageName = [fileDict objectForKey:@"Name"];
        //UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kImageViewX, 45, 700, 20)];
        UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kImageViewX, 45, 700, 20)];
        NSString *nameString = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_File_Name];
        fileNameLabel.text = [NSString stringWithFormat:@"%@ : %@",nameString, imageName];
        UIImage *image = [[UIImage alloc] initWithData:[appDelegate.dataBase getAttachmentDataForFile:imageName]];
        [self loadImageWithImage:image];
        [image release];
        [self.view addSubview:fileNameLabel];
    }
    else
    if(indexPath.section == 1)
    {
        NSArray *dataArrayForSelectedSection = [dataDict objectForKey:[itemsArray objectAtIndex:indexPath.section]];
        NSDictionary *fileDict = [dataArrayForSelectedSection objectAtIndex: indexPath.row];
        NSString *fileName = [fileDict objectForKey:@"Name"];
        saveDirectory = [saveDirectory stringByAppendingFormat:@"/videos"];
        videoPath = [[saveDirectory stringByAppendingPathComponent:fileName] retain];
        NSLog(@"Video Path = %@",videoPath);
        NSString *nameString = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_File_Name];
        UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kImageViewX, 45, 700, 20)];
        fileNameLabel.text = [NSString stringWithFormat:@"%@ : %@",nameString, fileName];        
        [self loadVideoAtPath:videoPath]; 
        [self.view addSubview:fileNameLabel];
        [fileNameLabel release];
    }
    
}
#pragma mark - Custom Methods
- (void)loadPDFAtPath:(NSString *)filePath
{
    NSURL * _url = [NSURL fileURLWithPath:filePath];
    NSURLRequest * requestObj = [NSURLRequest requestWithURL:_url];
    [webActivityIndicator setHidden:NO];
    [webActivityIndicator startAnimating];
    [self releaseAllViews];
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(kImageViewX, kImageViewY, kImageViewWidth, kImageViewHeight)];
    [self.webView setUserInteractionEnabled:YES];
    [self.webView loadRequest:requestObj];
    [self.view addSubview:webView];
    [webActivityIndicator stopAnimating];
    [webActivityIndicator setHidden:YES];
}
- (void)loadImageWithImage:(UIImage *)imageFile
{
    [webActivityIndicator setHidden:NO];
    [webActivityIndicator startAnimating];
    [self releaseAllViews];
    //imageView =[[UIImageView alloc] initWithFrame:CGRectMake(kImageViewX, kImageViewY, kImageViewWidth, kImageViewHeight)];
    imageView =[[UIImageView alloc] initWithFrame:CGRectMake(kImageViewX, kImageViewY, kImageViewWidth, kImageViewHeight)];
    
    [imageView setImage:imageFile];
    [imageView setUserInteractionEnabled:YES];
    [imageView setTag:1];
    [self.view addSubview:imageView];
    [webActivityIndicator stopAnimating];
    [webActivityIndicator setHidden:YES];
}
- (void)loadVideoAtPath:(NSString *)filePath
{
 
    [webActivityIndicator setHidden:NO];
    [webActivityIndicator startAnimating];
    [self releaseAllViews];
    NSURL *movieURL;
    if (filePath) {
        movieURL = [NSURL fileURLWithPath:filePath];
        if(moviePlayer)
            [moviePlayer release];
        moviePlayer = [[MPMoviePlayerController alloc]
                       initWithContentURL:movieURL];
    }

    [[self view] addSubview:[moviePlayer view]];
    
    CGRect frame = CGRectMake(kImageViewX, kImageViewY, kImageViewWidth, kImageViewHeight);
    [[moviePlayer view] setFrame:frame];
    [moviePlayer play];
    [webActivityIndicator stopAnimating];
    [webActivityIndicator setHidden:YES];   

}
- (void) removeSubViews
{
    NSArray *subViews = [self.view subviews];
    for(UIView *subView in subViews)
    {
        if(![subView isKindOfClass:[UITableView class]] && ![subView isKindOfClass:[UINavigationBar class]])
        {
            NSLog(@"Class = %@",[subView class]);
           [subView removeFromSuperview];
        }
    }
}
- (void) releaseAllViews
{
    [self removeSubViews];
    if(webView)
    {
        [webView release];
        webView = nil;
    }
    if(imageView)
    {
        [imageView release];
        imageView = nil;
    }
    if(moviePlayer)
    {
        [moviePlayer release];
        moviePlayer = nil;
    }
}
- (NSArray *) getPDF
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];	
    if(folderName)
        saveDirectory = [saveDirectory stringByAppendingFormat:@"/%@",folderName];
    NSError *error;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:saveDirectory error:&error];
    if(error == nil)
    {
        NSLog(@"No Files Found");
        return [NSArray arrayWithObjects:nil];
    }
    NSLog(@"Files = %@",fileArray);

    NSMutableArray *pdfArray = [[NSMutableArray alloc] init];
    for(NSString *file in fileArray)
    {
        if([file rangeOfString:@".pdf"].length > 0)
            [pdfArray addObject:file];
    }
    return [pdfArray autorelease];

}
- (NSArray *) getImages
{
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
                       
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];	
    if(folderName)
        saveDirectory = [saveDirectory stringByAppendingFormat:@"/%@",folderName];
    NSError *error;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:saveDirectory error:&error];
    if(error == nil)
    {
        NSLog(@"No Files Found");
        return [NSArray arrayWithObjects:nil];
    }
    NSLog(@"Files = %@",fileArray);
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for(NSString *file in fileArray)
    {
        if([file rangeOfString:@".png"].length > 0)
            [imageArray addObject:file];
    }
     */
    return [appDelegate.dataBase getImagesForRecordId:recordId withFileType:@"Image"]; 
}
- (NSArray *) getVideos
{
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];	
    if(folderName)
        saveDirectory = [saveDirectory stringByAppendingFormat:@"/%@",folderName];
    NSError *error;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * fileArray = [fileManager contentsOfDirectoryAtPath:saveDirectory error:&error];
    if(error == nil)
    {
        NSLog(@"No Files Found");
        return [NSArray arrayWithObjects:nil];
    }
    NSLog(@"Files = %@",fileArray);
    NSMutableArray *videoArray = [[NSMutableArray alloc] init];
    for(NSString *file in fileArray)
    {
        if([file rangeOfString:@".mov"].length > 0)
            [videoArray addObject:file];
    }
    return [videoArray autorelease];
     */
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.dataBase getImagesForRecordId:recordId withFileType:@"Video"]; 

}
- (void)startPlayingMovieWithURLString 
{
    // I get all of these callbacks **EXCEPT** the "willExitFullScreen:" callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitedFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];    
    if (self.moviePlayer) {
        [self.moviePlayer release];
    }
    NSLog(@"Video Path = %@",videoPath);
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoPath]];
    //self.moviePlayer.view.frame = self.view.frame;
    [self.view addSubview:moviePlayer.view];
    [[moviePlayer view] setFrame:CGRectMake(0, 0, 1024, 704)];
    
    [moviePlayer play];
    //[self.moviePlayer setFullscreen:YES animated:YES];
}
- (void)willEnterFullscreen:(NSNotification*)notification 
{
    NSLog(@"willEnterFullscreen");
}

- (void)enteredFullscreen:(NSNotification*)notification 
{
    NSLog(@"enteredFullscreen");
}

- (void)willExitFullscreen:(NSNotification*)notification 
{
    NSLog(@"willExitFullscreen");
}

- (void)exitedFullscreen:(NSNotification*)notification 
{
    NSLog(@"exitedFullscreen");
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playbackFinished:(NSNotification*)notification 
{
    NSNumber* reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackFinished. Reason: Playback Ended");         
            break;
        case MPMovieFinishReasonPlaybackError:
            NSLog(@"playbackFinished. Reason: Playback Error");
            break;
        case MPMovieFinishReasonUserExited:
            NSLog(@"playbackFinished. Reason: User Exited");
            break;
        default:
            break;
    }
    [self.moviePlayer setFullscreen:NO animated:YES];
    [self.moviePlayer.view removeFromSuperview];
}
#pragma mark - Touches Delegate
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if([[touch view] class] == [UIImageView class])
    {
        NSLog(@"Image View with Tag = %d",[touch view].tag);
        if([touch view].tag == 1)
        {
            //add new image view
            ImageViewController *imageController = [[ImageViewController alloc] init];
            //[imageController setImagePath:imagePath];
            [imageController setImageName:imageName];
            [self presentModalViewController:imageController animated:YES];
            [imageController release];
        }
        if([touch view].tag == 2)
        {
            //add new image view
            /*
            ImageViewController *imageController = [[ImageViewController alloc] init];
            [imageController setImagePath:imagePath];
            [self presentModalViewController:imageController animated:YES];
            [imageController release];
             */
            [self startPlayingMovieWithURLString];
        }

    }
    if([[touch view] class] == [UIWebView class])
    {
        PDFViewController *pdfController = [[PDFViewController alloc] init];
        [pdfController setPdfPath:pdfPath];
        [self presentModalViewController:pdfController animated:YES];
        [pdfController release];

    }
}
@end
