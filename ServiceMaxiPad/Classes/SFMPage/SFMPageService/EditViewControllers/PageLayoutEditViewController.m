//
//  PageLayoutEditViewController.m
//  ServiceMaxMobile
//
//  Created by shravya on 30/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageLayoutEditViewController.h"
#import "SFMCellFactory.h"
#import "SFMPageFieldCollectionHeaderView.h"
#import "StringUtil.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "SFMRecordFieldData.h"
#import "PageEditCollectionViewFlowLayout.h"
#import "SFMLookUpViewController.h"
#import "BarCodeScannerUtility.h"

static NSString *doubleHyphenString = @"--";
static NSString *cellIdentifier = @"CellIdentifier";
static NSString *collectionViewHeaderIdentifier = @"headerIdentifier";



@interface PageLayoutEditViewController() <BarCodeScannerProtocol>

@property (nonatomic,assign) BOOL isPortrait;

@property (nonatomic,assign) CGFloat internalTextFiedYOffset;
@property (nonatomic,strong) UIView  *textFieldView;
@property (nonatomic,strong) BarCodeScannerUtility *barcodeScanner;

@end

@implementation PageLayoutEditViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.pageLayoutCollectionView.collectionViewLayout = [[PageEditCollectionViewFlowLayout alloc] init];
    self.isPortrait = [self isViewInPortrait:[[UIApplication sharedApplication] statusBarOrientation]];
    [self.pageLayoutCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.pageLayoutCollectionView registerClass:[SFMPageFieldCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionViewHeaderIdentifier];
    [SFMCellFactory registerCellsFor:self.pageLayoutCollectionView];
    self.pageLayoutCollectionView.backgroundColor = [UIColor clearColor];
    self.pageLayoutCollectionView.backgroundView = nil;
    self.view.backgroundColor = [UIColor getUIColorFromHexValue:kPageViewMasterBGColor];
    self.pageLayoutCollectionView.scrollEnabled = NO;
    self.pageLayoutCollectionView.frame = self.view.bounds;
    
    self.pageEditControlHandler = [[PageEditControlHandler alloc] init];
    self.pageEditControlHandler.sfmPage = self.sfmPage;
    self.pageEditControlHandler.viewControllerDelegate = self;

}

- (CGFloat)heightOfTheView {
   return [self heightForTheEntirePageLayout];
}
- (CGFloat)internalOffsetToSelectedIndex {
    return [self internalOffSetForSelectedTextField];
}
- (void)willRemoveViewFromSuperView {
    [self resignAnyResponderIfAny];
}
- (void)resignAllFirstResponders {
    [self resignAnyResponderIfAny];
}
#pragma mark End

#pragma mark - Collection view delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self getNumberOfFields];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)getFinalIndexFromIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item;
//    NSInteger finalIndex = indexPath.section  * [self numberOfColumns] + indexPath.row;
//    return finalIndex;
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
   NSInteger finalIndex = [self getFinalIndexFromIndexPath:indexPath];
    
    //NSLog(@"Final Index %d == %d",finalIndex,indexPath.item);
    SFMPageField *pageField = [self getPageFieldForIndex:finalIndex];
    
    SFMRecordFieldData *fieldData = [self getRecordFieldForIndex:indexPath.item andPageField:pageField];
    
    [self formatNumericField:pageField recordData:fieldData];
    
    NSString *cellStaticIdentifier = nil;
    
    if (pageField.isReadOnly && [pageField.dataType isEqualToString:kSfDTTextArea]) {
        cellStaticIdentifier = [SFMCellFactory getResuseIdentifierForNonEditableTextView];
    }
    
    else if (pageField.isReadOnly) {
        cellStaticIdentifier = noneditReuseIdentifier;
        if ([pageField.dataType isEqualToString:kSfDTBoolean]) {
            cellStaticIdentifier = nonEditBoolReuseIdentifier;
        }
    }
    else{
        
        if ([pageField.dataType isEqualToString:kSfDTReference] && [pageField.fieldName isEqualToString:kSfDTRecordTypeId]) {
            cellStaticIdentifier = [SFMCellFactory getResuseIdentifierForType:kSfDTPicklist];
        }
        else{
            cellStaticIdentifier = [SFMCellFactory getResuseIdentifierForType:pageField.dataType];
        }
    }
    
    SFMCollectionViewCell *cell = (SFMCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellStaticIdentifier forIndexPath:indexPath];
    if (pageField.isRequired) {
          [cell showSuperScript:YES];
    }
    else{
          [cell showSuperScript:NO];
    }
  
    [cell setName:pageField.label];
    cell.delegate =  self;
    cell.indexPath = indexPath;
 
    cell.backgroundColor = [UIColor clearColor];
    if (![StringUtil isStringEmpty:fieldData.displayValue ]) {
           [cell setValue:fieldData.displayValue];
    }
    else{
       [cell setValue:fieldData.internalValue];
    }
   
    cell.clipsToBounds = YES;
    
    [cell setTextFieldDataType:pageField.dataType];
    [cell setPrecision:pageField.precision.doubleValue scale:pageField.scale.doubleValue];
    [cell setLengthVariable:pageField.lengthValue];
    [cell setFieldNameForeText:pageField.label];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
 
    if (indexPath.section > 0) {
        return nil;
    }
    SFMPageFieldCollectionHeaderView *headerView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        NSString *title = [self getCollectionViewTitle];
        headerView = (SFMPageFieldCollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionViewHeaderIdentifier forIndexPath:indexPath];
        headerView.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize20];
        headerView.titleLabel.textColor  = [UIColor blackColor];
        headerView.titleLabel.text = title;
    }
    return headerView;
}

