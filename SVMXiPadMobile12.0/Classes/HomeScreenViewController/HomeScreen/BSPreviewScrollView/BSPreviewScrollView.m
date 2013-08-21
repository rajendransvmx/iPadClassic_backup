//
//  BSPreviewScrollView.m
//
//  Created by Björn Sållarp on 7/14/10.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BSPreviewScrollView.h"
#import "iServiceAppDelegate.h"
extern void SVMXLog(NSString *format, ...);

#define SHADOW_HEIGHT 20.0
#define SHADOW_INVERSE_HEIGHT 10.0
#define SHADOW_RATIO (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT)
#define kNoOFModules 9
@implementation BSPreviewScrollView
@synthesize scrollView, pageSize, dropShadow, delegate;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if( ( self = [super initWithCoder:aDecoder] ) )
    {
        //do some initialization
    }
    return self;
}

- (void)awakeFromNib
{
	firstLayout = YES;
	dropShadow = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if(self)
	{
		firstLayout = YES;
		dropShadow = NO;
	}
	
	return self;
}

//  Unused methods
//- (id)initWithFrameAndPageSize:(CGRect)frame pageSize:(CGSize)size 
//{
//    self = [super initWithFrame:frame];
//	if (self) 
//	{
//		self.pageSize = size;
//    }
//    return self;
//}

-(void)loadPage:(int)page
{
	// Sanity checks
    if (page < 0)
    {
        // SMLog(@"page < 0");
        return;
    }
    if (page >= [scrollViewPages count])
    {
        // SMLog(@"page >= maxcount");
        return;
    }
	
	// Check if the page is already loaded
	UIView *view = [scrollViewPages objectAtIndex:page];
	
	// if the view is null we request the view from our delegate
//	if ((NSNull *)view == [NSNull null]) 
//	{
//		view = [delegate viewForItemAtIndex:self index:page]; //  Unused methods
//		[scrollViewPages replaceObjectAtIndex:page withObject:view];
//	}
	
	// add the controller's view to the scroll view	if it's not already added
	if (view.superview == nil) 
	{
		// Position the view in our scrollview
		CGRect viewFrame = view.frame;
		viewFrame.origin.x = viewFrame.size.width * page;
		viewFrame.origin.y = 0;
		
		view.frame = viewFrame;
		
		[self.scrollView addSubview:view];
	}
}

// Shadow code from http://cocoawithlove.com/2009/08/adding-shadow-effects-to-uitableview.html
- (CAGradientLayer *)shadowAsInverse:(BOOL)inverse
{
    CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
    CGRect newShadowFrame =	CGRectMake(0, 0, self.frame.size.width, inverse ? SHADOW_INVERSE_HEIGHT : SHADOW_HEIGHT);
    newShadow.frame = newShadowFrame;
    CGColorRef darkColor =[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:inverse ? (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT) * 0.5 : 0.5].CGColor;
    CGColorRef lightColor =	[self.backgroundColor colorWithAlphaComponent:0.0].CGColor;
    newShadow.colors = [NSArray arrayWithObjects: (id)(inverse ? lightColor : darkColor), (id)(inverse ? darkColor : lightColor), nil];
    return newShadow;
}

