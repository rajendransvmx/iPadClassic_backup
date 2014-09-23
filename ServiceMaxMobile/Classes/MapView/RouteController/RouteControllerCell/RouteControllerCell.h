//
//  RouteControllerCell.h
//  iService
//
//  Created by Samman Banerjee on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteControllerCell : UITableViewCell
{
    IBOutlet UITextView * textView;
}

- (void) setCellText:(NSString *)cellText;
- (NSString *)flattenHTML:(NSString *)html;

@end
