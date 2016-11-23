//
//  AddOrEditTaskVC.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "AddOrEditTaskVC.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "CheckBox.h"
#import "DateUtil.h"
#import "TagManager.h"
#import "StringUtil.h"
#import "AlertMessageHandler.h"
#import "UIPlaceHolderTextView.h"
#import "TaskHelper.h"
static NSString *priorityCellIdentifier = @"PriorityTaskCell";
@interface AddOrEditTaskVC ()<UICollectionViewDataSource, UICollectionViewDelegate,UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (strong, nonatomic) IBOutlet UIToolbar *titleToolBar;
@property (strong, nonatomic) IBOutlet UICollectionView *priorityCollectionView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;




@property (copy, nonatomic) NSArray *priorityDataSource;
@property (copy, nonatomic) NSArray *priorityNonLocalizedOptions;
@property (nonatomic) NSInteger selectedPriorityIndex;
@property (nonatomic, strong) NSDate *selectedDate;
@property (strong, nonatomic) SFMTaskModel *taskModel;
@property (copy, nonatomic) NSString *titleString;

@property (nonatomic, strong) UIView *maskView;

@end

@implementation AddOrEditTaskVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        self.priorityDataSource = @[[[TagManager sharedInstance]tagByName:kTagAddTaskPriorityHigh],
                                         [[TagManager sharedInstance]tagByName:kTagAddTaskPriorityNormal],
                                         [[TagManager sharedInstance]tagByName:kTagAddTaskPriorityLow]];

        self.priorityNonLocalizedOptions = @[kTaskPriorityHigh,kTaskPriorityNormal,kTaskPriorityLow];
        self.selectedPriorityIndex = 1;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
        {
            self.preferredContentSize = CGSizeMake(500, 513);
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    if(!([[[UIDevice currentDevice] systemVersion] floatValue] >= 8))
    {
        self.view.superview.bounds = CGRectMake(0, 0, 500, 513);//CGRectMake(0, 0, 420, 470);
    }
    self.view.superview.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.superview.layer.shadowOffset = CGSizeMake(3, 4);
    self.view.superview.layer.shadowRadius = 4.0f;
    self.view.superview.layer.shadowOpacity = 0.60f;
    self.view.superview.layer.masksToBounds = YES;
    self.view.superview.layer.cornerRadius  = 6.0;
}

