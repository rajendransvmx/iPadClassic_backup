//
//  PageEditDateFieldController.m
//  SampleDatePicker
//
//  Created by Shubha S on 01/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageEditDateFieldController.h"
#import "DateUtil.h"
#import "StringUtil.h"
#import "MBProgressHUD.h"

@interface PageEditDateFieldController ()

@property (nonatomic, strong)UIDatePicker *datePicker;
@property(nonatomic, strong)MBProgressHUD *HUD;

@end

@implementation PageEditDateFieldController

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
    [self setDefaultDate];
    [self hideAnimator];
}

- (void)setUpUI
{
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    [self.datePicker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.datePicker];
}

- (void)setDefaultDate
{
    if (![StringUtil isStringEmpty:self.recordData.internalValue]) {
        NSDate *selectedDate = [DateUtil dateFromString:self.recordData.internalValue inFormat:kDataBaseDate];
        [self.datePicker setDate:selectedDate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.datePicker.frame = self.view.bounds;
}


- (void)pickerValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    //NSString *dateInString = [DateUtil stringFromDate:datePicker.date inFormat:kDateFormatForSFMEdit];
    
    [self updateRecordDataToPageView:datePicker.date];
}

- (void)upadeteControlValueOnDismiss
{
   // NSString *dateInString = [DateUtil stringFromDate:self.datePicker.date inFormat:kDateFormatForSFMEdit];
    
    [self updateRecordDataToPageView:self.datePicker.date];
}

- (void)updateRecordDataToPageView:(NSDate *)date
{
    if (date != nil) {
        NSString *internaValue = [DateUtil stringFromDate:date inFormat:kDataBaseDate];
        NSString *dateString = [DateUtil stringFromDate:date inFormat:kDateFormatForSFMEdit];
        if (![StringUtil isStringEmpty:dateString] && ![StringUtil isStringEmpty:internaValue])
        {
            self.recordData.displayValue = dateString;
            self.recordData.internalValue = internaValue;
            [self.delegate valueForField:self.recordData forIndexPath:self.indexPath sender:self.datePicker];
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
