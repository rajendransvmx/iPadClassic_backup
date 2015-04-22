//
//  PageEditCollectionViewFlowLayout.m
//  ServiceMaxMobile
//
//  Created by shravya on 08/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageEditCollectionViewFlowLayout.h"

@implementation PageEditCollectionViewFlowLayout


- (void)prepareLayout {
    self.minimumInteritemSpacing = 20;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
        if (nil == attributes.representedElementKind) {
            NSIndexPath* indexPath = attributes.indexPath;
            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    return attributesToReturn;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *currentFrameAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
//    CGSize nextSize = CGSizeZero;
//    
//    NSIndexPath *nextPath =  [NSIndexPath indexPathForItem:(indexPath.item + 1) inSection:indexPath.section];
//    SGDetailViewController *someDataSource = (SGDetailViewController *)self.collectionView.dataSource;
//    
//    UIViewController <UICollectionViewDelegateFlowLayout>*someO = (UIViewController *)self.collectionView.dataSource;
//    
//    if ([someDataSource conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
//        nextSize  =  [someO collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:nextPath];
//    }
//    
    
    CGRect currentFrame =  currentFrameAttributes.frame ;
   
    
//    if (nextSize.width > 400) {
//        currentFrame.origin.x = 10.0;
//    }
    
    if (currentFrame.origin.x > 50 && currentFrame.origin.x < 320) {
            currentFrame.origin.x = 0.0;
    }
    else if (currentFrame.origin.x > 10 && currentFrame.origin.x < 50){
          currentFrame.origin.x = 0.0;
    }
    currentFrameAttributes.frame = currentFrame;
    return currentFrameAttributes;
}


@end
