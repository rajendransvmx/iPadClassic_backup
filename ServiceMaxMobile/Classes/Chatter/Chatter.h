//
//  Chatter.h
//  iService
//
//  Created by Samman Banerjee on 28/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSInterfaceObject.h"
#import "AppDelegate.h"
#import "ChatterCell.h"
#import "ImageCacheClass.h"

@protocol ChatterDelegate <NSObject>

@optional
- (void) showMap;
- (void) closeChatter;

@end

@interface ChatterURLConnection : NSURLConnection {
@private
    NSString * userName;
}

@property (nonatomic, retain) NSString * userName;
@end

@interface Chatter : UIViewController
<UITableViewDataSource, UITableViewDelegate, ChatterCellDelegate>
{
    id <ChatterDelegate> delegate;
    AppDelegate * appDelegate;
    
    IBOutlet UITableView * chatTable;
    iOSInterfaceObject * iOSObject;
    
    BOOL willShowMap;
    
    IBOutlet UIActivityIndicatorView * activity;

    NSString * selfId;
    NSString * productId, * productName;
    NSMutableArray * chatterArray;
    
    // Need to disable Done and Calendar button while query is being fired
    IBOutlet UIButton * doneButton, * calendarButton;
    
    IBOutlet UIImageView * productPicture;
    IBOutlet UILabel * productNameLabel, * productDateLabel;
    
    IBOutlet UITextField * newPostText;
    
    NSIndexPath * currentEditRow;
    ChatterCell * currentCell;
    BOOL didEditRow;
    
    CGRect originalRect;
    
    ImageCacheClass * imageCache;
    
    NSArray * userRecordArray;

    BOOL isTimerAlive, isKeyboardShowing;
    
    NSString * prevDateString;
    
    NSMutableArray * usrStringArray;
    NSUInteger usrStringIndex;
    
    NSArray * chatterQueryArray;
    
    NSMutableArray * chatterArrayForTable;
    
    BOOL isChatterAlive;
    NSTimer * timer;
    //Radha 22nd April Label
    IBOutlet UIButton * shareButton;
    IBOutlet UIButton * backButton;
    IBOutlet UINavigationItem * navChatterBar;
    NSMutableDictionary * userIdCache;
    
    NSMutableArray * userNameImageList;
    
    BOOL didRunOperation;
    
    IBOutlet UINavigationBar *navigationBar;
    
    /*Accessibility Changes*/
    IBOutlet UIImageView *servicemaxLogo;
    IBOutlet UIButton *helpButton;
    
}
@property (nonatomic , retain) NSArray * userRecordArray;
@property (nonatomic, assign) id <ChatterDelegate> delegate;
@property (nonatomic, retain) NSString * selfId;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

- (IBAction) Help;
- (IBAction) ShowMap;
- (IBAction) Done;

- (void) fetchPosts;
- (IBAction) postNewChat;
- (void) resetAndStartTimer;

- (void) processUsrStringArray;
- (NSString *) getUserNameFromArray:(NSArray *)userArray WithId:(NSString *)usrString;
// Samman - 30 Mar, 2011
- (NSString *) getUserEmailFromArray:(NSArray *)userArray WithId:(NSString *)usrString;
//sahana - 17th Aug 2011
- (NSString *) getFullPhotoUrlFromArray:userArray WithId:usrString;

- (void) loadChatter;

//- (NSMutableArray *) getTableDataFromChatterArray:(NSMutableArray *)_chatterArray;//  Unused methods

- (IBAction) launchSmartVan;

#define TIMERINTERVAL   8
#define POSTCELL        @"ChatterPostCell"
#define COMMENTCELL     @"ChatterCommentCell"

@end
