//
//  PageEditHeaderLayoutViewController.m
//  ServiceMaxMobile
//
//  Created by shravya on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageEditHeaderLayoutViewController.h"
#import "SFMRecordFieldData.h"
#import "StringUtil.h"
#import "TagManager.h"
#import "ValueMappingModel.h"

@interface PageEditHeaderLayoutViewController ()

@end

@implementation PageEditHeaderLayoutViewController

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
    self.pageEditControlHandler.isChild = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Overriden Functions

- (NSInteger)numberOfColumns {
    
    SFMHeaderLayout *headerLayout = self.sfmPage.process.pageLayout.headerLayout;
    if ([headerLayout.sections count] > self.selectedIndexPath.row) {
        
         SFMHeaderSection *selectedSection = [headerLayout.sections objectAtIndex:self.selectedIndexPath.row];
        if (selectedSection.noOfColumns > 0) {
            return selectedSection.noOfColumns;
        }
    }
    return 2;
}
- (SFMPageField *)getPageFieldForIndex:(NSInteger)selectedIndex {
    
    SFMHeaderLayout *headerLayout = self.sfmPage.process.pageLayout.headerLayout;
    if ([headerLayout.sections count] > self.selectedIndexPath.row) {
        
        SFMHeaderSection *selectedSection = [headerLayout.sections objectAtIndex:self.selectedIndexPath.row];
        if ([selectedSection.sectionFields count] > selectedIndex) {
            return [selectedSection.sectionFields objectAtIndex:selectedIndex];
        }
    }
    return nil;
}

- (SFMRecordFieldData *)getRecordFieldForIndex:(NSInteger)selectedIndex
                                  andPageField:(SFMPageField *)pageField {
    
    return [self.sfmPage.headerRecord objectForKey:pageField.fieldName];
    
}

- (NSString *)getCollectionViewTitle {
    
    NSString *title;
    SFMHeaderLayout *headerLayout = self.sfmPage.process.pageLayout.headerLayout;
    if ([headerLayout.sections count] > self.selectedIndexPath.row) {
        
        SFMHeaderSection *selectedSection = [headerLayout.sections objectAtIndex:self.selectedIndexPath.row];
        title = selectedSection.title;
        if ([StringUtil isStringEmpty:title]) {
            title = [[TagManager sharedInstance]tagByName:kTagInformation];
            
        }
    }
    return title;
}
- (NSInteger)getNumberOfFields {
    SFMHeaderLayout *headerLayout = self.sfmPage.process.pageLayout.headerLayout;
    if ([headerLayout.sections count] > self.selectedIndexPath.row) {
        
        SFMHeaderSection *selectedSection = [headerLayout.sections objectAtIndex:self.selectedIndexPath.row];
        return [selectedSection.sectionFields count];
    }
    return 0;
}
- (NSArray *)getAllFieldsOfCurrentPageLayout {
    SFMHeaderLayout *headerLayout = self.sfmPage.process.pageLayout.headerLayout;
    if ([headerLayout.sections count] > self.selectedIndexPath.row) {
        SFMHeaderSection *selectedSection = [headerLayout.sections objectAtIndex:self.selectedIndexPath.row];
        return selectedSection.sectionFields;
    }
    return nil;
}

- (CGSize) getCollectionViewSectionHeaderSize
{
    return CGSizeMake(50, 35);
}

- (void)valuesForField:(NSArray *)modelsArray
          forIndexPath:(NSIndexPath *)indexPath
         selectionMode:(NSInteger)selectionMode
{
    [super valuesForField:modelsArray forIndexPath:indexPath selectionMode:selectionMode];
    
    SFMPageField *pageField = [self getPageFieldForIndex:indexPath.item];
    if (pageField.fieldMappingId.length > 0) {
        
        if ([self.delegate isDelgateInShowAllMode]) {
             [self.delegate reloadDataForIndexPath:self.selectedIndexPath reloadAll:YES];
        }
        else{
            [self reloadDataAsync];
        }
    }
    else{
        [self reloadDataAsync];
    }
    
}
#pragma mark End

#pragma mark -SFMCollectionViewCellDelegate methods
- (void)cellValue:(id)value didChangeForIndexpath:(NSIndexPath*)indexPath {
    [super cellValue:value didChangeForIndexpath:indexPath];
}

- (void)cellDidTapForIndexPath:(NSIndexPath*)indexPath andSender:(id)sender {
     [super cellDidTapForIndexPath:indexPath andSender:sender];
}
- (void)valueForField:(SFMRecordFieldData *)model forIndexPath:(NSIndexPath *)indexPath sender:(id)sender {
    [super valueForField:model forIndexPath:indexPath sender:sender];
}

- (void)cellEditingBegan:(NSIndexPath*)indexpath andSender:(id)sender {
    [super cellEditingBegan:indexpath andSender:sender];
}

- (void)clearFieldAtIndexPath:(NSIndexPath*)indexPath andSender:(id)sender
{
    [super cellValue:@"" didChangeForIndexpath:indexPath];
}

- (void)launchBarcodeScannerForIndexPath:(NSIndexPath *)indexPath
{
    [super launchBarcodeScannerForIndexPath:indexPath];
}

#pragma mark End

