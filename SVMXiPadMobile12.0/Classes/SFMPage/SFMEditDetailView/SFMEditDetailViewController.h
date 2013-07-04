//
//  SFMEditDetailViewController.h
//  iService
//
//  Created by Krishna Shanbhag on 29/01/13.
//
//

#import <UIKit/UIKit.h>
#import "WSIntfGlobals.h"
//#import "DetailViewController.h"
#import "BOTControlDelegate.h"


@protocol SFMEditDetailDelegate;

@class iServiceAppDelegate;
@class DetailViewController;
@interface SFMEditDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate, ControlDelegate> {
    
    BOOL                isDefault;
    NSInteger           selectedSection;
    NSInteger           selectedRow;
	
	id <SFMEditDetailDelegate> detailDelegate;
	
	UIPopoverController * lookupPopover;
}

@property (nonatomic, assign) id <SFMEditDetailDelegate> detailDelegate;

@property (nonatomic, retain) DetailViewController          * parentReference;

@property (retain, nonatomic) UITableView                   *tableView;

@property (nonatomic,retain) NSArray                        * Disclosure_Fields;
@property (nonatomic,retain) NSArray                        * Disclosure_Details;
@property (nonatomic,retain) NSDictionary                   * Disclosure_dict;

@property (nonatomic,assign) BOOL line;
@property (nonatomic,assign) BOOL header;

@property (nonatomic, retain) NSIndexPath                   * selectedIndexPath;
@property (nonatomic)         NSInteger                       selectedRowForDetailEdit;

@property (nonatomic,retain) NSIndexPath                    *selectedIndexPathForEdit;
@property (nonatomic ,retain) NSIndexPath                   * currentEditRow;
@property (retain, nonatomic ) UIPopoverController           * lookupPopover;

@property (nonatomic, assign)   BOOL                        isInViewMode;
@property (nonatomic, assign)   BOOL                        isInEditDetail;

@property (nonatomic, assign)   NSInteger                   selectedSection;

- (float) getHeightForEditView ;
-(BOOL)isNecessaryFieldsFilled;

#define SHOWALL_HEADERS                     0
#define SHOW_HEADER_ROW                     1
#define SHOWALL_LINES                       2
#define SHOW_LINES_ROW                      3
#define SHOW_ALL_ADDITIONALINFO             4
#define SHOW_ADDITIONALINFO_ROW             5


@end

@protocol SFMEditDetailDelegate <NSObject>

@optional
- (void) moveTableviewForKeyboardHeight:(NSNotification *)notification;

@end
