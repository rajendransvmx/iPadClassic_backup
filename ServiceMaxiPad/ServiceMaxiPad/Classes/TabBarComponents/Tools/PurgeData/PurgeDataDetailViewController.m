//
//  PurgeDataDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "PurgeDataDetailViewController.h"
#import "SNetworkReachabilityManager.h"
#import "TagManager.h"
#import "Reachability.h"
#import "FileManager.h"
#import "SyncManager.h"

@interface PurgeDataDetailViewController ()

@end

@implementation PurgeDataDetailViewController

- (void)registerNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeActionAccordingToNetworkChangeNotification:)
                                                 name:kNetworkConnectionChanged
                                               object:nil];
    
}

- (void)deregisterNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
}


- (void)makeActionAccordingToNetworkChangeNotification:(NSNotification *)notification
{
    if ([notification isKindOfClass:[NSNotification class]])
    {
//        SXLogInfo(@" notification - %@", [notification description]);
//        
//        NSNumber *number = (NSNumber *) [notification object];
//        
//        SXLogInfo(@" notification value - %d", [number intValue]);
    }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self loadPurgeButton];
    });
}

- (void)loadPurgeButton
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        purgeDataBtn.userInteractionEnabled = YES;
        purgeDataBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        [purgeDataBtn setBackgroundColor:[UIColor colorWithHexString:@"#FF6633"]];
        [purgeDataBtn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    }
    else
    {
        purgeDataBtn.userInteractionEnabled = NO;
        purgeDataBtn.layer.borderColor =[UIColor colorWithHexString:@"#AEAEAE"].CGColor;
        [purgeDataBtn setBackgroundColor:[UIColor colorWithHexString:@"#AEAEAE"]];
        [purgeDataBtn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        
    }
}
//- (NSString*)getSyncMetaDataFilePath
//{
//    //    NSString *appDirPath = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getAppCustomSubDirectory];
//    //return [appDirPath stringByAppendingPathComponent:syncMetaDataFile];
//    NSString *appDirPath =[[FileManager getRootPath]stringByAppendingPathComponent:syncMetaDataFile];
//    return appDirPath;
//}
//
//- (void)updateSyncMetaDataWith:(NSMutableDictionary*)dict
//{
//    [dict writeToFile:[self getSyncMetaDataFilePath] atomically:NO];
//}
//
//- (void)updateLastConfigSyncTime:(NSDate*)date
//{
//    NSMutableDictionary *dict = [self getSyncMetaData];
//    [dict setObject:date forKey:lastConfigSyncTimeKey];
//    [self updateSyncMetaDataWith:dict];
//}

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
    // Do any additional setup after loading the view from its nib.
    //self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagPurgeData]];
    purgeDataBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    purgeDataBtn.layer.borderWidth = 0.8;
    [self.smPopover dismissPopoverAnimated:YES];
    
    [self registerNetworkChangeNotification];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadPurgeButton];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self deregisterNetworkChangeNotification];
}

- (IBAction)purgeDataClicked:(id)sender {
   /* Frequency check for Configsync data*/
   // [self makeRequestToserverForTheCategoryType:CategoryTypeDataPurgeFrequency];
    
    [self makeRequestToserverForTheCategoryType:CategoryTypeDataPurge];
}


-(void)setBgColorForSelectBtn:(id)inSender
{
    UIButton *btn = (UIButton *)inSender;
    btn.backgroundColor = [UIColor colorWithHexString:@"E15001"];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
}
-(void)setDefaultBgForBtn:(id)inBtnSender
{
    UIButton *btn = (UIButton *)inBtnSender;
    CGFloat borderWidth = 1.0f;
    //btn.frame =CGRectInset(btn.frame, -borderWidth, -borderWidth);
    btn.layer.borderColor =[UIColor colorWithHexString:@"#E15001"].CGColor;
    btn.layer.borderWidth = borderWidth;
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTitleColor:[UIColor colorWithHexString:@"#E15001"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setBgColorForSelectBtn:) forControlEvents:UIControlEventTouchDown];
}

- (void)makeRequestToserverForTheCategoryType:(CategoryType)categoryType
{
    if ([Reachability connectivityStatus])
    {
        [PurgeDataLoader makeRequestForFrequencyWithTheCallerDelegate:self
                                                       ForTheCategory:categoryType];
    }
    else
    {
        UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:@"Connection is not working" delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil];
         [_alert show];
    }
    
    
}

#pragma mark -Flow node delegate method

- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeDataPurgeFrequency:
            {
                if (st.syncStatus == SyncStatusSuccess)
                {
                    [self checkValidityAndMakeNextRequest];
                    
                }
                else if(st.syncStatus == SyncStatusFailed)
                {
                    
                    
                }
                break;
            }
            default:
                break;
        }
    }
}
- (void)checkValidityAndMakeNextRequest
{
    NSDate  *frequency;
    NSDate *LastConfigSyncTime;
    if ([frequency compare:LastConfigSyncTime] == NSOrderedDescending )
    {
        [self makeRequestToserverForTheCategoryType:CategoryTypeDataPurgeFrequency];
        
    }
    
    else
    {
        
    }
    
    
}

/**** dummy for testing  ******* */

- (void)test
{
    [PurgeDataLoader makeRequestForFrequencyWithTheCallerDelegate:self
                                                   ForTheCategory:CategoryTypeDataPurgeFrequency];
}

@end
