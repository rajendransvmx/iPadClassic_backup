//
//  SFMEditDetailViewController.m
//  iService
//
//  Created by Krishna Shanbhag on 29/01/13.
//
//

#import "SFMEditDetailViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "Utility.h" //10312
// Accessibility changes
#import "AccessibilitySFMDetailViewAndEditConstants.h"
#import "Utility.h"
@interface SFMEditDetailViewController ()

-(id)getControl:(NSString *)controlType withRect:(CGRect)frame withData:(NSArray *)datasource withValue:(NSString *)value fieldType:(NSString *)fieldType labelValue:(NSString *)labelValue enabled:(BOOL)readOnly refObjName:(NSString *)refObjName referenceView:(UIView *)POView indexPath:(NSIndexPath *)indexPath required:(BOOL)required valueKeyValue:(NSString *)valueKeyValue lookUpSearchId:(NSString *)searchid overrideRelatedLookup:(NSNumber *)Override_Related_Lookup fieldLookupContext:(NSString *)Field_Lookup_Context fieldLookupQuery:(NSString *)Field_Lookup_Query dependentPicklistControllerName:(NSString *)dependPick_controllerName picklistValidFor:(NSMutableArray *)validFor picklistIsdependent:(BOOL)isdependentPicklist objectAPIName:(NSString *)object_api_name forSourceObject:(NSString *)lookupContextSourceObject percisionValue:(NSDictionary *)numberValidationDict;
- (NSDictionary *) valueForcontrol:(UIView *) control_Type;

-(NSInteger)getControlFieldPickListIndexForControlledPicklist:(NSString *)fieldApi_name atIndexPath:(NSIndexPath *)indexPath controlType:(NSString *)controlType;

-(void)clearTheDependentPicklistValue:(NSString *)fieldApi_name atIndexPath:(NSIndexPath *)indexPath controlType:(NSString *)controlType  fieldValue:(NSString *)field_value;

-(NSInteger) HeaderColumns;
-(NSInteger) linesColumns;

//Aparna: FORMFILL
- (void) setFormFillInfo:(NSDictionary *)formFillDict
       forPageLayoutDict:(NSMutableDictionary *)pageLayoutDict
                recordId:(NSString *)recordId;
- (void)fillMappedFieldsForFieldAPIName:fieldAPI fieldKeyValue:fieldKeyValue;

@end

@implementation SFMEditDetailViewController
@synthesize tableView;
@synthesize Disclosure_Fields;
@synthesize Disclosure_Details;
@synthesize Disclosure_dict;
@synthesize selectedIndexPath;
@synthesize selectedRowForDetailEdit;
@synthesize line, header;
@synthesize selectedIndexPathForEdit;
@synthesize isInViewMode;
@synthesize isInEditDetail;
@synthesize parentReference;
@synthesize currentEditRow;
@synthesize lookupPopover;
@synthesize selectedSection;
@synthesize detailDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardDidShowNotification object:nil];
		//Defect Fix :- 7382
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
		//Defect Fix :- 7447
		heightForTableView = 0;

    }
    return self;
}

#pragma mark - Memory management

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	//Defect Fix :- 7382
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

	[Disclosure_Fields release];
    [Disclosure_Details release];
    [Disclosure_dict release];
    [selectedIndexPath release];
    [tableView release];
    [selectedIndexPathForEdit release];
    [parentReference release];
    [currentEditRow release];
	[lookupPopover release];	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - private methods
