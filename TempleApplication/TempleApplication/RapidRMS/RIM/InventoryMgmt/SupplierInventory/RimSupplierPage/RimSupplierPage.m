//
//  SupplierPage.m
//

#import "RimSupplierPage.h"
#import "UITableView+AddBorder.h"

#import "SupplierMaster+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "CompanyRepresentativeListVC.h"
#import "AddVenderVC.h"
#import "RmsDbController.h"
#import "RIMSupplierVendorCell.h"

@interface RimSupplierPage () <CompanyRepresentativeDelegate,NSFetchedResultsControllerDelegate>
{
    NSMutableArray *selectedSalesRepresentative;
    NSNumber *clickedVenderId;
    IntercomHandler *intercomHandler;
    NSMutableArray * arrayCheckedArry;
    NSMutableArray * supplierDetails;
    NSString * strSearchMaster;
    UIColor * colorDefault;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * itemSupplierList;

@property (nonatomic, strong) RmsDbController * rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, weak) IBOutlet UIButton * infoBtn;
@property (nonatomic, weak) IBOutlet UIButton * btnIntercom;
@property (nonatomic, weak) IBOutlet UIButton * btnAddVender;
@property (nonatomic, weak) IBOutlet UILabel * lblAddVender;
@property (nonatomic, weak) IBOutlet UITextField * txtMasterName;

@property (nonatomic, weak) IBOutlet UITableView * aTableView;

@property (nonatomic, assign) NSInteger objectIndex;
@end


@implementation RimSupplierPage

