//
//  CusTextView.m
//  CustomClassesipad
//
//  Created by Developer on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusTextView.h"
#import <QuartzCore/QuartzCore.h>
@implementation CusTextView

@synthesize controlDelegate;
@synthesize readOnly;
@synthesize cusTextView;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize control_type;

-(id) initWithFrame:(CGRect)frame lableValue:(NSString *)lableValue
{
    
    self=[super initWithFrame:frame];
    if(self)
    {
        cusTextView = [[CusTextViewHandler alloc] init];
        cusTextView.delegate = self;
        cusTextView.lableValue = lableValue;
        self.backgroundColor=[UIColor whiteColor];
        self.delegate = cusTextView;
        self.scrollEnabled=TRUE;
        self.autoresizesSubviews=YES;
        self.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        [self.layer setBackgroundColor:[[UIColor whiteColor]CGColor]];
        [self.layer setBorderWidth:1.0];
        [self.layer setBorderColor:[[UIColor grayColor]CGColor]];
        
    }
    return self;
}

- (BOOL) getReadOnly
{
    return readOnly;
}

//Siva Manne #3839
- (void) setRequired:(BOOL)_required 
{
    required = _required;
    if (required)
    {
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"required_textarea.png"]];
        [self addSubview: imgView];
        [self sendSubviewToBack: imgView];
        [imgView release];
    }
}

- (void) setReadOnly:(BOOL)flag
{
    self.editable = !flag;
}

-(void)dealloc
{
    [super dealloc];
}

- (void) setShouldResizeAutomatically:(BOOL)_shouldResizeAutomatically
{
    if (!_shouldResizeAutomatically)
        return;
    
    [self sizeToFit];
    
}

#pragma mark - CusTextViewHandler Delegate
- (void) didChangeText:(NSString *)_text
{  
    NSLog(@"%@ %d", _text, [_text length]);
    
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:_text fieldKeyValue:_text controlType:self.control_type];
}

@end
