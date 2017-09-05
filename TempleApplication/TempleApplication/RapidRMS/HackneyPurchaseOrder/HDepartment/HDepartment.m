//
//  HDepartment.m
//  RapidRMS
//
//  Created by Siya on 09/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "HDepartment.h"
#import "HCatalogCustomCell.h"
#import "HPurchaseOrderVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "Vendor_Item+Dictionary.h"

@interface HDepartment ()

@property (nonatomic, weak) IBOutlet UITableView *tblDepartment;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *departmentResultsetController;

@end

@implementation HDepartment
@synthesize managedObjectContext = __managedObjectContext;
@synthesize hpurchaseOrder;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    NSString  *catalogCell;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        catalogCell = @"HCatalogCustomCell_iPhone";
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:catalogCell bundle:nil];
    [self.tblDepartment registerNib:mixGenerateirderNib forCellReuseIdentifier:@"HCatalogCustomCell"];
    
//    [self departmentResultsetController];
//    [self.tblDepartment reloadData];
    // Do any additional setup after loading the view.
}

#pragma mark - Fetch Catalog Section

- (NSFetchedResultsController *)departmentResultsetController {
    
    if (_departmentResultsetController != nil) {
        return _departmentResultsetController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vendor_Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryDescription" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    fetchRequest.propertiesToFetch = @[@"categoryDescription"];
    
    _departmentResultsetController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"categoryDescription" cacheName:nil];
    
    [_departmentResultsetController performFetch:nil];
    _departmentResultsetController.delegate = self;
    
    NSArray *sections = self.departmentResultsetController.sections;
    if(sections.count==0)
    {
        return nil;
    }
    return _departmentResultsetController;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *viewTemp = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 35.0)];
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20.0, 8.0, 320.0, 23.0)];
   // NSMutableDictionary *dict = [self.arrayCatalogList objectAtIndex:section];
    lblTitle.text=@"Department";
    lblTitle.textColor =[UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0];
    
    viewTemp.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    UIView *viewBorder = [[UIView alloc]initWithFrame:CGRectMake(0.0, 34.0, 320.0, 1.0)];
    viewBorder.backgroundColor = [UIColor colorWithRed:2.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1.0];
    [viewTemp addSubview:viewBorder];
    [viewTemp addSubview:lblTitle];
    
    return viewTemp;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.departmentResultsetController.sections;
    return sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 58.0;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"HCatalogCustomCell";
    
    HCatalogCustomCell *catalogCell = (HCatalogCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSArray *sections = self.departmentResultsetController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[indexPath.row];
    
    catalogCell.lblSubName.text=sectionInfo.name;
    catalogCell.lblProducts.text=[NSString stringWithFormat:@"%ld Products", (unsigned long)sectionInfo.numberOfObjects];
    
    return catalogCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Vendor_Item *vitem = [self.departmentResultsetController objectAtIndexPath:indexPath];
    NSMutableDictionary *vendoritemDict = [vitem.getVendorItemDictionary mutableCopy];

    hpurchaseOrder.dictDept = vendoritemDict;
}

-(IBAction)btnDone:(id)sender{
    
//    if(hpurchaseOrder.dictDept)
//    {
//       [self.navigationController popViewControllerAnimated:YES];
//    }
//    else{
//        
//        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
//        {};
//        [self.rmsDbController popupAlertFromVC:self title:@"Message" message:@"Select  department" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
//    }
    
      [self.navigationController popViewControllerAnimated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
