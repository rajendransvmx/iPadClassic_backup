//
//  ChatterFooterView.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatterTextFieldDelegate.h"

@interface ChatterFooterView : UITableViewHeaderFooterView <UITextFieldDelegate>

@property (nonatomic, weak) id <ChatterTextFieldDelegate> footerTextFieldDelegate;
@property (nonatomic, assign)NSInteger section;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setTextFieldValue:(NSString *)text;

@end
