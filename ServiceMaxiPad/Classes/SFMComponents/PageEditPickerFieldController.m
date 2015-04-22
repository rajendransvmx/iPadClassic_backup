//
//  PageEditPickerFieldController.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 08/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageEditPickerFieldController.h"
#import "SFMPickerData.h"


@interface PageEditPickerFieldController ()

@property(nonatomic, strong)UIPickerView *picklistPicker;

@end

@implementation PageEditPickerFieldController

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
    [self setUpPickerView];
    
    
    // Do any additional setup after loading the view.
}

- (void)setUpPickerView
{
    self.picklistPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.picklistPicker.backgroundColor = [UIColor whiteColor];
    self.picklistPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.picklistPicker.delegate = self;
    self.picklistPicker.dataSource = self;
    
    [self.view addSubview:self.picklistPicker];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.picklistPicker.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [self.dataSource count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self titleForRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self updateRecordDataToPageView:row];
}

- (void)setPickerValue:(NSInteger )index
{
    [self.picklistPicker selectRow:index inComponent:0 animated:NO];
}

- (void)upadeteControlValueOnDismiss
{
    NSInteger row = [self.picklistPicker selectedRowInComponent:0];
    
    [self updateRecordDataToPageView:row];
}

- (void)updateRecordDataToPageView:(NSInteger)row
{
    if ([self.dataSource count] > 0) {
        NSString *value = [self titleForRow:row];
        NSString *internalValue = [self intenalValueForRow:row];
        
        self.recordData.displayValue = value;
        self.recordData.internalValue = internalValue;
        [self.delegate valueForField:self.recordData forIndexPath:self.indexPath sender:self.picklistPicker];
    }
}

- (NSString *)titleForRow:(NSInteger)row
{
    NSString *title = @"";
    
    SFMPickerData *model = [self.dataSource objectAtIndex:row];
    if (model != nil) {
        title = model.pickerLabel;
    }
    return title;
}

- (NSString *)intenalValueForRow:(NSInteger)row
{
    NSString *value  = nil;
    
    SFMPickerData *model = [self.dataSource objectAtIndex:row];
    if (model != nil) {
        value = model.pickerValue;
    }
    return value;
}
@end
