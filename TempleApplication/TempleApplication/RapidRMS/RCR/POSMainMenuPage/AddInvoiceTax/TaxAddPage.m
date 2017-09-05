//
//  TaxAddRemovePage.m
//  POSFrontEnd
//
//  Created by Triforce-Nirmal-Imac on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TaxAddPage.h"
#import "RmsDbController.h"
#import "TaxMaster+Dictionary.h"


@interface TaxAddPage ()
{
    NSMutableArray * resposetaxArray;
    NSMutableArray * arrayCheckedArry;
    NSMutableArray * taxDetails;
}
@property (nonatomic, weak) IBOutlet UITableView * aTableView;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) MICheckBox * taxCheckBox;

@end

@implementation TaxAddPage

@synthesize managedObjectContext = __managedObjectContext;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

	taxDetails = [[NSMutableArray alloc] init];
	resposetaxArray=[[NSMutableArray alloc]init];
	[self getTaxTypeDetails];
	
}

- (void) getTaxTypeDetails
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"taxNAME" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        for (TaxMaster *txMaster in resultSet) {
            NSMutableDictionary *taxDict=[[NSMutableDictionary alloc]init];
            taxDict[@"TAXNAME"] = txMaster.taxNAME;
            taxDict[@"PERCENTAGE"] = txMaster.percentage;
            taxDict[@"TaxId"] = txMaster.taxId;
            taxDict[@"TaxAmount"] = txMaster.amount;
            [resposetaxArray addObject:taxDict];
        }
    }
    [_aTableView reloadData];
}

