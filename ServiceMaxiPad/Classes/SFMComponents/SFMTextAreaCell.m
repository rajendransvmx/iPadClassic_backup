//
//  SFMTextAreaCell.m
//  CollectionSample
//
//  Created by Damodar on 01/10/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMTextAreaCell.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "StringUtil.h"
#import "Utility.h"
#import "TagManager.h"

@implementation SFMTextAreaCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = CellTypeEditableTextField;
        
        
        UITextView *textView = [[UITextView alloc] initWithFrame:frame];
        
        
        textView.delegate = self;
        
        CGRect fr = textView.frame;
        fr.origin.x = 8;
        fr.origin.y = 30;
        fr.size.width = frame.size.width - 16;
        fr.size.height = frame.size.height - fr.origin.y - 8;
        textView.frame = fr;
        
        textView.userInteractionEnabled = YES;
        textView.backgroundColor = [UIColor whiteColor];
        textView.tag = 101;
        textView.text = @"";
        textView.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
        textView.textColor = [UIColor colorFromHexString:kEditableTextFieldColor];
        textView.layer.borderColor = [[UIColor colorFromHexString:kSeperatorLineColor] CGColor];
        textView.layer.cornerRadius = 4;
        textView.layer.borderWidth = 1;
        textView.inputAccessoryView = [self barcodeView];
        
        self.valueField = textView;
        [self addSubview:self.valueField];
    }
    return self;
}

- (void)editTapped:(id)sender
{
    SFMTextAreaCell *textAreaCell = (SFMTextAreaCell*)[(UIButton*)sender superview];
    [self.delegate cellDidTapForIndexPath:textAreaCell.indexPath andSender:sender];
}

- (void)addEditButton:(CGRect)frame
{
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    editButton.tag = 9999;
    
    CGRect fr = editButton.frame;
    fr.size.width = 35;
    fr.size.height = 25;
    fr.origin.x = frame.origin.x + frame.size.width - fr.size.width;
    fr.origin.y = frame.origin.y + frame.size.height - fr.size.height;
    editButton.frame = fr;
    
    editButton.userInteractionEnabled = YES;
    [editButton addTarget:self
                   action:@selector(editTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [editButton setTitleColor:[UIColor colorFromHexString:kOrangeColor] forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor colorFromHexString:kOrangeColor] forState:UIControlStateSelected];
    [editButton setBackgroundColor:[UIColor whiteColor]];
    editButton.opaque = YES;
    self.clipsToBounds = YES;
    
    [editButton setTitle:[[TagManager sharedInstance]tagByName:kTag_edit] forState:UIControlStateNormal];
    editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:editButton];
}

- (void)addImageToGetFadeEffect
{
    UIImage *fadeoutImage = [UIImage imageNamed:@"fadeout"];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width - 40) - fadeoutImage.size.width, self.frame.size.height - 36, fadeoutImage.size.width, fadeoutImage.size.height)];
    imageView.tag = 102;
    imageView.image = [UIImage imageNamed:@"fadeout"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:imageView];
}

- (void)setMoreButtonTitleText:(NSString*)text
{
    [(UIButton*)[self viewWithTag:9999] setTitle:text forState:UIControlStateNormal];
}

- (void)hideMoreButton:(BOOL)hide
{
    [[self viewWithTag:9999] setHidden:hide];
}

- (void)hideFadeImage:(BOOL)hide
{
    [[self viewWithTag:102] setHidden:hide];
}

- (id)value
{
    return [self.valueField text];
}

- (void)setValue:(id)value
{
    [self.valueField setText:(NSString*)value];
    [self handleEditButtonForValue:(NSString*)value];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellEditingBegan:andSender:)])
    {
        [self.delegate cellEditingBegan:self.indexPath andSender:self];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellValue:didChangeForIndexpath:)])
    {
        [self.delegate cellValue:self.value didChangeForIndexpath:self.indexPath];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    BOOL isBackSpace =  [StringUtil isBackSpace:text];
    
    if(isBackSpace)
    {
        return YES;
    }

    if(textView.text.length + text.length > self.lenght)
    {
        return NO;
    }
    else
    {
        return YES;
    }
//    if(range.length +range.location +text.length <= self.lenght)
//     {
//         return YES;
//
//     }
//     else{
//         return NO;
//     }
    
    
}


