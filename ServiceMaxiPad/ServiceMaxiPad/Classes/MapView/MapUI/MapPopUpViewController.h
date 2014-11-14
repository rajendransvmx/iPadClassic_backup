
//
//  MapPopUpViewController.h
//  MapPopUp
//
//  Created by Anoop on 9/8/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkOrderSummaryModel.h"

@protocol MapPopUpDelegate<NSObject>

@optional

- (void) showJobDetailsForAnnotationIndex:(WorkOrderSummaryModel*)woSummaryModel;

@end


typedef NS_ENUM(NSUInteger, cellType) {
    cellTypeServiceLocation = 2,
    cellTypeContact = 4
};

@class WorkOrderSummaryModel, ContactImageModel;

@interface MapPopUpViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) id <MapPopUpDelegate> delegate;
@property (nonatomic, strong) WorkOrderSummaryModel *workOrderSummaryModel;

@end
