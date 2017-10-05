//
//  DODViewController.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 13/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DODViewController.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "SFMSearchFieldModel.h"
#import "SFMRecordFieldData.h"
#import "Utility.h"
#import "DateUtil.h"
#import "TaskGenerator.h"
#import "TaskModel.h"
#import "CacheManager.h"
#import "FlowDelegate.h"
#import "TaskManager.h"
#import "DODHelper.h"
#import "WebserviceResponseStatus.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"
#import "StringUtil.h"
#import "AppManager.h"
#import "SFPicklistService.h"
#import "FactoryDAO.h"

@implementation CustomDODButton

-(void)setSelected:(BOOL)selected {
    
    if(selected) {
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor getUIColorFromHexValue:kOrangeColor];
    }
    [super setSelected:selected];
}

@end


@interface DODViewController ()<UITableViewDelegate,UITableViewDataSource,FlowDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CustomDODButton *cancelButton;

@property (nonatomic, weak) id<DownloadOnDemandDelegate> delegate;
@property (nonatomic, strong) SFMSearchObjectModel *searchObject;
@property (nonatomic, strong) TransactionObjectModel *transactionObject;
@property (nonatomic, copy) NSDictionary *fieldLabelDict;
@property (nonatomic, copy) NSString *dodTaskID;

@end

@implementation DODViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preferredContentSize = CGSizeMake(320, 320);
    self.view.superview.layer.cornerRadius = 4.0f;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.preferredContentSize = CGSizeMake(320, 320);
}


- (void)setupUI {
    
    self.titleLabel.textColor = [UIColor getUIColorFromHexValue:kEditableTextFieldColor];
    self.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.progressView.progress    = 0.0f;
    self.cancelButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.cancelButton setTitle:[[TagManager sharedInstance]tagByName:kTag_Download] forState:UIControlStateNormal];
    [self.cancelButton setTitle:[[TagManager sharedInstance]tagByName:kTag_CancelDownload] forState:UIControlStateSelected];
    
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:15.0]];
    [self.cancelButton setTitleColor:[UIColor getUIColorFromHexValue:kOrangeColor] forState:UIControlStateSelected];
    self.cancelButton.selected = NO;
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.layer.borderColor = [UIColor getUIColorFromHexValue:kOrangeColor].CGColor;

    self.titleLabel.text = [self getCellDetailTitleStringForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonClicked:(UIButton *)sender {
    
    UIButton *button = (UIButton *)sender;
    button.selected = ![button isSelected]; // Important line
    if (button.selected) {
        
        /*
         * Selected.
         * Lets go forward to start download process.
         */
        
        if ([[AppManager sharedInstance] hasTokenRevoked])
        {
            
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired
                                                                   message:nil
                                                               andDelegate:nil];
        }
        else
        {
            [self startDownload];

        }
        
    } else {
        /*
         * Unselected.
         * :( user pressed cancel. Lets cancel.
         */
        [self cancelDownload];
    }
}

- (void)setupDODWithDelegate:(id<DownloadOnDemandDelegate>)delegate
                searchObject:(SFMSearchObjectModel *)searchModel
        andTransactionObject:(TransactionObjectModel *)transactionModel {
    
    self.searchObject = searchModel;
    self.transactionObject = transactionModel;
    self.delegate = delegate;
    self.fieldLabelDict = [DODHelper getLabelForDisplayFields:self.searchObject.displayFields object:self.searchObject.targetObjectName];
}

- (NSString *)getCellTitleStringForIndexPath:(NSIndexPath *)indexPath {
    
    SFMSearchFieldModel *fieldModel = [self.searchObject.displayFields objectAtIndex:indexPath.row];
    NSString *objectName =  [self getObjectNameFromSearchModel:fieldModel];
    NSString *titleString = [self.fieldLabelDict objectForKey:objectName];

    if (titleString) {
        
        return titleString;
    } else {
        return [fieldModel getDisplayFieldAsFieldName];
    }
}

-(NSString *)getObjectNameFromSearchModel:(SFMSearchFieldModel *)fieldModel
{
    NSString *objectName = nil;
    objectName  = [fieldModel getDisplayField];
    NSArray *array = [objectName componentsSeparatedByString:@"."];
    if ([array count]< 2)
    {
        objectName = [NSString stringWithFormat:@"%@.%@",fieldModel.objectName,fieldModel.fieldName];
    }
    return objectName;
}

- (NSString *)getCellDetailTitleStringForIndexPath:(NSIndexPath *)indexPath {
    
    SFMSearchFieldModel *fieldModel = [self.searchObject.displayFields objectAtIndex:indexPath.row];
    
    SFMRecordFieldData *fldValue1 = (SFMRecordFieldData *)[self.transactionObject valueForField:[fieldModel getDisplayField]];
    
    NSString *titleString = [self getDisplayStringForValue:fldValue1.displayValue withType:fieldModel.displayType forField:fldValue1.name]; // IPAD-4677
    if ([StringUtil isStringEmpty:titleString]) {
        titleString = @"- - - -";
    }
    return titleString;
}