#pragma  mark - GetvalueForcontrol
//related to save
-(BOOL)gettheChangedValue:(UIView *)view
{
    BOOL flag_value = NO;
    if([view isKindOfClass:[CSwitch class]])
    {
        CSwitch * switchType =(CSwitch *) view;
        
        if(switchType.on)
        {
            flag_value = TRUE;
        }
        else
        {
            flag_value = FALSE;
        }
    }
    return  flag_value;
}
//related to save
-(BOOL)getViewRequired:(UIView *) view
{
    BOOL Flag = NO;
    if([view isKindOfClass:[CusTextView class]])
    {
        CusTextView * textarea ;
        textarea =( CusTextView *) view;
        return  textarea.required;
    }
    if([view isKindOfClass:[CSwitch class]])
    {
        CSwitch *switch_control;
        switch_control=(CSwitch *) view;
        
        return switch_control.required;
    }
    if([view isKindOfClass:[CTextField class]])
    {
        CTextField * textFieldType ;
        textFieldType = (CTextField *) view;
        return textFieldType.required;
    }
    if([view isKindOfClass:[cusTextFieldAlpha class]])
    {
        cusTextFieldAlpha * string_type;
        string_type = (cusTextFieldAlpha *) view;
        return  string_type.required;
    }
    if([view isKindOfClass:[CusDateTextField class]])
    {
        CusDateTextField * date ;
        date = (CusDateTextField *) view;
        return date.required;
    }
    if([view isKindOfClass:[LookupField class]])
    {
        LookupField * lookup_type;
        lookup_type = (LookupField *)view;
        return lookup_type.required;
    }
    if([view isKindOfClass:[CtextFieldWithDatePicker class]])
    {
        CtextFieldWithDatePicker *dateTime;
        dateTime = (CtextFieldWithDatePicker *) view;
        
        return dateTime.required;
    }
    if([view isKindOfClass:[BotSpinnerTextField class]])
    {
        BotSpinnerTextField * picklist;
        picklist = (BotSpinnerTextField *)view;
        return picklist.required;
    }
    return Flag;
}
//saving any operation
-(void) lineseditingDone
{
    // APP DELEGATE SFM PAGE DATA
    NSInteger section = self.selectedIndexPath.section;
    NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
    NSMutableDictionary * detail = [details objectAtIndex:section];
    NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
    //SUCCESSIVE_SYNC
    NSMutableArray * detailIds = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
    if(self.selectedIndexPath.row != 0 && [detailIds count] >0)
    {
        NSString * ModifiedlocalId = [detailIds objectAtIndex:self.selectedIndexPath.row-1];
        [appDelegate.databaseInterface.modifiedLineRecords addObject:ModifiedlocalId];
    }
    NSInteger reqiredFieldCount = 0;
    // COLLECT ALL DATA FROM EDIT DETAIL SCREEN AND DUMP THEM ON APP DELEGATE SFM PAGE DATA (PROBABLY BUBBLE INFO)
    {
        for (int i = 0; i < [Disclosure_Details count]; i++)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            NSString * fieldValue = @"", * fieldType = @"";
            
            UIView * background = [[cell.contentView subviews] objectAtIndex:0];
            NSArray * backgroundSubViews = [background subviews];
            // testing
            
            for (int j = 0; j < [backgroundSubViews count]; j++)
            {
                UIView * view = [backgroundSubViews objectAtIndex:j];
                if(view.tag == 1)
                {
                    BOOL check_required = [self getViewRequired:view];
                    NSDictionary * dict = [self valueForcontrol:view];
                    NSInteger dict_count = [dict count];
                    NSString * id_type = nil;
                    NSString * control_type = nil;
                    fieldType = [dict objectForKey:DapiName];
                    fieldValue = [dict objectForKey:Dvalue];
                    if([fieldValue length] == 0 && check_required == TRUE)
                    {
                        reqiredFieldCount ++;
                    }
                    if(fieldValue == nil)
                    {
                        fieldValue = @"";
                    }
                    if(dict_count > 1)
                    {
                        id_type = [dict objectForKey:Didtype];
                        control_type = [dict objectForKey:Dcontrol_type];
                    }
                    NSMutableArray * detailValue = [detail_values objectAtIndex:self.selectedRowForDetailEdit];
                    for(int l = 0; l < [detailValue count]; l++)
                    {
                        NSMutableDictionary * dict = [detailValue objectAtIndex:l];
                        if ([fieldType isEqualToString:[dict objectForKey:gVALUE_FIELD_API_NAME]])
                        {
                            if([control_type isEqualToString:@"reference"])
                            {
								NSString * field_api_name_temp = [dict objectForKey:gVALUE_FIELD_API_NAME];
								//Fix for defect : 6028 Shrinivas
								if([field_api_name_temp  isEqualToString:@"RecordTypeId"])
								{
									NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
									id_type =  [appDelegate.databaseInterface getRecordTypeIdForRecordTypename:fieldValue objectApi_name:detailObjectName];
									
								}
                                if(id_type == nil)
                                {
                                    id_type = @"";
                                }
                                [dict setObject:id_type forKey:gVALUE_FIELD_VALUE_KEY];
                                [dict setObject:fieldValue forKey:gVALUE_FIELD_VALUE_VALUE];
                                break;
                            }
                            if([control_type isEqualToString:@"picklist"])
                            {
                                if(appDelegate.isWorkinginOffline)
                                {
                                    NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
                                    //query to acces the picklist values for lines
                                    NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldType tableName:SFPicklist objectName:detailObjectName];
                                    
                                    
                                    NSArray * allvalues = [picklistValues allValues];
                                    NSArray * allkeys = [picklistValues allKeys];
                                    
                                    for(int i =0; i<[picklistValues count];i++)
                                    {
                                        NSString * value = [allvalues objectAtIndex:i];
                                        if([value isEqualToString:fieldValue])
                                        {
                                            id_type = [allkeys objectAtIndex:i];
                                            break;
                                        }
                                    }
                                    
                                }
                                else
                                {
                                    for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
                                    {
                                        ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
                                        ZKDescribeField * descField = [descObj fieldWithName:fieldType];
                                        if (descField == nil)
                                            continue;
                                        else
                                        {
                                            NSArray * pickListEntryArray = [descField picklistValues];
                                            for (int k = 0; k < [pickListEntryArray count]; k++)
                                            {
                                                NSString * value = [[pickListEntryArray objectAtIndex:k] label];
                                                if([value isEqualToString:fieldValue])
                                                {
                                                    id_type =[[pickListEntryArray objectAtIndex:k] value];
                                                    break;
                                                }
                                            }
                                            break;
                                        }
                                    }
                                }
                                if(id_type == nil)
                                {
                                    id_type = @"";
                                }
                                [dict setObject:id_type forKey:gVALUE_FIELD_VALUE_KEY];
                                [dict setObject:fieldValue forKey:gVALUE_FIELD_VALUE_VALUE];
                                break;
                                
                            }
                            if([control_type isEqualToString:@"datetime"])
                            {
                                //sahana 9th Aug 2011
                                NSString * str = fieldValue;
                                NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                                //10312
                                [frm setTimeZone:[NSTimeZone systemTimeZone]];
                                [frm setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
                                NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                                [frm setCalendar:cal];
                                [cal release];
                                if ([Utility iSDeviceTime24HourFormat])
                                {
                                    [frm  setDateFormat:DATETIMEFORMAT24HR];
                                }
                                else
                                {
                                    [frm  setDateFormat:DATETIMEFORMAT];
                                }
                                NSDate * date = [frm dateFromString:str];
                                [frm  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                NSString * str1 = [frm stringFromDate:date];//.000Z
                                
                                // Convert this str1 back into GMT
                                if(str1 != nil)
                                {
                                    str1 = [iOSInterfaceObject getGMTFromLocalTime:str1];
                                    str1 = [str1  stringByReplacingOccurrencesOfString:@"Z" withString:@".000Z"];
                                }
                                
                                if(str1 != nil)
                                {
                                    if([str1 isEqualToString:@""])
                                        fieldValue = @"";
                                    else
                                        fieldValue = str1;
                                    
                                }
                                else
                                {
                                    fieldValue = @"";
                                }
                                SMLog(kLogLevelVerbose,@"%@",date);
                            }
                            if([control_type isEqualToString: @"date"])
                            {
                                
                                NSString * str = fieldValue;
                                NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                                [frm setDateFormat: @"MMM dd yyyy"];
                                NSDate * date = [frm dateFromString:str];
                                [frm  setDateFormat:@"yyyy-MM-dd"];
                                NSString * final_date = [frm stringFromDate:date];
                                if(final_date != nil)
                                {
                                    fieldValue = final_date;
                                    
                                }
                                else
                                {
                                    fieldValue = @"";
                                    
                                }
                                
                            }
                            
                            if([control_type isEqualToString:@"boolean"])
                            {
                                
                                BOOL changed =[self gettheChangedValue:view];
                                if (changed)
                                {
                                    fieldValue = @"1";
                                }
                                else
                                {
                                    fieldValue = @"0";
                                }
                            }
                            //Radha and sahana 9th Aug 2011
                            if([control_type isEqualToString:@"multipicklist"])
                            {
                                NSMutableArray * keyVal	 = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                                NSString * keyValueString =[[[NSString alloc] init] autorelease];
                                //                                NSInteger len;
                                
                                if(appDelegate.isWorkinginOffline)
                                {
                                    NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
                                    //query to acces the picklist values for lines
                                    NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldType tableName:SFPicklist objectName:detailObjectName];
                                    
                                    
                                    NSArray * allvalues = [picklistValues allValues];
                                    NSArray * allkeys = [picklistValues allKeys];
                                    NSArray * array = [fieldValue componentsSeparatedByString:@";"];
                                    
                                    for(int j = 0; j < [array count]; j++)
                                    {
                                        NSString * value_field = [array objectAtIndex:j];
                                        
                                        for(int i = 0; i < [picklistValues count]; i++)
                                        {
                                            NSString * value = [allvalues objectAtIndex:i];
                                            if([value isEqualToString:value_field])
                                            {
                                                [keyVal addObject:[allkeys objectAtIndex:i]];
                                                break;
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
                                    {
                                        ZKDescribeSObject * sObj = [appDelegate.describeObjectsArray objectAtIndex:i];
                                        ZKDescribeField * desField = [sObj fieldWithName:fieldType];
                                        if (desField == nil)
                                            continue;
                                        else
                                        {
                                            NSArray * multipicklistArray = [desField picklistValues];
                                            NSArray * array = [fieldValue componentsSeparatedByString:@";"];
                                            for (int j = 0; j < [array count]; j++)
                                            {
                                                for (int i = 0; i < [multipicklistArray count]; i++)
                                                {
                                                    NSString * value = [[multipicklistArray objectAtIndex:i] label];
                                                    if ([value isEqualToString:[array objectAtIndex:j]])
                                                    {
                                                        [keyVal addObject:[[multipicklistArray objectAtIndex:i] value]];
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                for(int j = 0 ; j < [keyVal count]; j++)
                                {
                                    if ([keyValueString length] > 0)
                                        keyValueString = [keyValueString stringByAppendingString:[NSString stringWithFormat:@";%@", [keyVal objectAtIndex:j]]];
                                    else
                                        keyValueString = [keyValueString stringByAppendingString:[keyVal objectAtIndex:j]];
                                }
                                
                                if([keyValueString length] == 0)
                                {
                                    keyValueString = @"";
                                }
                                
                                [dict setObject:keyValueString forKey:gVALUE_FIELD_VALUE_KEY];
                                [dict setObject:fieldValue     forKey:gVALUE_FIELD_VALUE_VALUE];
                                break;
                            }
                            else if ([control_type isEqualToString:@"currency"] || [control_type isEqualToString:@"percent"] || [control_type isEqualToString:@"double"]) //10346
                            {
                                NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
                                NSInteger scale = [appDelegate.dataBase getScaleValueForNumberField:fieldType objectName:detailObjectName validationField:MSCALE];
                                
                                BOOL iSNaN = [Utility isValueNotANumber:fieldValue];
                                
                                if ([fieldValue length] > 0 && (![fieldValue isEqualToString:@""]) && !iSNaN)
                                {
                                    NSString *formattedNumber = [Utility  getFormattedString:fieldValue decimalPoint:scale];
                                    if ([formattedNumber length] > 0)
                                    {
                                        NSMutableString * scalingString = [NSMutableString stringWithFormat:@"%@", formattedNumber];
                                        fieldValue = scalingString;
                                        
                                        if (scale >= 0)
                                        {
                                            NSString * newValue = [Utility appendOrRemoveZeroToDecimalPoint:scalingString decimalPoint:scale];
                                            
                                            if ([newValue length] > 0)
                                            {
                                                fieldValue = newValue;
                                            }
                                        }
                                    }
                                }
                                else if (iSNaN)
                                {
                                    fieldValue = @"";
                                }

                            }
                            [dict setObject:fieldValue forKey:gVALUE_FIELD_VALUE_KEY];
                            [dict setObject:fieldValue forKey:gVALUE_FIELD_VALUE_VALUE];
                            break;
                        }
                    }
                }
            }
            SMLog(kLogLevelVerbose,@"Values Altered Successfully");
        }
    }
    //sahana temp change -  required fields check
    
    if(reqiredFieldCount  > 0)
    {
        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
        NSString * required_field = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_REQUIRED_FIELDS];
        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        UIAlertView * alert_view = [[UIAlertView alloc] initWithTitle:warning message:required_field delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
        [alert_view show];
        [alert_view release];
    }
    else
    {
        //sahana 20th August 2011
		if ([detail_values count] > 0)
		{
			NSMutableArray * detailValue = [detail_values objectAtIndex:self.selectedRowForDetailEdit];
			for(int i =0; i< [detailValue count]; i++)
			{
				NSMutableDictionary  * dict = [detailValue objectAtIndex:i];
				NSString * api_name = [dict objectForKey:gVALUE_FIELD_API_NAME];
				if([api_name isEqualToString:gDETAIL_SAVED_RECORD])
				{
					[dict  setObject:[NSNumber numberWithInt:1] forKey:gVALUE_FIELD_VALUE_VALUE];
					[dict  setObject:[NSNumber numberWithInt:1] forKey:gVALUE_FIELD_VALUE_KEY];
				}
			}
			
		}
		[self.navigationController popViewControllerAnimated:YES];
    }
}

//value after operation
- (NSDictionary *) valueForcontrol:(UIView *) control_Type
{
    if([control_Type isKindOfClass:[CusTextView class]])
    {
        CusTextView * textarea ;
        textarea =( CusTextView *) control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:textarea.text,Dvalue,
                textarea.fieldAPIName,DapiName,
                @"textarea", Dcontrol_type,
                @"", Didtype,
                nil];
    }
    if([control_Type isKindOfClass:[CSwitch class]])
    {
        CSwitch *switch_control;
        switch_control=(CSwitch *) control_Type;
        
        NSArray * keys = [NSArray arrayWithObjects:Dvalue, DapiName, Dcontrol_type, Didtype, nil];
        
        if(switch_control.on)
        {
            NSArray * objects = [NSArray arrayWithObjects:@"True", switch_control.fieldAPIName, @"boolean", @"", nil];
            return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        }
        else
        {
            NSArray * objects = [NSArray arrayWithObjects:@"False", switch_control.fieldAPIName, @"boolean", @"", nil];
            return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        }
        
    }
    if([control_Type isKindOfClass:[CTextField class]])
    {
        CTextField * textFieldType ;
        textFieldType = (CTextField *) control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:textFieldType.text,Dvalue,textFieldType.fieldAPIName,DapiName, textFieldType.control_type, Dcontrol_type,nil];
    }
    if([control_Type isKindOfClass:[cusTextFieldAlpha class]])
    {
        cusTextFieldAlpha * string_type;
        string_type = (cusTextFieldAlpha *) control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:string_type.text,Dvalue,string_type.fieldAPIName,DapiName,nil];
    }
    if([control_Type isKindOfClass:[CusDateTextField class]])
    {
        CusDateTextField * date ;
        date = (CusDateTextField *) control_Type;
        if (date.text == nil)
            date.text = @"";
        NSString * value = date.text;
        return [NSDictionary dictionaryWithObjectsAndKeys:value,Dvalue,date.fieldAPIName,DapiName,date.control_type,Dcontrol_type,nil];
    }
    if([control_Type isKindOfClass:[LookupField class]])
    {
        LookupField * lookup_type;
        lookup_type = (LookupField *)control_Type;
        NSString * test = lookup_type.control_type;
        if(lookup_type.idValue == nil)
        {
            if(lookup_type.first_idValue == nil)
            {
                lookup_type.idValue =  @"";
            }
            else
            {
                lookup_type.idValue =  lookup_type.first_idValue;
                
            }
        }
        
        return [NSDictionary dictionaryWithObjectsAndKeys:lookup_type.text,Dvalue,lookup_type.fieldAPIName,DapiName,lookup_type.idValue,Didtype,test,Dcontrol_type, nil];
    }
    if([control_Type isKindOfClass:[CtextFieldWithDatePicker class]])
    {
        CtextFieldWithDatePicker *dateTime;
        dateTime = (CtextFieldWithDatePicker *) control_Type;
        if (dateTime.text == nil)
        {
            dateTime.text = @"";
        }
        //sahana Aug 16th
        NSString * dateTimeValue = dateTime.text ;
        return [NSDictionary dictionaryWithObjectsAndKeys:dateTimeValue,Dvalue,dateTime.fieldAPIName,DapiName,dateTime.control_type,Dcontrol_type,nil];
    }
    if([control_Type isKindOfClass:[BotSpinnerTextField class]])
    {
        BotSpinnerTextField * picklist;
        picklist = (BotSpinnerTextField *)control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:picklist.text,Dvalue,picklist.fieldAPIName,DapiName,picklist.control_type,Dcontrol_type, nil];
    }
    //Radha and sahana 9th Aug 2011
    if([control_Type isKindOfClass:[BMPTextView class]])
    {
        BMPTextView * Mppicklist;
        Mppicklist = (BMPTextView *)control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:Mppicklist.text,Dvalue,Mppicklist.fieldAPIName,DapiName,Mppicklist.control_type,Dcontrol_type, nil];
        
    }
    return nil;
}


//check if all required fields are added

-(BOOL)isNecessaryFieldsFilled
{
    NSInteger reqiredFieldCount = 0;
    // COLLECT ALL DATA FROM EDIT DETAIL SCREEN AND DUMP THEM ON APP DELEGATE SFM PAGE DATA (PROBABLY BUBBLE INFO)
    //control type
    
    for (int i = 0; i < [Disclosure_Details count]; i++)
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        NSString * fieldValue = @"";
        
        UIView * background = [[cell.contentView subviews] objectAtIndex:0];
        NSArray * backgroundSubViews = [background subviews];
        // testing
        
        for (int j = 0; j < [backgroundSubViews count]; j++)
        {
            UIView * view = [backgroundSubViews objectAtIndex:j];
            if(view.tag == 1)
            {
                
                BOOL check_required = [self getViewRequired:view];
                
                NSDictionary * dict = [self valueForcontrol:view];
                
                fieldValue = [dict objectForKey:Dvalue];
                if([fieldValue length] == 0 && check_required == TRUE)
                {
                    reqiredFieldCount ++;
                }
            }
            
        }
        SMLog(kLogLevelVerbose,@"Values Altered Successfully");
        
    }
    
    if(reqiredFieldCount >0)
    {
        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
        NSString * required_field = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_REQUIRED_FIELDS];
        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView * alert_view = [[UIAlertView alloc] initWithTitle:warning message:required_field delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
        [alert_view show];
        [alert_view release];
        return NO;
    }
    return YES;
}



-(NSMutableDictionary *)getRecordTypeIdAndObjectNameForCellAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary * return_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    if (!self.isInEditDetail)
    {
        // Determine if section is SHOWALLHEADER or SHOWHEADERSECTION and only then set dictionary value for fieldAPIName key
        // Header will have array of dictionaries
        // fetch the dictionary based on the indexPath and control in that row being edited
        // update dictionary value for key (fieldAPIName)
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {
			 int section = indexPath.section;
			 int index;

			 if (isDefault)
				 index = section;
			 else
				 index = selectedRow;
           
            NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            
            
            NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
            
            for (int i=0;i<[header_sections count];i++)
            {
                NSDictionary * section = [header_sections objectAtIndex:i];
                NSArray *section_fields = [section objectForKey:@"section_Fields"];
                for (int j=0;j<[section_fields count];j++)
                {
                    NSDictionary *section_field = [section_fields objectAtIndex:j];
                    
                    NSString * field_api = [section_field objectForKey:gFIELD_API_NAME];
                    if([field_api isEqualToString:@"RecordTypeId"])
                    {
                        NSString * key = [section_field objectForKey:gFIELD_VALUE_KEY];
                        [return_dict  setObject:(key!= nil)?key:@""  forKey:RecordType_Id];
                        [return_dict  setObject:headerObjName forKey:SFM_Object];
                        break;
                    }
                    //add key values to SM_header_fields dictionary
                    
                }
            }
        }
    }
    else
    {
        //sahana 26th sept 2011
        //control type
        NSMutableArray * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
        NSString * detail_objectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
        
        for (int i = 0; i < [detail_values count]; i++)
        {
            NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
            if([value_Field_API isEqualToString:@"RecordTypeId"])
            {
                NSString *key =  [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_VALUE_KEY];
                [return_dict  setObject:(key!= nil)?key:@""  forKey:RecordType_Id];
                [return_dict  setObject:detail_objectName forKey:SFM_Object];
                break;
            }
        }
    }
    return return_dict;
}

-(NSInteger)getControlFieldPickListIndexForControlledPicklist:(NSString *)fieldApi_name atIndexPath:(NSIndexPath *)indexPath controlType:(NSString *)controlType
{
    
        //sahana 26th sept 2011
        //control type
    if (!self.isInEditDetail)
    {
        // Determine if section is SHOWALLHEADER or SHOWHEADERSECTION and only then set dictionary value for fieldAPIName key
        // Header will have array of dictionaries
        // fetch the dictionary based on the indexPath and control in that row being edited
        // update dictionary value for key (fieldAPIName)
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {
            //            int section = indexPath.section;
            //            int index = 0;
            //
            //            if (isDefault)
            //                index = section;
            //            else
            //                index = selectedRow;
            
            
            NSMutableDictionary *_header = [appDelegate.SFMPage objectForKey:gHEADER];
            NSMutableArray *header_sections = [_header objectForKey:gHEADER_SECTIONS];
            
            
            for(int i=0; i <[header_sections count] ;i++)
            {
                NSDictionary * section_info = [header_sections objectAtIndex:i];
                NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
                
                for(int j= 0;j<[sectionFileds count]; j++)
                {
                    NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                    NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                    NSString * control_type = [filed_info objectForKey:gFIELD_DATA_TYPE];
                    NSString * dict_value = [filed_info objectForKey:gFIELD_VALUE_VALUE];
                    
                    //5878
                    if([filed_api_name isEqualToString:fieldApi_name])
                    {
                        if([control_type isEqualToString:@"picklist"] || [control_type isEqualToString:@"multipicklist"])
                        {
                            
                            NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                            NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                            
                            int index_value = [appDelegate.databaseInterface getIndexOfPicklistValueForOject_Name:headerObjName field_api_name:fieldApi_name value:dict_value];
                            
                            return index_value;
                            
                            
                        }
                        if([control_type isEqualToString:@"boolean"])
                        {
                            if([dict_value isEqualToString:@"True"] || [dict_value isEqualToString:@"true"] || [dict_value isEqualToString:@"1"])
                            {
                                return 1;
                            }
                            else
                            {
                                return 0;
                            }
                        }
                        
                    }
                }
            }
        }
    }
    else
    {
        NSMutableArray * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
		NSMutableArray * fieldArray = [Disclosure_dict objectForKey:@"details_Fields_Array"];
        NSMutableArray * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
        
        for (int i = 0; i < [detail_values count]; i++)
        {
            NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
            NSString * dict_value =  [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_VALUE_VALUE];
			NSString * control_type_name = @"";
			//#008082
			for (NSDictionary *  field_type_dict in fieldArray)
			{
				control_type_name = @"";
				NSString * field_type_name = [field_type_dict objectForKey:@"Field_API_Name"];
				if([fieldApi_name isEqualToString:field_type_name])
				{
					control_type_name = [field_type_dict objectForKey:@"Field_Data_Type"];
					break;
				}
			}
			
            if([fieldApi_name isEqualToString:value_Field_API])
            {
                //5878 #008082
                if([control_type_name isEqualToString: @"picklist"] || [control_type_name isEqualToString: @"multipicklist"])
                {
                    NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                    
                    int index_value = [appDelegate.databaseInterface getIndexOfPicklistValueForOject_Name:detailObjectName field_api_name:value_Field_API value:dict_value];
                    
                    return index_value;
                }
				//#008082
                if([control_type_name isEqualToString:@"boolean"])
                {
                    if([dict_value isEqualToString:@"True"] || [dict_value isEqualToString:@"true"] || [dict_value isEqualToString:@"1"])
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }
                }
            }
        }
    }
    return 9999999;
}

