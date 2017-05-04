//
//  TKCalendarMonthView.m
//  Created by Devin Ross on 6/10/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"
#import "TKGlobal.h"
#import "UIImage+TKCategory.h"
#import "NSDate+CalendarGrid.h"
#import "SMXConstants.h"
#import "SMXDateManager.h"
#import "StyleManager.h"
#import "CalendarPopupContent.h"
#import "StyleManager.h"
#import "SMXDateManager.h"
#import "SMXImportantFilesForCalendar.h"
#import "SMXCalendarViewController.h"

#pragma mark -
@interface TKCalendarMonthTiles : UIView {
	id target;
	SEL action;
	int firstOfPrev,lastOfPrev;
	NSArray *marks;
	int today;
	BOOL markWasOnToday;
	int selectedDay,selectedPortion;
	int firstWeekday, daysInMonth;
	BOOL startOnSunday;
    BOOL forIpad;
    int _monthIndex;
    int _yearIndex;
}
@property(nonatomic) float tileHeight;
@property (strong,nonatomic) NSDate *monthDate;
@property (nonatomic, strong) NSMutableArray *accessibleElements;
@property (nonatomic,assign) int monthIndex;
@property (nonatomic,assign) int yearIndex;

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday;
- (void) setTarget:(id)target action:(SEL)action;

- (void) selectDay:(int)day;
- (NSDate*) dateSelected;

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday;


@property (strong,nonatomic) UIImageView *selectedImageView;
@property (strong,nonatomic) UILabel *currentDay;
@property (strong,nonatomic) UILabel *dot;
@property (nonatomic,strong) NSArray *datesArray;

@end


#pragma mark -
@implementation TKCalendarMonthTiles
@synthesize tileHeight;
static int yearIndex;
static int monthIndex;
static UIImage *imageCircleOrange;

#define dotFontSize 18.0
#define dateFontSize 22.0
#define iPadDotFontSize  20.0
#define iPadDateFontSize 18.0
#define iPadSelectedDateCircleDiameter 38.

