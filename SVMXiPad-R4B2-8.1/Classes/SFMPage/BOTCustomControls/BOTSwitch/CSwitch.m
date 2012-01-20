//
//  CSwitch.m
//  CustomClassesipad
//
//  Created by Developer on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CSwitch.h"

#define SWITCH_WIDTH     94

#define SWITCH_HEIGHT    27


@implementation CSwitch
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize controlDelegate;
@synthesize control_type;
@synthesize valueChanged;

-(id)initWithFrame:(CGRect)frame
{
   // frame.size.width=SWITCH_WIDTH;
    //frame.size.height= SWITCH_HEIGHT;
    self=[super initWithFrame:frame];
    if(self)
    {
        //[self sendActionsForControlEvents:UIControlEventValueChanged];
        //UIControl * control;
        //[self sendAction:@selector(method:) to:self forEvent:[UIControl UIControlEventValueChanged]];
        [self addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        //[self sendAction:@selector() to:self  ];
        
    }
    
    return self;
}

-(BOOL) getSelected
{
    return self.selected;
}


-(id)initAtPoint:(CGPoint)point
{
    return self;
}

-(void)dealloc
{
    [super dealloc];
}
-(void)switchValueChanged:(id)sender
{
    [controlDelegate controlIndexPath:indexPath];
    
    valueChanged = TRUE;
    NSString * value ;
    if(self.on)
    {
        value = @"True";
    }
    else
    {
        value = @"False";
    }
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:value fieldKeyValue:value controlType:self.control_type];
}
@end