//Function called wen u changed the state of a control (say switch)
-(void)clearTheDependentPicklistValue:(NSString *)fieldApi_name atIndexPath:(NSIndexPath *)indexPath controlType:(NSString *)controlType  fieldValue:(NSString *)field_value
{
    if (!self.isInEditDetail)
    {
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {
            
            //            int section = indexPath.section;
            //            int index;
            //
            //            if (isDefault)
            //                index = section;
            //            else
            //                index = selectedRow;
            
            NSMutableDictionary *_header    = [appDelegate.SFMPage objectForKey:gHEADER];
            NSMutableArray *header_sections = [_header objectForKey:gHEADER_SECTIONS];
            NSString * headerObjName        = [_header objectForKey:gHEADER_OBJECT_NAME];
            
            
            
            NSMutableArray   * dependent_picklists = nil ;
            if([fieldApi_name isEqualToString:@"RecordTypeId"])
            {
				dependent_picklists = [appDelegate.databaseInterface getRtDependentPicklistsForObject:headerObjName recordtypeName:field_value];
            }
            else
            {
				dependent_picklists = [appDelegate.databaseInterface   getAllDependentPicklistSWhenControllerValueChanged:headerObjName controller_name:fieldApi_name];
            }
            
            
            for(int i=0; i <[header_sections count] ;i++)
            {
                NSDictionary * section_info = [header_sections objectAtIndex:i];
                NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
                
                for(int j= 0;j<[sectionFileds count]; j++)
                {
                    NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                    
                    NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                    NSString * control_type   = [filed_info objectForKey:gFIELD_DATA_TYPE];
                                        
                    if([control_type isEqualToString:@"picklist"])
                    {
                        if([dependent_picklists containsObject:filed_api_name])
                        {
                            if([fieldApi_name isEqualToString:@"RecordTypeId"])
                            {
                                NSString * label_ = [appDelegate.databaseInterface  getDefaultValueForRTPicklist:headerObjName recordtypeName:field_value field_api_name:filed_api_name type:@"Label"];
                                NSString  * value_ =[ appDelegate.databaseInterface  getDefaultValueForRTPicklist:headerObjName recordtypeName:field_value field_api_name:filed_api_name type:@"Value"];
                                
                                [filed_info setValue:label_ forKey:gFIELD_VALUE_VALUE];
                                [filed_info setValue:value_ forKey:gFIELD_VALUE_KEY];
                            }
                            else
                            {
                                [filed_info setValue:@"" forKey:gFIELD_VALUE_VALUE];
                                [filed_info setValue:@"" forKey:gFIELD_VALUE_KEY];
                            }
                            SMLog(kLogLevelVerbose,@"Fields Info ========= %@" , filed_info);
                        }
                        
                        
                    }
                }
            }
        }
    }
    else {
    NSMutableArray  * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
    NSMutableArray  * field_array = [Disclosure_dict objectForKey:gDETAILS_FIELDS_ARRAY];
    NSMutableArray  * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
    NSMutableDictionary * field_dataType_dict = [[[NSMutableDictionary alloc] initWithCapacity:0]autorelease];
    NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
    
    
    
    NSMutableArray   * dependent_picklists = nil ;
    
    if([fieldApi_name isEqualToString:@"RecordTypeId"])
    {
        dependent_picklists = [appDelegate.databaseInterface getRtDependentPicklistsForObject:detailObjectName recordtypeName:field_value];
    }
    else
    {
        dependent_picklists = [appDelegate.databaseInterface   getAllDependentPicklistSWhenControllerValueChanged:detailObjectName controller_name:fieldApi_name];
        
    }
    
    for(int j = 0 ; j< [field_array count]; j++)
    {
        NSDictionary * dict = [field_array objectAtIndex:j];
        NSString * api_name = [dict objectForKey:gFIELD_API_NAME];
        NSString * data_type = [dict objectForKey:gFIELD_DATA_TYPE];
        [field_dataType_dict setValue:data_type forKey:api_name];
    }
    NSArray * all_api_names = [field_dataType_dict allKeys];
    
    for (int i = 0; i < [detail_values count]; i++)
    {
        NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
        NSString * control_type = @"";
        for(NSString * api in all_api_names)
        {
            if([value_Field_API isEqualToString:api])
            {
                control_type = [field_dataType_dict objectForKey:api];
            }
        }
        
        //5878:
        if([control_type isEqualToString:@"picklist"] || [control_type isEqualToString:@"multipicklist"])
        {
            
            if([dependent_picklists containsObject:value_Field_API])
            {
                
                if([fieldApi_name isEqualToString:@"RecordTypeId"])
                {
                    NSString * label_ = [appDelegate.databaseInterface  getDefaultValueForRTPicklist:detailObjectName recordtypeName:field_value field_api_name:value_Field_API type:@"Label"];
                    NSString  * value_ =[ appDelegate.databaseInterface  getDefaultValueForRTPicklist:detailObjectName recordtypeName:field_value field_api_name:value_Field_API type:@"Value"];
                    
                    [[detail_values objectAtIndex:i] setValue:label_ forKey:gVALUE_FIELD_VALUE_VALUE];
                    [[detail_values objectAtIndex:i] setValue:value_ forKey:gVALUE_FIELD_VALUE_KEY];
                }
                else
                {
                    [[detail_values objectAtIndex:i] setValue:@"" forKey:gVALUE_FIELD_VALUE_VALUE];
                    [[detail_values objectAtIndex:i] setValue:@"" forKey:gVALUE_FIELD_VALUE_KEY];
                }
                
            }
            
        }
        
    }
    }
}