#pragma mark Accessibility Container methods
- (BOOL) isAccessibilityElement{
    return NO;
}
- (NSArray *) accessibleElements{
    if (_accessibleElements!=nil) return _accessibleElements;
    
    _accessibleElements = [[NSMutableArray alloc] init];
	
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateStyle:NSDateFormatterFullStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDate *firstDate = [self.datesArray objectAtIndex:0];
    forIpad=(([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) && (EnableLargeCalendarForIpad==YES))? YES:NO;
	for(int i=0;i<marks.count;i++){
		UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
		
		NSDate *day = [NSDate dateWithTimeIntervalSinceReferenceDate:[firstDate timeIntervalSinceReferenceDate]+(24*60*60*i)+5];
		element.accessibilityLabel = [formatter stringForObjectValue:day];
		CGRect r = [self convertRect:[self rectForCellAtIndex:i] toView:self.window];
        if(forIpad)
        {
            r.origin.y -= [CalendarPopupContent getTileHeightAdjustment];
		}
        else
        {
            r.origin.y -= 6;
        }
		element.accessibilityFrame = r;
		element.accessibilityTraits = UIAccessibilityTraitButton;
		element.accessibilityValue = [[marks objectAtIndex:i] boolValue] ? @"Has Events" : @"No Events";
		[_accessibleElements addObject:element];
		
	}
	
	
	
    return _accessibleElements;
}
- (NSInteger) accessibilityElementCount{
    return [[self accessibleElements] count];
}
- (id) accessibilityElementAtIndex:(NSInteger)index{
    return [[self accessibleElements] objectAtIndex:index];
}
- (NSInteger) indexOfAccessibilityElement:(id)element{
    return [[self accessibleElements] indexOfObject:element];
}



#pragma mark Init Methods
+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday{
	NSDate *firstDate, *lastDate;
	
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.day = 1;
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
    [CalendarPopupContent setCurrentMonth:info.month];
    [CalendarPopupContent setCurrentYear:info.year];
    yearIndex=info.year;
    monthIndex=info.month;
	
	NSDate *currentMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info = [currentMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	
	NSDate *previousMonth = [currentMonth previousMonth];
	NSDate *nextMonth = [currentMonth nextMonth];
	
	if(info.weekday > 1 && sunday){
		
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		int preDayCnt = (int)[previousMonth daysBetweenDate:currentMonth];
		info2.day = preDayCnt - info.weekday + 2;
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		
	}else if(!sunday && info.weekday != 2){
		
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		int preDayCnt = (int)[previousMonth daysBetweenDate:currentMonth];
		if(info.weekday==1){
			info2.day = preDayCnt - 5;
		}else{
			info2.day = preDayCnt - info.weekday + 3;
		}
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		
		
	}else{
		firstDate = currentMonth;
	}
	
	
	
	int daysInMonth = (int)[currentMonth daysBetweenDate:nextMonth];
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	TKDateInformation lastDateInfo = [lastInMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
	
	
	if(lastDateInfo.weekday < 7 && sunday){
		
		lastDateInfo.day = 7 - lastDateInfo.weekday;
		lastDateInfo.month++;
		lastDateInfo.weekday = 0;
		if(lastDateInfo.month>12){
			lastDateInfo.month = 1;
			lastDateInfo.year++;
		}
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
	}else if(!sunday && lastDateInfo.weekday != 1){
		
		
		lastDateInfo.day = 8 - lastDateInfo.weekday;
		lastDateInfo.month++;
		if(lastDateInfo.month>12){ lastDateInfo.month = 1; lastDateInfo.year++; }
        
		
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
	}else{
		lastDate = lastInMonth;
	}
	
	
	
	return [NSArray arrayWithObjects:firstDate,lastDate,nil];
}
-(NSArray *)selectedWeekCheck:(NSArray *)arrey{
    for(int i=0; i<[arrey count];i++){
    }
    return arrey;
}
- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday{
    self.backgroundColor = [UIColor magentaColor];//anish

	if(!(self=[super initWithFrame:CGRectZero])) return nil;
    forIpad=(([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) && (EnableLargeCalendarForIpad==YES)) ? YES:NO;
	firstOfPrev = -1;
    marks = [self selectedWeekCheck:markArray];//markArray;
	self.monthDate = date;
	startOnSunday = sunday;
	
	TKDateInformation dateInfo = [_monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	firstWeekday = dateInfo.weekday;
	
	
	NSDate *prev = [_monthDate previousMonth];
	daysInMonth = (int)[[_monthDate nextMonth] daysBetweenDate:_monthDate];
	
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:date startOnSunday:sunday];
	self.datesArray = dates;
	NSUInteger numberOfDaysBetween = [[dates objectAtIndex:0] daysBetweenDate:[dates lastObject]];
	NSUInteger scale = (numberOfDaysBetween / 7) + 1;
	CGFloat h ;
    if(forIpad)
    {
        float maxHeightAllowed=[CalendarPopupContent getCalendarViewHeight]-[CalendarPopupContent getCalendarTopBarHeight];
        tileHeight= maxHeightAllowed/scale;
        h=tileHeight * scale;
    }
    else
    {
        h=44.0f * scale;
    }
	
	TKDateInformation todayInfo = [[NSDate date] dateInformation];
	today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;
	
	int preDayCnt = (int)[prev daysBetweenDate:_monthDate];
	if(firstWeekday>1 && sunday){
		firstOfPrev = preDayCnt - firstWeekday+2;
		lastOfPrev = preDayCnt;
	}else if(!sunday && firstWeekday != 2){
		
		if(firstWeekday ==1){
			firstOfPrev = preDayCnt - 5;
		}else{
			firstOfPrev = preDayCnt - firstWeekday+3;
		}
		lastOfPrev = preDayCnt;
	}
	if(forIpad)
    {
        self.frame = CGRectMake(0, 1.0, [CalendarPopupContent getTileWidth]*7 ,h+1); //CGRectMake(0, 1.0, 640.0f+4.0f+9.0f , (h * 2)+1 );
    }
    else
    {
        self.frame = CGRectMake(0, 1.0, 320.0f, h+1);
    }
	//[self.selectedImageView addSubview:self.currentDay];
	//[self.selectedImageView addSubview:self.dot];
	self.multipleTouchEnabled = NO;
    
    
	return self;
}
- (void) setTarget:(id)t action:(SEL)a{
	target = t;
	action = a;
}


- (CGRect) rectForCellAtIndex:(int)index{
	
	int row = index / 7;
	int col = index % 7;
	if(forIpad)
    {
        return CGRectMake(col*[CalendarPopupContent getTileWidth], row*tileHeight+[CalendarPopupContent getTileHeightAdjustment], [CalendarPopupContent getTileWidth], tileHeight);// CGRectMake(col*92, row*88+29, 94, 90);
    }
    else{
        return CGRectMake(col*46, row*44+6, 47, 45);
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}

- (void) drawTileInRect:(CGRect)r day:(int)day mark:(CalendarMonthTileMark)mark font:(UIFont*)f1 font2:(UIFont*)f2{
	//drawing rect with text
	NSString *str = [NSString stringWithFormat:@"%d",day];
	CGRect rect = r;
	if (mark==AppointmentMarkBlue) {
        UIColor *blueColorMark = [UIColor getUIColorFromHexValue:kOrangeColor];//color: days with events
        UIImage *overlayImage=[self imageWithColor:blueColorMark];
		rect.origin.x += 2;
        if (forIpad) {
            rect.origin.y -= [CalendarPopupContent getTileHeightAdjustment];
            rect.origin.y+=11;
        }
        else
        {
            rect.origin.y -= 6;
        }
        
		rect.size.height -=22;
		rect.size.width += 1;
		[overlayImage drawInRect:rect];
    }else if(mark==SelectedDateOrangeCircle){
        UIImage *overlayImage=[UIImage imageNamed:@"orangeCircle.png"];//[self imageWithColor:blueColorMark];
        rect.origin.x +=(rect.size.width-iPadSelectedDateCircleDiameter)/2;
        if (forIpad) {
            rect.origin.y -= [CalendarPopupContent getTileHeightAdjustment];
            rect.origin.y+=(rect.size.height-iPadSelectedDateCircleDiameter)/2;
        }
        else
        {
            rect.origin.y -= 6;
        }
        
        rect.size.height =iPadSelectedDateCircleDiameter;
        rect.size.width =iPadSelectedDateCircleDiameter;
        [overlayImage drawInRect:rect];
    }
        
    CGSize expectedLabelSize;
    if (forIpad) {
        CGSize maximumSize = CGSizeMake(300, 9999);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        expectedLabelSize = [str sizeWithFont:f1
                            constrainedToSize:maximumSize
                                lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
        r.origin.y -= [CalendarPopupContent getTileHeightAdjustment];
        r.origin.y+=(r.size.height-expectedLabelSize.height)/2;
    }
    else
    {
        r.size.height -= 2;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    [str drawInRect: r
           withFont: f1
      lineBreakMode: NSLineBreakByWordWrapping
          alignment: NSTextAlignmentCenter];
#pragma clang diagnostic pop
    
    //This was creating problem, so i am reverting back
   /* NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    [str drawInRect:r
     withAttributes:@{NSFontAttributeName:f1, NSParagraphStyleAttributeName:paragraphStyle}];*/
    
    if(mark){
        if(forIpad)
        {
            r.size.height = 12;
            r.origin.y += expectedLabelSize.height + 6;
        }
        else
        {
            r.size.height = 10;
            r.origin.y += 18;
            
        }
        //This was creating problem, so i am reverting back
      /*  NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle1.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle1.alignment = NSTextAlignmentCenter;
        
        [@" " drawInRect:r
          withAttributes:@{NSFontAttributeName:f2, NSParagraphStyleAttributeName:paragraphStyle1}];*/
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        [@" " drawInRect: r
                withFont: f2
           lineBreakMode: NSLineBreakByWordWrapping
               alignment: NSTextAlignmentCenter];
#pragma clang diagnostic pop
    }
    
}
//- (void) drawTileInRect:(CGRect)r day:(int)day mark:(CalendarMonthTileMark)mark font:(UIFont*)f1 font2:(UIFont*)f2{
//    //drawing rect with text
//    NSString *str = [NSString stringWithFormat:@"%d",day];
//    CGRect rect = r;
//    if (mark==AppointmentMarkBlue) {
//        UIColor *blueColorMark = [UIColor getUIColorFromHexValue:kOrangeColor];//color: days with events
//        UIImage *overlayImage=[UIImage imageNamed:@"orangeCircle.png"];//[self imageWithColor:blueColorMark];
//        rect.origin.x +=(rect.size.width-iPadSelectedDateCircleDiameter)/2;
//        if (forIpad) {
//            rect.origin.y -= [CalendarPopupContent getTileHeightAdjustment];
//            rect.origin.y+=(rect.size.height-iPadSelectedDateCircleDiameter)/2;
//        }
//        else
//        {
//            rect.origin.y -= 6;
//        }
//        
//        rect.size.height =iPadSelectedDateCircleDiameter;
//        rect.size.width =iPadSelectedDateCircleDiameter;
//        [overlayImage drawInRect:rect];
//    }
//    
//    CGSize expectedLabelSize;
//    if (forIpad) {
//        CGSize maximumSize = CGSizeMake(300, 9999);
//        expectedLabelSize = [str sizeWithFont:f1
//                            constrainedToSize:maximumSize
//                                lineBreakMode:NSLineBreakByWordWrapping];
//        r.origin.y -= [CalendarPopupContent getTileHeightAdjustment];
//        r.origin.y+=(r.size.height-expectedLabelSize.height)/2;
//    }
//    else
//    {
//        r.size.height -= 2;
//    }
//    [str drawInRect: r
//           withFont: f1
//      lineBreakMode: NSLineBreakByWordWrapping
//          alignment: NSTextAlignmentCenter];
//    
//    if(mark){
//        if(forIpad)
//        {
//            r.size.height = 12;
//            r.origin.y += expectedLabelSize.height + 6;
//        }
//        else
//        {
//            r.size.height = 10;
//            r.origin.y += 18;
//            
//        }
//        [@" " drawInRect: r
//                withFont: f2
//           lineBreakMode: NSLineBreakByWordWrapping
//               alignment: NSTextAlignmentCenter];
//    }
//    
//}

- (void) drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    NSDate *currentDate =[[SMXDateManager sharedManager] currentDate];
    NSDateComponents *components = [NSDate componentsOfDate:currentDate];
    int firstDayOfTheWeek=[self getFirstDayOfTheWeek:(int)[components day] indexInWeek:(int)components.weekday];
    int LastDayOfTheWeek=[self getLastDayOfTheWeek:(int)[components day] indexInWeek:(int)components.weekday];
    BOOL isCurrentMonth=[self IsSelectedMonth:(int)components.month Year:(int)components.year];
	UIImage *tile = [self imageWithColor:[CalendarPopupContent getColor]];//<#(UIColor *)#>:TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/Month Calendar Date Tile.png")];
	CGRect r;
    if (forIpad) {
        r = CGRectMake(0, 0, [CalendarPopupContent getTileWidth], tileHeight);
    }
    else
    {
        r = CGRectMake(0, 0, 46, 44);
    }
	CGContextDrawTiledImage(context, r, tile.CGImage);
	
	if(today > 0){
		int pre = firstOfPrev > 0 ? lastOfPrev - firstOfPrev + 1 : 0;
		int index = today +  pre-1;
		CGRect r =[self rectForCellAtIndex:index];
        if (forIpad) {
            r.origin.y -= [CalendarPopupContent getTileHeightAdjustment];
        }
        else
        {
            r.origin.y -= 7;
        }
        
		[[UIImage imageWithContentsOfFile:(@"ServiceMaxMobile/Classes/Calendar/Month Calendar Today Tile.png")] drawInRect:r];
	}
	
	int index = 0;
	
	UIFont *font;
    UIFont *font2;
    if (forIpad) {
        font= [UIFont boldSystemFontOfSize:iPadDateFontSize];
        font2=[UIFont boldSystemFontOfSize:iPadDotFontSize];
    }
    else
    {
        font= [UIFont boldSystemFontOfSize:dateFontSize];
        font2=[UIFont boldSystemFontOfSize:dotFontSize];
    }
    
	UIColor *color = [UIColor clearColor];//pre month text color
	if(firstOfPrev>0){
		[color set];
		for(int i = firstOfPrev;i<= lastOfPrev;i++){
			r = [self rectForCellAtIndex:index];
			if ([marks count] > 0)
				[self drawTileInRect:r day:i mark:0 font:font font2:font2];
			else
				[self drawTileInRect:r day:i mark:NoAppointmentMark font:font font2:font2];
			index++;
		}
	}
	
	
	color = [UIColor blackColor];//[UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];//current month
	[color set];
	for(int i=1; i <= daysInMonth; i++){
        if (index % 7 == 0) {
            [[UIColor grayColor] set];
        }else if(index % 7 == 6){
            [[UIColor grayColor] set];
        }else{
            [[UIColor blackColor] set];
        }
		r = [self rectForCellAtIndex:index];
		if(today == i) [[UIColor orangeColor] set];
		
        if (![CalendarPopupContent getDayPopup]){
            if (isCurrentMonth) {
                if ([self selectedWeek:firstDayOfTheWeek IsCurrentWeek:i endDay:LastDayOfTheWeek] && [CalendarPopupContent getWeekIsActive]) {
                    [[UIColor whiteColor] set];
                    [self drawTileInRect:r day:i mark:1 font:font font2:font2];
                }else{
                    [self drawTileInRect:r day:i mark:0 font:font font2:font2];
                }
            }
            else{
                [self drawTileInRect:r day:i mark:0 font:font font2:font2];
            }
        }
        else{
            if ([components day]==i && isCurrentMonth) {
                [[UIColor whiteColor] set];
                [self drawTileInRect:r day:i mark:SelectedDateOrangeCircle font:font font2:font2];
            }else{
                [self drawTileInRect:r day:i mark:NoAppointmentMark font:font font2:font2];
            }
        }
		if(today == i) [color set];
		index++;
	}
	
	[[UIColor clearColor] set];//next month text color
	int i = 1;
	while(index % 7 != 0){
		r = [self rectForCellAtIndex:index] ;
		if ([marks count] > 0)
			[self drawTileInRect:r day:i mark:0 font:font font2:font2];
		else
			[self drawTileInRect:r day:i mark:NoAppointmentMark font:font font2:font2];
		i++;
		index++;
	}
}
-(BOOL )IsSelectedMonth:(int)month Year:(int)year{
    if ([CalendarPopupContent getCurrentYear]==year && [CalendarPopupContent getCurrentMonth]==month) {
        return TRUE;
    }
    return FALSE;
}
-(int )getFirstDayOfTheWeek:(int)CurrentDay indexInWeek:(int)index{
    int i=CurrentDay-(index-1);
    if (i<=0) {
        return 1;
    }
    return i;
}
-(int )getLastDayOfTheWeek:(int)CurrentDay indexInWeek:(int)index{
    int i=CurrentDay+(7-index);
    if (i>=daysInMonth) {
        return daysInMonth;
    }
    return i;
}
-(BOOL )selectedWeek:(int )fifstDay IsCurrentWeek:(int )currentDay endDay:(int)endday{
    if (currentDay>=fifstDay && currentDay<=endday) {
        return TRUE;
    }
    return FALSE;
}
- (void) selectDay:(int)day{
	
	int pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
	int tot = day + pre;
	int row = tot / 7;
	int column = (tot % 7)-1;
	selectedDay = day;
	selectedPortion = 1;
	if(day == today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image =[self imageWithColor:[UIColor clearColor]]; //[UIImage imageWithContentsOfFile:TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/calendar/Month Calendar Today Selected Tile.png")];
		markWasOnToday = YES;
	}else if(markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		NSString *path = TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/Month Calendar Date Tile Selected.png");
		self.selectedImageView.image = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		markWasOnToday = NO;
	}
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
	
//	if ([marks count] > 0) {
//		
//		if([[marks objectAtIndex: row * 7 + column ] boolValue]){
//			//[self.selectedImageView addSubview:self.dot];
//		}else{
//			//[self.dot removeFromSuperview];
//		}
//		
//	}else{
//		//[self.dot removeFromSuperview];
//	}
	if(column < 0){
		column = 6;
		row--;
	}
	CGRect r = self.selectedImageView.frame;
    if (forIpad) {
        r.origin.x = (column*[CalendarPopupContent getTileWidth]);
        r.origin.y = (row*tileHeight)-1;
    }
    else
    {
        r.origin.x = (column*46);
        r.origin.y = (row*44)-1;
    }
	self.selectedImageView.frame = r;
    //self.selectedImageView.image =[self imageWithColor:[UIColor orangeColor]];
}

-(void)setMonthDate:(NSDate *)inMonthDate
{
    _monthDate = inMonthDate;
}
- (NSDate*) dateSelected{
	if(selectedDay < 1 || selectedPortion != 1) return nil;
    
	TKDateInformation info = [_monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
   // TKDateInformation info = [_monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	info.day = selectedDay;
	NSDate *d = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
    
	
	return d;
	
}


- (void) reactToTouch:(UITouch*)touch down:(BOOL)down{
	
	CGPoint p = [touch locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0 || p.x < 0 || p.x > self.bounds.size.width) return;
	
	int column,row;
    if (forIpad) {
        column= p.x / [CalendarPopupContent getTileWidth], row = p.y / tileHeight;
    }
    else
    {
        column = p.x / 46, row = p.y / 44;
    }
	int day = 1, portion = 0;
	if (forIpad) {
        if(row == (int) (self.bounds.size.height / tileHeight)) row --;
	}
    else
    {
        if(row == (int) (self.bounds.size.height / 44)) row --;
    }
	int fir = firstWeekday - 1;
	if(!startOnSunday && fir == 0) fir = 7;
	if(!startOnSunday) fir--;
	
	if(row==0 && column < fir){
		day = firstOfPrev + column;
	}else{
		portion = 1;
		day = row * 7 + column  - firstWeekday+2;
		if(!startOnSunday) day++;
		if(!startOnSunday && fir==6) day -= 7;
        
	}
	if(portion > 0 && day > daysInMonth){
		portion = 2;
		day = day - daysInMonth;
	}
	
	
	if(portion != 1){
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/calendar/Month Calendar Date Tile Gray.png")];
		markWasOnToday = YES;
	}else if(portion==1 && day == today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
        /*This change for current date and selected date point*/
		//self.selectedImageView.image = [self imageWithColor:[UIColor greenColor]];//[UIImage imageWithContentsOfFile:TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/Month Calendar Today Selected Tile.png")];
		markWasOnToday = YES;
	}else if(markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		NSString *path = TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/Month Calendar Date Tile Selected.png");
		self.selectedImageView.image = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
	
	if ([marks count] > 0) {
		if([[marks objectAtIndex: row * 7 + column] boolValue]){
            //[self.selectedImageView addSubview:self.dot];
        }
        else{
            //[self.dot removeFromSuperview];
        }
	}else{
		//[self.dot removeFromSuperview];
	}
	
    
	
	
	CGRect r = self.selectedImageView.frame;
    if (forIpad) {
     	r.origin.x = (column*[CalendarPopupContent getTileWidth])+1;
        r.origin.y = (row*tileHeight)-1;
    }
    else
    {
        r.origin.x = (column*46);
        r.origin.y = (row*44)-1;
    }
	self.selectedImageView.frame = r;
    if(day == selectedDay && selectedPortion == portion){
        selectedDay = day;
        selectedPortion = portion;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:action withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]];
#pragma clang diagnostic pop
        
    }else{
        if(portion == 1 ){
            selectedDay = day;
            selectedPortion = portion;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:action withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]];
#pragma clang diagnostic pop
        }else if(down){
            /*  here i am disabling next and pre month cell in current calender popup*/
            //[target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil]];
            //selectedDay = day;
            //selectedPortion = portion;
        }
    }
	
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	//[super touchesBegan:touches withEvent:event];
	[self reactToTouch:[touches anyObject] down:NO];
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:NO];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:YES];
}

- (UILabel *) currentDay{
	if(_currentDay==nil){
		CGRect r = self.selectedImageView.bounds;
		r.origin.y -= 2;
		_currentDay = [[UILabel alloc] initWithFrame:r];
		_currentDay.text = @"1";
		_currentDay.textColor = [UIColor whiteColor];
		_currentDay.backgroundColor = [UIColor orangeColor];//color: selected day cell background color
		_currentDay.font = [UIFont boldSystemFontOfSize:dateFontSize];
		_currentDay.textAlignment = NSTextAlignmentCenter;
		_currentDay.shadowColor = [UIColor darkGrayColor];
		_currentDay.shadowOffset = CGSizeMake(0, -1);
	}
	return _currentDay;
}
- (UILabel *) dot{
	if(_dot==nil){
		CGRect r = self.selectedImageView.bounds;
        if (forIpad) {
            r.origin.y += (r.size.height/2)+25;
            r.size.height = 12;
        }
        else
        {
            r.origin.y += 29;
            r.size.height -= 31;
        }
		_dot = [[UILabel alloc] initWithFrame:r];
		_dot.text = @"abcd";
		_dot.textColor = [UIColor whiteColor];
		_dot.backgroundColor = [UIColor clearColor];
		_dot.font = [UIFont boldSystemFontOfSize:dotFontSize];
		_dot.textAlignment = NSTextAlignmentCenter;
		_dot.shadowColor = [UIColor clearColor];
		_dot.shadowOffset = CGSizeMake(0, -1);
	}
    _dot.hidden=YES;
	return _dot;
}
- (UIImageView *) selectedImageView{
	if(_selectedImageView==nil){
		NSString *path = TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/Month Calendar Date Tile Selected.png");
		UIImage *img = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		_selectedImageView = [[UIImageView alloc] initWithImage:img];
        if (forIpad) {
            _selectedImageView.frame = CGRectMake(0, 0, [CalendarPopupContent getTileWidth], tileHeight);
        }
        else
        {
            _selectedImageView.frame = CGRectMake(0, 0, 47, 45);
        }
	}
	return _selectedImageView;
}

@end



#pragma mark -
@interface TKCalendarMonthView ()
@property (strong,nonatomic) UIView *tileBox;
@property (strong,nonatomic) UIImageView *topBackground;
@property (strong,nonatomic) UILabel *monthYear;
@property (strong,nonatomic) UIButton *leftArrow;
@property (strong,nonatomic) UIButton *rightArrow;
@property (strong,nonatomic) UIImageView *shadow;
@property (nonatomic,assign) int monthIndex;
@end

#pragma mark -
@implementation TKCalendarMonthView


- (id) init{
	self = [self initWithSundayAsFirst:YES];
	return self;
}
- (id) initWithSundayAsFirst:(BOOL)s{
	if (!(self = [super initWithFrame:CGRectZero])) return nil;
	self.backgroundColor = [CalendarPopupContent getColor];//[UIColor [CalendarPopupContent]];//color: the complete month view. all other views are child view of this
	sunday = s;
    forIpad= (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) && (EnableLargeCalendarForIpad==YES))? YES :NO;
	currentTile = [[TKCalendarMonthTiles alloc] initWithMonth:[[NSDate date] firstOfMonth] marks:nil startDayOnSunday:sunday];
	[currentTile setTarget:self action:@selector(tile:)];
	tileHeight=[currentTile tileHeight];
	CGRect r;
    if (forIpad) {
        r= CGRectMake(0, 0, self.tileBox.bounds.size.width+4, self.tileBox.bounds.size.height + self.tileBox.frame.origin.y);
    }
    else
    {
        r= CGRectMake(0, 0, self.tileBox.bounds.size.width, self.tileBox.bounds.size.height + self.tileBox.frame.origin.y);
    }
    
	self.frame = r;
	
	[self addSubview:self.topBackground];
	self.topBackground.frame = CGRectMake(0, 0, self.bounds.size.width, [CalendarPopupContent getCalendarTopBarHeight]);
	[self.tileBox addSubview:currentTile];
	[self addSubview:self.tileBox];
	
	NSDate *date = [NSDate date];
	self.monthYear.text = [date monthYearString];
	[self addSubview:self.monthYear];
	
	
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
	[self addSubview:self.shadow];
	self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.bounds.size.width, self.shadow.frame.size.height);
	
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"eee"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    dateFormat.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	
	TKDateInformation sund;
	sund.day = 5;
	sund.month = 12;
	sund.year = 2010;
	sund.hour = 0;
	sund.minute = 0;
	sund.second = 0;
	sund.weekday = 0;
	
	
	NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
	NSString * sun = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 6;
	NSString *mon = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 7;
	NSString *tue = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 8;
	NSString *wed = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 9;
	NSString *thu = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 10;
	NSString *fri = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 11;
	NSString *sat = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	NSArray *ar;
	if(sunday) ar = [NSArray arrayWithObjects:sun,mon,tue,wed,thu,fri,sat,nil];
	else ar = [NSArray arrayWithObjects:mon,tue,wed,thu,fri,sat,sun,nil];
	
	int i = 0;
	for(NSString *s in ar){
		UILabel *label ;
        if (forIpad) {
            label= [[UILabel alloc] initWithFrame:CGRectMake([CalendarPopupContent getTileWidth] * i, 62, [CalendarPopupContent getTileWidth], 15)];
        }
        else
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(46 * i, 29, 46, 15)];
        }
        
		[self addSubview:label];
        
        //Added Accessibility Labels
        if ([s isEqualToString:@"Sun"]) {
            label.accessibilityLabel = @"Sunday";
            label.text = [[TagManager sharedInstance]tagByName:kTag_s];
            label.textColor = [UIColor grayColor];
        } else if ([s isEqualToString:@"Mon"]) {
            label.accessibilityLabel = @"Monday";
            label.text = [[TagManager sharedInstance]tagByName:kTag_m];
            label.textColor = [UIColor blackColor];
        } else if ([s isEqualToString:@"Tue"]) {
            label.accessibilityLabel = @"Tuesday";
            label.text = [[TagManager sharedInstance]tagByName:kTag_t];
            label.textColor = [UIColor blackColor];
        } else if ([s isEqualToString:@"Wed"]) {
            label.accessibilityLabel = @"Wednesday";
            label.text = [[TagManager sharedInstance]tagByName:kTag_w];
            label.textColor = [UIColor blackColor];
        } else if ([s isEqualToString:@"Thu"]) {
            label.accessibilityLabel = @"Thursday";
            label.text = [[TagManager sharedInstance]tagByName:kTag_thur];
            label.textColor = [UIColor blackColor];
        } else if ([s isEqualToString:@"Fri"]) {
            label.accessibilityLabel = @"Friday";
            label.text = [[TagManager sharedInstance]tagByName:kTag_f];
            label.textColor = [UIColor blackColor];
        } else if ([s isEqualToString:@"Sat"]) {
            label.accessibilityLabel = @"Saturday";
            label.text = [[TagManager sharedInstance]tagByName:kTag_sat];
            label.textColor = [UIColor grayColor];
        }
        
		label.textAlignment = NSTextAlignmentCenter;
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0, 1);
        if (forIpad) {
            label.font = [UIFont systemFontOfSize:18];
        }
        else
        {
            label.font = [UIFont systemFontOfSize:11];
        }
		label.backgroundColor = [CalendarPopupContent getColor];//[UIColor whiteColor];//color: week name background color
       // label.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
		i++;
	}
	
	return self;
}


