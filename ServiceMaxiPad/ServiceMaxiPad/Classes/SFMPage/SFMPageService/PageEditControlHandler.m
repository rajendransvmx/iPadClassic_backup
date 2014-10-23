//
//  PageEditControlHandler.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 08/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageEditControlHandler.h"
#import "PageEditPickerFieldController.h"
#import "PageEditDateFieldController.h"
#import "SFMPageEditManager.h"
#import "PageEditLongTexFieldController.h"
#import "PageEditDateTimeFieldController.h"
#import "StringUtil.h"
#import "SFMCollectionViewCell.h"
#import "ViewControllerFactory.h"
#import "PageEditMultiSelectFieldController.h"
#import "SFMPickerData.h"

@interface PageEditControlHandler ()
@property (nonatomic, strong)UIPopoverController *popOver;

@property (nonatomic, strong)SFMPageField *pageFieldData;
@property (nonatomic, strong)NSIndexPath *indexPath;


@end

@implementation PageEditControlHandler

- (id)init {
    
    self = [super init];
    if (self != nil) {
        self.pageManager = [[SFMPageEditManager alloc] init];
    }
    return self;
}

- (void)showPopoverForView:(SFMCollectionViewCell *)view indexPath:(NSIndexPath *)indexPath
                     field:(SFMPageField *)pageField
          recordObjectName:(NSString *)objectName
{
    NSLog(@"%@",self.popOver);
    if(self.popOver.isPopoverVisible) {
        [self.popOver dismissPopoverAnimated:YES];
        self.popOver = nil;
    }
    
    UITextField * textField = nil;
    
    if (![pageField.dataType isEqualToString:kSfDTTextArea]) {
        textField = (UITextField *)view.valueField;
    }
    
    self.pageFieldData = pageField;
    self.indexPath = indexPath;
    
    if ([pageField.dataType isEqualToString:kSfDTPicklist]){
        [self showPickerPopover:textField objectName:objectName];
    }
    else if ([pageField.dataType isEqualToString:kSfDTReference]
             && [pageField.fieldName isEqualToString:kSfDTRecordTypeId] )
    {
        [self showPickerPopover:textField objectName:objectName];
    }
    else if ([pageField.dataType isEqualToString:kSfDTDate]){
        [self showDatePopover:textField];
    }
    else if ([pageField.dataType isEqualToString:kSfDTDateTime]){
        [self showDateTimePopover:textField];
    }
    else if ([pageField.dataType isEqualToString:kSfDTTextArea]) {
        [self showLongTextPopover:objectName];
    }
    else if ([pageField.dataType isEqualToString:kSfDTMultiPicklist]) {
        [self showMultiSelectPopover:objectName];
    }
}

