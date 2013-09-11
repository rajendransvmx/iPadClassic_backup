//
//  OPDocTemplateSelectorViewController.m
//  iService
//
//  Created by Krishna Shanbhag on 21/05/13.
//
//

#import "OPDocTemplateSelectorViewController.h"
#import "iServiceAppDelegate.h"
@interface OPDocTemplateSelectorViewController ()

@end
@implementation OPDocTemplateSelectorViewController
@synthesize docTemplatesArray;
@synthesize delegate;

#pragma mark - Init methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - Memory management
- (void) dealloc {
    [super dealloc];
    [docTemplatesArray release];
    docTemplatesArray = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSMutableArray *) invokeDocTemplatesArray {
    if(self.docTemplatesArray == nil) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        self.docTemplatesArray = arr;
        [arr release];
    }
    return self.docTemplatesArray;
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self invokeDocTemplatesArray];
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.docTemplatesArray = [appDelegate.dataBase getDocumentTemplatesForProcessId:@"DAMO_OPDOC_001"];    
}
#pragma mark - Tableview datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    NSMutableDictionary *docTemplateDict = [self.docTemplatesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [docTemplateDict valueForKey:DOCUMENTS_NAME];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
    if (self.docTemplatesArray != nil && [self.docTemplatesArray count] > 0)
	{
		rowCount =  [self.docTemplatesArray count];
	}
	
    return rowCount;
}

#pragma mark - Tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *docTemplateDict = [self.docTemplatesArray objectAtIndex:indexPath.row];
    NSString *processId = [docTemplateDict objectForKey:DOCUMENTS_NAME];
    NSString *docId = [docTemplateDict objectForKey:DOCUMENTS_ID];
    if(self.delegate && [self.delegate respondsToSelector:@selector(doctemplateId:forProcessId:)]) {
        [self.delegate doctemplateId:docId forProcessId:processId];
    }
}
@end
