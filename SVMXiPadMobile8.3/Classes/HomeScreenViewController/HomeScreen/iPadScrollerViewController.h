//
//  iPadScrollerViewController.h
//  iPadScroller
//
//  Created by Samman on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSPreviewScrollView.h"
#import "TapImage.h"
#import "LocalizationGlobals.h"

@class CalendarController;
@class iServiceAppDelegate;

@interface iPadScrollerViewController : UIViewController
<BSPreviewScrollViewDelegate, TapImageDelegate>
{
	NSMutableArray * scrollPages;

    IBOutlet BSPreviewScrollView * scrollViewPreview;
    
    //Abinash
    IBOutlet UIActivityIndicatorView * activity;

    
    IBOutlet UIImageView * animateImage;
    IBOutlet UIView * refFrame;
    IBOutlet UIImageView * lastFrame;
    
    NSArray * itemArray, * descriptionArray;
    
    CalendarController * calendar;
    
    iServiceAppDelegate * appDelegate;
    
    BOOL isInternetAvailable;
}

@property (nonatomic, retain) NSArray * scrollPages;


- (NSMutableArray *) getScrollViewNames;
- (NSMutableArray *) getScrollViews;

- (void) showTasks;
- (void) showCreateObject;
- (void) showSearch;
- (void) showCalendar;
- (void) showChatter;
- (void) showMap;
- (void) showRecents;
- (void) showHelp;
- (NSString *)dateStringConversion:(NSDate*)date;

//Abinash
-(void)logout;
-(void)sync;



@end