- (NSDate*) dateForMonthChange:(UIView*)sender {
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
	//NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	NSDate *dateFirstDayOfMonth = [NSDate dateWithYear:nextInfo.year month:(nextInfo.month) day:nextInfo.day];
	return dateFirstDayOfMonth;
}

- (void) changeMonthAnimation:(UIView*)sender{
	
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
    if (![CalendarPopupContent getDayPopup]) {
        if (![CalendarPopupContent getWeekIsActive]) {
            /*here it was refreshing two time, so from this place i don't want to upde local date*/
            //[[SMXDateManager sharedManager] setCurrentDate:nextMonth];
           // [[NSNotificationCenter defaultCenter] postNotificationName:DATE_MONTH_TEXT_NOTIFICATION object:nextMonth];
        }
    }
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:sunday];
	NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:nextMonth marks:ar startDayOnSunday:sunday];
	[newTile setTarget:self action:@selector(tile:)];
	int overlap =  0;
	
	if(isNext){
        if (forIpad) {
            overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : tileHeight;
        }
        else
        {
            overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : 44;
        }
		
	}else{
        if (forIpad) {
            overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? tileHeight : 0;
        }
        else
        {
            overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? 44 : 0;
        }
	}
	
	float y = isNext ? currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap +2;
	
	newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
	newTile.alpha = 0;
	[self.tileBox addSubview:newTile];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];
	newTile.alpha = 1;
	[UIView commitAnimations];
	self.userInteractionEnabled = NO;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationEnded)];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.4];
	
	if(isNext){
		
		currentTile.frame = CGRectMake(0, -1 * currentTile.bounds.size.height + overlap + 2, currentTile.frame.size.width, currentTile.frame.size.height);
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
	}else{
		
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, currentTile.frame.size.width, currentTile.frame.size.height);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
	}
	[UIView commitAnimations];
	oldTile = currentTile;
	currentTile = newTile;
	_monthYear.text = [localNextMonth monthYearString];
}
- (void) changeMonth:(UIButton *)sender{
	
	NSDate *newDate = [self dateForMonthChange:sender];
    //month yesr chage from here
    if (![CalendarPopupContent getDayPopup]) {
        if (![CalendarPopupContent getWeekIsActive]) {
            [[SMXDateManager sharedManager] setCurrentDate:newDate];
            //[[NSNotificationCenter defaultCenter] postNotificationName:DATE_MONTH_TEXT_NOTIFICATION object:newDate];
            [[SMXCalendarViewController sharedInstance] leftButtonTextChangeOnDateChange:newDate];
        }
    }
	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:newDate animated:YES] )
		return;
	
	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
		[self.delegate calendarMonthView:self monthWillChange:newDate animated:YES];

	[self changeMonthAnimation:sender];
	if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
		[self.delegate calendarMonthView:self monthDidChange:currentTile.monthDate animated:YES];
    
}
- (void) animationEnded{
	self.userInteractionEnabled = YES;
	[oldTile removeFromSuperview];
	oldTile = nil;
}