- (void)layoutSubviews
{
	// We need to do some setup once the view is visible. This will only be done once.
	@try{
    if(appDelegate.metaSyncCompleted == YES)
    {
        appDelegate.metaSyncCompleted = NO;
        UIView *scrollViewWithTag = [self viewWithTag:100];
        [scrollViewWithTag removeFromSuperview];
        firstLayout = YES;                             
    }
	if(firstLayout)
	{
		// Add drop shadow to add that 3d effect
		if(dropShadow)
		{
			CAGradientLayer *topShadowLayer = [self shadowAsInverse:NO];
			CAGradientLayer *bottomShadowLayer = [self shadowAsInverse:YES];
			[self.layer insertSublayer:topShadowLayer atIndex:0];
			[self.layer insertSublayer:bottomShadowLayer atIndex:0];
			
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			
			// Position and stretch the shadow layers to fit
			CGRect topShadowLayerFrame = topShadowLayer.frame;
			topShadowLayerFrame.size.width = self.frame.size.width;
			topShadowLayerFrame.origin.y = 0;
			topShadowLayer.frame = topShadowLayerFrame;
			
			CGRect bottomShadowLayerFrame = bottomShadowLayer.frame;
			bottomShadowLayerFrame.size.width = self.frame.size.width;
			bottomShadowLayerFrame.origin.y = self.frame.size.height - bottomShadowLayer.frame.size.height;
			bottomShadowLayer.frame = bottomShadowLayerFrame;
			
			[CATransaction commit];
		}
			  
		// Position and size the scrollview. It will be centered in the view.
		// CGRect scrollViewRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
        CGRect scrollViewRect = CGRectMake(0, 0, 1024, pageSize.height);
		scrollViewRect.origin.x = 0; // ((self.frame.size.width - pageSize.width) / 2);
		scrollViewRect.origin.y = ((self.frame.size.height - pageSize.height) / 2);
		 
		scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
		scrollView.clipsToBounds = YES; // Important, this creates the "preview"
		scrollView.pagingEnabled = NO;
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.delegate = self;
		scrollView.tag = 100;
		[self addSubview:scrollView];
		
		int pageCount = [delegate itemCount:self];
		scrollViewPages = [[NSMutableArray alloc] initWithCapacity:pageCount];
		
		// Fill our pages collection with empty placeholders
		for(int i = 0; i < pageCount; i++)
		{
			[scrollViewPages addObject:[NSNull null]];
		}
		
		// Calculate the size of all combined views that we are scrolling through
        self.scrollView.contentSize = CGSizeMake([delegate itemCount:self] * pageSize.width, scrollView.frame.size.height);
		
        int numberOfModules = 8;
        iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        if([appDelegate enableGPS_SFMSearch])
		{
            if(appDelegate.db == nil)
                [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
			[appDelegate.dataBase createUserGPSTable];
            numberOfModules = 9;			
		}
		// Load the first n pages
        for (int i = 0; i < numberOfModules; i++)
            [self loadPage:i];
		
		firstLayout = NO;
        // scrollLooper = 5;
        // [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrollForth) userInfo:nil repeats:NO];
	}
	}@catch (NSException *exp) {
	SMLog(@"Exception Name BSPreviewScrollView :layoutSubviews %@",exp.name);
	SMLog(@"Exception Reason BSPreviewScrollView :layoutSubviews %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

- (void) scrollToIndex:(NSInteger)index
{
    NSArray * array = [scrollView subviews];
    UIView * viewAtIndex = [array objectAtIndex:index];
    [scrollView scrollRectToVisible:viewAtIndex.frame animated:YES];
}

- (void) scrollForth
{
    [self scrollToIndex:scrollLooper];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrollBack) userInfo:nil repeats:NO];
}

- (void) scrollBack
{
    scrollLooper++;
    if (scrollLooper == 6)
        scrollLooper = 0;
    [self scrollToIndex:scrollLooper];
    
//    if (scrollLooper != 0)
//        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(scrollShow) userInfo:nil repeats:NO];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

	// If the point is not inside the scrollview, ie, in the preview areas we need to return
	// the scrollview here for interaction to work
	if (!CGRectContainsPoint(scrollView.frame, point)) {
		return self.scrollView;
	}
	
	// If the point is inside the scrollview there's no reason to mess with the event.
	// This allows interaction to be handled by the active subview just like any scrollview
	return [super hitTest:point	withEvent:event];
}

-(int)currentPage
{
	// Calculate which page is visible 
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	return page;
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

-(void)scrollViewDidScroll:(UIScrollView *)sv
{
	int page = [self currentPage];
	
	
	// Load the visible and neighbouring pages 
	[self loadPage:page-1];
	[self loadPage:page];
	[self loadPage:page+1];
}

#pragma mark -
#pragma mark Memory management

// didReceiveMemoryWarning is not called automatically for views, 
// make sure you call it from your view controller
- (void)didReceiveMemoryWarning 
{
	// Calculate the current page in scroll view
//    int currentPage = [self currentPage];
//	
//	// unload the pages which are no longer visible
//	for (int i = 0; i < [scrollViewPages count]; i++) 
//	{
//		UIView *viewController = [scrollViewPages objectAtIndex:i];
//        if((NSNull *)viewController != [NSNull null])
//		{
//			if(i < currentPage-1 || i > currentPage+1)
//			{
//				[viewController removeFromSuperview];
//				[scrollViewPages replaceObjectAtIndex:i withObject:[NSNull null]];
//			}
//		}
//	}
	
}

- (void)dealloc 
{
	[scrollViewPages release];
	[scrollView release];
    [super dealloc];
}


@end