#pragma mark End


#pragma mark - data related methods
- (NSInteger)numberOfColumns {
    
    return 2;
}
#pragma mark End

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SXLogInfo(@"Clicked item %d",indexPath.item);
}
#pragma mark End

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = 0.0 ,height = 0.0;
    NSInteger finalIndex = [self getFinalIndexFromIndexPath:indexPath];
    SFMPageField *pageField = [self getPageFieldForIndex:finalIndex];
    height = [self heightForEachDataType:pageField.dataType];
    width = [self widthForDataType:pageField.dataType];
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 10;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    //return CGSizeMake(50, 35);
    return [self getCollectionViewSectionHeaderSize];
}
#pragma mark End

#pragma mark - Utility methods
- (BOOL)isViewInPortrait:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||  toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return  YES;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||  toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return  NO;
    }
    return self.isPortrait;
}

#pragma mark End

#pragma mark – Orientation handlers

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //[self.pageLayoutCollectionView reloadData];
     self.isPortrait = [self isViewInPortrait:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [[self.pageLayoutCollectionView collectionViewLayout] invalidateLayout];
    [self.pageEditControlHandler dismissPopover];
}

#pragma mark End

- (void)dealloc {
    _barcodeScanner = nil;
    _barcodeScanner.scannerDelegate = nil;
    SXLogDebug(@"PageLayoutEditViewController dealloc");
}


#pragma mark –  Height calculation for current page layout

- (CGFloat)heightForEachDataType:(NSString *)dataType {
    
    CGFloat cellHeight = 0.0;
    if([dataType isEqualToString:kSfDTTextArea])
    {
        cellHeight = 135.0;
    }
    else
    {
       cellHeight = 65;
    }
    return cellHeight;
}

- (CGFloat)widthForDataType:(NSString *)dataType {
    CGFloat width = 0.0;
    
    if ([self numberOfColumns] == 1 || ([dataType isEqualToString:kSfDTTextArea])) {
        if(self.isPortrait) {
            width = 748;
        }
        else{
            width = 682;
        }
        
    }
    else {
        if(self.isPortrait) {
            width = 364;
        }
        else{
            width = 331;
        }
        
    }
    return width;
}

- (CGFloat)heightForTheEntirePageLayout {
    
    return [self calculateHeightOfPageLayoutTillItemIndex:nil];
}

