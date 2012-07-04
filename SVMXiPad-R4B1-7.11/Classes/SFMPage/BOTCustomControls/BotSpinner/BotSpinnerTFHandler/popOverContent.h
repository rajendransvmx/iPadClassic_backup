//
//  popOverContent.h
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol setTextFieldPopover;
@protocol releasePickerPopOver;

@interface popOverContent : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource,UIPopoverControllerDelegate>
{
    NSArray *spinnerData;
    id <setTextFieldPopover> spinnerDelegate;
    id <releasePickerPopOver> releasepickerdelegate;
    NSInteger index;
    IBOutlet UIPickerView *valuePicker;
}
@property (nonatomic)     NSInteger index;
@property (nonatomic , assign)  id <setTextFieldPopover> spinnerDelegate;
@property (nonatomic , retain) NSArray *spinnerData;
@property (nonatomic , retain) UIPickerView *valuePicker;
@property (nonatomic ,assign )  id <releasePickerPopOver> releasepickerdelegate;
@end

@protocol setTextFieldPopover <NSObject>

@optional

-(void) setTextField:(NSString *)str;


@end

@protocol releasePickerPopOver <NSObject>

-(void) releasePickerPopOver;

@end