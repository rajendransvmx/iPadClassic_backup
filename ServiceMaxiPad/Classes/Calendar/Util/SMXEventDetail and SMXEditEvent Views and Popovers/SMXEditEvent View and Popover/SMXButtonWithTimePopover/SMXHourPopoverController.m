//
//  SMXHourPopoverController.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMXHourPopoverController.h"

@interface SMXHourPopoverController () <UIPickerViewDelegate>
@property (nonatomic, strong) UIViewController *popoverContent;
@property (nonatomic, strong) UIDatePicker *datePickerView;
@end

@implementation SMXHourPopoverController

#pragma mark - Synthesize

@synthesize protocol;
@synthesize popoverContent;
@synthesize datePickerView;

#pragma mark - Lifecycle

- (id)initWithDate:(NSDate *)date {
    
    datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, datePickerView.frame.size.width, datePickerView.frame.size.height)];
    [datePickerView setDatePickerMode:UIDatePickerModeTime];
    [datePickerView addTarget:self action:@selector(valueOfPickerChanged:) forControlEvents:UIControlEventValueChanged];
    [datePickerView setDate:date];
    
    popoverContent = [UIViewController new];
    popoverContent.view = datePickerView;
    popoverContent.preferredContentSize = datePickerView.frame.size;
    
    self = [super initWithContentViewController:popoverContent];
    
    return self;
}

- (IBAction)valueOfPickerChanged:(id)sender {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(valueChanged:)]) {
        [protocol valueChanged:datePickerView.date];
    }
}

@end