// Populating the view
-(id)getControl:(NSString *)controlType withRect:(CGRect)frame withData:(NSArray *)datasource withValue:(NSString *)value fieldType:(NSString *)fieldType labelValue:(NSString *)labelValue enabled:(BOOL)readOnly refObjName:(NSString *)refObjName referenceView:(UIView *)POView indexPath:(NSIndexPath *)indexPath required:(BOOL)required valueKeyValue:(NSString *)valueKeyValue lookUpSearchId:(NSString *)searchid overrideRelatedLookup:(NSNumber *)Override_Related_Lookup fieldLookupContext:(NSString *)Field_Lookup_Context fieldLookupQuery:(NSString *)Field_Lookup_Query dependentPicklistControllerName:(NSString *)dependPick_controllerName picklistValidFor:(NSMutableArray *)validFor picklistIsdependent:(BOOL)isdependentPicklist objectAPIName:(NSString *)object_api_name forSourceObject:(NSString *)lookupContextSourceObject percisionValue:(NSDictionary *)numberValidationDict
{
    if([controlType isEqualToString:@"picklist"])
    {
        BotSpinnerTextField * botSpinner;
        
        if (labelValue == nil)
        {
            botSpinner = nil;
            return botSpinner;
        }
        else
        {
            botSpinner = [[BotSpinnerTextField alloc] initWithFrame:frame initArray:datasource];
            botSpinner.text = value;
            //5970
            if(([value isEqualToString:@""]) && (![valueKeyValue isEqualToString:@""]))
            {
                if(([valueKeyValue length] > 0) && (![valueKeyValue isEqualToString:@" "]))
                {
                    botSpinner.text = valueKeyValue;
                }
            }
            if(!isInViewMode)
            {
                botSpinner.enabled = NO;
            }
            else
            {
                botSpinner.enabled = readOnly;
            }
            SMLog(kLogLevelVerbose,@"%@", value);
            botSpinner.indexPath = indexPath;
            botSpinner.fieldAPIName = fieldType;
            botSpinner.required = required;
            botSpinner.controlDelegate = self;
            botSpinner.control_type = controlType;
            botSpinner.TFHandler.isdependentPicklist =isdependentPicklist;
            botSpinner.TFHandler.validFor = validFor;
            botSpinner.TFHandler.controllerName = dependPick_controllerName;
            SMLog(kLogLevelVerbose,@" isdepentent value  validFor%@  controlType %@" , validFor , controlType);
            return botSpinner;
        }
    }
    
    if([controlType isEqualToString:@"boolean"])
    {
        frame.origin.y = 6;
        CSwitch * switchType = [[CSwitch alloc] initWithFrame:frame];
        
        if (!isInViewMode)
            switchType.enabled = NO;
        else
            switchType.enabled = readOnly;
        switchType.indexPath = indexPath;
        if([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"])
        {
            [switchType setOn:YES];
        }
        else
        {
            [switchType setOn:NO];
        }
        switchType.fieldAPIName = fieldType;
        switchType.required = required;
        switchType.controlDelegate = self;
        switchType.control_type = controlType;
        return switchType;
    }
    
    if([controlType isEqualToString:@"percent"])
    {
        CTextField * PercentType;
        //Keyboard fix for readonly fields 
        BOOL isFieldEnable;
        if (!isInViewMode)
        {
            isFieldEnable=NO;
        }
        else
        {
            isFieldEnable=readOnly;
        }
        PercentType = [[CTextField alloc] initWithFrame:frame lableValue:labelValue controlType:@"percent" isinViewMode:isInViewMode isEditable:isFieldEnable];
        PercentType.controlDelegate = self;
        PercentType.indexPath = indexPath;
        if (!isInViewMode)
            PercentType.enabled = NO;
        else
            PercentType.enabled = readOnly;
        
        PercentType.text = value;
        PercentType.fieldAPIName = fieldType;
        PercentType.required = required;
        PercentType.control_type = controlType;
        PercentType.precision = [[numberValidationDict objectForKey:MPRECISION] integerValue];
        PercentType.length = [[numberValidationDict objectForKey:@"lenght"] integerValue];
        return PercentType;
        
    }
    if([controlType isEqualToString:@"phone"])
    {
        CTextField * phonetype;
		//Keyboard fix for readonly fields
        BOOL isFiledEditable;
        if (!isInViewMode)
        {
            isFiledEditable=NO;
        }
        else
        {
            isFiledEditable=readOnly;
        }
        phonetype = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"phone" isinViewMode:isInViewMode isEditable:isFiledEditable];
        phonetype.controlDelegate = self;
        phonetype.indexPath = indexPath;
        if (!isInViewMode)
            phonetype.enabled = NO;
        else
            phonetype.enabled = readOnly;
        
        phonetype.text=value;
        phonetype.fieldAPIName = fieldType;
        phonetype.required = required;
        phonetype.control_type = controlType;
        return phonetype;
        
    }
    
    if([controlType isEqualToString:@"currency"])
    {
        CTextField * currency = nil;
        
        if ( labelValue == nil )
        {
            currency = nil;
            return currency;
        }
        else
        {
            currency = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"currency" isinViewMode:isInViewMode isEditable:readOnly]; //Keyboard fix for readonly fields
            currency.controlDelegate = self;
            currency.indexPath = indexPath;
            currency.enabled = readOnly;
            currency.text = value;
            currency.fieldAPIName = fieldType;
            currency.required = required;
            currency.control_type = controlType;
            currency.precision = [[numberValidationDict objectForKey:MPRECISION] integerValue];
            currency.length = [[numberValidationDict objectForKey:@"lenght"] integerValue];
            return currency;
        }
    }
    
    if([controlType isEqualToString:@"double"])
    {
        CTextField * doubleType;
        
        if (labelValue == nil)
        {
            doubleType = nil;
            return doubleType;
        }
        else
        {
            //Keyboard fix for readonly fields
			BOOL isFieldEditable;
			if (!isInViewMode)
				isFieldEditable=NO;
			else
				isFieldEditable=readOnly;
			doubleType = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"double" isinViewMode:isInViewMode isEditable:isFieldEditable];
            doubleType.controlDelegate = self;
            doubleType.text = value;
            doubleType.indexPath = indexPath;
            if (!isInViewMode)
                doubleType.enabled = NO;
            else
                doubleType.enabled = readOnly;
            doubleType.fieldAPIName = fieldType;
            doubleType.required = required;
            doubleType.control_type = controlType;
        
            //Defect :009746 Shubha

            doubleType.precision = [[numberValidationDict objectForKey:MPRECISION] integerValue];
            doubleType.length = [[numberValidationDict objectForKey:@"lenght"] integerValue];
            return doubleType;
        }
    }
    
    if([controlType isEqualToString:@"textarea"])
    {
        //Keyboard fix for readonly fields
        BOOL isFieldEditable ;
        if (!isInViewMode)
        {
            isFieldEditable=NO;
        }
        else
        {
            isFieldEditable=readOnly;
        }
        
        CusTextView * textarea = [[CusTextView alloc] initWithFrame:frame lableValue:labelValue isEditable:isFieldEditable];
        textarea.controlDelegate = self;
        if (!isInViewMode)
            textarea.editable = NO;
        else
            textarea.editable = readOnly;
        textarea.indexPath = indexPath;
        textarea.text=value;
	    textarea.object_api_name = object_api_name;
        textarea.font = [UIFont fontWithName:@"Helvetica" size:14];
        textarea.layer.cornerRadius = 5;
        textarea.fieldAPIName = fieldType;
        textarea.required = required;
        textarea.control_type = controlType;
        return textarea;
    }
    
    if([controlType isEqualToString:@"datetime"])
    {
        CtextFieldWithDatePicker * datetimeType = [[CtextFieldWithDatePicker alloc] initWithFrame:frame];
        datetimeType.text = value;
        NSString * string;
        if (!isInViewMode)
            datetimeType.enabled = NO;
        else
            datetimeType.enabled = readOnly;
        datetimeType.fieldAPIName = fieldType;
        datetimeType.required = required;
        datetimeType.controlDelegate = self;
        datetimeType.control_type = controlType;
        datetimeType.indexPath = indexPath;
        
        //sahana 16ht Aug
        NSRange range = [value  rangeOfString:@"-"];
        if(range.location == NSNotFound)
        {
            if(value != nil)
            {
                datetimeType.text =  value;
            }
            else
            {
                datetimeType.text = @"";
            }
            return datetimeType;
        }
        string = [iOSInterfaceObject localTimeFromGMT:value];
        string = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        string = [string stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
        //10312
        [frm setTimeZone:[NSTimeZone systemTimeZone]];
        
        [frm setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
        [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [frm setCalendar:cal];
        [cal release];
        NSDate * date = [frm dateFromString:string];
        //10312
        if ([Utility iSDeviceTime24HourFormat])
        {
            [frm  setDateFormat:DATETIMEFORMAT24HR];
        }
        else
        {
            [frm  setDateFormat:DATETIMEFORMAT];
        }
        datetimeType.text = [frm stringFromDate:date];
        
        //sahana 16ht Aug
        if (datetimeType.text == nil)
        {
            datetimeType.text = @"";
        }
        
        return datetimeType;
    }
    
    if([controlType isEqualToString:@"reference"] && [fieldType isEqualToString:@"RecordTypeId"])
    {
        BotSpinnerTextField * botSpinner = [[[BotSpinnerTextField alloc] initWithFrame:frame initArray:datasource] autorelease];
        botSpinner.text = value;
        if (!isInViewMode)
            botSpinner.enabled = NO;
        else
            botSpinner.enabled = readOnly;
        botSpinner.indexPath = indexPath;
        botSpinner.fieldAPIName = fieldType;
        botSpinner.required = required;
        botSpinner.control_type = controlType;
        botSpinner.controlDelegate = self;
        return botSpinner;
    }
    else if([controlType isEqualToString:@"reference"])
    {
        LookupField * lookup = nil;
        
        if (labelValue == nil)
        {
            lookup = nil;
            return lookup;
        }
        else
        {
			lookup = [[LookupField alloc] initWithFrame:frame labelValue:labelValue inView:POView];
            lookup.controlDelegate = self;
            [lookup settextField:value];
            if (!isInViewMode)
                lookup.enabled = NO;
            else
                lookup.enabled = readOnly;
            
            if (self.isInEditDetail)
            {
                lookup.selectedIndexPath = selectedIndexPath;
                lookup.Disclosure_dict = Disclosure_dict;
            }
            else
            {
                lookup.selectedIndexPath = nil;
            }
            
            lookup.first_idValue = valueKeyValue;
            lookup.indexPath = indexPath;
            lookup.searchId = searchid;
            lookup.objectName = refObjName;
            lookup.objectLabel = labelValue;
            lookup.fieldAPIName = fieldType;
            lookup.required = required;
            lookup.control_type = controlType;
            lookup.Override_Related_Lookup = Override_Related_Lookup;
            lookup.Field_Lookup_Context = Field_Lookup_Context;
            lookup.Field_Lookup_Query = Field_Lookup_Query;
			lookup.heightForPopover = heightForTableView; //Defect Fix :- 7447
            lookup.sourceObject = lookupContextSourceObject; //krishna CONTEXTFILTER
            return lookup;
        }
    }
    
    if([controlType isEqualToString:@"date"])
    {
        CusDateTextField * date_type = nil;
        
        if (labelValue == nil)
        {
            date_type = nil;
            return date_type;
        }
        else
        {
            date_type = [[CusDateTextField alloc] initWithFrame:frame];
            
            if (!isInViewMode)
                date_type.enabled = NO;
            else
                date_type.enabled = readOnly;
            date_type.indexPath = indexPath;
            date_type.fieldAPIName = fieldType;
            date_type.required = required;
            date_type.controlDelegate = self;
            date_type.control_type = controlType;
            
            //sahana 16ht Aug
            NSRange range = [value  rangeOfString:@"-"];
            if(range.location == NSNotFound)
            {
                if(value != nil)
                {
                    date_type.text =  value;
                }
                else
                {
                    date_type.text = @"";
                }
                return date_type;
            }
            
            NSRange range1 = [value rangeOfString:value];
            
            NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
            if (range1.length > 11 )
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            else
                [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate * d = [formatter dateFromString:value];
            NSDateFormatter *format =[[[NSDateFormatter alloc]init] autorelease];
            [format setDateFormat:@"MMM dd yyyy"];
            NSString * str = [format stringFromDate:d];
            date_type.text = str;
            //sahana 16ht Aug
            if(value != nil && str == nil)
            {
                date_type.text = value;
            }
            //sahana 16ht Aug
            if(date_type.text == nil)
            {
                date_type.text = @"";
            }
            
            return date_type;
        }
    }
    
    if([controlType isEqualToString:@"string"])
    {
        //Keyboard fix for readonly fields
        BOOL isFieldEditable;
        if (!isInViewMode)
            isFieldEditable = NO;
        else
            isFieldEditable = readOnly;
        
        cusTextFieldAlpha  * string_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode isEditable:isFieldEditable];        string_control.controlDelegate = self;
        string_control.text = value;
        if (!isInViewMode)
            string_control.enabled = NO;
        else
            string_control.enabled = readOnly;
        string_control.indexPath = indexPath;
        string_control.fieldAPIName = fieldType;
        string_control.required = required;
        string_control.control_type = controlType;
        return string_control;
    }
    if([controlType isEqualToString:@"email"])
    {
        //Keyboard fix for readonly fields
        BOOL isFieldEditable;
        if (!isInViewMode)
            isFieldEditable = NO;
        else
            isFieldEditable = readOnly;
		
        cusTextFieldAlpha  * email_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode isEditable:isFieldEditable];
        email_control.controlDelegate = self;
        email_control.text = value;
        if (!isInViewMode)
            email_control.enabled = NO;
        else
            email_control.enabled = readOnly;
        email_control.indexPath = indexPath;
        email_control.fieldAPIName = fieldType;
        email_control.required = required;
        email_control.control_type = controlType;
        return email_control;
        
    }
    if([controlType isEqualToString:@"url"])
    {
        //Keyboard fix for readonly fields
        cusTextFieldAlpha  * url_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode isEditable:YES];
        url_control.controlDelegate = self;
        url_control.text = value;
        url_control.enabled = readOnly; // defect 007354
        url_control.indexPath = indexPath;
        url_control.fieldAPIName = fieldType;
        url_control.required = required;
        url_control.control_type = controlType;
        return url_control;
    }
    if([controlType isEqualToString:@"multipicklist"])
    {
        BMPTextView  * multipicklist_type = [[BMPTextView alloc] initWithFrame:frame initArray:datasource];
        multipicklist_type.text = value;
        if (!isInViewMode)
            multipicklist_type.enabled = NO;
        else
            multipicklist_type.enabled = readOnly;
        multipicklist_type.indexPath = indexPath;
        multipicklist_type.fieldAPIName = fieldType;
        multipicklist_type.required = required;
        multipicklist_type.control_type= controlType;
        multipicklist_type.controlDelegate = self;
        
        //Aparna: 5878
        multipicklist_type.TextFieldDelegate.isdependentPicklist =isdependentPicklist;
        multipicklist_type.TextFieldDelegate.validFor = validFor;
        multipicklist_type.TextFieldDelegate.controllerName = dependPick_controllerName;

        
        return multipicklist_type;
    }
    return nil;
    
}
// get the columns for the descriptor
-(NSInteger) HeaderColumns
{
	//Fix for avoiding crash
	NSUInteger count = 0;
	
	if (Disclosure_Fields != nil && [Disclosure_Fields count] > 0)
	{
		count = [Disclosure_Fields count];
	}
    return count;
}