- (NSDate*) dateSelected{
	return [currentTile dateSelected];
}
- (NSDate*) monthDate{
	return [currentTile monthDate];
}

-(NSDate *)returnMiddleDay:(NSDate *)date
{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    
    [comps setDay:15];

    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorian dateFromComponents:comps];
    
}

- (void) selectDate:(NSDate*)date{
    //selected Date month's view
	//TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSDate *month = [[self returnMiddleDay:date] firstOfMonth];
    if([month isEqualToDate:[currentTile monthDate]]){
		[currentTile selectDay:info.day];
		return;
	}else {
		
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:month animated:YES] )
			return;
		
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
			[self.delegate calendarMonthView:self monthWillChange:month animated:YES];
		
		
		NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:sunday];
		NSArray *data = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
		TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:month
																			  marks:data
																   startDayOnSunday:sunday];
		[newTile setTarget:self action:@selector(tile:)];
		[currentTile removeFromSuperview];
		currentTile = newTile;
		[self.tileBox addSubview:currentTile];
        if (forIpad) {
            self.tileBox.frame = CGRectMake(0, [CalendarPopupContent getCalendarTopBarHeight], newTile.frame.size.width, newTile.frame.size.height);
        }
        else
        {
            self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);
        }

		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
        
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		self.monthYear.text = [date monthYearString];
		[currentTile selectDay:info.day];
		currentTile.backgroundColor=[UIColor brownColor];//anish
		if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[self.delegate calendarMonthView:self monthDidChange:date animated:NO];
		
		
	}
}
- (void) reload{
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[currentTile monthDate] startOnSunday:sunday];
	NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	
	TKCalendarMonthTiles *refresh = [[TKCalendarMonthTiles alloc] initWithMonth:[currentTile monthDate] marks:ar startDayOnSunday:sunday];
	[refresh setTarget:self action:@selector(tile:)];
	
	[self.tileBox addSubview:refresh];
	[currentTile removeFromSuperview];
	currentTile = refresh;
	
}