- (CGFloat)calculateHeightOfPageLayoutTillItemIndex:(NSIndexPath *)indexPath {
    CGFloat bottomCellPadding = 10.0;
    CGFloat totalHeightOfPage = 0.0;
    NSInteger numberOfColumns = [self numberOfColumns];
    NSArray *sectionFields = [self getAllFieldsOfCurrentPageLayout];
    NSInteger fieldCounter = 0;
    NSInteger sectionFieldCount = [sectionFields count];
    if (sectionFieldCount > 0) {
        
        NSInteger reminder =  sectionFieldCount % numberOfColumns;
        
        NSInteger loopCount = sectionFieldCount/numberOfColumns;
        if (reminder > 0 ) {
            loopCount++;
        }
        NSInteger outerCounter = 0;
        BOOL isRightPlaceHolderFromPreviousEmpty = NO;
        NSInteger flexibleLoopCounter = loopCount;
        for (outerCounter = 0; (outerCounter < flexibleLoopCounter && outerCounter < 300);outerCounter++) {
            
            CGFloat heightOfCurrentRow = 0.0;
            NSInteger innerCounter = numberOfColumns;
            NSInteger numberOfTextAreas = 0,numberOfTextFields = 0;
           
            while (innerCounter > 0) {
                
                if (sectionFieldCount > fieldCounter) {
                    BOOL prevTextArea = NO;
                    
                    if (numberOfTextAreas > 0) {
                        prevTextArea = YES;
                    }
                   
                    SFMPageField *pageField = [sectionFields objectAtIndex:fieldCounter];
                    if ([pageField.dataType isEqualToString:kSfDTTextArea]) {
                        numberOfTextAreas++;
                    }
                    else{
                        numberOfTextFields++;
                    }
                    
                    if (isRightPlaceHolderFromPreviousEmpty) {
                         isRightPlaceHolderFromPreviousEmpty = NO;
                        if (numberOfTextFields > 0 && numberOfTextAreas < 1) {
                            SXLogDebug(@"Increasing flexible loop counter");
                            flexibleLoopCounter++;
                            fieldCounter++;
                            break;
                        }
                       
                    }
                    if (numberOfTextFields == 1 && prevTextArea) {
                        isRightPlaceHolderFromPreviousEmpty = YES;
                    }
                    
                    CGFloat fieldHeight = [self heightForEachDataType:pageField.dataType];
                    if (heightOfCurrentRow < fieldHeight) {
                        heightOfCurrentRow = fieldHeight;
                    }
                   
                    fieldCounter++;
                    if (indexPath != nil && (fieldCounter - 1) >= indexPath.item) {
                        break;
                    }
                    
                }
                innerCounter--;
            }
            if (numberOfTextAreas > 0 && numberOfColumns == 2) {
                
                if (numberOfTextAreas == 2) {
                    heightOfCurrentRow = [self heightForEachDataType:kSfDTTextArea] * 2 + bottomCellPadding * 1;
                }
                else if (numberOfTextAreas == 1){
                   
                   
                    heightOfCurrentRow = [self heightForEachDataType:kSfDTTextArea];
                    if (numberOfTextFields > 0) {
                        heightOfCurrentRow += [self heightForEachDataType:kSfDTPicklist] + bottomCellPadding;
                    }
                }
            }
            totalHeightOfPage = totalHeightOfPage + heightOfCurrentRow;
            
            if (indexPath != nil && (fieldCounter - 1) >= indexPath.item) {
                break;
            }
        }
        
        totalHeightOfPage+=(outerCounter) * bottomCellPadding;
        
        
    }
    
    return totalHeightOfPage + [self getCollectionViewSectionHeaderSize].height +20;
}
- (void)calculateAndStoreInternalOffSetForIndexPath:(NSIndexPath *)indexPath{
    self.internalTextFiedYOffset = [self calculateHeightOfPageLayoutTillItemIndex:indexPath];
}
#pragma mark end


#pragma mark - Function to be overriden
- (SFMPageField *)getPageFieldForIndex:(NSInteger)selectedIndex {
    
       return nil;
}

- (SFMRecordFieldData *)getRecordFieldForIndex:(NSInteger)selectedIndex
                                  andPageField:(SFMPageField *)pageField {
    
    return nil;
}

- (NSString *)getCollectionViewTitle {
   
    return nil;
}
- (NSInteger)getNumberOfFields {
   
    return 0;
}

- (NSArray *)getAllFieldsOfCurrentPageLayout {
   
    return nil;
}

- (CGFloat)internalOffSetForSelectedTextField {
    return self.internalTextFiedYOffset;
}

- (CGSize) getCollectionViewSectionHeaderSize
{
    return CGSizeZero;
}
#pragma mark End

#pragma mark -SFMCollectionViewCellDelegate and PageEditControlDelegate methods

#pragma mark -SFMCollectionViewCellDelegate methods

- (void)clearFieldAtIndexPath:(NSIndexPath*)indexPath andSender:(id)sender
{

}