// CoreData Synthesize
@synthesize managedObjectContext = __managedObjectContext;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
	supplierDetails = [[NSMutableArray alloc] init];
    selectedSalesRepresentative = [[NSMutableArray alloc] init];

    if ([self.self.callingFunction isEqualToString:@"SearchSupp"]) {
        self.self.checkedSupplier = [[NSMutableArray alloc] init];
    }
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    colorDefault = [UIColor blackColor];
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioMulti_selected.png"];
    strSearchMaster = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![self.self.callingFunction isEqualToString:@"add"])
    {
        _btnAddVender.hidden = YES;
        _lblAddVender.hidden = YES;
    }
    else
    {
        _btnAddVender.hidden = NO;
        _lblAddVender.hidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction) toolBarActionHandler:(id)sender {
	switch ([sender tag]) {
		case 101:
            [self.view removeFromSuperview];
			break;
		case 102:
            arrayCheckedArry = [[NSMutableArray alloc]init];
            if([self.self.callingFunction isEqualToString:@"add"])
            {
                for(int i = 0; i < self.checkedSupplier.count; i++)
                {
                    NSMutableDictionary *dict = (self.checkedSupplier)[i];
                    dict[@"ItemCode"] = self.strItemcode;
                }
                arrayCheckedArry = [self.checkedSupplier mutableCopy];
            }
            else
            {
                arrayCheckedArry = [self.checkedSupplier mutableCopy];
            }
            
            if(arrayCheckedArry.count > 0)
            {
                if([self.callingFunction isEqualToString:@"SearchSupp"])
                {
                    [self.rimSupplierChangeDelegate didChangeSupplier:[arrayCheckedArry mutableCopy]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([self.callingFunction isEqualToString:@"add"])
                {
                    [self.rimSupplierChangeDelegate didChangeSupplier:[arrayCheckedArry mutableCopy]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([self.callingFunction isEqualToString:@"Generate"])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else
            {
                if([self.callingFunction isEqualToString:@"Generate"])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([self.callingFunction isEqualToString:@"SearchSupp"])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [self.rimSupplierChangeDelegate didChangeSupplier:[arrayCheckedArry mutableCopy]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
			break;
		default:
			break;
	}
}


#pragma mark - UITextFieldDelegate -

- (void)textFieldDidEndEditing:(UITextField *)textField {
    strSearchMaster = textField.text;
    [self reloadeMasterList];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    strSearchMaster = @"";
    [self reloadeMasterList];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    strSearchMaster = textField.text;
    [self reloadeMasterList];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {   // return NO to not change text
    if (_itemSupplierList.fetchedObjects.count > 0) {
        NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.aTableView scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
    strSearchMaster = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self reloadeMasterList];
    return YES;
}

-(IBAction)btnreloadeMasterList:(id)sender {
    [self.txtMasterName resignFirstResponder];
}
-(void)reloadeMasterList{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _itemSupplierList = nil;
        [self.aTableView reloadData];
    });
}

-(void)showMessageOfChangePriceTitle:(NSString *) messageTitle withMessage:(NSString *) message{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action){
    };
    [self.rmsDbController popupAlertFromVC:self title:messageTitle message:message buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPad()) {
        [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.itemSupplierList.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIMSupplierVendorCell * cell=(RIMSupplierVendorCell *)[self.aTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[RIMSupplierVendorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
	
    SupplierCompany *dept = [self.itemSupplierList objectAtIndexPath:indexPath];
    

	cell.lblName.text = [NSString stringWithFormat:@"%@",dept.companyName];
//    cell.lblEmail.text = [NSString stringWithFormat:@"%@",dept.email];
	cell.lblContect.text = [NSString stringWithFormat:@"%@",dept.phoneNo];
	cell.btnAction.hidden = TRUE;
    cell.imgIsSelected.image = imgDefault;
    cell.lblName.textColor = colorDefault;
//    cell.lblEmail.textColor = colorDefault;
    cell.lblContect.textColor = colorDefault;

    NSMutableDictionary *dictSelSupplier=[self getSupplierDictInfoAt:indexPath];

    if ([self isCheckedVenderOrNotVanderId:[dictSelSupplier valueForKey:@"VendorId"]]) {

        cell.lblName.textColor = colorSelected;
//        cell.lblEmail.textColor = colorSelected;
        cell.lblContect.textColor = colorSelected;
        [cell.btnAction setImage:[UIImage imageNamed:@"RIM_Com_Arrow_Detail"] forState:UIControlStateNormal];
        cell.imgIsSelected.image = imgSelected;

        cell.btnAction.hidden = FALSE;
        cell.btnAction.tag = indexPath.row;
        cell.btnAction.backgroundColor = [UIColor clearColor];
        [cell.btnAction addTarget:self action:@selector(btnSubCompanyClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];

	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictSelSupplier = [self getSupplierDictInfoAt:indexPath];
    
    if ([self isCheckedVenderOrNotVanderId:[dictSelSupplier valueForKey:@"VendorId"]]) {
        NSPredicate *salesRep = [NSPredicate predicateWithFormat:@"VendorId == %@",[dictSelSupplier valueForKey:@"VendorId"]];
        NSMutableArray *isVenderFound = [[self.checkedSupplier filteredArrayUsingPredicate:salesRep] mutableCopy];
        if(isVenderFound.count > 0)
        {
            [self.checkedSupplier removeObject:isVenderFound.firstObject];
        }
    }
    else {
        [self.checkedSupplier addObject:dictSelSupplier];
    }
    [_aTableView reloadData];
    
    if([self.callingFunction isEqualToString:@"POSearchSupp"]){
        NSMutableArray *vendorSelect = [[NSMutableArray alloc]init];
        [vendorSelect addObject:dictSelSupplier];
        [self.rimSupplierChangeDelegate didChangeSupplier:vendorSelect];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - CompanyRepresentative Methods -

-(IBAction)btnSubCompanyClicked:(id)sender
{
    UIButton *supplierButton = (UIButton *)sender;
    [self.rmsDbController playButtonSound];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    CompanyRepresentativeListVC *sales = [storyBoard instantiateViewControllerWithIdentifier:@"CompanyRepresentativeListVC_sid"];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:supplierButton.tag inSection:0];
    SupplierCompany * infoSupplier = [self.itemSupplierList objectAtIndexPath:indexPath];
    sales.supplierRepresentativeId = infoSupplier.companyId;
    clickedVenderId = infoSupplier.companyId;
    sales.self.callingFunction = self.callingFunction;
    sales.companyRepresentativeDelegate = self;
    
    NSPredicate *salesRep = [NSPredicate predicateWithFormat:@"VendorId == %@",clickedVenderId ];
    NSMutableArray *isVenderFound;
    isVenderFound = [[self.checkedSupplier filteredArrayUsingPredicate:salesRep] mutableCopy];
    if(isVenderFound.count > 0)
    {
        if (isVenderFound.firstObject[@"SalesRepresentatives"]) {
             sales.selectedSalesRepresentative = [isVenderFound.firstObject valueForKey:@"SalesRepresentatives"];
        }
        else {
            sales.selectedSalesRepresentative = [[NSMutableArray alloc]init];
        }
    }
    
    [self.navigationController pushViewController:sales animated:YES];
}

-(void)didSelectCompnayRepresentatives:(NSMutableArray *)selectedReprepsentative
{
    NSPredicate *salesRep = [NSPredicate predicateWithFormat:@"VendorId == %@",clickedVenderId ];
    NSMutableArray *isVenderFound = [[self.checkedSupplier filteredArrayUsingPredicate:salesRep] mutableCopy];
    if(isVenderFound.count > 0)
    {
        NSMutableDictionary *clickedVenderDict = isVenderFound.firstObject;
        [clickedVenderDict setValue:selectedReprepsentative forKey:@"SalesRepresentatives"];
    }
    //[selectedSalesRepresentative addObjectsFromArray:selectedRerepsentative];
}

-(NSMutableDictionary *)getSupplierDictInfoAt:(NSIndexPath *)indexPath{
    SupplierCompany *supplier = [self.itemSupplierList objectAtIndexPath:indexPath];
    return [self getSupplierDictInfo:supplier];
}

-(NSMutableDictionary *)getSupplierDictInfo:(SupplierCompany *)supplier {
    NSMutableDictionary *dictSelSupplier  = [[NSMutableDictionary alloc]init];
    dictSelSupplier[@"CompanyName"] = supplier.companyName;
    dictSelSupplier[@"Email"] = supplier.email;
    dictSelSupplier[@"ContactNo"] = supplier.phoneNo;
    dictSelSupplier[@"VendorId"] = supplier.companyId;
    dictSelSupplier[@"ItemCode"] = self.strItemcode;
    return dictSelSupplier;
}
-(BOOL)isCheckedVenderOrNotVanderId:(NSString *) strId {
    NSPredicate *salesRep = [NSPredicate predicateWithFormat:@"VendorId == %@",strId];
    NSMutableArray *isVenderFound = [[self.checkedSupplier filteredArrayUsingPredicate:salesRep] mutableCopy];
    if(isVenderFound.count > 0)
    {
        return true;
    }
    else{
        return false;
    }
}
-(IBAction)addVenderClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    AddVenderVC *addVender = [storyBoard instantiateViewControllerWithIdentifier:@"AddVenderVC_sid"];
    [self.navigationController pushViewController:addVender animated:YES];
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

#pragma mark - CoreData Methods
- (NSFetchedResultsController *)itemSupplierList {
    
    if (_itemSupplierList != nil) {
        return _itemSupplierList;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"companyName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    if (strSearchMaster.length > 0) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"companyName LIKE[cd] %@",[NSString stringWithFormat:@"*%@*",strSearchMaster]];
    }
    
    if ([UpdateManager countForContext:self.managedObjectContext FetchRequest:fetchRequest] == 0) {
        fetchRequest.predicate = nil;
        [self showMessageOfChangePriceTitle:@"Item Management" withMessage:[NSString stringWithFormat:@"No Record Found for %@",strSearchMaster]];
        strSearchMaster = @"";
        _txtMasterName.text = @"";
    }
    // Create and initialize the fetch results controller.
    _itemSupplierList = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_itemSupplierList performFetch:nil];
    _itemSupplierList.delegate = self;
    
    return _itemSupplierList;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemSupplierList]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [_aTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.itemSupplierList]) {
        return;
    }
    
    UITableView *tableView = _aTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.itemSupplierList]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_aTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_aTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemSupplierList]) {
        return;
    }
    [_aTableView endUpdates];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
