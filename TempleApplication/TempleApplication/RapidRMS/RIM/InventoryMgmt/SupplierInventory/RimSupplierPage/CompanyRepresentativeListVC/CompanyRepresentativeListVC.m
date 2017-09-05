//
//  CompanyRepresentativeListVC.m
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CompanyRepresentativeListVC.h"
#import "UITableView+AddBorder.h"
#import "RmsDbController.h"
#import "SupplierRepresentative+Dictionary.h"
#import "SupplierCompany+Dictionary.h"
#import "AddSalesRepresentativeVC.h"
#import "RIMSupplierVendorCell.h"


@interface CompanyRepresentativeListVC ()<NSFetchedResultsControllerDelegate>
{
    IntercomHandler *intercomHandler;
    UIColor * colorDefault;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * itemRepresentativeList;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, weak) IBOutlet UITableView *tblSuppRepresentative;
@property (nonatomic, weak) IBOutlet UIButton *infoBtn;
@property (nonatomic, weak) IBOutlet UIButton *btnAddCompanyRepresentative;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UILabel *lblAddCompanyRepresentative;

@end

@implementation CompanyRepresentativeListVC

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    if ([self.callingFunction isEqualToString:@"SearchSupp"]) {
        self.selectedSalesRepresentative = [[NSMutableArray alloc] init];
    }
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    colorDefault = [UIColor blackColor];
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioMulti_selected.png"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if([self.callingFunction isEqualToString:@"SearchSupp"])
    {
        CGRect frame = _infoBtn.frame;
        frame.origin.x = 70;
        _infoBtn.frame = frame;
        _btnAddCompanyRepresentative.hidden = YES;
        _lblAddCompanyRepresentative.hidden = YES;
    }
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [self.supplierRepresentative count];
    NSArray *sections = self.itemRepresentativeList.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIMSupplierVendorCell * cell=(RIMSupplierVendorCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[RIMSupplierVendorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    
    SupplierRepresentative *supplier = [self.itemRepresentativeList objectAtIndexPath:indexPath];
    
    cell.lblName.text = [NSString stringWithFormat:@"%@",supplier.companyName];
    
    cell.lblEmail.text = [NSString stringWithFormat:@"%@",supplier.firstName];
    cell.lblContect.text = [NSString stringWithFormat:@"%@",supplier.contactNo];
    cell.lblPosion.text = [NSString stringWithFormat:@"%@",supplier.position];
    cell.imgIsSelected.image = imgDefault;
    cell.lblName.textColor = colorDefault;
    cell.lblEmail.textColor = colorDefault;
    cell.lblContect.textColor = colorDefault;
    cell.lblPosion.textColor = colorDefault;

    NSMutableDictionary * curremtRepresentative = [self getRepresentativeDictInfoAt:indexPath];
    if([self.selectedSalesRepresentative containsObject:curremtRepresentative]) {

        cell.imgIsSelected.image = imgSelected;
        cell.lblName.textColor = colorSelected;
        cell.lblEmail.textColor = colorSelected;
        cell.lblContect.textColor = colorSelected;
        cell.lblPosion.textColor = colorSelected;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * curremtRepresentative = [self getRepresentativeDictInfoAt:indexPath];
    if([self.selectedSalesRepresentative containsObject:curremtRepresentative]) {
        [self.selectedSalesRepresentative removeObject:curremtRepresentative];
    }
    else {
        [self.selectedSalesRepresentative addObject:curremtRepresentative];
    }
    [self.tblSuppRepresentative reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    if(IsPhone())
//    {
//        self.navigationController.navigationBarHidden = NO;
//    }
}

-(NSDictionary *)getSelectedVenderName:(NSNumber *)selectedVenderId
{
    NSString *venderName = @"";
    NSNumber *venderId = @(0);

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierCompany" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %@",selectedVenderId];
    fetchRequest.predicate = predicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        for (SupplierCompany *supplier in resultSet)
        {
            venderName = supplier.companyName;
            venderId = supplier.companyId;
        }
    }
    NSDictionary *venderDict = @{@"VenderName":venderName ,@"VenderId":venderId};
    return venderDict;
}

-(IBAction)addSalesRepresentativeClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:RIMStoryBoard() bundle:nil];
    AddSalesRepresentativeVC *addSalesRepre = [storyBoard instantiateViewControllerWithIdentifier:@"AddSalesRepresentativeVC_sid"];
    
    NSDictionary *venderDict = [self getSelectedVenderName:self.supplierRepresentativeId];
    
    addSalesRepre.calledVenderName = [venderDict valueForKey:@"VenderName"];
    addSalesRepre.calledVenderId = [venderDict valueForKey:@"VenderId"];

    [self.navigationController pushViewController:addSalesRepre animated:YES];
}

- (IBAction)backToDepartmentView:(id)sender
{
    [self.companyRepresentativeDelegate didSelectCompnayRepresentatives:self.selectedSalesRepresentative];
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSMutableDictionary *)getRepresentativeDictInfoAt:(NSIndexPath *)indexPath{
    SupplierRepresentative *supplier = [self.itemRepresentativeList objectAtIndexPath:indexPath];
    return [self getRepresentativeInfo:supplier];
}
-(NSMutableDictionary *)getRepresentativeInfo:(SupplierRepresentative *)supplier{
    NSMutableDictionary *supplierDict = [[NSMutableDictionary alloc]init];
    supplierDict[@"FirstName"] = supplier.firstName;
    supplierDict[@"ContactNo"] = supplier.contactNo;
    supplierDict[@"Id"] = supplier.brnSupplierId;
    supplierDict[@"CompanyName"] = supplier.companyName;
    supplierDict[@"Position"] = supplier.position;
    supplierDict[@"Email"] = supplier.email;
    supplierDict[@"VendorId"] = self.supplierRepresentativeId;
    return supplierDict;
}
#pragma mark - CoreData Methods
- (NSFetchedResultsController *)itemRepresentativeList {
    
    if (_itemRepresentativeList != nil) {
        return _itemRepresentativeList;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupplierRepresentative" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId==%@",self.supplierRepresentativeId];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;

    _itemRepresentativeList = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_itemRepresentativeList performFetch:nil];
    _itemRepresentativeList.delegate = self;
    
    return _itemRepresentativeList;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemRepresentativeList]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblSuppRepresentative beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.itemRepresentativeList]) {
        return;
    }
    
    UITableView *tableView = self.tblSuppRepresentative;
    
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
    if (![controller isEqual:self.itemRepresentativeList]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblSuppRepresentative insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblSuppRepresentative deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.itemRepresentativeList]) {
        return;
    }
    [self.tblSuppRepresentative endUpdates];
}
@end