//return number of rows
-(NSInteger) linesColumns
{
	//Fix for avoiding crash
	NSUInteger count = 0;
	
	if (Disclosure_Details != nil && [Disclosure_Details count] > 0)
	{
		count = [Disclosure_Details count];
	}
    return count;
}

#pragma mark -
#pragma mark FORMFILL
//Aparna: FORMFILL
- (void) setFormFillInfo:(NSDictionary *)formFillDict
       forPageLayoutDict:(NSMutableDictionary *)pageLayoutDict
                recordId:(NSString *)recordId
{
    NSMutableDictionary *detailDictionary = pageLayoutDict;    NSString *detailObjectName = [detailDictionary objectForKey:gDETAIL_OBJECT_NAME];
    NSMutableArray *pageFieldsInfo = [detailDictionary objectForKey:gDETAILS_FIELDS_ARRAY];
    for(NSMutableDictionary *detailFieldDict in pageFieldsInfo)
    {
        
        NSString * fieldApiName = [detailFieldDict valueForKey:gFIELD_API_NAME];
        NSString * fieldDataType = [detailFieldDict valueForKey:gFIELD_DATA_TYPE];
        
        NSArray *formFillFieldArray = [formFillDict allKeys];
        if ([formFillFieldArray containsObject:fieldApiName])
        {
            NSString *fieldValue = [formFillDict valueForKey:fieldApiName];
            
            NSString *evaluatedLiteral = [appDelegate.dataBase evaluateLiteral:fieldValue forControlType:fieldDataType];
            if ([evaluatedLiteral length] > 0 )
            {
                fieldValue = evaluatedLiteral;
            }
            
            if ([fieldDataType isEqualToString:@"date"] || [fieldDataType isEqualToString:@"datetime"])
            {
                fieldValue = [fieldValue stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            }
            
            NSMutableArray *detailValuesArray = [pageLayoutDict valueForKey:gDETAILS_VALUES_ARRAY];
            if ([detailValuesArray count]>0)
            {
                NSMutableArray *allValuesArray = [detailValuesArray objectAtIndex:selectedRowForDetailEdit];
                for (NSMutableDictionary *dict in allValuesArray)
                {
                    
                    if ([[dict valueForKey:gVALUE_FIELD_API_NAME] isEqualToString:fieldApiName])
                    {
                        [dict setValue:fieldValue forKey:gVALUE_FIELD_VALUE_KEY];
                        NSString *value = [self.parentReference getValueForApiName:fieldApiName dataType:fieldDataType object_name:detailObjectName field_key:fieldValue];
                        [dict setValue:value forKey:gVALUE_FIELD_VALUE_VALUE];
                        
                    }
                    
                }
                
            }
            
        }
    }
    
}

- (void)fillMappedFieldsForFieldAPIName:fieldAPI fieldKeyValue:fieldKeyValue
{
    NSMutableArray * fieldsArray = [self.Disclosure_dict objectForKey:gDETAILS_FIELDS_ARRAY];
    for(NSDictionary * detailValueDict in fieldsArray)
    {
        if([[detailValueDict objectForKey:gFIELD_API_NAME] isEqualToString:fieldAPI])
        {
            NSString * fieldMapping = [detailValueDict objectForKey:gFIELD_MAPPING];
            if ([fieldMapping length] != 0)
            {
                
                NSIndexPath *selectedRootIndexPath = [appDelegate.sfmPageController.rootView getSelectedIndexPath];
                
                NSString * referenceObj = [detailValueDict objectForKey:gFIELD_RELATED_OBJECT_NAME];
                NSMutableArray *detailArray = [appDelegate.SFMPage objectForKey:gDETAILS];
                
                NSDictionary * formfillDict = [appDelegate.databaseInterface recordsToUpdateForObjectId:fieldKeyValue mappingId:fieldMapping objectName:referenceObj];
                if([detailArray count] >= selectedRootIndexPath.row)
                {
                    [self setFormFillInfo:formfillDict forPageLayoutDict:[detailArray objectAtIndex:selectedRootIndexPath.row] recordId:nil];
                }
            }
        }
    }

}

#pragma mark - Custom Controls' Delegate Method

// Called when the Lookup value is updated by the user.
- (void) didUpdateLookUp:(NSString *)updatedValue fieldApiName:(NSString *)fieldApiName valueKey:(NSString *)key
{
    [self.tableView reloadData];
}
// row of editing 
- (void) controlIndexPath:(NSIndexPath *)indexPath
{
    currentEditRow = [indexPath retain];
    SMLog(kLogLevelVerbose,@"%@", currentEditRow);
}

// This one's ONLY for LOOKUP
- (void) selectControlAtIndexPath:(NSIndexPath *)indexPath
{
    currentEditRow = [indexPath retain];
}

//called on invokation of popover
- (void) setLookupPopover:(UIPopoverController *)popover
{
    lookupPopover = popover;
}

// Lookup History
- (void) addLookupHistory:(NSMutableArray *)lookupHistory forRelatedObjectName:(NSString *)relatedObjectName
{
   
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.lookupHistory == nil)
        appDelegate.lookupHistory = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    [appDelegate.lookupHistory setObject:lookupHistory forKey:relatedObjectName];
}


- (void) control:(id)control didChangeValue:(NSString *)value atIndexPath:(NSIndexPath *)indexPath
{
    // Obtain the section and row for the control being edited curently
    // Modify the field according to the Field_API_Name
    SMLog(kLogLevelVerbose,@"%@", value);
}
- (void) deselectControlAtIndexPath:(NSIndexPath *)indexPath
{
}


