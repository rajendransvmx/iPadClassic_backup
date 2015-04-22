//
//  CustomTabBar.h
//  
//
//

#import <UIKit/UIKit.h>


#import "ViewControllerFactory.h"


@interface CustomTabBar : UITabBarController {
	UIButton *btn1;
	UIButton *btn2;
	UIButton *btn3;
	UIButton *btn4;
    UIButton *btn5;
	UIButton *btn6;
	UIButton *btn7;
	UIButton *btn8;

    
    
}

@property(nonatomic,assign)BOOL isTabClicked;
@property (nonatomic, strong) UIButton *btn1;
@property (nonatomic, strong) UIButton *btn2;
@property (nonatomic, strong) UIButton *btn3;
@property (nonatomic, strong) UIButton *btn4;
@property (nonatomic, strong) UIButton *btn5;
@property (nonatomic, strong) UIButton *btn6;
@property (nonatomic, strong) UIButton *btn7;
@property (nonatomic, strong) UIButton *btn8;

@property (nonatomic, strong) UIView *tabBarView;
@property (nonatomic, strong) UIView *transparentView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;




-(void) hideTabBar;
-(void) addCustomElements;
-(void) selectTab:(NSInteger)tabID;

-(void) hideNewTabBar;
//-(void) ShowNewTabBar;

@end
