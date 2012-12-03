//
//  TapImage.h
//
//  Created by Björn Sållarp on 7/14/10.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>

@protocol TapImageDelegate;

@interface TapImage : UIImageView
{
    id <TapImageDelegate> delegate;
    int index;
}

@property (nonatomic, retain) id <TapImageDelegate> delegate;
@property int index;

@end

@protocol TapImageDelegate <NSObject>

@optional
- (void) tappedImageWithIndex:(int)index;

@end