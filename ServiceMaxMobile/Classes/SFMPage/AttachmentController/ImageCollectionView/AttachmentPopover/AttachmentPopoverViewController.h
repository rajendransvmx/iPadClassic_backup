//
//  AttachmentPopoverViewController.h
//  ServiceMaxMobile
//
//  Created by Kirti on 11/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//
@protocol attachmentPopoverControllerDelegate <NSObject>

-(void)selectedOption:(int)selectedAction;

@end
#import <UIKit/UIKit.h>
@interface AttachmentPopoverViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,retain) IBOutlet UITableView *attachmentTableView;
@property (nonatomic,retain) NSArray * popoverArray;
@property (nonatomic,retain) id <attachmentPopoverControllerDelegate>attachmentDelegate;
@end
