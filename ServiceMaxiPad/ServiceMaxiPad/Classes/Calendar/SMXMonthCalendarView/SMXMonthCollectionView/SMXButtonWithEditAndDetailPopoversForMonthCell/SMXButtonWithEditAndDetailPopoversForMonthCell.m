//
//  SMXButtonWithEditAndDetailPopoversForMonthCell.m
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


#import "SMXButtonWithEditAndDetailPopoversForMonthCell.h"

#import "SMXEventDetailPopoverController.h"
#import "SMXEditEventPopoverController.h"

@interface SMXButtonWithEditAndDetailPopoversForMonthCell () <SMXEventDetailPopoverControllerProtocol, SMXEditEventPopoverControllerProtocol>
@property (nonatomic, strong) SMXEventDetailPopoverController *popoverControllerDetails;
@property (nonatomic, strong) SMXEditEventPopoverController *popoverControllerEditar;
@end

@implementation SMXButtonWithEditAndDetailPopoversForMonthCell

#pragma mark - Synthesize

@synthesize protocol;
@synthesize event;
@synthesize popoverControllerDetails;
@synthesize popoverControllerEditar;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:12.]];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setEvent:(SMXEvent *)_event {
    
    event = _event;
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

#pragma mark - Button Action

- (IBAction)buttonAction:(id)sender {
    
    if (event) {
        
        popoverControllerDetails = [[SMXEventDetailPopoverController alloc] initWithEvent:event];
        [popoverControllerDetails setProtocol:self];
        
        [popoverControllerDetails presentPopoverFromRect:self.frame
                                           inView:[super superview]
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
}

#pragma mark - SMXEventDetailPopoverController Protocol

- (void)showPopoverEditWithEvent:(SMXEvent *)_event {
    
    popoverControllerEditar = [[SMXEditEventPopoverController alloc] initWithEvent:_event];
    [popoverControllerEditar setProtocol:self];
    
    [popoverControllerEditar presentPopoverFromRect:self.frame
                                              inView:[super superview]
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
}

#pragma mark - SMXEditEventPopoverController Protocol

- (void)saveEditedEvent:(SMXEvent *)eventNew {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(saveEditedEvent:ofButton:)]) {
        [protocol saveEditedEvent:eventNew ofButton:self];
    }
}

- (void)deleteEvent {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(deleteEventOfButton:)]) {
        [protocol deleteEventOfButton:self];
    }
}

@end