#pragma mark - Page Edit Controllers
- (void)showPickerPopover:(UITextField *)view objectName:(NSString *)objectName
{
    SFMRecordFieldData *recordData = [self getRecordDataForObject];

    PageEditPickerFieldController *pickerView = [ViewControllerFactory createViewControllerByContext:ViewcontrollerPickerView];
    pickerView.dataSource = [self getPickListArray:objectName andFiledName:recordData.name];
    pickerView.recordData = recordData;
    pickerView.indexPath = self.indexPath;
    pickerView.delegate = self;
    
    self.popOver = [[UIPopoverController alloc] initWithContentViewController:pickerView];
    self.popOver.popoverContentSize = [self getPoPOverContentSize:pickerView.dataSource];
    self.popOver.delegate = self;
    
    [self.popOver presentPopoverFromRect:view.bounds inView:view
                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    if ([pickerView.dataSource count] > 0) {
        NSPredicate *valuePredicate = [NSPredicate predicateWithFormat:@"pickerLabel = %@", recordData.displayValue];
        NSArray *array = [pickerView.dataSource filteredArrayUsingPredicate:valuePredicate];
        if (![StringUtil isStringEmpty:recordData.displayValue]
            && [array count] > 0) {
            SFMPickerData *data = [array objectAtIndex:0];
            NSInteger indexValue = data.indexValue;
            [pickerView setPickerValue:indexValue];
        }
    }
   
}

- (void)showDatePopover:(UITextField *)view
{
    SFMRecordFieldData *recordData = [self getRecordDataForObject];
    
    PageEditDateFieldController *dateController = [ViewControllerFactory createViewControllerByContext:ViewControllerDateView];
    
    dateController.indexPath = self.indexPath;
    dateController.recordData = recordData;
    dateController.delegate = self;
    
    self.popOver = [[UIPopoverController alloc] initWithContentViewController:dateController];
    self.popOver.popoverContentSize = CGSizeMake(320, 216);
    self.popOver.delegate = self;
    
    [self.popOver presentPopoverFromRect:view.bounds inView:view
                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)showDateTimePopover:(UITextField *)view
{
    SFMRecordFieldData *recordData = [self getRecordDataForObject];
    
    PageEditDateTimeFieldController *dateTimeController = [ViewControllerFactory createViewControllerByContext:ViewControllerDateTimeView];
    
    dateTimeController.indexPath = self.indexPath;
    dateTimeController.recordData = recordData;
    dateTimeController.delegate = self;

    self.popOver = [[UIPopoverController alloc] initWithContentViewController:dateTimeController];
    self.popOver.popoverContentSize = CGSizeMake(320, 216);
    self.popOver.delegate = self;
    
    [self.popOver presentPopoverFromRect:view.bounds inView:view
                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

- (void)showLongTextPopover:(NSString *)objectName
{
    SFMRecordFieldData *recordData = [self getRecordDataForObject];
    
    PageEditLongTexFieldController *controller = [[PageEditLongTexFieldController alloc] initWithTitle:self.pageFieldData.label recordData:recordData];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    controller.indexPath = self.indexPath;
    controller.delegate= self;
    
    [self.viewControllerDelegate presentViewController:controller animated:YES completion:nil];
}

- (void)showMultiSelectPopover:(NSString *)objectName
{
    SFMRecordFieldData *recordData = [self getRecordDataForObject];
    
    PageEditMultiSelectFieldController *multiSelectController = [[PageEditMultiSelectFieldController alloc]
                                                        initWithTitle:self.pageFieldData.label
                                                                 recordData:recordData];
    multiSelectController.modalPresentationStyle = UIModalPresentationFormSheet;
    multiSelectController.indexPath = self.indexPath;
    multiSelectController.delegate = self;
    multiSelectController.dataSource = [self getPickListArray:objectName andFiledName:self.pageFieldData.fieldName];
    
    [self.viewControllerDelegate presentViewController:multiSelectController animated:YES completion:nil];
}
#pragma mark - End

- (SFMRecordFieldData *)getRecordDataForObject
{
    if(self.isChild) {
        return [self recordDataForDetail];
    }
    else {
        return [self recordDataForHeader];
    }
}

- (SFMRecordFieldData *)recordDataForHeader
{
    NSDictionary *headerDataDict = [self.sfmPage headerRecord];
    SFMRecordFieldData *recordData = [headerDataDict objectForKey:self.pageFieldData.fieldName];
    
    return recordData;
}

- (SFMRecordFieldData *)recordDataForDetail
{
    NSDictionary *detailDataDict = [self.sfmPage detailsRecord];
    SFMDetailLayout *layoutData = [self.sfmPage.process.pageLayout.detailLayouts
                                   objectAtIndex:self.indexPath.section];
    NSString *processCompId = layoutData.processComponentId;
    NSArray *detailArray = [detailDataDict objectForKey:processCompId];
    NSDictionary *recordDataDict = [detailArray objectAtIndex:self.indexPath.row];
    
    SFMRecordFieldData *recordData = [recordDataDict objectForKey:self.pageFieldData.fieldName];
    
    return recordData;
}

- (CGSize )getPoPOverContentSize:(NSArray *)dataArray
{
    CGSize size = CGSizeMake(320, 216);
    NSInteger maxLenght = 25;
    
    for (SFMPickerData *model in dataArray )
    {
        if ([model.pickerLabel length] > 25)
        {
            maxLenght = 40;
            break;
        }
    }
    if (maxLenght > 25) {
        size = CGSizeMake((maxLenght*13) - 30, 216);
    }
    return size;
}

- (NSArray *)getPickListArray:(NSString *)objectName andFiledName:(NSString *)fieldName
{
    if (self.isChild) {
        objectName = [self getObjectNameForChild];
    }
    
    self.pageManager.editViewControllerDelegate = self.viewControllerDelegate;
    return [self.pageManager getPicklistValueForIndexPath:objectName pageField:self.pageFieldData sfmpage:self.sfmPage];
}

- (void)valueForField:(SFMRecordFieldData *)model forIndexPath:(NSIndexPath *)indexPath sender:(id)sender
{
    [self.viewControllerDelegate valueForField:model forIndexPath:indexPath sender:sender];
}

- (void)resetDependentPicklistFieldsForIndexpth:(NSIndexPath *)indexPath
{
    NSArray *dependentPicklistFields = [self dependentPicklistsForField:self.pageFieldData.fieldName indexPath:indexPath];
    NSLog(@"%@", dependentPicklistFields);
    
    if ([dependentPicklistFields count] > 0) {
        if([self.viewControllerDelegate respondsToSelector:@selector(clearDependentFields:)]) {
            [self.viewControllerDelegate clearDependentFields:dependentPicklistFields];
        }
    }
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    PageEditControlsViewController * controller = (PageEditControlsViewController *)popoverController.contentViewController;
    
    [controller upadeteControlValueOnDismiss];
}

- (NSArray *)dependentPicklistsForField:(NSString *)fieldName indexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *fieldArray = [NSMutableArray new];
    
    if (self.isChild) {
        
        SFMDetailLayout *detailLayout =[self.sfmPage.process.pageLayout.detailLayouts objectAtIndex:indexPath.section];
        
        for (SFMPageField *pageField in  detailLayout.detailSectionFields)
        {
            if ([pageField.controlerField isEqualToString:fieldName])
            {
                [fieldArray addObject:pageField];
            }
        }
    }
    else {
        for (SFMHeaderSection *pageHeaderSection in self.sfmPage.process.pageLayout.headerLayout.sections )
        {
            for (SFMPageField *pageField in [pageHeaderSection sectionFields])
            {
                if ([pageField.controlerField isEqualToString:fieldName])
                {
                    [fieldArray addObject:pageField];
                }
            }
        }
    }
    return fieldArray;
}

- (NSString *)getObjectNameForChild
{
    SFMDetailLayout *detailLayout =  [self.sfmPage.process.pageLayout.detailLayouts objectAtIndex:self.indexPath.section];
    return detailLayout.objectName;
}
- (void)dealloc
{
    self.popOver = nil;
    self.indexPath = nil;
    self.pageFieldData = nil;
}

#pragma mark -
#pragma mark Popover Dismiss Methods

- (void)dismissPopover
{
    if (self.popOver != nil) {
        if([self.popOver isPopoverVisible])
        {
            [self.popOver dismissPopoverAnimated:YES];
        }
    }
}


@end
