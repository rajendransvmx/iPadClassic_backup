 //
//  ManualDataSyncRoot.m
//  iService
//
//  Created by Parashuram on 14/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ManualDataSyncRoot.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "ManualDataSyncDetail.h"
#import "AttachmentDatabase.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation ManualDataSyncRoot

//@synthesize manualDataSyncDetail;
@synthesize recordIdArray;
@synthesize objectsArray;
@synthesize objectsDict;
@synthesize objectDetailsArray;

@synthesize dataSyncRootDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    attachmentErrorExists = FALSE;

  
     attachmentErrorExists = [appDelegate.attachmentDataBase doesRowsExistsForTable:@"AttachmentError"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
      //release it
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   // return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeRight)||
            (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    //return 1;
    if(attachmentErrorExists)
    {
        return 2;
    }
    return 1;

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Return the number of rows in the section.
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //Fix for avoiding crash
    NSUInteger rowCount = 0;
    
    switch (section) {
        case 0:
                objectsArray = nil;
                objectsArray  = [appDelegate.calDataBase getConflictObjects];
                [objectsArray retain];
                if (section == 0 && objectsArray != nil && [objectsArray count] > 0)
                {
                    rowCount =  [objectsArray count];
                }
                return rowCount;
                break;
        case 1:
                return 1;
                break;
        default:
            break;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else
    {
        cell.backgroundView = nil;
    }
    
    //########################## THIS IS NEW CODE ############################//
    UILabel * cellLabel = [[[UILabel alloc] init] autorelease];
    cellLabel.backgroundColor = [UIColor clearColor];
    cellLabel.frame = CGRectMake(0, 0, 300, 44);
    
    UIView * bgView = nil;
    UIImageView * bgImage = nil;
    UIImage * image = nil;
    
    
    switch (indexPath.section)
    {
        case 0:
        {   
            bgView = [[[UIView alloc] initWithFrame:CGRectMake(40, 7, 300, SectionHeaderHeight)] autorelease]; 
            {
                AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                NSString * label = @"";
                label = [appDelegate.calDataBase getLabelForObject:[objectsArray objectAtIndex:indexPath.row]];
                cellLabel.text = label;
            }
            if ([indexPath isEqual:lastSelectedIndexPath])
            {
                image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
                image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                [bgImage setContentMode:UIViewContentModeScaleToFill];
                cellLabel.textColor = [UIColor whiteColor];
            }
            else
            {
                image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
                image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                [bgImage setContentMode:UIViewContentModeScaleToFill];
                cellLabel.textColor = [UIColor blackColor];
            }
            
            if ([cellLabel.text length] > 0)
            {
                bgImage.frame = CGRectMake(0, 7, 300, SectionHeaderHeight); //old 40
                bgImage.tag = BGIMAGETAG;
                [bgView addSubview:bgImage];
                cellLabel.center = bgView.center;
                cellLabel.tag = CELLLABELTAG;
                [bgView addSubview:cellLabel];
                cell.backgroundView = bgView;
            }
            break;
        }
        case 1:
            
            bgView = [[[UIView alloc] initWithFrame:CGRectMake(40, 7, 300, SectionHeaderHeight)] autorelease];
            {
                AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                NSString * label = @"";
                label = @"Attachment";
                cellLabel.text = label;
            }
            if ([indexPath isEqual:lastSelectedIndexPath])
            {
                image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
                image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                [bgImage setContentMode:UIViewContentModeScaleToFill];
                cellLabel.textColor = [UIColor whiteColor];
            }
            else
            {
                image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
                image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                [bgImage setContentMode:UIViewContentModeScaleToFill];
                cellLabel.textColor = [UIColor blackColor];
            }
            
            if ([cellLabel.text length] > 0)
            {
                bgImage.frame = CGRectMake(0, 7, 300, SectionHeaderHeight); //old 40
                bgImage.tag = BGIMAGETAG;
                [bgView addSubview:bgImage];
                cellLabel.center = bgView.center;
                cellLabel.tag = CELLLABELTAG;
                [bgView addSubview:cellLabel];
                cell.backgroundView = bgView;
            }
            break;
            
        default:
            break;
       
    }
    if ([cellLabel.text length] > 0)
    {
        bgImage.frame = CGRectMake(0, 7, 300, SectionHeaderHeight); //old 40
        bgImage.tag = BGIMAGETAG;
        [bgView addSubview:bgImage];
        cellLabel.center = bgView.center;
        cellLabel.tag = CELLLABELTAG;
        [bgView addSubview:cellLabel];
        cell.backgroundView = bgView;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SMLog(kLogLevelVerbose,@"Title = %@",cellLabel.text);
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

/*ios7_support Kirti*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([Utility notIOS7])
    {
        return SectionHeaderHeight;
    }
    else
    {
        return 53;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat  HeaderHeight = 0.0;;
    //return SectionHeaderHeight;
    switch (section) 
    {
        case 0:
        {
            HeaderHeight = SectionHeaderHeight;
            break;
        }
        case 1:
        {
            HeaderHeight = SectionHeaderHeight;
            break;
        }
        
    }
    return HeaderHeight; 
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImageView * view = nil;
    NSString * sectionTitle = nil;
    switch (section) 
    {
        case 0:
        {
            sectionTitle = [app.wsInterface.tagsDictionary objectForKey:sync_choose_object];
            
            if (sectionTitle == nil)
            {
                return nil;
            }
            
            // Create label with section title
            UILabel *label = [[[UILabel alloc] init] autorelease];
            label.frame = CGRectMake(20, 3, 220, 30);
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:16];
            label.text = sectionTitle;
            
            // Create header view and add label as a subview
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 320, SectionHeaderHeight)];//320 width before changing
            view.image = [UIImage imageNamed:@"SFM-View-line-header-bg.png"];
            [view autorelease];
            [view addSubview:label];
        
            //8915 - show all button text.
            int fontSize = 15;
            int paddint = 10; //To give padding between text and button edge
            UIButton * header_button = [[[UIButton alloc]  init ] autorelease] ;
            
            [header_button  setBackgroundImage:[UIImage imageNamed:@"show-all.png"] forState:UIControlStateNormal];
            [header_button setBackgroundImage:[UIImage imageNamed:@"show-all-hover.png"] forState:UIControlStateHighlighted];
            header_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [header_button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
            
            [header_button setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:SHOWALLBUTTONTEXT] forState:UIControlStateNormal];
            
            //get variable frame based on font.
            CGSize frameSize = [header_button.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(1024, 1024) lineBreakMode:NSLineBreakByWordWrapping];
            
            header_button.frame = CGRectMake(view.frame.size.width - (frameSize.width + paddint), 15, frameSize.width + paddint, 28);
            
            [header_button addTarget:self action:@selector(didSelectHeader:) forControlEvents:UIControlEventTouchUpInside];
            
            view.tag = section;
            
            UIView * lView = [[[UIView alloc] initWithFrame:view.frame] autorelease];
            [lView addSubview:view];
            
            if ([objectsArray count]>1)
                [lView addSubview:header_button];
            
            return lView;
            break;
            
        }
        case 1:
        {
            sectionTitle = @"Attachment Error";
            
            if (sectionTitle == nil)
            {
                return nil;
            }
            
            // Create label with section title
            UILabel *label = [[[UILabel alloc] init] autorelease];
            label.frame = CGRectMake(20, 3, 220, 30);
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:16];
            label.text = sectionTitle;
            
            // Create header view and add label as a subview
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 320, SectionHeaderHeight)];//320 width before changing
            view.image = [UIImage imageNamed:@"SFM-View-line-header-bg.png"];
            [view autorelease];
            [view addSubview:label];
            
            int fontSize = 15;
            int paddint = 10; //To give padding between text and button edge
            UIButton * header_button = [[[UIButton alloc]  init ] autorelease] ;//WithFrame:CGRectMake(250, 15, 65, 28)] autorelease];//6 44 44
            
            //8915 - show
            [header_button  setBackgroundImage:[UIImage imageNamed:@"show-all.png"] forState:UIControlStateNormal];
            [header_button setBackgroundImage:[UIImage imageNamed:@"show-all-hover.png"] forState:UIControlStateHighlighted];
            header_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [header_button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
            
            [header_button setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:SHOWALLBUTTONTEXT] forState:UIControlStateNormal];
            
            //get variable frame based on font.
            CGSize frameSize = [header_button.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(1024, 1024) lineBreakMode:NSLineBreakByWordWrapping];
            
            header_button.frame = CGRectMake(view.frame.size.width - (frameSize.width + paddint), 15, frameSize.width + paddint, 28);
            
            [header_button addTarget:self action:@selector(didSelectHeader:) forControlEvents:UIControlEventTouchUpInside];
            
            view.tag = section;
            
            UIView * lView = [[[UIView alloc] initWithFrame:view.frame] autorelease];
            [lView addSubview:view];
            
            if ([objectsArray count]>1)
                [lView addSubview:header_button];
            
            return lView;
            break;
            
        }
            
    }
    
    return view;
    
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([dataSyncRootDelegate respondsToSelector:@selector(didSelectRowAtIndexPath:)])
    {
        [dataSyncRootDelegate rowSelected];
        [dataSyncRootDelegate didSelectRowAtIndexPath:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIImage * image = nil;
    
    if (lastSelectedIndexPath == indexPath) 
    {
    
        UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        UIView * cellBackgroundView = selectedCell.backgroundView;
        UIImageView * bgImage = (UIImageView *)[cellBackgroundView viewWithTag:BGIMAGETAG];
        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
        image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
        [bgImage setImage:image];
        [bgImage setContentMode:UIViewContentModeScaleToFill];
        UILabel * selectedCellLabel = (UILabel *)[cellBackgroundView viewWithTag:CELLLABELTAG];
        selectedCellLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
        UIView * lastSelectedCellBackgroundView = lastSelectedCell.backgroundView;
        UIImageView * lastSelectedCellBGImage = (UIImageView *)[lastSelectedCellBackgroundView viewWithTag:BGIMAGETAG];
        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        [lastSelectedCellBGImage setImage:image];
        [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
        UILabel * lastSelectedCellLabel = (UILabel *)[lastSelectedCellBackgroundView viewWithTag:CELLLABELTAG];
        lastSelectedCellLabel.textColor = [UIColor blackColor];

    }
    
    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * cellBackgroundView = selectedCell.backgroundView;
    UIImageView * bgImage = (UIImageView *)[cellBackgroundView viewWithTag:BGIMAGETAG];
    image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    [bgImage setImage:image];
    [bgImage setContentMode:UIViewContentModeScaleToFill];
    UILabel * selectedCellLabel = (UILabel *)[cellBackgroundView viewWithTag:CELLLABELTAG];
    selectedCellLabel.textColor = [UIColor whiteColor];
    
        
    lastSelectedIndexPath = [indexPath retain];    
}

- (void) didSelectHeader:(id) sender
{
    [dataSyncRootDelegate didSelectHeader:sender];
}

//9195
- (void)reloadViews {
   
        attachmentErrorExists = [appDelegate.attachmentDataBase doesRowsExistsForTable:@"AttachmentError"];
        [self.tableView reloadData];
    
}

@end
