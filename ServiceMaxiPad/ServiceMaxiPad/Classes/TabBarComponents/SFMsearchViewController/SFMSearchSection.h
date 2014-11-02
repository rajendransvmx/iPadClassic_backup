/**
 *  @file   SFMSearchSection.h
 *  @class  SFMSearchSection
 *
 *  @brief Section view for handling tap.
 *
 *   Responsible as the discloser in the search detail view
 *
 *
 *  @author
 *  @author Krishna shanbhag
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <UIKit/UIKit.h>

/**
 * @protocol  <SFMSearchSectionViewDelegate>
 * @name didTapOnSection
 *
 * @author Krishna Shanbhag
 *
 * @brief <Tap on section should disclose/Open up the child views>
 *
 *
 *
 * @param  section
 * Section to be disclose or opene up the child processes
 *
 * @return Description of the return value
 *
 */
@protocol SFMSearchSectionViewDelegate <NSObject>
- (void) didTapOnSection:(int)section;
@end

@interface SFMSearchSection : UITableViewHeaderFooterView

@property (nonatomic, assign) id<SFMSearchSectionViewDelegate> delegate;

/** section for which the guesture to be applied */
@property (nonatomic, assign) NSInteger section;

/** title label for section */
@property (nonatomic, strong) UILabel * titleLabel;

/** Accessory image for diclosing and opening up the child views */
@property (nonatomic, strong) UIImageView *accessoryImageView;
@end
