//
//  SyncProgressBar.h
//  iService
//
//  Created by Radha Sathyamurthy on 07/04/13.
//  
//

#import <UIKit/UIKit.h>


/* State of current display */
typedef enum {
    eNone , 
    eStart,
    ePause,
    eResume,
    eStop,
    eRunning,
    eCompleted,
    eFailed
} ProgressBarState;

/* Priorities : Depending on which the UI element will be updated. */
typedef enum {
    eHigh,
    eMedium,
    eLow
} Priority;

//RADHA
typedef enum 
{
    SYNC_NONE = 0,
    SYNC_STARTS = 1,
    GETDELETE_DONE = 2,
    GETEDELETE_DC_DONE = 3,
    PUTDELETE_DONE = 4,
    PUTINSERT_DONE = 5,
    GETINSERT_DONE = 6,
    GETINSERT_DC_DONE = 7,
    PUTUPDATE_DONE = 8,
    GETUPDATE_DONE = 9,
    GETUPDATE_DC_DONE = 10,
    TXFETCH_DONE = 11,
    SYNC_END = 12
    
}SYNCPROGRESSSTATE;


typedef enum
{
	oSYNC_NONE = 0,
	oSYNC_STARTS = 1,
	oGETDELETE_DONE = 2,
	oPUTDELETE_DONE = 3,
	oPUTINSERT_DONE = 4,
	oGETINSERT_DONE = 5,
	oPUTUPDATE_DONE = 6,
	oGETUPDATE_DONE = 7,
	oTXFETCH_DONE = 8,
	oSYNC_END = 9,
    
}OPTIMIZEDSYNCSTATE;

typedef enum
{
	eEVENTSYNC_NONE = 0,
	eEVENTSYNC_STARTS = 2,
	eEVENTSYNC_GETID = 4,
	eEVENTSYNC_GETDATA = 6,
	eEVENTSYNC_UPDATADATA = 8,
	eEVENTSYNC_PUTDATA = 10,
	eEVENTSYNC_END = 12,
}EVENTSYNCSTATE;


typedef enum
{
	METASYNC_NONE = 0,
	METASYNC_STARTS = 1,
	METASYNC_METADATA = 2,
	METASYNC_PAGEDATA = 3,
	METASYNC_OBJECTDEF = 4,
	METASYNC_PICKLISTDEF = 5,
	METASYNC_WIZARD = 6,
	METASYNC_TAGS = 7,
	METASYNC_SEARCH = 8,
	METASYNC_GETPRICE = 9,
	METASYNC_DEPPICKLIST = 10,
	METASYNC_POPULATEDATA = 11,
	METSSYNC_END = 12,
}METASYNCSTATE;


typedef enum
{
	cSYNC_STARTS = 0,
	cSYNC_PUTINSERT = 2,
	cSYNC_PUTDELETE = 4,
	cSYNC_PUTUPDATE = 6,
	cSYNC_PUTRECORDS = 8,
	cSYNC_END =10,	
}CONFLICTSYNCSTATE;


typedef enum
{
	CUSTOMSYNC_STARTS = 0,
	CUSTOMSYNC_REQDATA = 1,
	CUSTOMSYNC_GETDATA = 2,
	CUSTOMSYNC_PUTDATA = 3,
	CUSTOMSYNC_END = 4,
}CUSTOMSYNCSTATE;

@class SyncProgressBar;


// Protocol to inform delegates about any interuption
@protocol ProgressBarDelegate <NSObject>

// This method will be called to inform delegate when progressBar is ready to accept progress
- (void)progressBarDidStartUpdating:(SyncProgressBar*)progressbar;

// This method will be called to inform delegate when progressBar no more accepts progrss from it.
- (void)progressBarDidStopUpdating:(SyncProgressBar*)progressbar;

@end


@interface SyncProgressBar : UIView

// Delegate to notify any interuption
@property (assign) id<ProgressBarDelegate> delegate;

// Indicates current state of the progressBar
@property (assign) ProgressBarState currentState;

// Informs which priority task updates are going on.
@property (assign) Priority currentPriority;


// ImageView that is displayed on the screen to indicate progress
@property (nonatomic, retain) UIImageView *progressIndicator;

// Label to display the percentage completed [ placed at the center of ImageView ]
@property (nonatomic, retain) UILabel *percentage;

//Diaplays current progress percentage
@property (assign) SYNCPROGRESSSTATE syncProgressState;
@property (assign) OPTIMIZEDSYNCSTATE optimizedSyncProgress;
@property (assign) EVENTSYNCSTATE eventsyncProgressState;
@property (assign) METASYNCSTATE metasyncProgressState;
@property (assign) CONFLICTSYNCSTATE conflictSyncProgressState;
@property (assign) CUSTOMSYNCSTATE customSyncProgressState;


// Returns the singleton instance of ProgressBar class object
+ (SyncProgressBar*)getInstance;


// Returns success if progressbar will be reset and updates can be started.
- (BOOL)startWithPriority:(Priority)priority forObject:(id)sender withTextHidden:(BOOL)hideText;


// Updates about the progressBar state
- (void)setProgressBarState:(ProgressBarState)state forObject:(id)sender forProgress:(NSUInteger)percent; // Commented to make it private for now
- (ProgressBarState)progressBarState;


// Optional : You not need you can choose to hide the text. Also check whether its hidden.
// For eHigh priority by default there will be no text displayed.
// For others by default text will be displayed even if it was hidden earlier.
- (void)setPercentageTextHidden:(BOOL)hidden; // Commented to make it private for now
- (BOOL)isPercentageTextHidden;


// Updates progressBar only if there is a sender and it should be the delegate else progress will be ignored.
- (void)updateProgress:(NSInteger)percentage forObject:(id)sender;

@end
