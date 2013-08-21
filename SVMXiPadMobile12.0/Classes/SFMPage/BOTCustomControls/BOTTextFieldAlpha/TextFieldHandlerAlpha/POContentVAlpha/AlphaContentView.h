//
//  AlphaContentView.h
//  CustomClassesipad
//
//  Created by Developer on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol setAlphaTextField;
@protocol releasetextFieldAlphaPO;


@interface AlphaContentView : UIViewController <UITextFieldDelegate ,UIPopoverControllerDelegate>
{
    IBOutlet UITextField * poTextField;
    id <setAlphaTextField> cVdelegate;
    id <releasetextFieldAlphaPO> relesePOdelegate;
    IBOutlet UILabel *AlphaLabel;
    
}
@property (nonatomic , assign)  id <releasetextFieldAlphaPO> relesePOdelegate;
@property (nonatomic ,retain)IBOutlet UILabel *AlphaLabel;
@property (nonatomic , assign)  id <setAlphaTextField> cVdelegate;
@property (nonatomic , retain)   IBOutlet UITextField * poTextField;
@end

@protocol setAlphaTextField <NSObject>

@optional
//-(void) settextfieldValue:(NSString *) str;//  Unused Methods

@end

@protocol releasetextFieldAlphaPO <NSObject>

//-(void) releaseTextHandlerPO;//  Unused Methods

@end
