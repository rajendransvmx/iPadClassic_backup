//
//  AttachmentWebView.h
//  ServiceMaxMobile
//
//  Created by Sahana on 10/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AttachmentWebviewdelegate;

@interface AttachmentWebView : UIViewController<UINavigationControllerDelegate,UIWebViewDelegate,UIAlertViewDelegate>
@property (nonatomic, retain) NSString * attachmentLocalId;
- (IBAction)deleteAttachment:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *deleteButton;
@property (retain, nonatomic) IBOutlet UIWebView * webView;
@property (nonatomic, retain) NSString * attachmentFileName;
@property (nonatomic, retain)  NSString * attachmentType;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activity;
@property (nonatomic,assign)  id <AttachmentWebviewdelegate> webviewdelgate;
@property (nonatomic, retain) NSString *attachmentCategory;
@property (nonatomic, assign) BOOL isInViewMode;
@end
@protocol AttachmentWebviewdelegate <NSObject>

-(void)dismissWebView;
- (void) didDeleteAttchment:(NSString *) attachmentLocalId;
-(void) deleteLocalAttachment:(NSString *)localAttachment;//9219
@end