#pragma mark - Tableview delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.searchObject.displayFields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"DODCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:cellIdentifier];
        
        cell.textLabel.font       = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
        cell.textLabel.textColor  = [UIColor grayColor];
        cell.detailTextLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
    }
    
    cell.textLabel.text           = [self getCellTitleStringForIndexPath:indexPath];
    cell.detailTextLabel.text     = [self getCellDetailTitleStringForIndexPath:indexPath];
    cell.detailTextLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int CELL_SIZE_WITHOUT_LABELS = 10;
    
    int height = [self findHeightForText:[self getCellTitleStringForIndexPath:indexPath]
                             havingWidth:300
                                 andFont:[UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14]];
    
    height += [self findHeightForText:[self getCellDetailTitleStringForIndexPath:indexPath]
                          havingWidth:300
                              andFont:[UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16]];;
    
    return height + CELL_SIZE_WITHOUT_LABELS;
}

- (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    
    CGFloat result = font.pointSize+4;
    if (text) {
        CGSize size;
        
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height+1);
        result = MAX(size.height, result); //At least one row
    }
    return result;
}

- (NSString *) getDisplayStringForValue:(NSString *)value withType:(NSString *)displayType forField:(NSString *)fieldName { // IPAD-4677
    if ([Utility isStringEmpty:value] && ![value isKindOfClass:[NSNumber class]]) {
        return @"";
    }
    
    if([displayType isEqualToString:kSfDTDateTime]) {
        
        value = [DateUtil getUserReadableDateForDateBaseDate:value];
    }
    else if ([displayType isEqualToString:kSfDTDate]) {
        
        value = [DateUtil getUserReadableDateForDBDateTime:value];
    }
    
    else if ([displayType isEqualToString:kSfDTBoolean]) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *numValue = (NSNumber *)value;
            value = [numValue stringValue];
        }
        BOOL istrue = [Utility isItTrue:value];
        //value = istrue ? kYes : kNo; //HS Fix:020290
        value = istrue ? [[TagManager sharedInstance]tagByName:kTagYes]:[[TagManager sharedInstance]tagByName:kTagNo];
        
    }
    
    else if ([displayType isEqualToString:kSfDTPicklist]) { // IPAD-4677
        
        id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
        NSString *displayValue =  [picklistService getDisplayValueFromPicklistForObjectName:self.searchObject.targetObjectName forFiledName:fieldName forValue:value];
        value = (![StringUtil isStringEmpty:displayValue])?displayValue:value;
    }
    else
    {
        if ([value isKindOfClass:[NSNumber class]]) {
            
            NSNumber *numValue = (NSNumber *)value;
            value = [numValue stringValue];
        }
    }
    return value;
}

- (void)clearDODRelatedDataFromCache {
    
    CacheManager *cache = [CacheManager sharedInstance];
    [cache clearCacheByKey:@"searchSFID"];
    [cache clearCacheByKey:@"searchObjectName"];
}

#pragma mark - Download and Cancel method
- (void)startDownload {
    
    if (!self.transactionObject) {
        return;
    }
    
    CacheManager *cache = [CacheManager sharedInstance];
    
    if ([self.transactionObject valueForField:kId] && self.searchObject.targetObjectName) {
        
        SFMRecordFieldData *recordData = (SFMRecordFieldData *)[self.transactionObject valueForField:kId];
        if (recordData.internalValue) {
            [cache pushToCache:recordData.internalValue byKey:@"searchSFID"];
            [cache pushToCache:self.searchObject.targetObjectName byKey:@"searchObjectName"];
        } else {
            return;
        }
        

    } else {
        
        return;
    }
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeDOD
                                             requestParam:nil
                                           callerDelegate:self];
    
    self.progressView.progress = .5f;
    self.dodTaskID = taskModel.taskId;
    [[TaskManager sharedInstance] addTask:taskModel];

}

- (void)cancelDownload {
    
    [[TaskManager sharedInstance] cancelFlowNodeWithId:self.dodTaskID];
    [self clearDODRelatedDataFromCache];
    [self downloadCancelled];
}


- (void)downloadCancelled {
    
    self.progressView.progress = 0.0f;
    if (self.delegate &&
        [self.delegate conformsToProtocol:@protocol(DownloadOnDemandDelegate)]) {
        
        if ([self.delegate respondsToSelector:@selector(downloadCancelledForSFMSearchObject:transactionObject:)]) {
            
            [self.delegate downloadCancelledForSFMSearchObject:self.searchObject transactionObject:self.transactionObject];
        }
    }
}

- (void)downloadedSuccessfully {
    
    self.progressView.progress = 1.0f;
    [self clearDODRelatedDataFromCache];
    if (self.delegate &&
        [self.delegate conformsToProtocol:@protocol(DownloadOnDemandDelegate)]) {
        
        if ([self.delegate respondsToSelector:@selector(downloadedSuccessfullyForSFMSearchObject:transactionObject:)]) {
            
            [self.delegate downloadedSuccessfullyForSFMSearchObject:self.searchObject transactionObject:self.transactionObject];
        }
    }
}

- (void)downloadFailedWithError:(NSError *)error {
    
    if (error) {
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:0
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];

    }
    [self downloadCancelled];
}
#pragma mark - End
#pragma mark - Flow Delegate methods
- (void)flowStatus:(id)status {
    
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeDOD:
            {
                if  (st.syncStatus == SyncStatusSuccess)
                {
                    [self downloadedSuccessfully];
                }
                else if (st.syncStatus == SyncStatusFailed)
                {
                    [self downloadFailedWithError:st.syncError];
                }
                else if (st.syncStatus == SyncStatusInCancelled)
                {
                    [self downloadCancelled];
                }
                break;
            }
            default:
                break;
        }
    }
}
#pragma mark - End
#pragma mark - Popover delegate methods.
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return !self.cancelButton.isSelected;
}
#pragma mark - End
@end
