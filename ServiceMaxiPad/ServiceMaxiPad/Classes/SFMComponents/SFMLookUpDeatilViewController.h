//
//  RelatedViewViewController.h
//  SLookUp
//
//  Created by Chinnababu on 08/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//


#import "SFMLookUp.h"

@interface SFMLookUpDeatilViewController: UIViewController
@property (nonatomic, strong) SFMLookUp *lookUpObject;
@property (nonatomic)        NSInteger SelectedIndex;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end


