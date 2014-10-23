//
//  TroubleShootDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingDetailViewController.h"
#import "ZipArchive.h"
#import "FileManager.h"

@interface TroubleshootingDetailViewController()

@property(nonatomic, strong)ZipArchive * zip;
@property(nonatomic, strong)NSString * folderNameToCreate;

@end

@implementation TroubleshootingDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)loadwebViewForThedocId:(NSString *)docId
                andThedocName:(NSString *)docName;{
    NSString * documentsDirectoryPath = [FileManager getTroubleshootingSubDirectoryPath];
    
    NSString * folderPath = [documentsDirectoryPath stringByAppendingPathComponent:docId];
    
    [self unzipAndViewFile:[folderPath stringByAppendingString:@".zip"]];
    
    NSString * actualFilePath = [documentsDirectoryPath stringByAppendingPathComponent:docName];
    actualFilePath = [actualFilePath stringByAppendingPathComponent:@"index.html"];
    
    
    // NSURL * baseURL = [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:productName]];
    NSError * error;
    
    NSString * fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
    
    
    if (fileContents == nil)
    {
        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", docId, @".zip"]];
        [self unzipAndViewFile:filePath];
        fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
    }
    [self.webView loadHTMLString:fileContents baseURL:nil];
  }

- (BOOL) unzipAndViewFile:(NSString *)_file
{
    if (self.zip == nil)
        self.zip = [[ZipArchive alloc] init];
    
    BOOL retVal = [self.zip UnzipOpenFile:_file];
    
    if (!retVal){
        return NO;
    }
    // Directory Path to unzip file to...
    NSString * docDir = [FileManager getTroubleshootingSubDirectoryPath];
    // Create "dataName" directory in Documents
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    [fm createDirectoryAtPath:[docDir stringByAppendingPathComponent:self.folderNameToCreate]
  withIntermediateDirectories:YES
                   attributes:(NSDictionary *)nil
                        error:(NSError **)&error];
    
    NSString * unzipPath = [docDir stringByAppendingPathComponent:self.folderNameToCreate];
    
    retVal = [self.zip UnzipFileTo:unzipPath overWrite:YES];
    
    if (!retVal)
    {
        return NO;
    }
    
    return YES;
}

-(void)splitViewController:(SMSplitViewController *)splitViewController didHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover
{
    self.masterViewButton.hidden = NO;
    
    [self.masterViewButton addTarget:barButtonItem.target action:barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
}

- (void)splitViewController:(SMSplitViewController *)splitViewController didShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.masterViewButton.hidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _webView = nil;
    //[super dealloc];
}
@end
