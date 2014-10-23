//
//  SMXEventDetailPopoverController.m
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

#import "SMXEventDetailPopoverController.h"

#import "SMXEventDetailView.h"

@interface SMXEventDetailPopoverController () <SMXEventDetailViewProtocol>
@property (nonatomic, strong) UIViewController *popoverContent;
@property (nonatomic, strong) SMXEvent *event;
@end

@implementation SMXEventDetailPopoverController

#pragma mark - Synthesize

@synthesize protocol;
@synthesize popoverContent;
@synthesize event;

#pragma mark - Lifecycle

- (id)initWithEvent:(SMXEvent *)eventInit {
    
    event = eventInit;
    
    CGSize size = CGSizeMake(360, 130.);
    SMXEventDetailView *viewDetails = [[SMXEventDetailView alloc] initWithFrame:CGRectMake(0., 0., size.width, size.height) event:eventInit];
    [viewDetails setProtocol:self];
    
    popoverContent = [UIViewController new];
    popoverContent.view = viewDetails;
    popoverContent.preferredContentSize = viewDetails.frame.size;
    
    self = [super initWithContentViewController:popoverContent];
    
    return self;
}

#pragma mark - Button Actions

- (void)showEditViewWithEvent:(SMXEvent *)_event {
    
    [self dismissPopoverAnimated:YES];
    
    if ([protocol respondsToSelector:@selector(showPopoverEditWithEvent:)]) {
        [protocol showPopoverEditWithEvent:_event];
    }
}
@end
