//
//  SMXSearchBarWithAutoComplete.h
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

@interface SMXSearchBarWithAutoComplete : UISearchBar

@property (nonatomic, strong, readonly) NSMutableArray *arrayOfTableView;
@property (nonatomic, strong) NSString *stringClientName;
@property (nonatomic, strong) NSNumber *numCustomerID;
@property (nonatomic, strong) UITableView *tableViewCustom;

- (void)closeKeyboardAndTableView;

@end
