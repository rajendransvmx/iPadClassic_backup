//
//  NotificationTrackerVC.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 06/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "NotificationTrackerVC.h"
#import "NotificationDownloadCell.h"
#import "TagConstant.h"
#import "TagManager.h"


@interface NotificationTrackerVC ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *notificationTableView;
@property (strong, nonatomic) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) PushNotificationModel *userActionreqModel;
@property (nonatomic) UserActionPresentedOn userActionPresentingMode;
@end

@implementation NotificationTrackerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = [[TagManager sharedInstance]tagByName:kTag_Downloads];
    
    [self.notificationTableView registerNib:[UINib nibWithNibName:@"NotificationDownloadCell" bundle:nil] forCellReuseIdentifier:@"notificationDownloadCell"];
    self.notificationTableView.separatorColor = [UIColor clearColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    
}

- (void) downloadProgressForNotification:(PushNotificationModel *)model {
    
    
    if (self.dataSourceArray == nil) {
        self.dataSourceArray = [[NSMutableArray alloc] init];
    }
    
    if(![self.dataSourceArray containsObject:model])
    {
       
            [self.dataSourceArray addObject:model];

    }
    
    [self.notificationTableView reloadData];
    [self.notificationTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:(self.dataSourceArray.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dataSourceArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NotificationDownloadCell *cell = (NotificationDownloadCell *)[tableView dequeueReusableCellWithIdentifier:@"notificationDownloadCell"];
    
//    if (cell == nil) {
//       cell =  [[NotificationDownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notificationDownloadCell"];
//    }
    
    
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero] ;
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    
    PushNotificationModel *model = self.dataSourceArray[indexPath.row];

    //NSLog(@"PushNotification %@ %f",[self resultStateForRequest:model], [self progressForRequest:model]);
    cell.progressStatusLabel.text = [self resultStateForRequest:model];

    [cell.downloadProgressView setProgress:[self progressForRequest:model] animated:YES];
   // [self hideProgressBarforCell:cell withModel:model];
    
    //cell.requestDescription.text = model.notificationMessage;
    //cell.requestTitle.text = @"";
    
    //Uncommnet once we get data from server
    cell.requestDescription.text = model.notificationMessage;
    cell.requestTitle.text = model.notificationTitle;

    return cell;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    return 1;
}
- (void) hideProgressBarforCell:(NotificationDownloadCell *)cell withModel:(PushNotificationModel *)model {
    
    if (model.requestStatus == NotificationRequestStateDownloadCompleted) {
        cell.downloadProgressView.hidden = YES;
    }
}
- (float) progressForRequest:(PushNotificationModel *)model {
    
    float progress = 0.0;
    if (model.requestStatus == NotificationRequestStateDownloadStarted) {
        progress = 0.2;
    }
    if (model.requestStatus == NotificationRequestStateDownloadInProgress) {
        progress = 0.6;
    }
    if (model.requestStatus == NotificationRequestStateDownloadCompleted || model.requestStatus == NotificationRequestStateDownloadFailed || model.requestStatus == NotificationRequestStateNetworkNotReachable) {
        progress = 1.0;
    }
    return progress;
}
- (NSString *) resultStateForRequest:(PushNotificationModel *)model {
    
    NSString *resultString = nil;
    if (model.requestStatus == NotificationRequestStateDownloadStarted) {
       resultString = [[TagManager sharedInstance]tagByName:kTag_Started];
    }
    if (model.requestStatus == NotificationRequestStateDownloadInProgress) {
        resultString = [[TagManager sharedInstance]tagByName:kTag_InProgress];
    }
    if (model.requestStatus == NotificationRequestStateDownloadCompleted) {
        resultString = [[TagManager sharedInstance]tagByName:kTag_Completed];
    }
    if (model.requestStatus == NotificationRequestStateDownloadFailed || model.requestStatus == NotificationRequestStateNetworkNotReachable) {
        resultString = [[TagManager sharedInstance]tagByName:kTagPushLogStatusFailed];
    }
    return resultString;
}

-(void)presentuserActionForRequest:(PushNotificationModel *)reqModel presentingMode:(NSInteger)presentingMode;
{
    // dismiss progress table view
    // Make notification view transparent
    // present alert view
    
    // ALERT VIEW DELEGATE IMPLEMENTAION
    
    if(presentingMode == 0){
        self.userActionPresentingMode = UserActionPresentedOnNonEditScreen;
    
    }
    else if(presentingMode == 1){
        self.userActionPresentingMode = UserActionPresentedOnEditScreen;

    }
    self.userActionreqModel = reqModel;
    [self presentUIActionView];
    
}


-(void)presentUIActionView{
    
    UIAlertView * alertView = nil;
    
    if(self.userActionPresentingMode == UserActionPresentedOnEditScreen)
    {
        alertView  = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTag_ServiceMax] message:[[TagManager sharedInstance]tagByName:kTag_WouldLikeViewCancel] delegate:self cancelButtonTitle:nil otherButtonTitles:[[TagManager sharedInstance]tagByName:kTag_SaveAndView],[[TagManager sharedInstance]tagByName:kTag_AbandonAndView],[[TagManager sharedInstance]tagByName:kTagCancelButton], nil];
    }
    else
    {
        alertView  = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTag_ServiceMax] message:[[TagManager sharedInstance]tagByName:kTag_WouldLikeViewCancel] delegate:self cancelButtonTitle:nil otherButtonTitles:[[TagManager sharedInstance]tagByName:kTag_View],[[TagManager sharedInstance]tagByName:kTagCancelButton] , nil];
    }

    [alertView performSelectorOnMainThread:@selector(show) withObject:self waitUntilDone:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.userActionPresentingMode == UserActionPresentedOnEditScreen)
    {
        if (buttonIndex == 0) {
            [self notifyManagerForSelectedUSerOption:NotificationUSerActionSaveAndView];
        }
        else if (buttonIndex ==1){
            [self notifyManagerForSelectedUSerOption:NotificationUserActionView];
        }
        else if(buttonIndex == 2){
            [self notifyManagerForSelectedUSerOption:NotificationUserActionCancel];
        }
    }
    else
    {
         if (buttonIndex ==0){
            [self notifyManagerForSelectedUSerOption:NotificationUserActionView];
        }
        else if(buttonIndex == 1){
            [self notifyManagerForSelectedUSerOption:NotificationUserActionCancel];
        }
        
    }
    
}



-(void)notifyManagerForSelectedUSerOption:(NotificationUserActionState)userActionState
{
    // CALL : NOTIFICATION MANAGER onSelectionOfUserAction
    [[PushNotificationManager sharedInstance] onSelectionOfUserAction:userActionState forRequest: self.userActionreqModel];

}
-(void)dealloc
{
    NSLog(@"Dealloc NotifcationVC");
    
}
@end
