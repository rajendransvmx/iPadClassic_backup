//
//  LinkedProcessViewController.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 09/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LinkedProcessDelegate <NSObject>

- (void)showLinkedProcess:(id)processInfo;

@end

@interface LinkedProcessViewController : UITableViewController

@property(nonatomic, strong)NSArray *linkedProces;
@property(nonatomic, strong)NSString *headerObject;
@property(nonatomic, strong)NSString *objectName;
@property(nonatomic, strong)NSString *recordId;

@property(nonatomic, weak)id <LinkedProcessDelegate> linkedProcessDelegate;

- (CGSize)getPopoverContentSize;
@end
