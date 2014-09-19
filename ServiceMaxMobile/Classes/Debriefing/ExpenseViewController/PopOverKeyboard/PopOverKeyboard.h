//
//  PopOverKeyboard.h
//  Debriefing
//
//  Created by Sanchay on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumericKeyboardDelegate <NSObject>

@optional 
-(void)didNumericKeyboardDisappear;
-(void)didKeyboardEditOccur;

@end

@interface PopOverKeyboard : UIViewController
{
	id <NumericKeyboardDelegate> delegate;
	id parent;
	UITextField *txtField;
	BOOL editingBegun;
    BOOL didErasePreviousNum;
}

@property (nonatomic, retain) id parent;
@property (nonatomic, retain) UITextField *txtField;
@property (nonatomic, assign) id <NumericKeyboardDelegate> delegate;

- (IBAction) EnterNumber:(id)sender;
- (IBAction) BackSpace:(id)sender;

@end
