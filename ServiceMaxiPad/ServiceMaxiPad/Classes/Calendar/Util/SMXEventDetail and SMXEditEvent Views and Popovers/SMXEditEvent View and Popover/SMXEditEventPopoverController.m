//
//  SMXEditEventPopoverController.m
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

#import "SMXEditEventPopoverController.h"

#import "SMXEditEventView.h"
#import "SMXImportantFilesForCalendar.h"

@interface SMXEditEventPopoverController () <SMXEditEventViewProtocol>
@property (nonatomic, strong) UIViewController *popoverContent;
@property (nonatomic, strong) SMXEvent *event;
@end

@implementation SMXEditEventPopoverController

#pragma mark - Synthesize

@synthesize protocol;
@synthesize event;
@synthesize popoverContent;

#pragma mark - Lifecycle

- (id)initWithEvent:(SMXEvent *)eventInit {
    
    if (!eventInit) {
        NSDateComponents *comp = [NSDate componentsOfCurrentDate];
        eventInit = [SMXEvent new];
        eventInit.stringCustomerName = @"";
        eventInit.ActivityDateDay = [NSDate date];
        eventInit.dateTimeBegin = [NSDate dateWithHour:comp.hour min:comp.minute];
        eventInit.dateTimeEnd = [NSDate dateWithHour:comp.hour min:comp.minute+15];
    }
    
    event = eventInit;
    
    CGSize size = CGSizeMake(300., 700.);
    SMXEditEventView *viewEditar = [[SMXEditEventView alloc] initWithFrame:CGRectMake(0., 0., size.width, size.height) event:eventInit];
    [viewEditar setProtocol:self];
    
    popoverContent = [UIViewController new];
    popoverContent.view = viewEditar;
    popoverContent.preferredContentSize = size;
    
    self = [super initWithContentViewController:popoverContent];
    
    return self;
}

#pragma mark - SMXEditEventView Protocol

- (void)saveEvent:(SMXEvent *)_event {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(saveEditedEvent:)]) {
        [protocol saveEditedEvent:_event];
    }
    
    [self removeThisView:nil];
}

- (void)deleteEvent:(SMXEvent *)_event {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(deleteEvent)]) {
        [protocol deleteEvent];
    }
    
    [self removeThisView:nil];
}

- (void)removeThisView:(UIView *)view {
    
    [self dismissPopoverAnimated:YES];
}

@end
