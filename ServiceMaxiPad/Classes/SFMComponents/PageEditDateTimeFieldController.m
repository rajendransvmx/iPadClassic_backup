//
//  PageEditDateTimeFieldController.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageEditDateTimeFieldController.h"
#import "StringUtil.h"
#import "DateUtil.h"
#import "MBProgressHUD.h"
#import "NSDate+SMXDaysCount.h"

@interface PageEditDateTimeFieldController ()

@property(nonatomic, strong)UIDatePicker *dateTimePicker;
@property(nonatomic, strong)MBProgressHUD *HUD;

@end

@implementation PageEditDateTimeFieldController

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
    [self showAnimator];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUpUI];
    [self setDefaultDateTimeValue];
    [self hideAnimator];
}

- (void)setUpUI
{
    self.dateTimePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.dateTimePicker.backgroundColor = [UIColor whiteColor];
    self.dateTimePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.dateTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.dateTimePicker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.dateTimePicker];
}

- (void)setDefaultDateTimeValue
{
    if (![StringUtil isStringEmpty:self.recordData.internalValue]) {
        NSDate *selectedDate = [DateUtil getDateFromDatabaseString:self.recordData.internalValue];
        [self.dateTimePicker setDate:selectedDate];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.dateTimePicker.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self showAnimator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pickerValueChanged:(id)sender {
    
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    [self updateRecordDataToPageView:datePicker.date];
}

- (void)upadeteControlValueOnDismiss
{
    [self updateRecordDataToPageView:self.dateTimePicker.date];
}

- (void)updateRecordDataToPageView:(NSDate *)date
{
    if (date != nil){
        NSString *internaValue = [DateUtil getSecZeroedDatabaseStringForDate:date];
        //ANOOP 017148: [DateUtil getSecZeroedUserReadableDateForGMT:date];
        NSString *dateString = [NSDate localDateTimeStringFromDate:date];
        if (![StringUtil isStringEmpty:dateString] && ![StringUtil isStringEmpty:internaValue])
        {
            self.recordData.displayValue = dateString;
            self.recordData.internalValue = internaValue;
            [self.delegate valueForField:self.recordData forIndexPath:self.indexPath sender:self.dateTimePicker];
        }
    }
}

- (void)hideAnimator
{
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
    }
}

- (void)showAnimator
{
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.HUD];
        // Set determinate mode
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        [self.HUD show:YES];
    }
}

@end
