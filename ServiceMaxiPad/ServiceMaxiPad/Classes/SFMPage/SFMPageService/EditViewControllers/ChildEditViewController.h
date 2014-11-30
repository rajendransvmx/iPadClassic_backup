//
//  ChildEditViewController.h
//  ServiceMaxMobile
//
//  Created by shravya on 30/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageEditDetailViewController.h"
#import "SFMPage.h"



@interface ChildEditViewController : UIViewController <PageEditDetailViewControllerDelegate>

@property(nonatomic,strong)SFMPage *sfmPage;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic, assign)id<ChildEditViewControllerDelegate> delegate;

- (void) loadDataWithSfmPage:(SFMPage *)sfmPage
                forIndexPath:(NSIndexPath *)indexPath;

@end



