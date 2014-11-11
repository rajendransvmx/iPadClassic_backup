//
//  AttachmentWebView.m
//  ServiceMaxMobile
//
//  Created by Sahana on 10/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "AttachmentWebView.h"
#import "AttachmentUtility.h"
#import "Utility.h"
#import <MessageUI/MessageUI.h>
#import "SMLogger.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "AlertMessageHandler.h"
#import "AttachmentHelper.h"
#import "ModifiedRecordModel.h"
#import "StyleManager.h"
#import "TagManager.h"

static NSInteger const kDeleteButton = 321;

@interface AttachmentWebView ()

- (void)loadwebview;
- (void)populateNavigationBar;

@end

@implementation AttachmentWebView

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
    self.webView.backgroundColor = [UIColor navBarBG];
    self.view.backgroundColor = [UIColor navBarBG];
    [self populateNavigationBar];
    [self loadwebview];
}

-(void)loadwebview
{
    //D-00003728
    NSMutableArray * toolBarItems = [NSMutableArray arrayWithCapacity:0];
    UIBarButtonItem * share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAttachment:)];
    [toolBarItems addObject:share];

    if (self.isInViewMode) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        //D-00003728
         UIBarButtonItem * flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
         [toolBarItems addObject:flexibleSpace];
        
        UIBarButtonItem * trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAttachment:)];
        trashButton.enabled = YES;
        [toolBarItems addObject:trashButton];

    }
    self.toolbar.items = (NSArray *)toolBarItems;
    [self.webView setScalesPageToFit:YES];
        
    //D-00003728
    if (self.url != nil)
    {
        self.url = nil;
    }
    
    self.url = [AttachmentUtility getUrlForAttachment:_attachmentTXModel];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _webView.delegate = nil;
    _webView = nil;
    _toolbar = nil;//D-00003728
    _url = nil;
}

- (IBAction)deleteAttachment:(id)sender
{
    NSString *delete = [[TagManager sharedInstance] tagByName:kTagDeleteButtonTitle];
    if (![delete length]) {
        delete = @"Delete";
    }
    NSString *cancel = [[TagManager sharedInstance] tagByName:kCancelButtonTitle];
    if (![cancel length]) {
        cancel = @"Cancel";
    }
    [[AlertMessageHandler sharedInstance] showCustomMessage:[NSString stringWithFormat:@"The selected attachment will be removed from the %@ and will be deleted from the server at the next sync. This action cannot be undone.", _parentObjectName] withDelegate:self tag:kDeleteButton title:@"" cancelButtonTitle:cancel andOtherButtonTitles:[NSArray arrayWithObject:delete]];
}

//D-00003728
- (void)shareAttachment:(id)sender
{
    self.view.backgroundColor = [UIColor brownColor];
    
    //11338
    NSData * data =  [AttachmentUtility getEncodedDataForExistingAttachment:_attachmentTXModel];
    
    if ([data length])
    {
        [AttachmentUtility saveDuplicateAttachmentData:data forAttachment:_attachmentTXModel];
        
        NSURL *fileUrl = [AttachmentUtility getDuplicateAttachmentURL:_attachmentTXModel];
        
        if (fileUrl != nil)
        {
            [self displaySharingView:fileUrl sender:(UIBarButtonItem *)sender];
        }
    }
}

//D-00003728
- (void)displaySharingView:(NSURL*)url sender:(UIBarButtonItem *)button
{
    //11450
    UIActivityViewController * sharingView = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    sharingView.view.backgroundColor = [UIColor navBarBG];
    
    NSArray * excludedActivities = nil;
    NSMutableArray *sharingOptions = [NSMutableArray arrayWithArray:@[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                                                      UIActivityTypePostToWeibo, UIActivityTypePostToFlickr,
                                                                      UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,UIActivityTypeAssignToContact]];
    
    if ([Utility isDeviceIOS8]) {
        [sharingOptions addObject:UIActivityTypePrint];
    }
    excludedActivities = sharingOptions;
    
    //12123
    __block UIPopoverController * popover = nil;
    popover = [[UIPopoverController alloc] initWithContentViewController:sharingView];
    popover.delegate = self;
    [popover presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    

    [sharingView setCompletionHandler:^(NSString *activityType, BOOL completed) {
        NSLog (@"Activity Type = %@ Completed = %d", activityType, completed);

        if (activityType == UIActivityTypeMail)
        {
            if (![MFMailComposeViewController canSendMail])
            {
                NSString *cancel = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
                if (![cancel length]) {
                    cancel = [[TagManager sharedInstance]tagByName:kTagAlertErrorOk];
                }
                
                NSString *message = [[TagManager sharedInstance] tagByName:kTagAlertConfigureMail];
                if (![message length]) {
                    message = @"Configure email in your device";
                }
                
                [[AlertMessageHandler sharedInstance] showCustomMessage:message withDelegate:nil tag:0 title:[[TagManager sharedInstance] tagByName:kTagAlertApplicationError] cancelButtonTitle:cancel andOtherButtonTitles:nil];
                // device is not configured to send mail
            }
        }
        if (popover != nil)
            popover = nil;
    }];

}

/** Populating navigation bar **/
- (void)populateNavigationBar
{
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.navigationItem.title = _attachmentTXModel.nameWithoutExtension;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    //[self alertImproperformat];
    [_activity stopAnimating];
    _activity.hidden=YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewer
{
    [_activity stopAnimating];
    _activity.hidden=YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webViewer
{
    [_activity startAnimating];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kDeleteButton) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            
            BOOL isSuccess = [AttachmentUtility deleteAttachment:_attachmentTXModel];
            
            if (isSuccess) {
                
                isSuccess = [AttachmentHelper deleteAttachmentsWithLocalIds:[NSArray arrayWithObject:_attachmentTXModel.localId]];
                
                if ([_attachmentTXModel.idOfAttachment length]) {

                    ModifiedRecordModel *modifiedModel = [[ModifiedRecordModel alloc] init];
                    modifiedModel.syncFlag = YES;
                    modifiedModel.sfId = _attachmentTXModel.idOfAttachment;
                    modifiedModel.recordType = kRecordTypeDetail;
                    modifiedModel.operation = kModificationTypeDelete;
                    modifiedModel.objectName = kAttachmentTableName;
                    modifiedModel.parentObjectName = _parentSFObjectName;
                    modifiedModel.recordLocalId = _attachmentTXModel.localId;
                    [AttachmentHelper saveDeleteAttachmentsToModifiedRecords:[NSMutableArray arrayWithObject:modifiedModel]];
                }
                if (isSuccess)
                {
                    if (self.webviewdelgate && [self.webviewdelgate respondsToSelector:@selector(didDeleteAttachment:)])
                    {
                        [self.webviewdelgate didDeleteAttachment:_attachmentTXModel];
                    }
                }
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


-(void)alertImproperformat
{
    NSString *title = [[TagManager sharedInstance] tagByName:kTagAlertApplicationError];
    NSString *message = @"File cannot be loaded on the webview, File not supported by web view";
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    _activity.hidden=TRUE;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end