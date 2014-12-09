//
//  RelatedViewViewController.m
//  SLookUp
//
//  Created by Chinnababu on 08/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMLookUpDeatilViewController.h"
#import "SFMRecordFieldData.h"
#import "SFNamedSearchComponentModel.h"
#import "StringUtil.h"
#import "SFObjectFieldModel.h"

#define Title_Font @"HelveticaNeue-Light"
#define SubTitle_Font @"HelveticaNeue-Regular"
#define Title_Font_Size 14
#define SubTitle_Font_size 16


@interface SFMLookUpDeatilViewController ()
{
    int yPadding;
    int y ,
    dfltLabelHeight;
}

//@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation SFMLookUpDeatilViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    [self setUplabels];
   // [self.view addSubview:self.scrollView];
    
}
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpView
{
    self.scrollView.scrollEnabled= YES;
    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.contentMode = UIViewContentModeScaleToFill;

}
-(void)setUplabels
{
    dfltLabelHeight = 20;  // will be resized!
    yPadding = 10;
    y = yPadding;
    
    NSDictionary * dataDict =  [self.lookUpObject.dataArray objectAtIndex:self.SelectedIndex];
    
    for (int i = 0; i < [self.lookUpObject.displayFields count]; i++)
    {
        SFNamedSearchComponentModel * model = [self.lookUpObject.displayFields objectAtIndex:i];
        SFObjectFieldModel *  fieldModel = [self.lookUpObject.fieldInfoDict objectForKey:model.fieldName];
        
        SFMRecordFieldData * recordData = [dataDict objectForKey:model.fieldName];
        
        NSString *fieldLabel = fieldModel.label;
        NSString *fieldValue = recordData.displayValue;
        if([StringUtil isStringEmpty:fieldValue]){
            fieldValue = @"-";
        }
        
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(15, y,
                                                                         280, dfltLabelHeight)];
        titleLabel .lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.text= fieldLabel;
        titleLabel.autoresizesSubviews = YES;  // doesn't matter here
        titleLabel.numberOfLines = 0;
        titleLabel.font=[UIFont fontWithName:Title_Font size:Title_Font_Size];
        
        [titleLabel  sizeToFit];
        
        CGRect frame = titleLabel.frame;
        titleLabel.frame = frame;
        y +=  titleLabel.frame.size.height ;
        
        UILabel* subTitleLabel = [[UILabel alloc] initWithFrame: CGRectMake(15, y,
                                                                            280, dfltLabelHeight)];
        subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subTitleLabel.text=fieldValue;
        subTitleLabel.autoresizesSubviews = YES;  // doesn't matter here
        subTitleLabel.numberOfLines = 0;
        subTitleLabel.font=[UIFont fontWithName:SubTitle_Font size:SubTitle_Font_size];
        [subTitleLabel sizeToFit];
        
        [self.scrollView addSubview:titleLabel];
        [self.scrollView addSubview:subTitleLabel];
        
        frame = subTitleLabel.frame;
        subTitleLabel.frame = frame;
        y += yPadding + subTitleLabel.frame.size.height ;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width-10, y+40);
    

}

@end
