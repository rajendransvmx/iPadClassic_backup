//
//  selectProcess.h
//  project
//
//  Created by Samman on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol selectProcessDelegate;

@interface selectProcess : UIViewController
{
    id <selectProcessDelegate> delegate;
    UIPopoverController * popOver;
    IBOutlet UITextField * processIdField, * recordIdField;
}

@property (nonatomic, assign) id <selectProcessDelegate> delegate;
@property (nonatomic, retain) UIPopoverController * popOver;

- (void) setProcessId:(NSString *)processId forRecordId:(NSString *)recordId;
- (IBAction) btnClick:(id)sender;
-(IBAction)editClicked:(id)sender;
- (IBAction)viewClicked:(id)sender;

@end

@protocol selectProcessDelegate <NSObject>

@optional
- (void) didSubmitProcess:(NSString *)processId forRecord:(NSString *)recordId;
-(void)isViewable;
-(void)isEditable;
@end