- (void)cellValue:(id)value didChangeForIndexpath:(NSIndexPath*)indexPath {
    NSString *strValue = (NSString *)value;
    SFMPageField *pageField = [self getPageFieldForIndex:indexPath.item];
    SFMRecordFieldData *model = [[SFMRecordFieldData alloc] initWithFieldName:pageField.fieldName value:strValue andDisplayValue:strValue];
    [self fieldValueChangedFor:indexPath andRecordFieldModel:model];
    
    if ([pageField.dataType isEqualToString:kSfDTBoolean]) {
        NSArray *dependentPicklst = [self.pageEditControlHandler dependentPicklistsForField:pageField.fieldName
                                                                                  indexPath:self.selectedIndexPath];
        if ([dependentPicklst count] > 0){
            [self clearDependentFields:dependentPicklst dataDict:nil];
        }
    }
   // NSLog(@"Section = %d row = %d", self.selectedIndexPath.section, self.selectedIndexPath.row);
}

- (void)cellDidTapForIndexPath:(NSIndexPath*)indexPath andSender:(id)sender {
    
     [self resignAnyResponderIfAny];
    SFMCollectionViewCell *sernderView = (SFMCollectionViewCell *)sender;
    SFMPageField *pageField = [self getPageFieldForIndex:indexPath.item];
    SFMRecordFieldData *recordField =  [self getRecordFieldForIndex:indexPath.item andPageField:pageField];
    
   // SXLogInfo(@"Data type %@ = %@",pageField.dataType,recordField.internalValue);
    if ([pageField.dataType isEqualToString:kSfDTPicklist]
        || [pageField.dataType isEqualToString:kSfDTDateTime]
        || [pageField.dataType isEqualToString:kSfDTDate]
        || [pageField.dataType isEqualToString:kSfDTTextArea]
        || ([pageField.dataType isEqualToString:kSfDTReference] && [pageField.fieldName isEqualToString:kSfDTRecordTypeId])
        || [pageField.dataType isEqualToString:kSfDTMultiPicklist] ) {
        
       [self.pageEditControlHandler showPopoverForView:sernderView indexPath:self.selectedIndexPath field:pageField recordObjectName:self.sfmPage.objectName];
    }
    else if ([pageField.dataType isEqualToString:kSfDTReference]){
        [self presentLookUpViewForIndexPath:self.selectedIndexPath pageField:pageField recordField:recordField singleSelection:singleSelectionMode];
    }
}

- (void)valueForField:(SFMRecordFieldData *)model forIndexPath:(NSIndexPath *)indexPath sender:(id)sender {
    [self fieldValueChangedFor:indexPath andRecordFieldModel:model];
    [self reloadDataAsync];
    
    if ([sender isKindOfClass:[UIPickerView class]]) {
        [self.pageEditControlHandler resetDependentPicklistFieldsForIndexpth:indexPath recordTyeId:model.internalValue];
    }
}

- (void)valuesForField:(NSArray *)modelsArray
         forIndexPath:(NSIndexPath *)indexPath
        selectionMode:(NSInteger)selectionMode
{
    if(selectionMode == singleSelectionMode)
    {
        if([modelsArray count] > 0){
            SFMRecordFieldData *model = [modelsArray objectAtIndex:0];
            [self fieldValueChangedFor:indexPath andRecordFieldModel:model];
            [self applyFormFillingIfAnyForRecordField:model andIndexPath:indexPath];
        }
    }
}


- (void)cellEditingBegan:(NSIndexPath*)indexpath andSender:(id)sender {
    SFMCollectionViewCell *cell = (SFMCollectionViewCell *)sender;
    self.textFieldView = cell.valueField;
    [self calculateAndStoreInternalOffSetForIndexPath:indexpath];
    [self.delegate keyboardShownInSelectedIndexPath:self.selectedIndexPath];
}

- (void)resignAnyResponderIfAny {
    if ([self.textFieldView isKindOfClass:[UITextField class]]) {
        UITextField *txtField = (UITextField *)self.textFieldView;
        [txtField resignFirstResponder];
    }
    else  if ([self.textFieldView isKindOfClass:[UITextView class]]) {
        UITextView *txtField = (UITextView *)self.textFieldView;
        [txtField resignFirstResponder];
    }
    self.textFieldView = nil;

}
- (void)launchBarcodeScannerForIndexPath:(NSIndexPath *)indexPath 
{
    if(self.barcodeScanner == nil)
    {
        self.barcodeScanner = [[BarCodeScannerUtility alloc] init];
        self.barcodeScanner.scannerDelegate = self;
    }
    self.barcodeScanner.indexPath = indexPath;
    [self.barcodeScanner loadScannerOnViewController:self forModalPresentationStyle:0];
}

