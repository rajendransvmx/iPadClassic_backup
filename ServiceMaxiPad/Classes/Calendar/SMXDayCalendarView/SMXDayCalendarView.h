//
//  SMXDayCalendarView.h
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


#import <UIKit/UIKit.h>
#import "SMXConstants.h"
#import "SMXEventDetailView.h"
#import "SMXReschedulePopup.h"
#import "SMXMultiDayCalculation.h"
#import "SMXDayScrollView.h"



@protocol SMXDayCalendarViewProtocol <NSObject>
@required
- (void)setNewDictionary:(NSDictionary *)dict;
@optional
- (void)addReshudlingWindow:(SMXEvent *)event_Loc;
@end

@interface SMXDayCalendarView : UIView

@property (nonatomic, assign) id<SMXDayCalendarViewProtocol> protocol;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic, strong) SMXEventDetailView *viewDetail;
@property (nonatomic,strong) SMXReschedulePopup *sMXReschedulePopup;
@property (nonatomic,strong) SMXMultiDayCalculation *multiDayCalculation;
@property (nonatomic, strong) SMXDayScrollView *dayContainerScroll;

- (void)invalidateLayout;
- (void)showLeftPanel;
-(void)removeCalender;
-(void)refreshDetailView;
-(void)rescheduleEvent:(SMXEvent *) _event;
- (void)addReshudlingWindow:(SMXEvent *)event_Loc;
- (void)showViewDetailsWithEvent:(SMXBlueButton *)_button cell:(UICollectionViewCell *)cell;

@end
