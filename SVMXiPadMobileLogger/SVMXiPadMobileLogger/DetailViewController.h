//
//  DetailViewController.h
//  SVMXiPadMobileLogger
//
//  Created by Siva Manne on 07/11/12.
//  Copyright (c) 2012 Siva Manne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) id detailData;

@property (strong, nonatomic) IBOutlet UITextView *detailDescriptionLabel;

@property (nonatomic, assign) int isLogFromFileSystem;

@end
