//
//  SVMAccessoryButton.h
//  iService
//
//  Created by Krishna Shanbhag on 01/02/13.
//
//

#import <UIKit/UIKit.h>

@interface SVMAccessoryButton : UIButton

@property (nonatomic, retain) NSIndexPath *indexpath;
//Radha Defect Fix 7446
@property (nonatomic, assign) NSInteger index;

@end