// Store values per session, Click of a item in popover (Operation performing)
- (void) updateDictionaryForCellAtIndexPath:(NSIndexPath *)indexPath fieldAPIName:(NSString *)fieldAPI fieldValue:(NSString *)fieldValue fieldKeyValue:(NSString *)fieldKeyValue controlType:(NSString *)control_type
{
    
    //sahana 26th sept 2011
    //control type
    if (!self.isInEditDetail)
    {
        // Determine if section is SHOWALLHEADER or SHOWHEADERSECTION and only then set dictionary value for fieldAPIName key
        // Header will have array of dictionaries
        // fetch the dictionary based on the indexPath and control in that row being edited
        // update dictionary value for key (fieldAPIName)
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {
            int row = indexPath.row;
            int section = indexPath.section;
            int index;
            
            if (isDefault)
                index = section;
            else
                index = selectedRow;
            
            NSMutableDictionary *header_section = [appDelegate.wsInterface GetHeaderSectionForSequenceNumber:index];
            int coloumns = [[header_section objectForKey:gSECTION_NUMBER_OF_COLUMNS] intValue];
            NSMutableArray * fields = [header_section objectForKey:gSECTION_FIELDS];
            NSMutableDictionary *fieldc1 = nil;
            NSMutableDictionary *fieldc2 = nil;
            
            for (int i=0;i < [fields count];i++)
            {
                if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
                    && [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 1)
                    fieldc1 = [fields objectAtIndex:i];
                
                if (coloumns == 2)
                {
                    if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
                        && [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 2)
                        fieldc2 = [fields objectAtIndex:i];
                }
            }
            //if there is only coloumn2 present, but not coloumn1, swap them! - pavamamn - check this. this does not sound right!
            if (fieldc1 == nil && fieldc2 != nil)
            {
                fieldc1 = fieldc2;
                fieldc2 = nil;
            }
            NSMutableArray * field_columns = [NSMutableArray arrayWithObjects:fieldc1, fieldc2, nil];
            for (int j = 0; j < [field_columns count]; j++)
            {
                NSMutableDictionary * dict = [field_columns objectAtIndex:j];
                NSString * fieldAPIName = [dict objectForKey:gFIELD_API_NAME];
                
                if([fieldAPIName isEqualToString:fieldAPI])
                {
                    if([control_type isEqualToString: @"picklist"])
                    {
                        if(appDelegate.isWorkinginOffline)
                        {
                            NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                            NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                            
                            //query to acces the picklist values for lines
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:headerObjName];
                            
                            
                            NSArray * allvalues = [picklistValues allValues];
                            NSArray * allkeys = [picklistValues allKeys];
                            
                            for(int i =0; i<[picklistValues count];i++)
                            {
                                NSString * value = [allvalues objectAtIndex:i];
                                if([value isEqualToString:fieldValue])
                                {
                                    fieldKeyValue = [allkeys objectAtIndex:i];
                                    break;
                                }
                            }
                            if(fieldKeyValue == nil)
                            {
                                fieldKeyValue = @"";
                            }
                            
                        }
                        else
                        {
                            for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
                            {
                                ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
                                ZKDescribeField * descField = [descObj fieldWithName:fieldAPIName];
                                if (descField == nil)
                                    continue;
                                else
                                {
                                    NSArray * pickListEntryArray = [descField picklistValues];
                                    for (int k = 0; k < [pickListEntryArray count]; k++)
                                    {
                                        NSString * value = [[pickListEntryArray objectAtIndex:k] label];
                                        if([value isEqualToString:fieldValue])
                                        {
                                            fieldKeyValue =[[pickListEntryArray objectAtIndex:k] value];
                                            break;
                                        }
                                        else
                                        {
                                            fieldKeyValue = @"";
                                        }
                                    }
                                    break;
                                }
                            }
                            
                            if(fieldKeyValue == nil)
                            {
                                fieldKeyValue = @"";
                            }
                        }
                        
                    }
                    if([control_type isEqualToString:@"multipicklist"])
                    {
                        NSMutableArray * keyVal	 = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                        NSString * keyValueString =[[[NSString alloc] init] autorelease];
                        
                        
                        if(appDelegate.isWorkinginOffline)
                        {
                            NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                            NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                            
                            //query to acces the picklist values for lines
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:headerObjName];
                            
                            
                            NSArray * allvalues = [picklistValues allValues];
                            NSArray * allkeys = [picklistValues allKeys];
                            NSArray * array = [fieldValue componentsSeparatedByString:@";"];
                            
                            for(int j = 0; j < [array count]; j++)
                            {
                                NSString * value_field = [array objectAtIndex:j];
                                
                                for(int i = 0; i < [picklistValues count]; i++)
                                {
                                    NSString * value = [allvalues objectAtIndex:i];
                                    if([value isEqualToString:value_field])
                                    {
                                        [keyVal addObject:[allkeys objectAtIndex:i]];
                                        break;
                                    }
                                }
                            }
                            
                            for(int j = 0 ; j < [keyVal count]; j++)
                            {
                                if ([keyValueString length] > 0)
                                    keyValueString = [keyValueString stringByAppendingString:[NSString stringWithFormat:@";%@", [keyVal objectAtIndex:j]]];
                                else
                                    keyValueString = [keyValueString stringByAppendingString:[keyVal objectAtIndex:j]];
                            }
                            
                            if([keyValueString length] == 0)
                            {
                                keyValueString = @"";
                            }
                            
                            fieldKeyValue = keyValueString;
                        }
                        
                    }
                    if([control_type isEqualToString: @"date"])
                    {
                        NSString * str = fieldValue;
                        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                        [frm setDateFormat: @"MMM dd yyyy"];
                        NSDate * date = [frm dateFromString:str];
                        [frm  setDateFormat:@"yyyy-MM-dd"];
                        NSString * final_date = [frm stringFromDate:date];
                        if ((final_date != nil) && (![str isEqualToString:@""]))
                        {
                            fieldValue = final_date;
                            fieldKeyValue = final_date;
                        }
                        else
                        {
                            fieldValue = @"";
                            fieldKeyValue = @"";
                        }
                    }
                    if([control_type isEqualToString:@"datetime"])
                    {
                        NSString * str = fieldValue;
                        
                        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                        [frm setDateFormat:DATETIMEFORMAT];
                        NSDate * date = [frm dateFromString:str];
                        [frm  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString * str1 = [frm stringFromDate:date];//.000Z
                        
                        // Convert this str1 back into GMT
                        str1 = [iOSInterfaceObject getGMTFromLocalTime:str1];
                        str1 = [str1  stringByReplacingOccurrencesOfString:@"Z" withString:@".000Z"];
                        if ((str1 != nil) && (![str isEqualToString:@""]))
                        {
                            fieldValue = str1;
                            fieldKeyValue = str1;
                        }
                        else
                        {
                            fieldValue = @"";
                            fieldKeyValue = @"";
                        }
                        SMLog(kLogLevelVerbose,@"%@",date);
                    }
                    if([fieldAPI isEqualToString:@"RecordTypeId"])
                    {
                        NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                        NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                        
                        fieldKeyValue =  [appDelegate.databaseInterface getRecordTypeIdForRecordTypename:fieldValue objectApi_name:headerObjName];
                        if (fieldKeyValue == nil || fieldValue == nil || [fieldValue length] == 0 || [fieldKeyValue length] == 0)
                        {
                            fieldKeyValue = @"";
                            fieldValue = @"";
                        }
                    }
                    
                    [dict setValue:fieldKeyValue forKey:gFIELD_VALUE_KEY];
                    [dict setValue:fieldValue    forKey:gFIELD_VALUE_VALUE];
                }
            }
        }
    }
    else
    {
        NSMutableArray * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
        
        for (int i = 0; i < [detail_values count]; i++)
        {
            NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
            if([fieldAPI isEqualToString:value_Field_API])
            {
                if([control_type isEqualToString: @"picklist"])
                {
                    if(appDelegate.isWorkinginOffline)
                    {
                        NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                        //query to acces the picklist values for lines
                        NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:value_Field_API tableName:SFPicklist objectName:detailObjectName];
                        
                        
                        NSArray * allvalues = [picklistValues allValues];
                        NSArray * allkeys = [picklistValues allKeys];
                        
                        for(int i =0; i<[picklistValues count];i++)
                        {
                            NSString * value = [allvalues objectAtIndex:i];
                            if([value isEqualToString:fieldValue])
                            {
                                fieldKeyValue = [allkeys objectAtIndex:i];
                                break;
                            }
                        }
                        if(fieldKeyValue == nil)
                        {
                            fieldKeyValue = @"";
                        }
                    }
                    
                }
                if([control_type isEqualToString:@"multipicklist"])
                {
                    
                    NSMutableArray * keyVal	 = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                    NSString * keyValueString =[[[NSString alloc] init] autorelease];
                    
                    if(appDelegate.isWorkinginOffline)
                    {
                        NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                        
                        //query to acces the picklist values for lines
                        NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:value_Field_API tableName:SFPicklist objectName:detailObjectName];
                        
                        
                        NSArray * allvalues = [picklistValues allValues];
                        NSArray * allkeys = [picklistValues allKeys];
                        NSArray * array = [fieldValue componentsSeparatedByString:@";"];
                        
                        for(int j = 0; j < [array count]; j++)
                        {
                            NSString * value_field = [array objectAtIndex:j];
                            
                            for(int i = 0; i < [picklistValues count]; i++)
                            {
                                NSString * value = [allvalues objectAtIndex:i];
                                if([value isEqualToString:value_field])
                                {
                                    [keyVal addObject:[allkeys objectAtIndex:i]];
                                    break;
                                }
                            }
                        }
                        
                        for(int j = 0 ; j < [keyVal count]; j++)
                        {
                            if ([keyValueString length] > 0)
                                keyValueString = [keyValueString stringByAppendingString:[NSString stringWithFormat:@";%@", [keyVal objectAtIndex:j]]];
                            else
                                keyValueString = [keyValueString stringByAppendingString:[keyVal objectAtIndex:j]];
                        }
                        
                        if([keyValueString length] == 0)
                        {
                            keyValueString = @"";
                        }
                        
                        fieldKeyValue = keyValueString;
                    }
                }
                
                if([control_type isEqualToString: @"date"])
                {
                    NSString * str = fieldValue;
                    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                    [frm setDateFormat: @"MMM dd yyyy"];
                    NSDate * date = [frm dateFromString:str];
                    [frm  setDateFormat:@"yyyy-MM-dd"];
                    NSString * final_date = [frm stringFromDate:date];
                    if ((final_date != nil) && (![str isEqualToString:@""]))
                    {
                        fieldValue = final_date;
                        fieldKeyValue = final_date;
                    }
                    else
                    {
                        fieldValue = @"";
                        fieldKeyValue = @"";
                    }
                }
                if([control_type isEqualToString:@"datetime"])
                {
                    NSString * str = fieldValue;
                    
                    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                    //10312
                    [frm setTimeZone:[NSTimeZone systemTimeZone]];
                    
                    [frm setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
                    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    [frm setCalendar:cal];
                    [cal release];
                    if ([Utility iSDeviceTime24HourFormat])
                    {
                        [frm  setDateFormat:DATETIMEFORMAT24HR];
                    }
                    else
                    {
                        [frm  setDateFormat:DATETIMEFORMAT];
                    }
                    NSDate * date = [frm dateFromString:str];
                    [frm  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString * str1 = [frm stringFromDate:date];//.000Z
                    
                    // Convert this str1 back into GMT
                    str1 = [iOSInterfaceObject getGMTFromLocalTime:str1];
                    str1 = [str1  stringByReplacingOccurrencesOfString:@"Z" withString:@".000Z"];
                    
                    if ((str1 != nil) && (![str isEqualToString:@""]))
                    {
                        fieldValue = str1;
                        fieldKeyValue = str1;
                    }
                    else
                    {
                        fieldValue = @"";
                        fieldKeyValue = @"";
                    }
                    SMLog(kLogLevelVerbose,@"%@",date);
                }
                if([fieldAPI isEqualToString:@"RecordTypeId"])
                {
                    
                    NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                    fieldKeyValue =  [appDelegate.databaseInterface getRecordTypeIdForRecordTypename:fieldValue objectApi_name:detailObjectName];
                    if (fieldKeyValue == nil || fieldValue == nil || [fieldValue length] == 0 || [fieldKeyValue length] == 0)
                    {
                        fieldKeyValue = @"";
                        fieldValue = @"";
                    }
                }
                //Aparna: FORMFILL
                if([control_type isEqualToString:@"reference"])
                {
                    [self fillMappedFieldsForFieldAPIName:fieldAPI fieldKeyValue:fieldKeyValue];
                }

                
                [[detail_values objectAtIndex:i] setValue:fieldValue forKey:gVALUE_FIELD_VALUE_VALUE];
                [[detail_values objectAtIndex:i] setValue:fieldKeyValue forKey:gVALUE_FIELD_VALUE_KEY];
                break;
            }
            
        }
    }
}

#pragma mark - TableView Datasource and delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.isInEditDetail)
    {
		//Fix for avoiding crash
		NSUInteger rowCount = 0;
        if (isDefault)
        {
            if (selectedSection == SHOWALL_HEADERS)
            {
                NSMutableDictionary *_header = [appDelegate.SFMPage objectForKey:gHEADER];
                NSMutableArray *header_sections = [_header objectForKey:gHEADER_SECTIONS];
				
				if (header_sections != nil && [header_sections count] > 0)
				{
					rowCount = [header_sections count];
				}
				
                return rowCount;
            }
            else if (selectedSection == SHOWALL_LINES)
            {
                NSMutableArray *details = [appDelegate.SFMPage objectForKey:gDETAILS];
				if (details != nil && [details count] > 0)
				{
					rowCount = [details count];
				}
				
                return rowCount;
            }
            else if (selectedSection == SHOW_ALL_ADDITIONALINFO)
            {
				if (appDelegate.additionalInfo != nil && [appDelegate.additionalInfo count] > 0)
				{
					rowCount = [appDelegate.additionalInfo count];
				}
				
                return rowCount;
            }
        }
        else
        {
            // Will always be 1 section
            return 1;
        }
    }
    else
        return 1;
    
    return 0;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        NSInteger row = 0;
        if (self.header == YES && self.line == NO)
        {
            row = [self HeaderColumns];
        }
        else
        {
            row = [self linesColumns];
        }
        return row;
        // Return number of items in the row dictionary
    return 0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;

    if (!self.isInEditDetail)
    {
        if(isInViewMode)
        {
            
            if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
            {
                NSInteger index;
                NSInteger section = indexPath.section;
                if (isDefault)
                    index = section;
                else
                    index = selectedRow;
                
                NSMutableDictionary *header_section = [appDelegate.wsInterface GetHeaderSectionForSequenceNumber:index];
                
                int coloumns = [[header_section objectForKey:gSECTION_NUMBER_OF_COLUMNS] intValue];
                NSMutableArray * fields = [header_section objectForKey:gSECTION_FIELDS];
                NSMutableDictionary *fieldc1 = nil;
                NSMutableDictionary *fieldc2 = nil;
                
                BOOL SLA_FLAG;
                SLA_FLAG = [[header_section objectForKey:gSLA_CLOCK] boolValue];
                if(SLA_FLAG)
                {
                    return gSTANDARD_TABLE_ROW_HEIGHT;
                }
                
                for (int i=0;i < [fields count];i++)
                {
                    if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
                        && [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 1)
                        fieldc1 = [fields objectAtIndex:i];
                    
                    if (coloumns == 2)
                    {
                        if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
                            && [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 2)
                            fieldc2 = [fields objectAtIndex:i];
                    }
                }
                //8th Sept 2011
                //if there is only coloumn2 present, but not coloumn1, swap them! - pavamamn - check this. this does not sound right!
                if (fieldc1 == nil && fieldc2 != nil)
                {
                    fieldc1 = fieldc2;
                    fieldc2 = nil;
                }
                
                NSMutableArray * field_columns = [NSMutableArray arrayWithObjects:fieldc1, fieldc2, nil];
                
                for (int j = 0; j < [field_columns count]; j++)
                {
                    NSMutableDictionary * dict = [field_columns objectAtIndex:j];
                    NSString *field_datatype=[dict objectForKey:gFIELD_DATA_TYPE];
                    if([field_datatype isEqualToString:@"textarea"])
                    {
                        return 93;
                    }
                }
            }
        }
        else
        {
            return gSTANDARD_TABLE_ROW_HEIGHT;
        }
    }
    else
    {
        if(isInViewMode)
        {
            NSString * control_type = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_DATA_TYPE];
            if([control_type isEqualToString:@"textarea"])
            {
                return 93;

            }
        }
        
    }
    return gSTANDARD_TABLE_ROW_HEIGHT;
}

