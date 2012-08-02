//
//  SearchCriteriaViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol setTextFieldPopoverForSFMSearch <NSObject>
@optional
- (void) setTextField:(NSString *)value withTag:(int)tag;
@end
@interface SearchCriteriaViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) NSArray *pickerData;
@property (nonatomic, assign) int tag;
@property (nonatomic , assign)  id <setTextFieldPopoverForSFMSearch> pickerDelegate;
@end
