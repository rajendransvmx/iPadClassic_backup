//
//  AttachmentWebView.h
//  ServiceMaxMobile
//
//  Created by Sahana on 10/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentTXModel.h"

@protocol AttachmentWebviewdelegate <NSObject>

- (void)didDeleteAttachment:(AttachmentTXModel*)attachment;

@end

@interface AttachmentWebView : UIViewController <UINavigationControllerDelegate,UIWebViewDelegate,UIAlertViewDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) IBOutlet UIWebView * webView;
@property (nonatomic, strong) AttachmentTXModel *attachmentTXModel;
@property (nonatomic, copy) NSString *parentObjectName;
@property (nonatomic, copy) NSString *parentSFObjectName;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * activity;
@property (nonatomic, weak)  id <AttachmentWebviewdelegate> webviewdelgate;
@property (nonatomic, assign) BOOL isInViewMode;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) NSURL * url;

- (void)deleteAttachment:(id)sender;
- (void)shareAttachment:(id)sender;

@end