- (UIView *) tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section
{
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
    NSInteger width = tableView1.frame.size.width;
    NSDictionary * oldValue = nil;
    
    UIView * background = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
        [background setAutoresizingMask:( UIViewAutoresizingFlexibleRightMargin )];
        [background setAutoresizesSubviews:YES];
        [cell setAutoresizesSubviews:YES];
    }
    else
    {
        background = [[cell.contentView subviews] objectAtIndex:0];
        NSArray * backgroundSubViews = [background subviews];
        // testing
        
        for (int i = 0; i < [backgroundSubViews count]; i++)
        {
            UIView * view = [backgroundSubViews objectAtIndex:i];
            if(view.tag == 1)
            {
                oldValue = [self valueForcontrol:view];
                
                break;
            }
        }
        //sahana  16th Aug
        for(int j = 0; j< [[cell.contentView subviews] count]; j++)
        {
            background = [[cell.contentView subviews] objectAtIndex:j];
            NSArray * backgroundSubViews = [background subviews];
            
            for (int i = 0; i < [backgroundSubViews count]; i++)
            {
                [[backgroundSubViews objectAtIndex:i] removeFromSuperview];
            }
            [background removeFromSuperview];
        }
        background = nil;
    }
    if(background == nil)
    {
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
    }
    if (self.header == YES)
    {
        return cell;
    }
    
    UIView * id_Type = nil;
    
    NSInteger control_height = 28;
    NSInteger row = [indexPath row];
    //adding label
    CGPoint p = cell.frame.origin;
    p.x = p.x + 10;
    CGSize size = cell.frame.size;
    size.width = size.width/2;
    NSMutableArray * arr = nil;
    
    CGRect lableframe = CGRectMake(background.frame.origin.x+7, background.frame.origin.y+6,240, background.frame.size.height);
    CGRect idFrame = CGRectMake(background.frame.origin.x+250, background.frame.origin.y+6, 350, background.frame.size.height);
    
    NSString * control_type = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_DATA_TYPE];
    
    //sahana 22nd Aug 2011
    if(isInViewMode)
    {
        if([control_type isEqualToString:  @"textarea"])
        {
            background.frame = CGRectMake(0, 0, width, 90);
            lableframe = CGRectMake(background.frame.origin.x+6, background.frame.origin.y,240,90);
            idFrame = CGRectMake(background.frame.origin.x+250, background.frame.origin.y, 350, 90);
        }
    }
    UILabel * lbl = [[[UILabel alloc] initWithFrame:lableframe] autorelease];
    NSString * label_name = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_LABEL];
	lbl.userInteractionEnabled = TRUE;
	UITapGestureRecognizer * singltTapForEdit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
	singltTapForEdit.numberOfTapsRequired = 1;
	[lbl addGestureRecognizer:singltTapForEdit];
	[singltTapForEdit release];
	
	lbl.text = label_name;
    lbl.textColor = [UIColor blackColor];
    lbl.backgroundColor = [UIColor clearColor];
    //sahana 23rd sept 2011
    if(!isInViewMode)
    {
        lbl.userInteractionEnabled = TRUE;
        UITapGestureRecognizer * tapMe_Value = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [lbl addGestureRecognizer:tapMe_Value];
        [tapMe_Value release];
        
    }
    
    NSString * field_API_Name = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_API_NAME];
    
    //control type
    NSMutableArray * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
    NSMutableArray * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
    NSMutableArray * details_Fields_Array = [Disclosure_dict objectForKey:gDETAILS_FIELDS_ARRAY];
    BOOL readOnly = [[[details_Fields_Array objectAtIndex:row] objectForKey:gFIELD_READ_ONLY] boolValue];
    
    NSString * value = @"";
    NSString * keyValue = nil;
    
    for (int i = 0; i < [detail_values count]; i++)
    {
        NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
        if ([field_API_Name isEqualToString:value_Field_API])
        {
            value = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_VALUE_VALUE];
            keyValue = [[detail_values objectAtIndex:i]  objectForKey:gVALUE_FIELD_VALUE_KEY];
			break;
        }
        
    }
    
    CGRect frame = CGRectMake(p.x+250, 6, tableView.frame.size.width-256-20,control_height);
    
    [background addSubview:lbl];
    // the process type is in View Mode
    if(!isInViewMode)
    {
        if([control_type isEqualToString:@"reference"])
        {
            NSString * key = keyValue;
            NSString * related_to_table_name = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_RELATED_OBJECT_NAME];
            NSString * api_name = field_API_Name;
            
            CusLabel * custLabel = [[CusLabel alloc] initWithFrame:idFrame];
            custLabel.backgroundColor = [UIColor clearColor];
            
            custLabel.text = value;
            custLabel.tapRecgLabel = value;  //RADHA 2012june07
            custLabel.controlDelegate = self;
			custLabel.userInteractionEnabled = TRUE;
            custLabel.id_ = key;
            custLabel.refered_to_table_name = related_to_table_name;
            custLabel.object_api_name = api_name;
			custLabel.isInDetailMode = YES;
			
            
            //Radha 2012june08
            BOOL recordExists = [appDelegate.dataBase checkIfRecordExistForObject:related_to_table_name Id:key];
			
			//Aparna: 6889
            if (!recordExists)
            {
                NSString *sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:related_to_table_name local_id:key];
                recordExists = [appDelegate.dataBase checkIfRecordExistForObject:related_to_table_name Id:sf_id];
            }
            
            
            BOOL flag_ = FALSE;
            
            if (recordExists)
            {
                for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
                {
                    NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
                    NSString * objName = [viewLayoutDict objectForKey:@"SPR14__Source_Object_Name__c"];
                    if ([objName isEqualToString:related_to_table_name])
                    {
                        flag_ = TRUE;
                        break;
                    }
                }
                if(flag_)
                {
                    custLabel.textColor = [UIColor blueColor];
					UITapGestureRecognizer * singltTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
					singltTap.numberOfTapsRequired = 1;
					[custLabel addGestureRecognizer:singltTap];
					
                    //8953 - Defect Fix
					UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOnReferenceLabel:)];
					doubleTap.numberOfTapsRequired = 2;
					[custLabel addGestureRecognizer:doubleTap];
					
                    //8953 - Defect Fix
                    [singltTap requireGestureRecognizerToFail:doubleTap];
                    [singltTap release];
                    [doubleTap release];
                }//Changes updated for reference fields
				else
				{
					UITapGestureRecognizer * singltTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
					singltTap.numberOfTapsRequired = 1;
					[custLabel addGestureRecognizer:singltTap];
					[singltTap release];
					
				}

            }
			else
			{
				UITapGestureRecognizer * singltTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
				singltTap.numberOfTapsRequired = 1;
				[custLabel addGestureRecognizer:singltTap];
				[singltTap release];

			}
            
            CGPoint cellCenter=cell.center;
            CGPoint controlCentre=custLabel.center;
            controlCentre.y=cellCenter.y;
            controlCentre=cellCenter;            
            [background addSubview:custLabel];
            [background bringSubviewToFront:custLabel];//8953 - Defect Fix
		}
        
        else
        {
            UILabel * value_lbl = [[[UILabel alloc] initWithFrame:idFrame] autorelease];
            
            value_lbl.backgroundColor = [UIColor clearColor];
            
            //sahana 23rd sept  2011
            value_lbl.userInteractionEnabled = TRUE;
            UITapGestureRecognizer * tapMe_Value = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [value_lbl addGestureRecognizer:tapMe_Value];
            [tapMe_Value release];
            
            if ([control_type isEqualToString:@"boolean"])
            {
                UIImageView *v1 = nil;
                
                if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"])
                {
                    v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                    v1.backgroundColor = [UIColor clearColor];
                    v1.frame = CGRectMake(idFrame.origin.x, 12, 18, 18);
                    v1.contentMode = UIViewContentModeCenter;
                    [background addSubview:v1];
                }
                else
                {
                    v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                    v1.backgroundColor = [UIColor clearColor];
                    v1.contentMode = UIViewContentModeCenter;
                    v1.frame = CGRectMake(idFrame.origin.x, 12, 18, 18);
                    [background addSubview:v1];
                }
                UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip-Edit.png"]] autorelease];
                bgView.backgroundColor=[UIColor colorWithRed:215 green:241 blue:252 alpha:1];

                cell.backgroundView = bgView;
                [cell.contentView addSubview:background];
                return cell;
            }
            
            //sahana Aug 10th 2010
            if([control_type isEqualToString:@"datetime"])
            {
                value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                value = [value stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
                //8945 - edtv
                value = [iOSInterfaceObject localTimeFromGMT:value];
                value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                //10312
                [frm setTimeZone:[NSTimeZone systemTimeZone]];
                
                [frm setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
                NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                [frm setCalendar:cal];
                [cal release];
                [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                NSDate * date = [frm dateFromString:value];
                //10312
                if ([Utility iSDeviceTime24HourFormat])
                {
                    [frm  setDateFormat:DATETIMEFORMAT24HR];
                }
                else
                {
                    [frm  setDateFormat:DATETIMEFORMAT];
                }
                value = [frm stringFromDate:date];
            }
            //sahana Aug 10th 2010
            if([control_type isEqualToString:@"date"])
            {
                NSRange range = [value rangeOfString:value];
                
                NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
                if (range.length > 11 )
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                else
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                NSDate * date = [formatter dateFromString:value];
                NSDateFormatter * format =[[[NSDateFormatter alloc]init] autorelease];
                [format setDateFormat:@"MMM dd yyyy"];
                value = [format stringFromDate:date];
            }
            value_lbl.text = value;
            
            CGPoint cellCenter=cell.center;
            CGPoint controlCentre=value_lbl.center;
            controlCentre.y=cellCenter.y;
            controlCentre=cellCenter;
            
            [background addSubview:value_lbl];
        }
        
        [cell.contentView addSubview:background];
        UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip-Edit.png"]] autorelease];
        bgView.backgroundColor=[UIColor colorWithRed:215 green:241 blue:252 alpha:1];

        cell.backgroundView = bgView;
        //Radha - Debrief UI Changes - separator - 18th June '13
		tableView.separatorColor = [UIColor  colorWithRed:255 green:251 blue:255 alpha:1];
        return cell;
    }
    
    NSString * refObjName = nil;
    NSString * refObjSearchId = nil;
    
    // Special handling for Lookup Additional Filter
    NSNumber * Override_Related_Lookup = nil;
    NSString * Field_Lookup_Context = @"";
    NSString * Field_Lookup_Query = @"";
    
    
    
    
    NSMutableArray * validFor = nil;
    BOOL isdependentPicklist = FALSE;
    NSString * dependPick_controllerName = @"";
    
    //krishna CONTEXTFILTER
    NSString *lookupContextSourceObject = @"";
    
    
    if ([control_type isEqualToString:@"reference"])
    {
        refObjName = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_RELATED_OBJECT_NAME];
        refObjSearchId = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_RELATED_OBJECT_SEARCH_ID];
        
        Override_Related_Lookup = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_OVERRIDE_RELATED_LOOKUP];
        Field_Lookup_Context = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_LOOKUP_CONTEXT];
        Field_Lookup_Query = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_LOOKUP_QUERY];
        
        //krishna CONTEXTFILTER
        lookupContextSourceObject = [[Disclosure_Details objectAtIndex:row] objectForKey:gCONTEXTSOURCEOBJ];
    }
    
    NSString * fieldAPIName = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_API_NAME];
    
    //5878
    if([control_type isEqualToString:  @"picklist"] || [control_type isEqualToString:@"multipicklist"])
    {
        if(appDelegate.isWorkinginOffline)
            
        {
            NSString * detail_objectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
            NSMutableArray * descObjArray = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray * descObjValidFor = [[NSMutableArray alloc] initWithCapacity:0];
            
            isdependentPicklist  = [[appDelegate.databaseInterface getPicklistINfo_isdependentOrControllername_For_field_name:DEPENDENT_PICKLIST field_api_name:fieldAPIName object_name:detail_objectName] boolValue];
            
            dependPick_controllerName = [appDelegate.databaseInterface getPicklistINfo_isdependentOrControllername_For_field_name:CONTROLLER_FIRLD field_api_name:fieldAPIName object_name:detail_objectName];
            

            
            //query to acces the picklist values for lines
            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:detail_objectName];
            
            NSArray * actual_keys = [picklistValues allKeys];
            
            NSArray * allvalues = [picklistValues allValues];
            
            NSMutableArray * allkeys_ordered = [[NSMutableArray alloc] initWithCapacity:0];
            
            if ([control_type isEqualToString: @"picklist"])
            {
                [allkeys_ordered addObject:@" "];
                [descObjArray addObject:@" "] ;
                [descObjValidFor addObject:@" "];
            }
            
			//Fix for Defect #4656
			allvalues = [appDelegate.calDataBase sortPickListUsingIndexes:allvalues WithfieldAPIName:fieldAPIName tableName:SFPicklist objectName:detail_objectName];
			
			for (NSString * str in allvalues )
            {
                [descObjArray addObject:str];
                
                for(NSString * actual_key in actual_keys)
                {
                    NSString * temp_actual_value =  [picklistValues objectForKey:actual_key];
                    if([temp_actual_value isEqualToString:str])
                    {
                        [allkeys_ordered  addObject:actual_key];
                        break;
                    }
                    
                }
            }
            
            if(isdependentPicklist)
            {
                
                NSMutableDictionary * temp_valid_for = [appDelegate.databaseInterface  getValidForDictForObject:detail_objectName field_api_name:fieldAPIName];
                
                NSArray * validForKeys  = [temp_valid_for allKeys];
                
                for(NSString * orderd_key  in allkeys_ordered)
                {
                    BOOL flag_ =  [validForKeys containsObject:orderd_key];
                    if(flag_)
                    {
                        NSString * value_validFor =  [temp_valid_for objectForKey:orderd_key];
                        [descObjValidFor addObject:(value_validFor!= nil)?value_validFor:@""];
                    }
                    
                }
            }
            
            arr = [[[NSMutableArray  alloc] initWithArray:descObjArray] autorelease];
            validFor = [[[NSMutableArray alloc] initWithArray:descObjValidFor] autorelease];
            [allkeys_ordered release];
            [descObjArray release];
            [descObjValidFor release];
        }
        
    }
    
    if ([control_type isEqualToString:@"reference"] && [fieldAPIName isEqualToString:@"RecordTypeId"])
    {
        NSString * detail_objectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
        arr = [appDelegate.databaseInterface getRecordTypeValuesForObjectName:detail_objectName];
    }
    if(oldValue != nil)
    {
        if([control_type isEqualToString:@"reference"])
        {
            
        }
        else
        {
            NSString * apiName = [oldValue objectForKey:DapiName];
            if([apiName isEqualToString:fieldAPIName])
            {
                // value = [oldValue  objectForKey:Dvalue];
            }
        }
    }
    //10346
    NSDictionary * precisionDict = nil;
    
    BOOL required = [[[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_REQUIRED] boolValue];
	
	NSString * object_api_name = [Disclosure_dict objectForKey:@"detail_object_name"];
    
    //10346
    //Defect :009746 Shubha

    if ([control_type isEqualToString:@"currency"] || [control_type isEqualToString:@"percent"] || [control_type isEqualToString:@"double"] )
    {
        precisionDict = (NSDictionary *)[appDelegate.dataBase getNumberFieldVadlidationData:fieldAPIName objectName:object_api_name validationField:MPRECISION];
    }

    
    id_Type = [self getControl:control_type withRect:idFrame withData:arr withValue:value fieldType:fieldAPIName labelValue:label_name enabled:!readOnly refObjName:refObjName referenceView:self.view indexPath:indexPath required:required valueKeyValue:keyValue lookUpSearchId:refObjSearchId overrideRelatedLookup:Override_Related_Lookup fieldLookupContext:Field_Lookup_Context fieldLookupQuery:Field_Lookup_Query dependentPicklistControllerName:dependPick_controllerName picklistValidFor:validFor picklistIsdependent:isdependentPicklist objectAPIName:object_api_name forSourceObject:lookupContextSourceObject percisionValue:precisionDict]; //10346
    
    /*Accessibility Changes*/
    id_Type.isAccessibilityElement = YES;
    NSString * identifier = [[NSString alloc] initWithFormat:@"%@%@", kAccInputlabel, label_name];
    [id_Type setAccessibilityIdentifier:identifier];
    [identifier release];
	
    
    id_Type.tag = 1;
    
    if (readOnly)
    {
        if ([control_type isEqualToString:@"boolean"])
        {
            UIImageView *v1 = nil;
            
            if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"])
            {
                v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                v1.backgroundColor = [UIColor clearColor];
                v1.frame = CGRectMake(idFrame.origin.x, 12, 18, 18);
                v1.contentMode = UIViewContentModeCenter;
                [background addSubview:v1];
            }
            else
            {
                v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                v1.backgroundColor = [UIColor clearColor];
                v1.contentMode = UIViewContentModeCenter;
                v1.frame = CGRectMake(idFrame.origin.x, 12, 18, 18);
                [background addSubview:v1];
            }
			//Defect Fix #7415
            UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip-Edit.png"]] autorelease];
            bgView.backgroundColor=[UIColor colorWithRed:215 green:241 blue:252 alpha:1];
            
            cell.backgroundView = bgView;
            [cell.contentView addSubview:background];
            return cell;
        }
    }
    
    [id_Type setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin)];
    CGPoint cellCenter1=cell.center;
    CGPoint controlCentre=id_Type.center;
    controlCentre.y=cellCenter1.y;
    controlCentre=cellCenter1;
    [background addSubview:id_Type];
    [cell.contentView addSubview:background];
    
    UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip-Edit.png"]] autorelease];
    bgView.backgroundColor=[UIColor colorWithRed:215 green:241 blue:252 alpha:1];
    
    cell.backgroundView = bgView;
	tableView.separatorColor = [UIColor whiteColor]; // Radha - Debrief UI Changes - 18 June '13
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (float) getHeightForEditView {
    
    NSInteger numberOfRows = [self tableView:self.tableView numberOfRowsInSection:0 ];
    float heightForView = 0.0;
    for (int i=0; i<numberOfRows; i++) {
        
        heightForView += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
	heightForTableView = heightForView; //Defect Fix :- 7447
    return heightForView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isInEditDetail)
    {
        if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
        {
            
            NSInteger i =  indexPath.row ;
            if(i == 0)
            {
                currentEditRow = nil;
                return;
            }
        }
    }
    currentEditRow = [indexPath retain];
}
-(void)keyBoardDidShow:(NSNotification *)notification
{	
	if ([self.detailDelegate respondsToSelector:@selector(moveTableviewForKeyboardHeight:)])
		[self.detailDelegate moveTableviewForKeyboardHeight:notification];

}
-(void)keyboardDidHide:(NSNotification *)notification
{
	if ([self.detailDelegate respondsToSelector:@selector(moveTableviewForKeyboardHeight:)])
		[self.detailDelegate moveTableviewForKeyboardHeight:notification];
}

