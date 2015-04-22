//
//  PageEditMultiSelectFieldController.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 14/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "PageEditControlsViewController.h"

@interface PageEditMultiSelectFieldController : PageEditControlsViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property(nonatomic, strong)NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UILabel *TapSelectLabel;


- (instancetype)initWithTitle:(NSString *)title recordData:(SFMRecordFieldData *)model;

@end