//
//  TaxAddRemovePage.m
//  POSFrontEnd
//
//  Created by Triforce-Nirmal-Imac on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SupplierPage.h"
#import "RmsDbController.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
@interface SupplierPage ()
{
    NSInteger objectIndex;
    
    NSMutableArray * resposesupplierArray;
    NSMutableArray * arrayCheckedArry;
    NSMutableArray * supplierDetails;
    
    MICheckBox *taxCheckBox;
}
@property(nonatomic,strong)NSMutableArray *checkedSupplier;

@property (nonatomic, assign) NSInteger objectIndex;

@property (nonatomic, weak) IBOutlet UITableView * aTableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView * indicatorView;

@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation SupplierPage

@synthesize objectIndex,checkedSupplier;
@synthesize managedObjectContext = __managedObjectContext;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext=self.rmsDbController.managedObjectContext;

    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        _aTableView.separatorInset = UIEdgeInsetsZero;
    }

   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responsesupplierlist:) name:@"SupplierDetailResult" object:nil];
    
	supplierDetails = [[NSMutableArray alloc] init];
	//prevTaxDetails = [[self.crmController.reciptDataAry objectAtIndex:objectIndex] valueForKey:@"ItemTaxDetail"];
	resposesupplierArray=[[NSMutableArray alloc]init];
	[self.view bringSubviewToFront:_indicatorView];
	[self getSupplierDetails];
    
    [self getCheckedSupplier];
	
}

-(void) getCheckedSupplier{
}

- (void) getSupplierDetails
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"companyName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        for (SupplierCompany *supplier in resultSet) {
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"SupplierName"] = supplier.companyName;
            supplierDict[@"ContactNo"] = supplier.phoneNo;
            supplierDict[@"Id"] = supplier.companyId;
            supplierDict[@"CompanyName"] = supplier.companyName;
            [resposesupplierArray addObject:supplierDict];
        }
    }
    [_indicatorView setHidden:YES];
    [_aTableView reloadData];
}

- (void)responsesupplierlist:(NSNotification *)notification
{
    NSMutableArray * responseData = notification.object;
    
    if ([[notification.object valueForKey:@"SupplierDetailResult"] count] > 0)
    {
        if ([[[notification.object valueForKey:@"SupplierDetailResult"] valueForKey:@"IsError"] intValue] == 0)
        {
            NSMutableArray *responsearray = [self.rmsDbController objectFromJsonString:[[responseData valueForKey:@"SupplierDetailResult"] valueForKey:@"Data"]];
            if(responsearray.count>0)
            {
                [supplierDetails removeAllObjects];
                resposesupplierArray=[responsearray mutableCopy];
                [_indicatorView setHidden:YES];
                [_aTableView reloadData];
            }
        }
    }
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
            for(int i=0;i<resposesupplierArray.count;i++){
                
                NSMutableDictionary *dict = resposesupplierArray[i];
                
                if(dict[@"Checked"]){
                    [arrayCheckedArry addObject:dict];
                }
            }
            //delegate.itemsupplierarray=[arrayCheckedArry mutableCopy];
          //  item.itemSwipedSupplierArray=[arrayCheckedArry mutableCopy];
          //  [item createsupplierList];
            
            [self.view removeFromSuperview];
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
	return resposesupplierArray.count;
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
    NSMutableDictionary *dictTemp2 = resposesupplierArray[indexPath.row];
    
   if([dictTemp2[@"Checked"]intValue]==1)
    {
        dictTemp2[@"Checked"] = @"1";
        taxCheckBox.isChecked = YES;
        [taxCheckBox setImage:[UIImage imageNamed:@"checkbox_ticked.png"] forState:UIControlStateNormal];
    }
    
    
    for(int i = 0;i<checkedSupplier.count;i++)
    {
        NSMutableDictionary *dictTemp = checkedSupplier[i];
        if([dictTemp[@"Id"]intValue] == [dictTemp2[@"Id"]intValue])
        {
            dictTemp2[@"Checked"] = @"1";
            taxCheckBox.isChecked = YES;
         [taxCheckBox setImage:[UIImage imageNamed:@"checkbox_ticked.png"] forState:UIControlStateNormal];
        }
    }
        
	[cell.contentView addSubview:taxCheckBox];
	
	UILabel * taxTypeName = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 200, 30)];
	taxTypeName.text = [NSString stringWithFormat:@"%@",[resposesupplierArray[indexPath.row] valueForKey:@"SupplierName"]];
	taxTypeName.numberOfLines = 0;
	taxTypeName.textAlignment = NSTextAlignmentLeft;
	taxTypeName.backgroundColor = [UIColor clearColor];
	taxTypeName.textColor = [UIColor blackColor];
	taxTypeName.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:taxTypeName];
	
	UILabel * taxTypePrecentage = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 150, 30)];
	taxTypePrecentage.text = [NSString stringWithFormat:@"%@",[resposesupplierArray[indexPath.row] valueForKey:@"Companyname"]];
	taxTypePrecentage.numberOfLines = 0;
	taxTypePrecentage.textAlignment = NSTextAlignmentRight;
	taxTypePrecentage.backgroundColor = [UIColor clearColor];
	taxTypePrecentage.textColor = [UIColor blackColor];
	taxTypePrecentage.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:taxTypePrecentage];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.crmController UserTouchEnable];

    taxCheckBox.indexPath = [indexPath copy];
    taxCheckBox.isChecked = YES;
    [taxCheckBox setDefault];
    [taxCheckBox checkBoxClicked];
  // [tableView reloadData];
	
}

#pragma mark -
#pragma mark Logic Implement




- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath {
    
  /*  NSString *max = [checkedSupplier valueForKeyPath:@"@max.Id"];
//    int iInt1 = (int)index1;
  //  NSDictionary *selectedBuilding = [checkedSupplier objectAtIndex: iInt1];
    for (int i=0; i<=[checkedSupplier count]; i++) {
        
    if ([checkedSupplier containsObject:max]) {
        [checkedSupplier removeObjectAtIndex:i];
    }
    }
    NSMutableDictionary *dictTemp = [resposesupplierArray objectAtIndex:indexPath.row];
    
    if([dictTemp objectForKey:@"Checked"])
    {
        [dictTemp removeObjectForKey:@"Checked"];
        NSMutableDictionary *dictTemp2 = [resposesupplierArray objectAtIndex:indexPath.row];
        NSString *strTagString2=[[dictTemp2 objectForKey:@"SupplierName"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        for(int i = 0;i<[checkedSupplier count];i++)
        {
            NSMutableDictionary *dictTemp = [checkedSupplier objectAtIndex:i];
            NSString *strTagString=[dictTemp objectForKey:@"SupplierName"];
            
            if([strTagString isEqualToString:strTagString2])
            {
                [checkedSupplier removeObjectAtIndex:i];
            }
        }
    }
    else{
        [dictTemp setObject:@"1" forKey:@"Checked"];
    }
    
    [resposesupplierArray replaceObjectAtIndex:indexPath.row withObject:dictTemp];
    [aTableView reloadData];

    
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
