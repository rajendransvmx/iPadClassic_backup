//
//  AttachmentPopoverViewController.h
//  ServiceMax
//
//  Created by Anoop on 13/11/13.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ImagePickerOptions) {
    
    ImagePickerOptionFromCameraRoll,
    ImagePickerOptionNewPicture,
    ImagePickerOptionNewVideo
};

@protocol AttachmentPopoverControllerDelegate <NSObject>

-(void)selectedOption:(ImagePickerOptions)selectedIndex;

@end

@interface AttachmentPopoverViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *attachmentTableView;
@property (nonatomic, strong) id <AttachmentPopoverControllerDelegate>attachmentDelegate;

@end