- (void)layoutSubviews {
    
    [self handleEditButtonForValue:((UITextView*)self.valueField).text];
    [super layoutSubviews];
    [self resetFrame];
}
- (void)resetFrame {
    UITextView *textView = (UITextView *)self.valueField;
    CGRect frame =  textView.frame ;
    frame.size.width = self.frame.size.width - 16;
    textView.frame = frame;
}

- (void)enableTextViewScroll:(BOOL)enable
{
    [(UITextView*) [self viewWithTag:101] setScrollEnabled:enable];
    
}

- (void)setEditableFlagForTextView:(BOOL)editable
{
    [(UITextView*) [self viewWithTag:101] setEditable:editable];
}

- (void)enableTextViewUserInteraction:(BOOL)enable
{
    [(UITextView*) [self viewWithTag:101] setUserInteractionEnabled:enable];
    
}

- (void)handleEditButtonForValue:(NSString*)value
{
    UITextView *textView = (UITextView * )self.valueField;
    CGSize textSize =  [StringUtil getSizeOfText:value withFont:((UITextView * )self.valueField).font andRect:textView.frame];
    
    UIView *view = [self viewWithTag:9999];
    if (view != nil) {
        [view removeFromSuperview];
    }
    
    UIView *viewTwo = [self viewWithTag:102];
    if (viewTwo != nil) {
        [viewTwo removeFromSuperview];
    }
    
    if (textSize.height > 104)
    {
        [self addEditButton:CGRectMake(self.frame.size.width - 40, self.frame.size.height - 39, 30, 30)];
        [self hideMoreButton:NO];
        [self enableTextViewScroll:NO];
        [self setEditableFlagForTextView:NO];
        [self enableTextViewUserInteraction:NO];
        [self addImageToGetFadeEffect];
        [self hideFadeImage:NO];
    } else{
        [self hideMoreButton:YES];
        [self enableTextViewScroll:YES];
        [self setEditableFlagForTextView:YES];
        [self enableTextViewUserInteraction:YES];
        [self hideFadeImage:YES];
    }
}

- (UIView *)barcodeView
{
    if ([Utility isCameraAvailable]) {
        UIView *barCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 46)];
        barCodeView.backgroundColor = [UIColor colorFromHexString:@"B5B7BE"];
        
        CGRect buttonFrame = CGRectMake(0, 6, 72, 32);
        
        UIButton *barCodeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [barCodeButton setBackgroundImage:[UIImage imageNamed:@"barcode.png"] forState:UIControlStateNormal];
        
        CGFloat xPosition = CGRectGetWidth(barCodeView.frame) - 90;
        buttonFrame.origin.x = xPosition;
        
        barCodeButton.frame = buttonFrame;
        
        barCodeButton.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [barCodeButton addTarget:self
                          action:@selector(lauchBarCode)
                forControlEvents:UIControlEventTouchUpInside];
        [barCodeView addSubview:barCodeButton];
        
        return barCodeView;
    }
    return nil;
}

- (void)lauchBarCode
{
    if ([self.delegate respondsToSelector:@selector(launchBarcodeScannerForIndexPath:)]) {
        [self.delegate launchBarcodeScannerForIndexPath:self.indexPath];
    }
}
- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

- (void)setTextFieldDataType:(NSString*)dataType
{
    //self.valueField.keyboardType = [SMXiPad_Utility getKeyBoardTypeForDataType:dataType];
    self.dataType = dataType;
}
- (void)setLengthVariable:(NSInteger)lenght
{
    self.lenght = lenght;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
