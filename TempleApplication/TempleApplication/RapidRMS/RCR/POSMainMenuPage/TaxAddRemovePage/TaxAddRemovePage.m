//
//  TaxAddRemovePage.m
//  POSFrontEnd
//
//  Created by Triforce-Nirmal-Imac on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TaxAddRemovePage.h"
#import "RmsDbController.h"
#import "TaxMaster+Dictionary.h"
@interface TaxAddRemovePage ()
{
    NSMutableArray * resposetaxArray;
    
    MICheckBox * taxCheckBox;
}

@property (nonatomic, weak) IBOutlet UITableView * aTableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView * indicatorView;

@property (nonatomic, strong)NSMutableArray * arrayCheckedArry;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end


@implementation TaxAddRemovePage

@synthesize arrayCheckedArry;
@synthesize managedObjectContext = __managedObjectContext;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        _aTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    self.managedObjectContext=self.rmsDbController.managedObjectContext;

   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseTaxlist:) name:@"TaxResult" object:nil];
    
	resposetaxArray=[[NSMutableArray alloc]init];
	[self.view bringSubviewToFront:_indicatorView];
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
            taxDict[@"Amount"] = txMaster.amount;
            [resposetaxArray addObject:taxDict];
        }
    }
    [_indicatorView setHidden:YES];
    [_aTableView reloadData];
}

- (IBAction) toolBarActionHandler:(id)sender {
	switch ([sender tag]) {
		case 101:
            [self.rmsDbController playButtonSound];
            [self.view removeFromSuperview];
			/*[delegate.editItemPopover dismissPopoverAnimated:YES];
			delegate.editItemPopover = nil;*/
			break;
		case 102:
            [self.rmsDbController playButtonSound];
            arrayCheckedArry=[[NSMutableArray alloc]init];
            for(int i=0;i<resposetaxArray.count;i++){
                NSMutableDictionary *dict = resposetaxArray[i];
                
                if(dict[@"Checked"]){
                   // [dict setObject:[resposetaxArray valueForKey:@"TaxId"] forKey:@"TaxId"];
                   // [dict setObject:@"0.0" forKey:@"TaxAmount"];
                    [arrayCheckedArry addObject:dict];
                }
            }
//            delegate.itemtaxarray=[[NSMutableArray alloc] init];
			//delegate.itemtaxarray=[arrayCheckedArry mutableCopy];
         //   itemTax.itemSwipedTaxArray=[arrayCheckedArry mutableCopy];
            [self.view removeFromSuperview];
           // [delegate createtaxList];
          //  [itemTax createtaxList];
			break;
		default:
			break;
	}
}



#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return resposetaxArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	{
    taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
	[taxCheckBox setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[taxCheckBox setTitle:@"" forState:UIControlStateNormal];
	taxCheckBox.tag = indexPath.row;
	taxCheckBox.indexPath = [indexPath copy];
	taxCheckBox.delegate = self;
	/*if () {
		taxCheckBox.isChecked = YES;
	} else {*/
		taxCheckBox.isChecked = NO;
	//}
	[taxCheckBox setDefault];
    }
    NSMutableDictionary *dictTemp2 = resposetaxArray[indexPath.row];
    if([dictTemp2[@"Checked"]intValue]==1)
    {
        dictTemp2[@"Checked"] = @"1";
        taxCheckBox.isChecked = YES;
        [taxCheckBox setImage:[UIImage imageNamed:@"checkbox_ticked.png"] forState:UIControlStateNormal];
    }
    
    for(int i = 0;i<arrayCheckedArry.count;i++)
    {
        NSMutableDictionary *dictTemp = arrayCheckedArry[i];
        if([dictTemp[@"TaxId"]intValue] == [dictTemp2[@"TaxId"]intValue])
        {
            dictTemp2[@"Checked"] = @"1";
            taxCheckBox.isChecked = YES;
            [taxCheckBox setImage:[UIImage imageNamed:@"checkbox_ticked.png"] forState:UIControlStateNormal];
        }
    }

	[cell.contentView addSubview:taxCheckBox];
	
	UILabel * taxTypeName = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 200, 30)];
	taxTypeName.text = [NSString stringWithFormat:@"%@",[resposetaxArray[indexPath.row] valueForKey:@"TAXNAME"]];
	taxTypeName.numberOfLines = 0;
	taxTypeName.textAlignment = NSTextAlignmentLeft;
	taxTypeName.backgroundColor = [UIColor clearColor];
	taxTypeName.textColor = [UIColor blackColor];
	taxTypeName.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:taxTypeName];
	
	UILabel * taxTypePrecentage = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 50, 30)];
	taxTypePrecentage.text = [NSString stringWithFormat:@"%.2f%@",[[resposetaxArray[indexPath.row] valueForKey:@"PERCENTAGE"] floatValue],@"%"];
	taxTypePrecentage.numberOfLines = 0;
	taxTypePrecentage.textAlignment = NSTextAlignmentLeft;
	taxTypePrecentage.backgroundColor = [UIColor clearColor];
	taxTypePrecentage.textColor = [UIColor blackColor];
	taxTypePrecentage.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:taxTypePrecentage];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.crmController UserTouchEnable];

    taxCheckBox.tag = indexPath.row;
    taxCheckBox.indexPath = [indexPath copy];
    [taxCheckBox checkBoxClicked];
    [tableView reloadData];
}

#pragma mark -
#pragma mark Logic Implement





- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath {
 ///   NSMutableDictionary *dictTemp = [resposetaxArray objectAtIndex:indexPath.row];
 /*   NSInteger max = [[resposetaxArray valueForKeyPath:@"@max.PERCENTAGE"] integerValue];
    if([dictTemp objectForKey:@"Checked"])
    {
        [dictTemp removeObjectForKey:@"Checked"];
        NSMutableDictionary *dictTemp2 = [resposetaxArray objectAtIndex:indexPath.row];
        NSString *strTagString2=[dictTemp2 objectForKey:@"TAXNAME"];
        for(int i = 0;i<[arrayCheckedArry count];i++)
        {
            NSMutableDictionary *dictTemp = [arrayCheckedArry objectAtIndex:i];
            NSString *strTagString=[dictTemp objectForKey:@"TAXNAME"];
            
            if([strTagString isEqualToString:strTagString2])
            {
                [arrayCheckedArry removeObjectAtIndex:i];
            }
        }
    }
    else
    {
        [dictTemp setObject:@"1" forKey:@"Checked"];
    }
    [resposetaxArray replaceObjectAtIndex:indexPath.row withObject:dictTemp];
	if (checked) {
	} else {
	}*/
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
