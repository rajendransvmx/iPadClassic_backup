//
//  PageEditChildLayoutViewController.m
//  ServiceMaxMobile
//
//  Created by Aparna on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageEditChildLayoutViewController.h"
#import "StringUtil.h"
#import "PageLayoutConstants.h"

@interface PageEditChildLayoutViewController ()
@property (nonatomic,assign) BOOL isPortrait;
@end

@interface PageLayoutEditViewController (Extended)
- (CGFloat)widthForDataType:(NSString *)dataType;
@end

@implementation PageEditChildLayoutViewController

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
    // Do any additional setup after loading the view.
    self.pageEditControlHandler.isChild = YES;
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

#pragma mark -
#pragma mark Private Methods
-(SFMDetailLayout *)detaillayout
{
    SFMDetailLayout *detailLayout = nil;
    NSArray *detailLayoutArray = self.sfmPage.process.pageLayout.detailLayouts;
    if ([detailLayoutArray count] > self.selectedIndexPath.section) {
        
        detailLayout = [detailLayoutArray objectAtIndex:self.selectedIndexPath.section];
    }
    return detailLayout;
    
}

- (NSMutableDictionary *) editedRecord{
    SFMDetailLayout *detailLayout = [self detaillayout];
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    NSArray * detailRecords = [detailDict objectForKey: detailLayout.processComponentId];
    if ([detailRecords count]>self.selectedIndexPath.row) {
        NSMutableDictionary * recordDict = [detailRecords objectAtIndex:self.selectedIndexPath.row];
        return recordDict;
    }
    
    return nil;
    
}

- (BOOL) isFirstFieldValueChanged:(NSString *)fieldName
{
    BOOL isValueChanged = NO;
    SFMDetailLayout *detailLayout = [self detaillayout];
    NSArray * detailFields = detailLayout.detailSectionFields;
    SFMPageField * field  = nil;
    if([detailFields count] > 0)
    {
        field  = [detailFields objectAtIndex:0];
        if ([field.fieldName isEqualToString:fieldName]) {
            isValueChanged = YES;
        }
    }
    return isValueChanged;
}

#pragma mark - Overriden Functions

- (void)clearFieldAtIndexPath:(NSIndexPath*)indexPath andSender:(id)sender
{
    [super cellValue:@"" didChangeForIndexpath:indexPath];
}

- (SFMPageField *)getPageFieldForIndex:(NSInteger)selectedIndex {
    
        SFMDetailLayout *detailLayout = [self detaillayout];
        if ([detailLayout.detailSectionFields count] > selectedIndex) {
            return [detailLayout.detailSectionFields objectAtIndex:selectedIndex];
        }
    return nil;
}

- (SFMRecordFieldData *)getRecordFieldForIndex:(NSInteger)selectedIndex
                                  andPageField:(SFMPageField *)pageField {
    
    SFMRecordFieldData * recordField = nil;
    if (pageField.fieldName != nil) {
        
        NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
            SFMDetailLayout *detailLayout = [self detaillayout];
            NSArray * detailRecords = [detailDict objectForKey: detailLayout.processComponentId];
            if ([detailRecords count]>self.selectedIndexPath.row) {
                NSDictionary * recordDict = [detailRecords objectAtIndex:self.selectedIndexPath.row];
                recordField = [recordDict objectForKey:pageField.fieldName];
                
            }
    }
    
    return recordField;
}

- (NSString *)getCollectionViewTitle {
    return nil;
}

- (NSInteger)getNumberOfFields {
        SFMDetailLayout *detailLayout = [self detaillayout];
        return [detailLayout.detailSectionFields count];
}
- (NSArray *)getAllFieldsOfCurrentPageLayout {
    
    SFMDetailLayout *detailLayout = [self detaillayout];
    return detailLayout.detailSectionFields;
}

- (NSInteger)numberOfColumns {
    return 2;
}

- (CGFloat)widthForDataType:(NSString *)dataType {

    CGFloat width = [super widthForDataType:dataType];
    if ([dataType isEqualToString:kSfDTTextArea]) {
           return width-40;
    }
    return width-20;
}