- (void) responseTaxlist:(NSNotification *)notification {
    NSMutableArray * responseData = notification.object;
    
    if ([[notification.object valueForKey:@"TaxResult"] count] > 0)
    {
        if ([[[notification.object valueForKey:@"TaxResult"] valueForKey:@"IsError"] intValue] == 0)
        {
            NSMutableArray *responsearray = [self.rmsDbController objectFromJsonString:[[responseData valueForKey:@"TaxResult"]  valueForKey:@"Data"]];
            
            if(responsearray.count>0)
            {
                [taxDetails removeAllObjects];
                resposetaxArray=[responsearray mutableCopy];
                [_aTableView reloadData];
            }
        }
    }
}
- (IBAction) toolBarActionHandler:(id)sender
{
	switch ([sender tag]) {
		case 101:
            [self.rmsDbController playButtonSound];
            self.crmController.taxtagvalue=101;
           
            [self.view removeFromSuperview];
            if (self.itemTaxEditDelegate)
            {
                [self.itemTaxEditDelegate didCancelItemTaxEdit];
            }
            else
            {
            }
            break;
		case 102:
            self.crmController.taxtagvalue=102;
            [self.rmsDbController playButtonSound];

            [self.itemTaxEditDelegate didEditItemWithItemTaxDetail:taxDetails];

            [self.view removeFromSuperview];
			break;
		default:
			break;
	}
}
-(NSString *) taxcalc{
    float taxAmt = 0.0;
    for (int i=0; i<taxDetails.count; i++) {
        taxAmt += [[taxDetails[i] valueForKey:@"ItemTaxAmount"] floatValue];
    }
    NSString *staxTotAmt=[NSString stringWithFormat:@"%@",[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",taxAmt]]];
    return staxTotAmt;
}
-(NSString *) taxpercentagecalc{
    float taxperc = 0.0;
    for (int i=0; i<taxDetails.count; i++) {
        taxperc += [[taxDetails[i] valueForKey:@"TaxPercentage"] floatValue];
    }
    NSString *staxTotper=[NSString stringWithFormat:@"%.2f%@",taxperc,@" %"];
    return staxTotper;
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return resposetaxArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	 self.taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
	[self.taxCheckBox setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.taxCheckBox setTitle:@"" forState:UIControlStateNormal];
	self.taxCheckBox.tag = indexPath.row;
	self.taxCheckBox.indexPath = [indexPath copy];
	self.taxCheckBox.delegate = self;
	/*if () {
		taxCheckBox.isChecked = YES;
	} else {*/
		self.taxCheckBox.isChecked = NO;
	//}
    
    NSMutableDictionary *dictTemp2 = resposetaxArray[indexPath.row];
    if([dictTemp2[@"Checked"]intValue]==1)
    {
        dictTemp2[@"Checked"] = @"1";
        self.taxCheckBox.isChecked = YES;
        [self.taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
    }
    
    for(int i = 0;i<arrayCheckedArry.count;i++)
    {
        NSMutableDictionary *dictTemp = arrayCheckedArry[i];
        if([dictTemp[@"TaxId"]intValue] == [dictTemp2[@"TaxId"]intValue])
        {
            dictTemp2[@"Checked"] = @"1";
            self.taxCheckBox.isChecked = YES;
            [self.taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
        }
    }
	[self.taxCheckBox setDefault];
	[cell.contentView addSubview:self.taxCheckBox];
	
	UILabel * taxTypeName = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 200, 30)];
	taxTypeName.text = [NSString stringWithFormat:@"%@",[resposetaxArray[indexPath.row] valueForKey:@"TAXNAME"]];
	taxTypeName.numberOfLines = 0;
	taxTypeName.textAlignment = NSTextAlignmentLeft;
	taxTypeName.backgroundColor = [UIColor clearColor];
	taxTypeName.textColor = [UIColor blackColor];
	taxTypeName.font = [UIFont fontWithName:@"Lato" size:16];
	[cell.contentView addSubview:taxTypeName];
	
	UILabel * taxTypePrecentage = [[UILabel alloc] initWithFrame:CGRectMake(220, 5, 70, 30)];
	taxTypePrecentage.text = [NSString stringWithFormat:@"%.2f%@",[[resposetaxArray[indexPath.row] valueForKey:@"PERCENTAGE"] floatValue],@"%"];
	taxTypePrecentage.numberOfLines = 0;
	taxTypePrecentage.textAlignment = NSTextAlignmentRight;
	taxTypePrecentage.backgroundColor = [UIColor clearColor];
	taxTypePrecentage.textColor = [UIColor blackColor];
	taxTypePrecentage.font = [UIFont fontWithName:@"Lato-Bold" size:15];
	[cell.contentView addSubview:taxTypePrecentage];
    
    UIImageView *imgBG = [[UIImageView alloc]initWithFrame:CGRectMake(15, 44, 300, 1)];
    imgBG.backgroundColor = [UIColor colorWithWhite:0.855 alpha:1.000];
    [cell.contentView addSubview:imgBG];

	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.taxCheckBox.indexPath = [indexPath copy];
    self.taxCheckBox.isChecked = YES;
    [self.taxCheckBox setDefault];
    [self.taxCheckBox checkBoxClicked];
    
    [tableView reloadData];
}


- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath {
    
    //hiten
    
	/*if (checked)
     {
     }
     else
     {
     }*/
    
    
    NSMutableDictionary *dictTemp = resposetaxArray[indexPath.row];
    
    if(dictTemp[@"Checked"])
    {
        [dictTemp removeObjectForKey:@"Checked"];
        NSMutableDictionary *dictTemp2 = resposetaxArray[indexPath.row];
        NSString *strTagString2=dictTemp2[@"TAXNAME"];
        for(int i = 0;i<taxDetails.count;i++)
        {
            NSMutableDictionary *dictTemp = taxDetails[i];
            NSString *strTagString=dictTemp[@"TAXNAME"];
            
            if([strTagString isEqualToString:strTagString2])
            {
                [taxDetails removeObjectAtIndex:i];
            }
        }
    }
    else
    {
        dictTemp[@"Checked"] = @"1";
        
        [self setUpTaxPriceArray:resposetaxArray[indexPath.row] withTextTypeIndex:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        
    }
    resposetaxArray[indexPath.row] = dictTemp;
    
    
}
- (void) setUpTaxPriceArray:(NSMutableDictionary *)itemObject withTextTypeIndex:(NSString *)index {
	
		NSMutableDictionary * taxDetailsObject = [[NSMutableDictionary alloc] init];
		//[taxDetailsObject setObject:[self getItemTaxAmtForItemPrice:[itemObject valueForKey:@"TAXNAME"] withObjectAtIndex:index] forKey:@"TAXNAME"];
    
        taxDetailsObject[@"TAXNAME"] = [resposetaxArray[index.intValue] valueForKey:@"TAXNAME"];
		taxDetailsObject[@"TaxAmount"] = [resposetaxArray[index.intValue] valueForKey:@"TaxAmount"];
		taxDetailsObject[@"TaxId"] = [resposetaxArray[index.intValue] valueForKey:@"TaxId"];
		taxDetailsObject[@"TaxPercentage"] = [resposetaxArray[index.intValue] valueForKey:@"PERCENTAGE"];
		[taxDetails addObject:taxDetailsObject];
	
}

- (void) removeObjectFromTaxDetailsArrayForId:(NSString *)taxId {
	for (int i=0; i<taxDetails.count; i++) {
		if ([[taxDetails[i] valueForKey:@"TaxId"] isEqual:taxId]) {
			[taxDetails removeObjectAtIndex:i];
		}
	}
}

- (NSString *) getItemTaxAmtForItemPrice:(NSString *)price withObjectAtIndex:(NSString *)index {
	NSString * returnTaxPrice = [NSString stringWithFormat:@"%.2f",([[resposetaxArray[index.intValue] valueForKey:@"PERCENTAGE"] floatValue]*price.floatValue)/100];
	return returnTaxPrice;
}




#pragma mark -
#pragma mark Mamory Management

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
//    [super dealloc];
}


@end
