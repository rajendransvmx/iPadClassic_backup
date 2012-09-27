//
//  ColorPickerController.h
//  MathMonsters
//
//  Created by Ray Wenderlich on 5/3/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraPickerDelegate
- (void)cameraSelected:(int )index;
@end


@interface CameraPickerController : UITableViewController

@property (nonatomic, retain) NSMutableArray *cameraArray;
@property (nonatomic, assign) id<CameraPickerDelegate> delegate;
- (void) buttonSelectedWithTag:(id) sender;
@end