- (NSMutableDictionary *)getRecordDictionaryForSelectedIndexPath {
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    
    SFMDetailLayout *detailLayout = [self detaillayout];
    NSArray * detailRecords = [detailDict objectForKey: detailLayout.processComponentId];
    if ([detailRecords count] > self.selectedIndexPath.row) {
        NSMutableDictionary * recordDict = [detailRecords objectAtIndex:self.selectedIndexPath.row];
        return recordDict;
    }
    return nil;
}
#pragma mark -End


#pragma mark - Protected method which changes all the values in page layout
- (void)fieldValueChangedFor:(NSIndexPath *)indexPath
         andRecordFieldModel:(SFMRecordFieldData *)newRecordFieldModel {
   
    NSMutableDictionary *recordDictionary =  [self getRecordDictionaryForSelectedIndexPath];
    SFMRecordFieldData *oldRecordFieldModel = [recordDictionary objectForKey:newRecordFieldModel.name];
    if (oldRecordFieldModel == nil && newRecordFieldModel != nil) {
        [[self editedRecord] setObject:newRecordFieldModel forKey:newRecordFieldModel.name];
    }
    else {
        oldRecordFieldModel.internalValue = newRecordFieldModel.internalValue;
        oldRecordFieldModel.displayValue = newRecordFieldModel.displayValue;
    }
    if ([self isFirstFieldValueChanged:newRecordFieldModel.name]) {
        if ([self.delegate respondsToSelector:@selector(reloadDataForIndexPath:reloadAll:)]) {
            [self.delegate reloadDataForIndexPath:self.selectedIndexPath reloadAll:NO];
        }
    }
}
#pragma mark End

