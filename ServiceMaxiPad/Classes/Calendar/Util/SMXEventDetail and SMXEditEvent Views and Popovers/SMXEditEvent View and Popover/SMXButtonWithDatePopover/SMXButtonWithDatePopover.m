//
//  SMXButtonWithDatePopover.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMXButtonWithDatePopover.h"

#import "SMXDatePopoverController.h"
#import "SMXImportantFilesForCalendar.h"

@interface SMXButtonWithDatePopover () <SMXDatePopoverControllerProtocol>
@property (nonatomic, strong) SMXDatePopoverController *popoverControllerDate;
@end

@implementation SMXButtonWithDatePopover

#pragma mark - Synthesize

@synthesize popoverControllerDate;
@synthesize dateOfButton;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date {
    
    self = [self initWithFrame:frame];
    
    NSDateComponents *compDate = date.componentsOfDate;
    
    if (self) {
        dateOfButton = [NSDate dateWithYear:compDate.year month:compDate.month day:compDate.day];
        [self setTitle:[NSDate stringDayOfDate:date] forState:UIControlStateNormal];
    }
    return self;
}

#pragma mark - Button Action

- (IBAction)buttonAction:(id)sender {
    
    popoverControllerDate = [[SMXDatePopoverController alloc] initWithDate:dateOfButton];
    [popoverControllerDate setProtocol:self];
        
    [popoverControllerDate presentPopoverFromRect:self.frame
                                                  inView:[super superview]
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
}

#pragma mark - SMXDatePopoverController Protocol

- (void)valueChanged:(NSDate *)newDate {
    
    NSDateComponents *compNewDate = newDate.componentsOfDate;
    dateOfButton = [NSDate dateWithYear:compNewDate.year month:compNewDate.month day:compNewDate.day];
    [self setTitle:[NSDate stringDayOfDate:dateOfButton] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
