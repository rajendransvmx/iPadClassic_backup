//
//  SearchCriteriaViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol setTextFieldPopover <NSObject>
@optional
- (void) setTextField:(NSString *)value;
@end
@interface SearchCriteriaViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) NSArray *pickerData;
@property (nonatomic , assign)  id <setTextFieldPopover> pickerDelegate;
@end