//Defect:10775 fix

- (void)resignAllPrevResponsder:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell =  [self.tableView cellForRowAtIndexPath:self.currentEditRow];
    NSArray * allSubViews = [cell.contentView subviews];
    
    for ( UIView * background in allSubViews) {
        NSArray * backgroundSubViews = [background subviews];
        for (UIView *eachView in backgroundSubViews) {
            if ([eachView isKindOfClass:[UITextField class]] || [eachView isKindOfClass:[UITextView class]]) {
                [eachView resignFirstResponder];
            }
        }
    }
}

-(void)tapRecognized:(id)sender
{
    UITapGestureRecognizer * tap = sender;
    if ([tap.view isKindOfClass:[UILabel  class]])
    {
        UILabel * label = (UILabel *) tap.view;
        if(label.text == nil)
            return;
        //if the text length is 0 then dont show the popover
        if([label.text length] == 0)
            return;
        
        // content View class
       LabelPOContentView * label_popOver_content = [[LabelPOContentView alloc ] init];
        
        // calculating the size for the popover
        UIFont * font = [UIFont systemFontOfSize:17.0];
        CGSize size =[label.text  sizeWithFont:font];
        
        //subview for the content view
        UITextView * contentView_textView;
        if(size.width > 240)
        {
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 90);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 90)];
        }
        else
        {
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 34);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 34)];
        }
        
        contentView_textView.text = label.text;
        contentView_textView.font = font;
        contentView_textView.userInteractionEnabled = YES;
        contentView_textView.editable = NO;
        contentView_textView.textAlignment = UITextAlignmentCenter;
        [label_popOver_content.view addSubview:contentView_textView];
        
        CGSize size_po = CGSizeMake(label_popOver_content.view.frame.size.width, label_popOver_content.view.frame.size.height);
        UIPopoverController * label_popOver = [[UIPopoverController alloc] initWithContentViewController:label_popOver_content];
        [label_popOver setPopoverContentSize:size_po animated:YES];
        
        label_popOver.delegate = self;
		
        [label_popOver presentPopoverFromRect:CGRectMake(label.frame.size.width/2,14, 10, 10) inView:label permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
        [contentView_textView release];
        [label_popOver_content release];
        
    }
}

- (void) doubleTapOnReferenceLabel:(id)cusLabel
{
	UITapGestureRecognizer * tap = cusLabel;
    if ([tap.view isKindOfClass:[UILabel  class]])
    {
		AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        CusLabel * label = (CusLabel *) tap.view;
        if(label.text == nil)
            return;
        if([label.text length] == 0)
            return;
        
        NSString * reffered_to_table_name = label.refered_to_table_name;
        NSString * temp_record_id = label.id_;
		
        //Radha 2012june08 08:00
        BOOL recordExists = [appDelegate.dataBase checkIfRecordExistForObject:reffered_to_table_name Id:temp_record_id];
		
		//Aparna: 6889
        if (!recordExists)
        {
            NSString *sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:reffered_to_table_name local_id:temp_record_id];
            recordExists = [appDelegate.dataBase checkIfRecordExistForObject:reffered_to_table_name Id:sf_id];
        }

        if (recordExists == FALSE)
            return;
		
        NSString * record_id = [appDelegate.databaseInterface  getLocalIdFromSFId:temp_record_id tableName:reffered_to_table_name];
		
		//Aparna: 6889
        if (record_id == nil || [record_id isEqualToString:@""] || [record_id isEqualToString:@" "])
        {
            record_id = temp_record_id;
        }

        
        NSString * newProcessId = @"";
        for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
        {
            NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
            NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
            if ([objName isEqualToString:reffered_to_table_name])
            {
                newProcessId = [viewLayoutDict objectForKey:@"SPR14__ProcessID__c"];
                break;
            }
        }
        
        if([newProcessId length] != 0 && newProcessId != nil && [record_id length] != 0 && record_id  != nil )
        {
//			appDelegate.oldRecordId = currentRecordId;
//            appDelegate.oldProcessId = currentProcessId;
//            if(isInEditDetail)
//            {
//                [parentReference initAllrequriredDetailsForProcessId:newProcessId recordId:record_id object_name:reffered_to_table_name];
//                [parentReference fillSFMdictForOfflineforProcess:newProcessId forRecord:record_id ];
//                [parentReference didReceivePageLayoutOffline];
//            }
//            else
//            {
                [parentReference initAllrequriredDetailsForProcessId:newProcessId recordId:record_id object_name:reffered_to_table_name];
                [parentReference fillSFMdictForOfflineforProcess:newProcessId forRecord:record_id ];
                [parentReference didReceivePageLayoutOffline];
//            }
			
        }
    }
}
- (void)removeFromSuperview
{
	SMLog(kLogLevelVerbose,@"removeFromSuperview");
}

- (void)viewDidUnload {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	//Defect Fix :- 7382
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
