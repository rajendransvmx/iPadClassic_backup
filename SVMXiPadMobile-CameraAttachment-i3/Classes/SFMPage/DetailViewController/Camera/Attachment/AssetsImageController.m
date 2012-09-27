//
//  AssetsImageController.m
//  iService
//
//  Created by Siva Manne on 29/06/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "AssetsImageController.h"
#import "iServiceAppDelegate.h"
@interface AssetsImageController ()

@end

@implementation AssetsImageController
@synthesize imageTableView;
@synthesize delegate = _delegate;
@synthesize attachmentDataDict;
@synthesize acitivity;
-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize 
{  
    UIGraphicsBeginImageContext(newSize);  
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];  
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();    
    return newImage;  
}
- (IBAction) attachAssetsImagesToRecord:(id)sender
{
    // show activity indicator
    [acitivity setHidden:NO];
    [acitivity startAnimating];
    NSLog(@"Assets Count = %d",[assets count]);
    for(int i=0;i<[assets count];i++)
    {        
        NSDictionary *dict = [assets objectAtIndex:i];
        if([[dict objectForKey:@"Selected"] intValue])
        {
            NSLog(@"Selected %d Image",i);
            NSMutableDictionary *cameraDataDict = [[NSMutableDictionary alloc] init];
            
            NSString *attachment_Id    =  [attachmentDataDict objectForKey:@"attachment_Id"];
            NSString *apiName          =  [attachmentDataDict objectForKey:@"object_api_name"];
            NSString *objectNumber     =  [attachmentDataDict objectForKey:@"WorkOrderNumber"];
            NSString *recordId         =  [attachmentDataDict objectForKey:@"record_Id"];
            NSString *attachmentType   =  [attachmentDataDict objectForKey:@"AttachmentType"];
            
            NSString *imageFileName;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
            NSDate *date = [NSDate date];
            NSString *timeStamp = [dateFormatter stringFromDate:date];
            if([attachmentType isEqualToString:ALAssetTypePhoto])
            {
                if(![objectNumber isEqualToString:@""])
                    imageFileName = [NSString stringWithFormat:@"%@+%@.png",objectNumber,timeStamp];
                else
                    imageFileName = [NSString stringWithFormat:@"image+%@.png",timeStamp];
            }
            if([attachmentType isEqualToString:ALAssetTypeVideo])
            {
                if(![objectNumber isEqualToString:@""])
                    imageFileName = [NSString stringWithFormat:@"%@+%@.mov",objectNumber,timeStamp];
                else
                    imageFileName = [NSString stringWithFormat:@"video+%@.mov",timeStamp];
            }
            
            ALAsset *asset = [dict objectForKey:@"AssetInfo"];
            NSData *imageData = nil;
            if([attachmentType isEqualToString:ALAssetTypePhoto])
            {
                UIImage *myImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];    
                myImage = [self scaleImage:myImage toSize:CGSizeMake(900, 600)];
                imageData = UIImagePNGRepresentation(myImage);
                NSUInteger size = [imageData length];
                float sizeinMB = (1.0 *size)/1048576;
                NSString *imgSize = [NSString stringWithFormat:@"%0.3f MB",sizeinMB];
                [cameraDataDict setObject:imgSize forKey:@"size"];
                [cameraDataDict setObject:@"Image" forKey:@"fileType"];
            }
            if([attachmentType isEqualToString:ALAssetTypeVideo])
            {
                //get the video 
                // copy to documents/videos/ folder
                /* Get the asset's representation object */ 
                ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
                const NSUInteger BufferSize = 1024; 
                uint8_t buffer[BufferSize]; 
                NSUInteger bytesRead = 0;
                long long currentOffset = 0; 
                NSError *readingError = nil;
                /* Find the documents folder (an array) */
                NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                         NSUserDomainMask, YES);
                /* Retrieve the one documents folder that we need */ 
                NSString *documentsFolder = [documents objectAtIndex:0];
                /* Construct the path where the video has to be saved */ 
                NSFileManager *fileManager = [[NSFileManager alloc] init];

                documentsFolder = [documentsFolder stringByAppendingFormat:@"/videos"];
                if (![fileManager fileExistsAtPath:documentsFolder])
                    [fileManager createDirectoryAtPath:documentsFolder 
                           withIntermediateDirectories:NO 
                                            attributes:nil 
                                                 error:&readingError];

                NSString *videoPath = [documentsFolder stringByAppendingPathComponent:imageFileName]; 
                NSLog(@"Video Path = %@",videoPath);
                /* Create the file if it doesn't exist already */
                if ([fileManager fileExistsAtPath:videoPath] == NO)
                {
                    [fileManager createFileAtPath:videoPath contents:nil attributes:nil];
                }
                
                /* We will use this file handle to write the contents of the media assets to the disk */
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:videoPath];
                do{
                    /* Read as many bytes as we can put in the buffer */ 
                    bytesRead = [assetRepresentation getBytes:(uint8_t *)&buffer
                                                   fromOffset:currentOffset length:BufferSize
                                                        error:&readingError];
                    /* If we couldn't read anything, we will exit this loop */ 
                    if (bytesRead == 0)
                    {
                        break; 
                    }
                    /* Keep the offset up to date */ 
                    currentOffset += bytesRead;
                    /* Put the buffer into an NSData */ 
                    NSData *readData = [[NSData alloc] initWithBytes:(const void *)buffer length:bytesRead];
                    /* And write the data to file */ 
                    [fileHandle writeData:readData];
                } while (bytesRead > 0);
                NSLog(@"Finished reading and storing the  video in the documents folder");
                float sizeinMB = (1.0 *currentOffset)/1048576;
                NSString *imgSize = [NSString stringWithFormat:@"%0.3f MB",sizeinMB];
                [cameraDataDict setObject:imgSize forKey:@"size"];

                [cameraDataDict setObject:@"Video" forKey:@"fileType"];

            }
            [cameraDataDict setObject:attachment_Id forKey:@"attachment_Id"];
            [cameraDataDict setObject:apiName forKey:@"object_api_name"];
            [cameraDataDict setObject:objectNumber forKey:@"WorkOrderNumber"];
            [cameraDataDict setObject:recordId forKey:@"record_Id"];
            [cameraDataDict setObject:imageFileName forKey:@"fileName"];
            
            

            iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.calDataBase insertCameraData:imageData withInfo:cameraDataDict];
            [cameraDataDict release];

        }
    }
    [acitivity stopAnimating];
    [acitivity setHidden:YES];
    [_delegate dismissAssetsPopOver];
}
- (void)dealloc
{
    self.delegate = nil;
    self.imageTableView = nil;
    self.attachmentDataDict = nil;
    self.acitivity = nil;
    [super dealloc];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [assets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
	ALAsset *asset = [[assets objectAtIndex:indexPath.row] objectForKey:@"AssetInfo"];
	[cell.imageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    //myImage = [UIImage imageWithCGImage:[[myAsset defaultRepresentation] fullScreenImage]];    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if([[[assets objectAtIndex:indexPath.row] objectForKey:@"Selected"] intValue])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *dict = [assets objectAtIndex:indexPath.row];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;        
        [dict setObject:@"0" forKey:@"Selected"];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [dict setObject:@"1" forKey:@"Selected"];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"View Did Appear");
    [acitivity setHidden:NO];
    [acitivity startAnimating];
    // Do any additional setup after loading the view from its nib.
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != NULL) 
        {
            NSLog(@"Asset Type = %@",[result valueForProperty:ALAssetPropertyType]);
            NSLog(@"Attachment Type = %@",[attachmentDataDict objectForKey:@"AttachmentType"]);
            NSString *assetType = [attachmentDataDict objectForKey:@"AttachmentType"];
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:assetType])
            {
                NSLog(@"See Asset: %@", result);
                NSMutableDictionary *assetDict = [[NSMutableDictionary alloc] init];
                [assetDict setObject:result forKey:@"AssetInfo"];
                [assetDict setObject:@"0" forKey:@"Selected"];
                [assets addObject:assetDict];
                [assetDict release];
            }
        }
    };
    
    void (^assetGroupEnumerator)( ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
        
        
        [self.imageTableView reloadData];
    };
    
    assets = [[NSMutableArray alloc] init];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //ALAssetsGroupAll
    /*
     [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
     usingBlock:assetGroupEnumerator
     failureBlock: ^(NSError *error) {
     NSLog(@"Failed with Error %@",[error userInfo]);
     }];
     */
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock: ^(NSError *error) {
                             NSLog(@"Failed with Error %@",[error userInfo]);
                         }];
    
    
    [acitivity stopAnimating];
    [acitivity setHidden:YES];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[assets release];
    NSLog(@"View Did DisAppear");
}
- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