#pragma mark - Method to cleaar depenednt values for picklist
- (void)clearDependentFields:(NSArray *)pageFields dataDict:(NSDictionary *)defaultValueDict;
{
    SFMDetailLayout * layout = [self.sfmPage.process.pageLayout.detailLayouts
                              objectAtIndex:self.selectedIndexPath.section];
    NSString *compId = layout.processComponentId;
    
    NSArray *detailArray = [self.sfmPage.detailsRecord objectForKey:compId];
    NSDictionary *recordDataDict = [detailArray objectAtIndex:self.selectedIndexPath.row];
    
    for (SFMPageField *field in pageFields) {
        SFMRecordFieldData *fieldModel = [recordDataDict objectForKey:field.fieldName];
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
    [self reloadDataAsync];
}
#pragma mark End

- (SFMRecordFieldData *)getInternalValueForLiteral:(NSString *)lietral
{
    SFMDetailLayout * layout = [self.sfmPage.process.pageLayout.detailLayouts
                                objectAtIndex:self.selectedIndexPath.section];
    NSString *compId = layout.processComponentId;
    
    NSArray *detailArray = [self.sfmPage.detailsRecord objectForKey:compId];
    NSDictionary *recordDataDict = [detailArray objectAtIndex:self.selectedIndexPath.row];
    
    SFMPageEditManager *pageManager = [[SFMPageEditManager alloc] init];
    
    ValueMappingModel * mappingModel = [[ValueMappingModel alloc] init];
    mappingModel.currentRecord = [NSMutableDictionary dictionaryWithDictionary:recordDataDict];
    mappingModel.headerRecord = self.sfmPage.headerRecord;
    mappingModel.currentObjectName = layout.objectName;
    mappingModel.headerObjectName = self.sfmPage.objectName;
    
    SFMRecordFieldData *recordData = [pageManager getDisplayValueForLiteral:lietral mappingObject:mappingModel];
    
    return recordData;
}
- (SFMRecordFieldData *)filterCriteriaForContextFilter:(NSString *)fieldName forHeaderObject:(NSString *)headerValue {
    
    if([headerValue isEqualToString:kcurrentRecordContextFilter ] || [headerValue length] == 0 || [headerValue isEqualToString:@""]) {
        
        SFMDetailLayout * layout = [self.sfmPage.process.pageLayout.detailLayouts
                                    objectAtIndex:self.selectedIndexPath.section];
        NSString *compId = layout.processComponentId;
        
        NSArray *detailArray = [self.sfmPage.detailsRecord objectForKey:compId];
        NSDictionary *recordDataDict = [detailArray objectAtIndex:self.selectedIndexPath.row];
        
        SFMRecordFieldData *recordData = [recordDataDict objectForKey:fieldName];
        return recordData;

    }
    else {
        
        SFMRecordFieldData *recordData = [self.sfmPage getHeaderFieldDataForName:fieldName];
        return recordData;
    }
    return nil;
}
- (void)reloadDataAsync {
    [super reloadDataAsync];
}

#pragma mark - Method to fetch data for picklist
- (SFMPageField *)getPageFieldForField:(NSString *)fieldName
{
    SFMPageField *pageField = nil;
    
    NSArray *detailLayoutArray = self.sfmPage.process.pageLayout.detailLayouts;
    
    SFMDetailLayout *layout = [detailLayoutArray objectAtIndex:self.selectedIndexPath.section];
    
    for (SFMPageField *fieldData in [layout detailSectionFields]) {
        if ([fieldData.fieldName isEqualToString:fieldName]) {
            pageField = fieldData;
            break;
        }
    }
    return pageField;
    
}

- (SFMRecordFieldData *)getRecordDataForField:(NSString *)fieldName
{
    NSDictionary *detailDataDict = [self.sfmPage detailsRecord];
    SFMDetailLayout *layoutData = [self.sfmPage.process.pageLayout.detailLayouts
                                   objectAtIndex:self.selectedIndexPath.section];
    NSString *processCompId = layoutData.processComponentId;
    NSArray *detailArray = [detailDataDict objectForKey:processCompId];
    NSDictionary *recordDataDict = [detailArray objectAtIndex:self.selectedIndexPath.row];
    
    SFMRecordFieldData *recordData = [recordDataDict objectForKey:fieldName];
    
    return recordData;
}

- (NSString *)recordLocalId
{
    NSDictionary *detailDataDict = [self.sfmPage detailsRecord];
    SFMDetailLayout *layoutData = [self.sfmPage.process.pageLayout.detailLayouts
                                   objectAtIndex:self.selectedIndexPath.section];
    NSString *processCompId = layoutData.processComponentId;
    NSArray *detailArray = [detailDataDict objectForKey:processCompId];
    NSDictionary *recordDataDict = [detailArray objectAtIndex:self.selectedIndexPath.row];
    
    SFMRecordFieldData *recordData = [recordDataDict objectForKey:kLocalId];
    
    return recordData.internalValue;
}

#pragma mark End

- (void)cellEditingBegan:(NSIndexPath*)indexpath andSender:(id)sender {
    self.tappedCellIndex = [NSIndexPath indexPathForItem:indexpath.item inSection:self.selectedIndexPath.row];
    [super cellEditingBegan:indexpath andSender:sender];

}

- (void)cellValue:(id)value didChangeForIndexpath:(NSIndexPath*)indexPath {
    self.tappedCellIndex = nil;
    [super cellValue:value didChangeForIndexpath:indexPath];
}

- (void)launchBarcodeScannerForIndexPath:(NSIndexPath *)indexPath
{
    [super launchBarcodeScannerForIndexPath:indexPath];
}

#pragma mark - FormFill mapping

- (void)valuesForField:(NSArray *)modelsArray
          forIndexPath:(NSIndexPath *)indexPath
         selectionMode:(NSInteger)selectionMode
{
    [super valuesForField:modelsArray forIndexPath:indexPath selectionMode:selectionMode];
    [self reloadDataAsync];
}

- (void)applyFormFillingIfAnyForRecordField:(SFMRecordFieldData *)recordFieldData
                               andIndexPath:(NSIndexPath *)indexPath{
    
    
    if (recordFieldData.internalValue.length <= 0) {
        return;
    }
    SFMPageField *pageField = [self getPageFieldForField:recordFieldData.name];

    if (![StringUtil isStringEmpty:pageField.fieldMappingId]) {
        
        [self.pageEditControlHandler.pageManager applyFormFillOnChildRecordOfIndexPath:self.selectedIndexPath sfpage:self.sfmPage withPageField:pageField andselectedIndex:recordFieldData];
        
    }
    
}

#pragma mark End
- (NSString *)getsourceObjectName:(SFMPageField *)pageField {
    
    if ([pageField.sourceObjectField isEqualToString:kcurrentRecordContextFilter] || [pageField.sourceObjectField length] == 0 || [pageField.sourceObjectField isEqualToString:@""] ) {
        
        SFMDetailLayout *detailLayout = [self detaillayout];
        return  detailLayout.objectName;

    }
    return self.sfmPage.objectName;
}


@end
