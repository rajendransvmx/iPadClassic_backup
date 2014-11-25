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
@property (nonatomic, retain) UIButton *btn1;
@property (nonatomic, retain) UIButton *btn2;
@property (nonatomic, retain) UIButton *btn3;
@property (nonatomic, retain) UIButton *btn4;
@property (nonatomic, retain) UIButton *btn5;
@property (nonatomic, retain) UIButton *btn6;
@property (nonatomic, retain) UIButton *btn7;
@property (nonatomic, retain) UIButton *btn8;

@property (nonatomic, retain) UIView *tabBarView;




-(void) hideTabBar;
-(void) addCustomElements;
-(void) selectTab:(NSInteger)tabID;

-(void) hideNewTabBar;
//-(void) ShowNewTabBar;

@end
