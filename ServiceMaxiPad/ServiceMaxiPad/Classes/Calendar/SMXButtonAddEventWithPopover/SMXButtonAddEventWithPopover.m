//
//  SMXButtonAddEventWithPopover.m
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


#import "SMXButtonAddEventWithPopover.h"

#import "SMXAddEventPopoverController.h"

@interface SMXButtonAddEventWithPopover () <SMXAddEventPopoverControllerProtocol>
@property (nonatomic, strong) SMXAddEventPopoverController *popoverControllerAdd;
@end

@implementation SMXButtonAddEventWithPopover

#pragma mark - Synthesize

@synthesize popoverControllerAdd;
@synthesize protocol;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:30.]];
        [self setTitle:@"+" forState:UIControlStateNormal];
        
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

#pragma mark - Button Action

- (IBAction)buttonAction:(id)sender {
    
    popoverControllerAdd = [[SMXAddEventPopoverController alloc] initPopover];
    [popoverControllerAdd setProtocol:self];
        
    [popoverControllerAdd presentPopoverFromRect:self.frame inView:[super superview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - SMXAddEventPopoverController Protocol

- (void)addNewEvent:(SMXEvent *)eventNew {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(addNewEvent:)]) {
        [protocol addNewEvent:eventNew];
    }
    
}

@end