#pragma mark End



#pragma mark - Protected method which changes all the values in page layout
- (void)fieldValueChangedFor:(NSIndexPath *)indexPath
         andRecordFieldModel:(SFMRecordFieldData *)newRecordFieldModel {
}
#pragma mark End

#pragma mark - Method to cleaar depenednt values for picklist
- (void)clearDependentFields:(NSArray *)pageFields dataDict:(NSDictionary *)defaultValueDict;
{
    
}

#pragma mark End

#pragma mark - Look up view controller
-(void)presentLookUpViewForIndexPath:(NSIndexPath *)indexPath pageField:(SFMPageField *)pageField
                         recordField:(SFMRecordFieldData *)recordField
                     singleSelection:(LookUpSelectionMode)selectionMode
{
    SFMLookUpViewController * lookUp = [[SFMLookUpViewController alloc] initWithNibName:@"SFMLookUpViewController" bundle:nil];
    if(selectionMode == singleSelectionMode)
    {
        lookUp.lookUpId =  pageField.namedSearch;
        lookUp.objectName = pageField.relatedObjectName;
        lookUp.callerFieldName = pageField.fieldName;
        lookUp.pageField = pageField;
        lookUp.contextObjectName = [self getsourceObjectName:pageField];
    }
    lookUp.indexPath = indexPath;
    lookUp.delegate = self;
    lookUp.selectionMode = selectionMode;
    lookUp.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:lookUp animated:YES completion:^{
    }];
}
#pragma mark End


- (void)reloadDataAsync {
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.pageLayoutCollectionView reloadData];
                       
                   });
}

#pragma mark - FormFill mapping

- (void)applyFormFillingIfAnyForRecordField:(SFMRecordFieldData *)recordFieldData
                               andIndexPath:(NSIndexPath *)indexPath{
    
    
}
#pragma mark - get source object name
- (NSString *)getsourceObjectName:(SFMPageField *)pageField
{
    return nil;
}
#pragma mark End

#pragma mark - Barcode Scanner delegate method
- (void)barcodeSuccessfullyDecodedWithData:(NSString *)decodedData
{
    SXLogInfo(@"DecodedData = %@", decodedData );
    [self updateBarCodeText:decodedData indexPath:self.barcodeScanner.indexPath];
}
- (void) barcodeCaptureCancelled
{
    SXLogDebug(@"barcodeCaptureCancelled" );
}

#pragma mark - End

#pragma mark - Update barcode code value
- (void)updateBarCodeText:(NSString *)value indexPath:(NSIndexPath *)indexPath
{
    SFMRecordFieldData *record = [self getRecordDataForValue:value indexPath:indexPath];
    if (record != nil) {
        [self fieldValueChangedFor:indexPath andRecordFieldModel:record];
        [self reloadDataAsync];
    }
}

- (SFMRecordFieldData *)getRecordDataForValue:(NSString *)value indexPath:(NSIndexPath *)indexPath
{
    SFMRecordFieldData *recordData = nil;
    
    if ([value length] > 0) {
        SFMPageField *pageField = [self getPageFieldForIndex:indexPath.item];
        recordData = [[SFMRecordFieldData alloc] initWithFieldName:pageField.fieldName value:value andDisplayValue:value];
    }
    return recordData;
}
#pragma mark - End

-(void)formatNumericField:(SFMPageField*)pageField recordData:(SFMRecordFieldData *)recordField{
   
     if( (![StringUtil isStringEmpty:recordField.internalValue])
         && ([pageField.dataType isEqualToString:kSfDTCurrency]
         || [pageField.dataType isEqualToString:kSfDTDouble]
         || [pageField.dataType isEqualToString:kSfDTPercent])){  //Except integer for other numberfields should consider.
            
        double value = recordField.internalValue.doubleValue;
        NSString * finalValue  = [[NSString alloc] initWithFormat:@"%.*f",pageField.scale.intValue,value];
        recordField.internalValue = finalValue;
        recordField.displayValue = finalValue;
    }
}
@end
