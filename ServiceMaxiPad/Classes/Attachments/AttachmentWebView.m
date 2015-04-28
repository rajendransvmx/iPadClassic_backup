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
#import "DateUtil.h"
#import "StringUtil.h"
#import "PushNotificationHeaders.h"

static NSInteger const kDeleteButton = 321;

@interface AttachmentWebView ()

@property(nonatomic, strong) UIPopoverController *sharePopOver;

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
    
    [self populateNavigationBar];
    [self loadwebview];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    [self registerForPopOverDismissNotification];
    
}

-(void)loadwebview
{
    if (_attachmentTXModel.isOutputdoc)
    {
        self.toolbar.items = nil;
    }
    else
    {
        NSMutableArray * toolBarItems = [NSMutableArray arrayWithCapacity:0];
        UIBarButtonItem * share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAttachment:)];
        [toolBarItems addObject:share];
        
        if (!self.isInViewMode)
        {
            UIBarButtonItem * flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [toolBarItems addObject:flexibleSpace];
            
            UIBarButtonItem * trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAttachment:)];
            trashButton.enabled = YES;
            [toolBarItems addObject:trashButton];
            
        }
        self.toolbar.items = (NSArray *)toolBarItems;
    }
    [self.webView setScalesPageToFit:YES];
    
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

- (IBAction)deleteAttachment:(id)sender
{
    NSString *delete = [[TagManager sharedInstance] tagByName:kTagDeleteButtonTitle];
    NSString *cancel = [[TagManager sharedInstance] tagByName:kTagCancelButton];
    
    [[AlertMessageHandler sharedInstance] showCustomMessage:[NSString stringWithFormat:[[TagManager sharedInstance] tagByName: kTag_TheSelectedAttachementWillBeRemoved], _parentObjectName] withDelegate:self tag:kDeleteButton title:@"" cancelButtonTitle:cancel andOtherButtonTitles:[NSArray arrayWithObject:delete]];
    
}

//D-00003728
- (void)shareAttachment:(id)sender
{
    self.view.backgroundColor = [UIColor brownColor];
    
    //11338
    NSData * data =  [AttachmentUtility getEncodedDataForExistingAttachment:_attachmentTXModel];
    
    if (data != nil && ![data isKindOfClass:[NSNull class]])
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
    
    NSArray * excludedActivities = nil;
    NSMutableArray *sharingOptions = [NSMutableArray arrayWithArray:@[UIActivityTypeAssignToContact, UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                                                      UIActivityTypePostToWeibo, UIActivityTypePostToFlickr,
                                                                      UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeAddToReadingList]];
    
    if (![[AttachmentUtility imageTypesDict] valueForKey:self.attachmentTXModel.extensionName])
    {
        [sharingOptions addObject:UIActivityTypeSaveToCameraRoll];
    }
    excludedActivities = sharingOptions;
    sharingView.excludedActivityTypes = excludedActivities;
    
    if (!self.sharePopOver)
    {
        self.sharePopOver  = [[UIPopoverController alloc] initWithContentViewController:sharingView];
        self.sharePopOver .delegate = self;
    }
    [self.sharePopOver  presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
/* TODO : Enable this code after migrating to minversion iOS8 - Anoop
#ifdef isIOS8ANDABOVE
    [sharingView setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
    SXLogDebug (@"Activity Type = %@ Completed = %d returned items %@ error %@", activityType, completed, returnedItems, activityError);
#else
    [sharingView setCompletionHandler:^(NSString *activityType, BOOL completed) {
    SXLogDebug (@"Activity Type = %@ Completed = %d", activityType, completed);
#endif
*/
    [sharingView setCompletionHandler:^(NSString *activityType, BOOL completed) {
        SXLogDebug (@"Activity Type = %@ Completed = %d", activityType, completed);
        if (activityType == UIActivityTypeMail)
        {
            if (![MFMailComposeViewController canSendMail])
            {
                NSString *cancel = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
                NSString *message = [[TagManager sharedInstance] tagByName:kTagAlertConfigureMail];
                [[AlertMessageHandler sharedInstance] showCustomMessage:message withDelegate:nil tag:0 title:[[TagManager sharedInstance] tagByName:kTagAlertApplicationError] cancelButtonTitle:cancel andOtherButtonTitles:nil];
                // device is not configured to send mail
            }
        }
        [self.sharePopOver dismissPopoverAnimated:YES];
        if (self.sharePopOver != nil)
            self.sharePopOver = nil;
    }];
    sharingView = nil;
}

/** Populating navigation bar **/
- (void)populateNavigationBar
{
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.navigationItem.title = _attachmentTXModel.name;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
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
                
                if (![StringUtil isStringEmpty:_attachmentTXModel.idOfAttachment]) {

                    ModifiedRecordModel *modifiedModel = [[ModifiedRecordModel alloc] init];
                    modifiedModel.syncFlag = YES;
                    modifiedModel.sfId = _attachmentTXModel.idOfAttachment;
                    modifiedModel.recordType = kRecordTypeDetail;
                    modifiedModel.operation = kModificationTypeDelete;
                    modifiedModel.objectName = kAttachmentTableName;
                    modifiedModel.parentObjectName = _parentSFObjectName;
                    modifiedModel.recordLocalId = _attachmentTXModel.localId;
                    modifiedModel.parentLocalId = _parentId;
                    modifiedModel.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
                    [AttachmentHelper saveDeleteAttachmentsToModifiedRecords:[NSMutableArray arrayWithObject:modifiedModel]];
                }
                else
                {
                    [AttachmentHelper deleteAttachmentsWithLocalIds:@[_attachmentTXModel.localId]];
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


-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc
{
    _parentId = nil;
    _webView.delegate = nil;
    _webView = nil;
    _toolbar = nil;//D-00003728
    _url = nil;
    
    [self deregisterForPopOverDismissNotification];
}

-(void)registerForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissDodPopoverAttachment)
                                                 name:POP_OVER_DISMISS
                                               object:nil];
}

-(void)deregisterForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POP_OVER_DISMISS object:nil];
}

- (void)dismissDodPopoverAttachment
{
    [self performSelectorOnMainThread:@selector(dismissDodPopoverIfNeeded) withObject:self waitUntilDone:YES];
}

-(void)dismissDodPopoverIfNeeded{
    if ([self.sharePopOver isPopoverVisible] &&
        self.sharePopOver) {
        
        [self.sharePopOver dismissPopoverAnimated:YES];
        self.sharePopOver = nil;
    }
}
@end
