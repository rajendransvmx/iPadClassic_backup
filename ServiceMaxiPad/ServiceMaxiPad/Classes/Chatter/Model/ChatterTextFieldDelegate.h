//
//  ChatterTextFieldDelegate.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 01/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatterTextFieldDelegate <NSObject>

@optional
- (void)textEditingBegan:(id)sender;
- (void)textEditingDone;
- (void)sectiontextEditingDone:(id)sender;
- (void)textFieldReturned;
@end
