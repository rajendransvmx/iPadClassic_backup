//
//  SFMLookUpFilterViewController.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 02/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMLookUpFilterCell.h"

@protocol LookUpFilterDelegate <NSObject>

-(void)applyFilterChanges:(NSArray *)advanceFilter;

@end

@interface SFMLookUpFilterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FilterDelegate>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, weak)id <LookUpFilterDelegate> delegate;

- (CGSize )getPoPOverContentSize;

@end
