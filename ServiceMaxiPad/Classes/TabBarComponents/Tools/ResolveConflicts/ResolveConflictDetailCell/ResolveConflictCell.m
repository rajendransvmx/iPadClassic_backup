//
//  ResolveConflictCell.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 05/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ResolveConflictCell.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "TagManager.h"

@implementation ResolveConflictCell

- (void)awakeFromNib {
    // Initialization code
    [self setUpView];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    
    /*
     * Setup the basic style for labels according to UI Spec
     */
    self.objectLabel.font          = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    self.objectNameLabel.font      = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18];
    self.objectNameLabel.textColor = [UIColor grayColor];
    
    self.resolveLabel.textColor = [UIColor getUIColorFromHexValue:kOrangeColor];
    self.resolveLabel.font      = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize16];
    
    self.userResolutionLabel.font        = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize16];
    self.changeResolutionLabel.textColor = [UIColor getUIColorFromHexValue:kOrangeColor];
}

- (void)configureCellForResolve {
    
    /*
     * Initially view will be hidden so lets unhide it. And set the value from tag.
     */
    self.resolveView.hidden = NO;
    self.resolveLabel.text  = [[TagManager sharedInstance]tagByName:kTag_Resolve];
}

- (void)configureCellForResolutionWithUserResolution:(NSString *)resolutionString {
    
    /*
     * Initially view will be hidden so lets unhide it. And set the value from tag.
     */
    self.resolutionView.hidden         = NO;
    self.changeResolutionLabel.text    = [[TagManager sharedInstance]tagByName:kTag_Change_Resolution];
    self.userResolutionLabel.text      = resolutionString;
    self.userResolutionLabel.textColor = [UIColor blackColor];
}

- (void)prepareForReuse {
    
    /*
     * Reset the cell to as its new ;)
     */
    self.resolveView.hidden    = YES;
    self.resolutionView.hidden = YES;
    self.objectNameLabel.text  = @"";
    self.objectLabel.text      = @"";
}

@end
