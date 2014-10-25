//
//  ChildEditViewControllerDelegate.h
//  ServiceMaxMobile
//
//  Created by shravya on 10/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChildEditViewControllerDelegate <NSObject>

- (void)reloadData;
- (void)keyboardShownInSelectedIndexPath:(NSIndexPath *)indexPath;
- (void) reloadDataForIndexPath:(NSIndexPath *)indexPath reloadAll:(BOOL)reloadAllSections;

@end
