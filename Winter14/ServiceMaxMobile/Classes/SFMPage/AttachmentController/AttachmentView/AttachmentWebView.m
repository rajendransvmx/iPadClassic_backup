//
//  AttachmentWebView.m
//  ServiceMaxMobile
//
//  Created by Sahana on 10/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "AttachmentWebView.h"
#import "AttachmentUtility.h"
#import "Globals.h"
#import "Utility.h"

#import "AttachmentUtility.h"


@interface AttachmentWebView ()
-(void)loadwebview;
- (void)populateNavigationBar;
@end

@implementation AttachmentWebView
@synthesize attachmentFileName, attachmentLocalId, attachmentType,webView;
@synthesize activity;
@synthesize attachmentCategory;
@synthesize isInViewMode;
@synthesize webviewdelgate;

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
    [self populateNavigationBar];
    //self.webView.frame=CGRectMake(0, 0, 100, 100);
    [ self loadwebview];
}

-(void)loadwebview
{
    NSString * extension = [AttachmentUtility fileExtension:self.attachmentFileName];
    NSString * documetName = nil;
    NSString * filePath = nil;
    
    if (nil == attachmentLocalId)
    {
        //Handle For OPDoc
        documetName = [AttachmentUtility fileName:[self.attachmentFileName stringByDeletingPathExtension] extension:extension];
        filePath = [AttachmentUtility getOPDocPath:documetName];
        self.navigationItem.rightBarButtonItem = nil;

    }
    else{
        documetName = [AttachmentUtility fileName:attachmentLocalId extension:extension];
        filePath = [AttachmentUtility getFullPath:documetName];
        if (self.isInViewMode) {
            self.navigationItem.rightBarButtonItem = nil;

        }
        else
        {
            UIBarButtonItem *trashButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAttachment:)];
            self.navigationItem.rightBarButtonItem = trashButton;
            [trashButton release];

        }
        [self.webView setScalesPageToFit:YES];
    }
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_deleteButton release];
    [webView release];
    [attachmentFileName release];
    [attachmentLocalId release];
    [attachmentType release];
    [super dealloc];
}
- (IBAction)deleteAttachment:(id)sender
{
    [AttachmentUtility conformationforDelete:self];
}

-(BOOL)conformationforDelete
{
    NSString *message=[appDelegate.wsInterface.tagsDictionary objectForKey:DOC_DELETE_CONFIRMATION];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:DELETE_ACTION]otherButtonTitles:[appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE], nil];
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [alert release];
    return YES;
}

/** Populating navigation bar **/
- (void)populateNavigationBar
{
    NSString *backButtonTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:PHOTOS_VIDEOS];
    
    if (self.attachmentCategory != nil)
    {
        backButtonTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:DOCUMENT_LIST];
    }
    
    //Fix 009137: Back '<' should be displayed to navigate to previous screen after viewing an image/video/document
    backButtonTitle = [NSString stringWithFormat:@"< %@",backButtonTitle];
    UIBarButtonItem *containingRightBarButton = [[UIBarButtonItem alloc]initWithTitle:backButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = containingRightBarButton;
    [containingRightBarButton release];
    
    self.navigationItem.title = [self.attachmentFileName stringByDeletingPathExtension];

}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [activity stopAnimating];
    activity.hidden=YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webViewer
{
    [activity stopAnimating];
    activity.hidden=YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webViewer
{
    [activity startAnimating];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSArray *array=[NSArray arrayWithObjects:attachmentLocalId, nil];
        if ([self.attachmentCategory isEqualToString:DOCUMENT_CATEGORY])
        {
            [AttachmentUtility deleteIdsFromAttachmentlist:array forType:DOCUMENT_DICT];
        }
        else
        {
            [AttachmentUtility deleteIdsFromAttachmentlist:array forType:IMAGES_DICT];
        }
        
        if ([self.webviewdelgate respondsToSelector:@selector(didDeleteAttchment:)])
        {
            [self.webviewdelgate didDeleteAttchment:self.attachmentLocalId];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else  if(buttonIndex == 2)
    {
        // Vipin - 009088
        // Remove Document/Image locally
        
        NSArray *array=[NSArray arrayWithObjects:attachmentLocalId, nil];
        [AttachmentUtility removeSelectedAttachmentFiles:array];
        
        if ([self.webviewdelgate respondsToSelector:@selector(didDeleteAttchment:)])
        {
            [self.webviewdelgate didDeleteAttchment:self.attachmentLocalId];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

-(void)alertImproperformat
{
    NSString *title=[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error];;
    NSString *message=@"File cannot be loaded on the webview, File not supported by web view";
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [alert release];
    activity.hidden=TRUE;
}
-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}



@end