- (void) tile:(NSArray*)ar{
	
	if([ar count] < 2){
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[self.delegate calendarMonthView:self didSelectDate:[self dateSelected]];
        
	}else{
		
		int direction = [[ar lastObject] intValue];
		UIButton *b = direction > 1 ? self.rightArrow : self.leftArrow;
		
		NSDate* newMonth = [self dateForMonthChange:b];
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:newMonth animated:YES])
			return;
		
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)])
			[self.delegate calendarMonthView:self monthWillChange:newMonth animated:YES];
		
		
		
		[self changeMonthAnimation:b];
		
		int day = [[ar objectAtIndex:0] intValue];
        
        
		// thanks rafael
		TKDateInformation info = [[currentTile monthDate] dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		info.day = day;
        
        NSDate *dateForMonth = [NSDate dateFromDateInformation:info  timeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
		[currentTile selectDay:day];
		
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[self.delegate calendarMonthView:self didSelectDate:dateForMonth];
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[self.delegate calendarMonthView:self monthDidChange:dateForMonth animated:YES];
        
		
	}
	
}

#pragma mark Properties
- (UIImageView *) topBackground{
	if(_topBackground==nil){
		_topBackground = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/Month Grid Top Bar.png")]];
	}
	return _topBackground;
}
- (UILabel *) monthYear{
	if(_monthYear==nil){
        if (forIpad) {
            _monthYear = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 5, self.tileBox.frame.size.width, 38), 40, 6)];
        }
        else
        {
            _monthYear = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, self.tileBox.frame.size.width, 38), 40, 6)];
        }
		_monthYear.textAlignment = NSTextAlignmentCenter;
		_monthYear.backgroundColor = [CalendarPopupContent getColor];//[UIColor whiteColor];//color: month name
		_monthYear.font = [UIFont boldSystemFontOfSize:22];
        _monthYear.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
        [_monthYear setTextColor:[UIColor getUIColorFromHexValue:@"434343"]];
		_monthYear.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	}
	return _monthYear;
}
- (UIButton *) leftArrow{
	if(_leftArrow==nil){
		_leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		_leftArrow.tag = 0;
        _leftArrow.accessibilityLabel = [[TagManager sharedInstance]tagByName:kTag_PreviousMonth];
		[_leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		[_leftArrow setImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cal-left-arrow" ofType:@"png"]] forState:0];
        if (forIpad) {
            _leftArrow.frame = CGRectMake(24, 10, 47, 38);
        }
        else
        {
            _leftArrow.frame = CGRectMake(0, 0, 48, 38);
        }
        
	}
    _leftArrow.backgroundColor=[UIColor clearColor];
     _leftArrow.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 14, 20);
	return _leftArrow;
}
- (UIButton *) rightArrow{
	if(_rightArrow==nil){
		_rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		_rightArrow.tag = 1;
        _rightArrow.accessibilityLabel = [[TagManager sharedInstance]tagByName:kTag_NextMonth];
		[_rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
        if (forIpad) {
            _rightArrow.frame = CGRectMake(self.tileBox.frame.size.width-51, 10, 47, 38);
        }
        else
        {
            _rightArrow.frame = CGRectMake(320-45, 0, 48, 38);
        }
		[_rightArrow setImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cal-right-arrow" ofType:@"png"]] forState:0];
	}
    _rightArrow.backgroundColor=[UIColor clearColor];
    _rightArrow.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 14, 20);
	return _rightArrow;
}
- (UIView *) tileBox{
	if(_tileBox==nil){
        if (forIpad) {
            _tileBox = [[UIView alloc] initWithFrame:CGRectMake(1, [CalendarPopupContent getCalendarTopBarHeight], currentTile.frame.size.width, currentTile.frame.size.height)];
        }
        else
        {
            _tileBox = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, currentTile.frame.size.height)];
        }
		_tileBox.clipsToBounds = YES;
	}
	return _tileBox;
}
- (UIImageView *) shadow{
	if(_shadow==nil){
		_shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"ServiceMaxMobile/Classes/Calendar/Month Calendar Shadow.png")]];
	}
	return _shadow;
}

@end
