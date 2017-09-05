//
//  SupplierPage.m
//

#import "RimSupplierPagePO.h"
#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import  "POmenuListVC.h"
#import "RmsDbController.h"


@interface RimSupplierPagePO ()
{
    IntercomHandler *intercomHandler;
    
    NSMutableArray *resposesupplierArray;
    NSMutableArray *arrayCheckedArry;
    NSMutableArray *checkedSupplier;

    NSString *strItemcode;
    NSString *callingFunction;
    
    MICheckBox *taxCheckBox;
}

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UITableView *aTableView;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *rimsController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end


@implementation RimSupplierPagePO

@synthesize strItemcode;
@synthesize callingFunction,checkedSupplier;

// CoreData Synthesize
@synthesize managedObjectContext = __managedObjectContext;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
	resposesupplierArray=[[NSMutableArray alloc]init];
	[self getSupplierDetails];
    [self getCheckedSupplier];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.navigationController.navigationBarHidden = YES;
    }
    else{
//          self._rimController.objPOMenuList.navigationController.navigationBarHidden = YES;
    }
    /*if(self.objGenerateOdr)
    {
        self.navigationController.navigationBarHidden = YES;
        
        
    }*/
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.navigationController.navigationBarHidden = NO;
    }
    else{
//        self._rimController.objPOMenuList.navigationController.navigationBarHidden = YES;

    }
    /*if(self.objGenerateOdr)
    {
        self.navigationController.navigationBarHidden = NO;
    }*/
}

-(void) getCheckedSupplier
{
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
            supplierDict[@"Email"] = supplier.email;
            [resposesupplierArray addObject:supplierDict];
        }
    }
    [_aTableView reloadData];
}