- (void)setupUI {
    
    /**
     * Changes to title tool bar as to change uibarbuttonitem to support titleview.
     */
    UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
    titleView.frame = CGRectMake(0, 0, 100, self.titleToolBar.frame.size.height);
    [titleView setTitle:self.titleString forState:UIControlStateNormal];
    [titleView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleView.userInteractionEnabled = NO;
    self.titleBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:titleView];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.titleToolBar.items = @[self.cancelBarButton,spacer,self.titleBarButtonItem,spacer1,self.saveBarButton];
    self.descriptionTextView.layer.borderColor = [UIColor getUIColorFromHexValue:kActionBgColor].CGColor;
    self.descriptionTextView.layer.borderWidth = 2.0f;
    self.descriptionTextView.layer.cornerRadius = 4.0f;
    
    self.cancelBarButton.title = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    self.saveBarButton.title = [[TagManager sharedInstance]tagByName:kTagSfmActionButtonSave];
    self.descriptionTextView.text = self.taskModel.taskDescription;
    self.descriptionTextView.placeholder = [[TagManager sharedInstance]tagByName:kTag_TextGoes];
    self.descriptionTextView.textColor = [UIColor blackColor];
    self.descriptionTextView.placeholderColor = [UIColor lightGrayColor];
    [self.priorityCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:priorityCellIdentifier];
    self.datePicker.date = self.selectedDate;
    
    self.descriptionLabel.text = [[TagManager sharedInstance]tagByName:kTag_description];
    self.descriptionLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    self.descriptionLabel.textColor = [UIColor grayColor];
    
    self.dueDateLabel.text = [[TagManager sharedInstance]tagByName:kTag_duedate];
    self.dueDateLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    self.dueDateLabel.textColor = [UIColor grayColor];
    
    self.priorityLabel.text = [[TagManager sharedInstance]tagByName:kTag_priority];
    self.priorityLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    self.priorityLabel.textColor = [UIColor grayColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - exposed methods

- (void)showAddNewTaskScreen {
    
    self.titleString = [[TagManager sharedInstance]tagByName:kTag_NewTask];
    self.isNewlyCreadedTask = YES;
    NSString *priority;
    if (self.selectedPriorityIndex < [self.priorityDataSource count]) {
        priority = [self.priorityNonLocalizedOptions objectAtIndex:self.selectedPriorityIndex];
    } else {
        priority = kTaskPriorityNormal;
    }
    
    
    self.taskModel = [[SFMTaskModel alloc]initWithLocalId:nil
                                              description:nil
                                                 priority:priority
                                                 recordId:nil
                                              createdDate:[NSDate date]];
    self.selectedDate = [NSDate date];
    [(UIViewController *)self.delegate presentViewController:self animated:YES completion:nil];
    
}

- (void)showEditTaskScreenForTask:(SFMTaskModel *)task {
    
    self.titleString = [[TagManager sharedInstance]tagByName:kTag_EditTask];
    self.taskModel = [[SFMTaskModel alloc]initWithLocalId:task.localID
                                              description:task.taskDescription
                                                 priority:task.priority
                                                 recordId:task.sfId
                                              createdDate:task.date];

    self.isNewlyCreadedTask = NO;
    if ([self.priorityNonLocalizedOptions containsObject:task.priority]) {
        self.selectedPriorityIndex = [self.priorityNonLocalizedOptions indexOfObject:task.priority];
    }else {
        self.selectedPriorityIndex = 1;
    }

    self.selectedDate = task.date;
    [(UIViewController *)self.delegate presentViewController:self animated:YES completion:nil];
}

#pragma mark - nav Bar button actions
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender {
    
    if ([self.delegate respondsToSelector:@selector(addOrEditTaskVC:userPressedCancelForTask:)]) {
        
        [self.delegate addOrEditTaskVC:self userPressedCancelForTask:self.taskModel];
    }
}

- (IBAction)saveButtonClicked:(UIBarButtonItem *)sender {
    
    if ([StringUtil isStringEmpty:self.descriptionTextView.text]) {
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:[[TagManager sharedInstance]tagByName:kTag_PleaseFillDesc]

                                                   withDelegate:nil
                                                            tag:0
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
        return;
    }
    
    NSString * text = self.descriptionTextView.text;
    
    if(text.length > 255)
    {
        text = [text substringWithRange:NSMakeRange(0, 255)];
        self.descriptionTextView.text = text;
    }

    if ((self.selectedPriorityIndex < [self.priorityNonLocalizedOptions count]) &&
        (self.selectedPriorityIndex > -1)) {
        self.taskModel.priority = [self.priorityNonLocalizedOptions objectAtIndex:self.selectedPriorityIndex];
    }
    self.taskModel.taskDescription = self.descriptionTextView.text;
    self.taskModel.date = self.selectedDate;
    if ([self.delegate respondsToSelector:@selector(addOrEditTaskVC:userPressedSaveForTask:)]) {
        
        [self.delegate addOrEditTaskVC:self userPressedSaveForTask:self.taskModel];
    }
}

- (void)dealloc {
    _priorityCollectionView = nil;
    _descriptionTextView = nil;
    _titleToolBar = nil;
    _saveBarButton = nil;
    _cancelBarButton = nil;
    _titleBarButtonItem = nil;
    _taskModel = nil;
}
#pragma mark - Collectionview delegate and datasource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.priorityDataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:priorityCellIdentifier forIndexPath:indexPath];
    if (cell) {
        // Refresh cell to as new one :)
        for (UIView *oldView in [cell.contentView subviews]) {
            [oldView removeFromSuperview];
        }
    }
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, 165, 40)];
    if (indexPath.row < [self.priorityDataSource count]) {
        titleLabel.text = [self.priorityDataSource objectAtIndex:indexPath.row];
    }
    CheckBox *checkBox  = [[CheckBox alloc]initWithFrame:CGRectMake(0,5, 30, 30)];
    checkBox.userInteractionEnabled = NO;
    if(self.selectedPriorityIndex == indexPath.row)
    {
        [checkBox defaultValueForCheckbox:YES];
    }
    [cell.contentView addSubview:checkBox];
    [cell.contentView addSubview:titleLabel];
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissKeyboardIfNeeded];
    self.selectedPriorityIndex = indexPath.row;
    [self.priorityCollectionView reloadData];

}
#pragma mark - End

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissKeyboardIfNeeded];
}

- (void)dismissKeyboardIfNeeded {
    
    [self.maskView removeFromSuperview];
    self.maskView = nil;
    [self setEditing:NO animated:YES];
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextView class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}

#pragma mark - Picker methods
- (IBAction)datePickerChanged:(UIDatePicker *)sender {
    [self dismissKeyboardIfNeeded];
    self.selectedDate = sender.date;
}
#pragma mark - End

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return newLength <= 255;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self.maskView removeFromSuperview];
    CGRect rect = self.view.bounds;
    rect.origin.y += 200;
    rect.size.height -= 300;
    
    self.maskView = [[UIView alloc]initWithFrame:rect];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboardIfNeeded)];
    [self.maskView addGestureRecognizer:tapGesture];
    [self.view addSubview:self.maskView];
    
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}
@end
