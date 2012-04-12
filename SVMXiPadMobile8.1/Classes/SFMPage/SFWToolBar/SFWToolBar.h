//
//  SFWToolBar.h
//  iService
//
//  Created by Pavamanaprasad Athani on 26/12/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SFWToolBarDelegate;

@interface SFWToolBar : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    id <SFWToolBarDelegate> delegate;
    NSMutableDictionary * wizard_info;
    IBOutlet UIView *ipad_only_view;
    NSMutableArray * buttonsArray_offline;
    NSMutableArray * ipad_only_array;
    UIPopoverController * popOver;
    IBOutlet UITableView *sfw_tableview;
    NSMutableDictionary * wizard_buttons;

}
@property (nonatomic , retain)IBOutlet UITableView *sfw_tableview;
@property (nonatomic , retain) NSMutableDictionary * wizard_buttons;
@property (nonatomic , retain) UIPopoverController * popOver;
@property (nonatomic , retain) NSMutableArray * ipad_only_array;
@property (nonatomic , retain) IBOutlet UIView *ipad_only_view;
@property (nonatomic , retain) NSMutableDictionary * wizard_info;
@property (nonatomic , retain) NSMutableArray * buttonsArray_offline;
@property (nonatomic, retain) id <SFWToolBarDelegate> delegate;
-(void)showIpadOnlyButtons;

@end

@protocol SFWToolBarDelegate <NSObject>

@optional
-(void) offlineActions:(NSDictionary *)buttonDict;

@end
#define  BUTTON_WIDTH   150
#define  BUTTON_HEIGHT  60 

#define CELL_BUTTON_WIDTH  150
#define CELL_BUTTON_HEIGHT 80
#define NUM_BUTTONS_LIMIT  6