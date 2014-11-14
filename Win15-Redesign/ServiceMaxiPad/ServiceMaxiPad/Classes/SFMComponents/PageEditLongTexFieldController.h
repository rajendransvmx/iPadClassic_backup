//
//  PageEditLongTexFieldController.h
//  SFM
//
//  Created by Radha Sathyamurthy on 07/10/14.
//  Copyright (c) 2014 Radha Sathyamurthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageEditControlDelegate.h"
#import "SFMRecordFieldData.h"

@interface PageEditLongTexFieldController : UIViewController <UITextViewDelegate>

- (id)initWithTitle:(NSString *)title recordData:(SFMRecordFieldData *)model;

@property (weak, nonatomic) id <PageEditControlDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
