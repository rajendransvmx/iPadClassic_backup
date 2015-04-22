//
//  SMXMonthCalendarView.m
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


#import "SMXMonthCalendarView.h"

#import "SMXMonthCollectionView.h"
#import "SMXMonthHeaderView.h"
#import "SMXImportantFilesForCalendar.h"
#import "StyleManager.h"

@interface SMXMonthCalendarView () <SMXMonthCollectionViewProtocol>
@property (nonatomic, strong) SMXMonthCollectionView *collectionViewMonth;
@end

@implementation SMXMonthCalendarView

#pragma mark - Synthesize

@synthesize dictEvents;
@synthesize collectionViewMonth;
@synthesize protocol;
@synthesize grayBorder;
@synthesize whiteBorder;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dateChanged:) name:DATE_MANAGER_DATE_CHANGED object:nil];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        SMXMonthHeaderView *view = [[SMXMonthHeaderView alloc] initWithFrame:CGRectMake(0., 0., self.frame.size.width, HEADER_HEIGHT_MONTH)];
        [self addSubview:view];
        
        collectionViewMonth = [[SMXMonthCollectionView alloc] initWithFrame:CGRectMake(0.,HEADER_HEIGHT_MONTH, self.frame.size.width, self.frame.size.height-(HEADER_HEIGHT_MONTH)) collectionViewLayout:[UICollectionViewLayout new]];
        [collectionViewMonth setProtocol:self];
        
        [self addSubview:collectionViewMonth];
        
        [collectionViewMonth scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        
        //on calender cell tap, Scrolleview's delegate method is calling...so we are setting initial offset value.
        //collectionViewMonth.lastContentOffset=collectionViewMonth.contentOffset.y;
        [self setAutoresizingMask: AR_WIDTH_HEIGHT];
        [collectionViewMonth setAutoresizingMask:AR_WIDTH_HEIGHT | AR_TOP_BOTTOM_MONTH];
        [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        //collectionViewMonth.backgroundColor=[UIColor whiteColor];
    }
    [self addSubview:[self grayLine:CGRectMake(0,41,self.frame.size.width, 1)]];
    [self addSubview:[self whiteLine:CGRectMake(0,40,self.frame.size.width, 1)]];
    return self;
}
-(UIImageView *)grayLine:(CGRect )rect{
    grayBorder=[[UIImageView alloc] initWithFrame:rect];
    grayBorder.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
    return grayBorder;
}
-(UIImageView *)whiteLine:(CGRect )rect{
    whiteBorder=[[UIImageView alloc] initWithFrame:rect];
    whiteBorder.backgroundColor=[UIColor whiteColor];
    return whiteBorder;
}
-(void)refreshScreen{
    [collectionViewMonth reloadData];
    //[collectionView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setDictEvents:(NSMutableDictionary *)_dictEvents {
    
    dictEvents = _dictEvents;
    
    [collectionViewMonth setDictEvents:_dictEvents];
    [collectionViewMonth reloadData];
}

#pragma mark - Invalidate Layout

- (void)invalidateLayout {
    [collectionViewMonth.collectionViewLayout invalidateLayout];
    grayBorder.frame= CGRectMake(0,41,self.frame.size.width, 1);
    whiteBorder.frame= CGRectMake(0,40,self.frame.size.width, 1);
    [collectionViewMonth reloadData];
}

#pragma mark - SMXDateManager Notification

- (void)dateChanged:(NSNotification *)not {
    grayBorder.frame= CGRectMake(0,41,self.frame.size.width, 1);
    whiteBorder.frame= CGRectMake(0,40,self.frame.size.width, 1);
    [collectionViewMonth setContentOffset:CGPointMake(0., collectionViewMonth.frame.size.height) animated:NO];
    [collectionViewMonth reloadData];
}

#pragma mark - SMXMonthCollectionView Protocol

- (void)setNewDictionary:(NSDictionary *)dict {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(setNewDictionary:)]) {
        [protocol setNewDictionary:dict];
    }
}


@end