#pragma mark - Private method which changes all the values in page layout
- (void)fieldValueChangedFor:(NSIndexPath *)indexPath
         andRecordFieldModel:(SFMRecordFieldData *)newRecordFieldModel {
    
    if (newRecordFieldModel.name == nil) {
        return;
    }
    
     SFMRecordFieldData *oldRecordFieldModel = [self.sfmPage.headerRecord objectForKey:newRecordFieldModel.name];
    if (oldRecordFieldModel == nil && newRecordFieldModel != nil) {
        [self.sfmPage.headerRecord setObject:newRecordFieldModel forKey:newRecordFieldModel.name];
    }
    else {
        oldRecordFieldModel.internalValue = newRecordFieldModel.internalValue;
        oldRecordFieldModel.displayValue = newRecordFieldModel.displayValue;
    }
}
#pragma mark - END

#pragma mark - Method to cleaar depenednt values for picklist 
- (void)clearDependentFields:(NSArray *)pageFields dataDict:(NSDictionary *)defaultValueDict;
{
    for (SFMPageField *field in pageFields) {
        SFMRecordFieldData *fieldModel = [self.sfmPage.headerRecord objectForKey:field.fieldName];
        fieldModel.internalValue = nil;
        fieldModel.displayValue = nil;
        
        if ([defaultValueDict count] > 0) {
            NSDictionary *dict = [defaultValueDict objectForKey:field.fieldName];
            if ([dict count] > 0) {
                fieldModel.internalValue = [dict objectForKey:kdefaultValue];
                fieldModel.displayValue = [dict objectForKey:kdefaultLabel];
            }
        }
        [self fieldValueChangedFor:self.selectedIndexPath andRecordFieldModel:fieldModel];
    }
    BOOL shouldReloadAll = [self checkIfDependentFieldsInOtherSection:pageFields];
    if (shouldReloadAll) {
        [self.delegate reloadDataForIndexPath:self.selectedIndexPath reloadAll:YES];
    }
    else {
        [self reloadDataAsync];
    }
}

- (BOOL)checkIfDependentFieldsInOtherSection:(NSArray *)pageFields
{
    BOOL resultValue = NO;
    
    NSArray *sections = self.sfmPage.process.pageLayout.headerLayout.sections;
    
    for (SFMPageField *fieldModel in pageFields) {
        
        for (int i = 0; i < [sections count]; i++) {
            if (i == self.selectedIndexPath.row) {
                continue;
            }
            SFMHeaderSection *headerSection = [sections objectAtIndex:i];
            
            for (SFMPageField *pageField in headerSection.sectionFields) {
                
                if ([pageField.fieldName isEqualToString:fieldModel.fieldName]) {
                    resultValue = YES;
                    break;
                }
            }
        }
    }
    return resultValue;
}

- (void)reloadDataAsync {
    [super reloadDataAsync];
}
#pragma mark End
- (SFMRecordFieldData *)getInternalValueForLiteral:(NSString *)lietral
{
    SFMPageEditManager *manager = [[SFMPageEditManager alloc] init];
    
    ValueMappingModel * mappingModel = [[ValueMappingModel alloc] init];
    mappingModel.currentRecord = self.sfmPage.headerRecord;
    mappingModel.headerRecord = self.sfmPage.headerRecord;
    mappingModel.currentObjectName = self.sfmPage.objectName;
    mappingModel.headerObjectName = self.sfmPage.objectName;
    
    SFMRecordFieldData *recordData = [manager getDisplayValueForLiteral:lietral mappingObject:mappingModel];

    return recordData;
}
- (SFMRecordFieldData *)filterCriteriaForContextFilter:(NSString *)fieldName forHeaderObject:(NSString *)headerValue{
    
    //Header value is off no use.
    SFMRecordFieldData *recordData = [self.sfmPage getHeaderFieldDataForName:fieldName];
    return recordData;
}


- (SFMPageField *)getPageFieldForField:(NSString *)fieldName
{
    SFMPageField *pageField = nil;
    for (SFMHeaderSection *pageHdrSection in self.sfmPage.process.pageLayout.headerLayout.sections)
    {
        pageField = [pageHdrSection pageFieldForField:fieldName];
        if (pageField != nil)
            break;
    }
    return pageField;
    
}
- (SFMRecordFieldData *)getRecordDataForField:(NSString *)fieldName
{
    return [self.sfmPage getHeaderFieldDataForName:fieldName];
}

- (NSString *)recordLocalId
{
    return self.sfmPage.recordId;
}

#pragma mark End

#pragma mark - FormFill mapping

- (void)applyFormFillingIfAnyForRecordField:(SFMRecordFieldData *)recordFieldData
                               andIndexPath:(NSIndexPath *)indexPath{
    

    if (recordFieldData.internalValue.length <= 0) {
        return;
    }
    SFMPageField *pageField = [self getPageFieldForField:recordFieldData.name];
    if (![StringUtil isStringEmpty:pageField.fieldMappingId]) {
        
        [self.pageEditControlHandler.pageManager applyFormFillSettingOfHeaderPageField:pageField withRecordField:recordFieldData sfPage:self.sfmPage];
        
    }
    
}

#pragma mark End
- (NSString *)getsourceObjectName:(SFMPageField *)pageField {
    
   return  self.sfmPage.objectName;
}

@end
