//
//  ActionMenu.h
//  project
//
//  Created by Samman on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActionMenuDelegate;

@interface ActionMenu : UITableViewController 
{
    id <ActionMenuDelegate> delegate;
    NSMutableArray * buttons;
    UIPopoverController * popover;
     NSString * cancel, * save, * quick_save, * summary, * troubleShooting, * chatter; 
    CGFloat maxSize;
    // IOS 8 changes for UI
    CGSize contentSize;

    //8915
    NSMutableArray *buttonTypeArray;
    NSMutableDictionary *buttonDisplayDict;
}
@property (nonatomic, retain) NSMutableDictionary *buttonDisplayDict;
@property (nonatomic, retain) NSMutableArray *buttonTypeArray;
@property (nonatomic, retain) id <ActionMenuDelegate> delegate;
@property (nonatomic, retain) NSMutableArray * buttons;
@property (nonatomic, retain) UIPopoverController * popover;
@property (nonatomic, assign) CGSize contentSize;// IOS 8 changes for UI


@end

@protocol ActionMenuDelegate

@optional
- (void) didSubmitDefaultAction:(NSString *)defaultAction;
- (void) didSubmitAction:(NSString *)processId processTitle:(NSString *)processTitle;
- (void) didInvokeWebService:(NSString *)method event_name:(NSString *)event_name;
- (void) BackOnSave:(NSString *) tergetCall;
//- (void)  OnQuickSave:(NSString *) tergetCall;//  Unused methods
//- (void) stopActivityIndicator;//  Unused methods
- (void) dismissActionMenu;
-(void) offlineActions:(NSDictionary *)buttonDict;

@end
