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
#import <CoreLocation/CoreLocation.h>
@class CalendarController;
@class iServiceAppDelegate;

@interface iPadScrollerViewController : UIViewController
<BSPreviewScrollViewDelegate, TapImageDelegate, CLLocationManagerDelegate>
{
	NSMutableArray * scrollPages;

    IBOutlet BSPreviewScrollView * scrollViewPreview;
    
    IBOutlet UIImageView * animateImage;
    IBOutlet UIView * refFrame;
    IBOutlet UIImageView * lastFrame;
    
    NSArray * itemArray, * descriptionArray;
    
    CalendarController * calendar;
    
    iServiceAppDelegate * appDelegate;
    
    BOOL isInternetAvailable;
}

@property (nonatomic, retain) NSArray * scrollPages;
@property (nonatomic, retain) CLLocationManager *locationManager;
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

@end
