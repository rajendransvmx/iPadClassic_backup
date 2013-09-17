//
//  AddTaskController.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 17/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskViewController.h"

@interface AddTaskController : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverControllerDelegate>
{
    AppDelegate * appDelegate;
    
    IBOutlet UITextView * textView;
    IBOutlet UIPickerView * picker;
	IBOutlet UILabel *enterTaskLabel;
    
	IBOutlet UILabel *setPriorityLable;
    NSArray * pickerValues;
    
    UIPopoverController * popOverController;
    
    TaskViewController * taskView;
    
    NSUInteger selectedPickerRow;
    IBOutlet UIButton * cancelBuuton;
    IBOutlet UIButton * doneButton;
    IBOutlet UILabel * taskPrompt;
    IBOutlet UILabel * priority;
    
}

@property (nonatomic, retain) UIPopoverController * popOverController;

@property (nonatomic, retain) TaskViewController * taskView;

- (IBAction) Cancel;
- (IBAction) Done;

- (NSMutableArray *) getTask;

@end
