//
//  NewHelpViewController.h
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 07/05/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

/**
 *  @file   HelpViewController.h
 *  @class  HelpViewController
 *
 *  @brief  Load Help page.
 *
 *  @author  Naveen Vasu
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>

/**
 *  Help - HTML file Name
 *
 *  Enum represetation of File Names.
 *
 */

typedef enum HelpPageName : NSUInteger
{
    HelpPageNameHome = 1,
    HelpPageNameSFMSearch = 2,
    HelpPageNameChatter = 3,
    HelpPageNameCreateNew = 4,
    HelpPageNameViewRecord = 5,
    HelpPageNameCreateEditRecord = 6,
    HelpPageNameMapView = 7,
    HelpPageNameSync = 8,
    HelpPageNameDayView = 9,
    HelpPageNameWeekView = 10,
    HelpPageNameSummary = 11,
    HelpPageNameServiceReport = 12,
    HelpPageNameProductManualHelp = 13,
    HelpPageNameRecents = 14,
    HelpPageNameTroubleshooting = 15
}
HelpPageName;

@interface HelpViewController : UIViewController<UIWebViewDelegate>
{
    HelpPageName selectedHelpPage;
    
    IBOutlet UIWebView *helpWebView;
    IBOutlet UIImageView *navigationBarImgView;
    IBOutlet UIImageView *logoImageView;
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIButton *backButton;
    
}

/**
 * @name  setHelpPageName:(NSUInteger)helpPageNumber
 *
 * @author Naveen Vasu
 *
 * @brief Set the Page to be highlighted when Help loads
 *
 * @param  NSUInteger helpPageNumber
 *
 * @return void
 *
 */
- (void)setHelpPageName:(NSUInteger)helpPageNumber;

/**
 * @name  exitHelp
 *
 * @author Naveen Vasu
 *
 * @brief Exit from the Help Page to the page from it was launched
 *
 * @return IBAction
 *
 */
- (IBAction)exitHelp;

@end