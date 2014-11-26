//
//  SMXMonthCollectionViewFlowLayout.m
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

#import "SMXMonthCollectionViewFlowLayout.h"
#import "SMXImportantFilesForCalendar.h"

@implementation SMXMonthCollectionViewFlowLayout

- (CGSize)collectionViewContentSize {
    
    return CGSizeMake(self.collectionView.frame.size.width, 3*(self.collectionView.frame.size.height));
}

#pragma mark - Forcing de max space between cells to be equal to SPACE_COLLECTIONVIEW_CELL

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *arr = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes* atts in arr) {
        
        if (nil == atts.representedElementKind) {
            NSIndexPath *ip = atts.indexPath;
            atts.frame = [self layoutAttributesForItemAtIndexPath:ip].frame;
        }
    }
    return arr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes* atts = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (indexPath.item == 0 || indexPath.item == 1) // degenerate case 1, first item of section
        return atts;
    
    NSIndexPath *ipPrev = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    
    CGRect fPrev = [self layoutAttributesForItemAtIndexPath:ipPrev].frame;
    CGFloat rightPrev = fPrev.origin.x + fPrev.size.width + SPACE_COLLECTIONVIEW_CELL;
    
    if (atts.frame.origin.x <= rightPrev) // degenerate case 2, first item of line
        return atts;
    
    CGRect f = atts.frame;
    f.origin.x = rightPrev;
    atts.frame = f;
    
    return atts;
}

@end
