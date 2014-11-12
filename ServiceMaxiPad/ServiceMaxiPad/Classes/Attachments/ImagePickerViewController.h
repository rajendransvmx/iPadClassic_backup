//
//  ImagePickerViewController.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol attachmentPopoverControllerDelegate <NSObject>

-(void)selectedOption:(int)selectedAction;

@end

@interface ImagePickerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,retain) IBOutlet UITableView *attachmentTableView;
@property (nonatomic,retain) NSArray * popoverArray;
@property (nonatomic,retain) id <attachmentPopoverControllerDelegate>attachmentDelegate;

@end