- (IBAction) toolBarActionHandler:(id)sender {
	switch ([sender tag]) {
		case 101:
            [self.view removeFromSuperview];
			break;
		case 102:
            arrayCheckedArry=[[NSMutableArray alloc]init];
            for(int i=0;i<resposesupplierArray.count;i++)
            {
                NSMutableDictionary *dict = resposesupplierArray[i];
                if(dict[@"Checked"]){
                    dict[@"ItemCode"] = strItemcode;
                    [arrayCheckedArry addObject:dict];
                }
                else
                {
                    dict[@"ItemCode"] = strItemcode;
                    [arrayCheckedArry removeObject:dict];
                }
            }
            if(arrayCheckedArry.count > 0)
            {
                if([callingFunction isEqualToString:@"SearchSupp"])
                {
//                    objSuppInven.arrFilterSupplier = [arrayCheckedArry mutableCopy];
//                    [objSuppInven getSupplierSearchData];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([callingFunction isEqualToString:@"add"])
                {
//                    if (delegate.itemInfoDataObject==nil) {
//                        delegate.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
//                    }
//                    delegate.itemInfoDataObject.itemsupplierarray=[arrayCheckedArry mutableCopy];
//                    [delegate createsupplierList];
                    [self.rimSupplierPagePODelegate didChangeSupplierPagePO:arrayCheckedArry withOtherData:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([callingFunction isEqualToString:@"Generate"])
                {
//                    objGenerateOdr.arrSelectedSupplier=[arrayCheckedArry mutableCopy];
//                    objGenerateOdr.uvSelectSupplier.hidden = NO;
//                    [objGenerateOdr displaySelectedSupplier];
                    [self.rimSupplierPagePODelegate didChangeSupplierPagePO:arrayCheckedArry withOtherData:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([callingFunction isEqualToString:@"NewManualEntry"])
                {
                    //objNewEntry.arrSelectedSupplier=[arrayCheckedArry mutableCopy];
                    NSDictionary * otherInfo;
                    if(arrayCheckedArry.count>0)
                    {
                        otherInfo = [[arrayCheckedArry mutableCopy] firstObject];
                    }
                    [arrayCheckedArry removeAllObjects];
                    [self.rimSupplierPagePODelegate didChangeSupplierPagePO:arrayCheckedArry withOtherData:otherInfo];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }
            else
            {
                if([callingFunction isEqualToString:@"Generate"])
                {
//                    objGenerateOdr.arrSelectedSupplier=[arrayCheckedArry mutableCopy];
//                    objGenerateOdr.uvSelectSupplier.hidden = YES;
//                    [objGenerateOdr displaySelectedSupplier];
                    [self.rimSupplierPagePODelegate didChangeSupplierPagePO:arrayCheckedArry withOtherData:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([callingFunction isEqualToString:@"NewManualEntry"])
                {
                    NSDictionary * otherInfo;
                    if(arrayCheckedArry.count>0)
                    {
                        otherInfo = [[arrayCheckedArry mutableCopy] firstObject];
                    }
                    [self.rimSupplierPagePODelegate didChangeSupplierPagePO:arrayCheckedArry withOtherData:otherInfo];
                     [arrayCheckedArry removeAllObjects];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([callingFunction isEqualToString:@"SearchSupp"])
                {
//                    objSuppInven.arrFilterSupplier = [arrayCheckedArry mutableCopy];
//                    [objSuppInven getSupplierSearchData];
//                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
//                    if (delegate.itemInfoDataObject==nil) {
//                        delegate.itemInfoDataObject=[[ItemInfoDataObject alloc]init];
//                    }
//                    delegate.itemInfoDataObject.itemsupplierarray=[arrayCheckedArry mutableCopy];
//                    [delegate createsupplierList];
                    [self.rimSupplierPagePODelegate didChangeSupplierPagePO:arrayCheckedArry withOtherData:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
			break;
		default:
			break;
	}
}



#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
        return 44;
//    }
//    else
//    {
//        return 49;
//    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return resposesupplierArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    CGRect suppNameFrame;
    CGRect companyNameFrame;
    CGRect contactNoFrame;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(290, 10, 22, 22)];
        suppNameFrame = CGRectMake(10, 7, 90, 30);
        companyNameFrame = CGRectMake(110, 7, 90, 30);
        contactNoFrame = CGRectMake(210 ,2, 80, 40);
    }
    else
    {
        taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(975, 10, 22, 22)];
        suppNameFrame = CGRectMake(20, 7, 280, 30);
        companyNameFrame = CGRectMake(400, 7, 250, 30);
        contactNoFrame = CGRectMake(720, 7, 220, 30);
    }
    
	//taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(3, 10, 20, 20)];
	[taxCheckBox setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[taxCheckBox setTitle:@"" forState:UIControlStateNormal];
	taxCheckBox.tag = indexPath.row;
	taxCheckBox.indexPath = [indexPath copy];
	taxCheckBox.delegate = self;
    taxCheckBox.isChecked = NO;
    [taxCheckBox setDefault];
	
	UILabel * taxTypeName = [[UILabel alloc] initWithFrame:suppNameFrame];
	taxTypeName.text = [NSString stringWithFormat:@"%@",[resposesupplierArray[indexPath.row] valueForKey:@"SupplierName"]];
	taxTypeName.numberOfLines = 2;
	taxTypeName.textAlignment = NSTextAlignmentLeft;
	taxTypeName.backgroundColor = [UIColor clearColor];
	taxTypeName.textColor = [UIColor blackColor];
	taxTypeName.font = [UIFont fontWithName:@"Lato" size:14];
	[cell.contentView addSubview:taxTypeName];
	
	UILabel * taxTypePrecentage = [[UILabel alloc] initWithFrame:companyNameFrame];
	taxTypePrecentage.text = [NSString stringWithFormat:@"%@",[resposesupplierArray[indexPath.row] valueForKey:@"Email"]];
	taxTypePrecentage.numberOfLines = 2;
	taxTypePrecentage.textAlignment = NSTextAlignmentLeft;
    taxTypePrecentage.backgroundColor = [UIColor clearColor];
	taxTypePrecentage.textColor = [UIColor blackColor];
	taxTypePrecentage.font = [UIFont fontWithName:@"Lato" size:14];
	[cell.contentView addSubview:taxTypePrecentage];
    
    UILabel *suppcontact = [[UILabel alloc] initWithFrame:contactNoFrame];
	suppcontact.text = [NSString stringWithFormat:@"%@",[resposesupplierArray[indexPath.row] valueForKey:@"ContactNo"]];
	suppcontact.numberOfLines = 2;
	suppcontact.textAlignment = NSTextAlignmentLeft;
    suppcontact.backgroundColor = [UIColor clearColor];
	suppcontact.textColor = [UIColor blackColor];
	suppcontact.font = [UIFont fontWithName:@"Lato" size:14];
	[cell.contentView addSubview:suppcontact];
    
    NSMutableDictionary *dictTemp2 = resposesupplierArray[indexPath.row];
    
    if([dictTemp2[@"Checked"]intValue]==1)
    {
        dictTemp2[@"Checked"] = @"1";
        taxCheckBox.isChecked = YES;
        [taxCheckBox setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail_sel"] forState:UIControlStateNormal];
        taxTypeName.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
        taxTypePrecentage.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
        suppcontact.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
    }
    
    for(int i = 0;i<checkedSupplier.count;i++)
    {
        NSMutableDictionary *dictTemp = checkedSupplier[i];
        if([dictTemp[@"Id"]intValue] == [dictTemp2[@"Id"]intValue])
        {
            dictTemp2[@"Checked"] = @"1";
            taxCheckBox.isChecked = YES;
            [taxCheckBox setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail_sel"] forState:UIControlStateNormal];
            taxTypeName.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
            taxTypePrecentage.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
            suppcontact.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];  
        }
    }
    
	[cell addSubview:taxCheckBox];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    taxCheckBox.indexPath = [indexPath copy];
    [taxCheckBox checkBoxClicked];
    [tableView reloadData];
}

#pragma mark -
#pragma mark Logic Implement

- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath
{
    if([callingFunction isEqualToString:@"NewManualEntry"])
    {
        for(int i=0;i<resposesupplierArray.count;i++){
            
            NSMutableDictionary *dictTemp = resposesupplierArray[i];
            if(dictTemp[@"Checked"]){
                [dictTemp removeObjectForKey:@"Checked"];
            }
            else if(i==indexPath.row){
                dictTemp[@"Checked"] = @"1";
                resposesupplierArray[indexPath.row] = dictTemp;
                
            }
        }
        [_aTableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self backtoPOEntryPage];
        });
       
    }
    else{
        
        NSMutableDictionary *dictTemp = resposesupplierArray[indexPath.row];
        if(dictTemp[@"Checked"])
        {
            [dictTemp removeObjectForKey:@"Checked"];
            NSMutableDictionary *dictTemp2 = resposesupplierArray[indexPath.row];
            NSString *strTagString2=dictTemp2[@"SupplierName"];
            for(int i = 0;i<checkedSupplier.count;i++)
            {
                NSMutableDictionary *dictTemp = checkedSupplier[i];
                NSString *strTagString=dictTemp[@"SupplierName"];
                if([strTagString isEqualToString:strTagString2])
                {
                    [checkedSupplier removeObjectAtIndex:i];
                }
            }
        }
        else
        {
            dictTemp[@"Checked"] = @"1";
        }
        resposesupplierArray[indexPath.row] = dictTemp;
        [_aTableView reloadData];
    }
    
    
}

-(void)backtoPOEntryPage{
    
    UIButton *btnTemp = [[UIButton alloc]init];
    btnTemp.tag = 102;
    [self toolBarActionHandler:btnTemp];
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

-(IBAction)backToItemView:(id)sender
{
    [self exitTimerViewController];
}

- (void)exitTimerViewController {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.view removeFromSuperview];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
