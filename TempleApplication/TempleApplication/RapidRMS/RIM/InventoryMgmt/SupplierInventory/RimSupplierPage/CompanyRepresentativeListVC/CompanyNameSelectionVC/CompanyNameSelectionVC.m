//
//  StateSelectionVC.m
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CompanyNameSelectionVC.h"
#import "UITableView+AddBorder.h"
#import "SupplierCompany+Dictionary.h"
#import "RmsDbController.h"
#import "RIMSupplierVendorCell.h"

@interface CompanyNameSelectionVC () <UITableViewDataSource,UITableViewDelegate>
{
    NSInteger IndexSound;
    NSString *selectedCompanyName;
    NSInteger selectedCompanyId;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) IBOutlet UITableView *companyNameTableview;
@property (nonatomic, strong) NSMutableArray *venderCompanyNames;

@end

@implementation CompanyNameSelectionVC
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.venderCompanyNames = [[NSMutableArray alloc] init];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    selectedCompanyName = @"";
    IndexSound = -1;
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioselected.png"];
    [self getSupplierDetails];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
            
            if([self.companyNameSelected isEqualToString:supplier.companyName])
            {
                selectedCompanyName = supplier.companyName;
                selectedCompanyId = supplier.companyId.integerValue;
            }
            [self.venderCompanyNames addObject:supplierDict];
        }
    }
    [self.companyNameTableview reloadData];
}

#pragma mark - Table view data source -

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venderCompanyNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIMSupplierVendorCell * cell=(RIMSupplierVendorCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[RIMSupplierVendorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.lblName.text = [NSString stringWithFormat:@"%@",[self.venderCompanyNames[indexPath.row] valueForKey:@"CompanyName"]];
    cell.lblContect.text = [NSString stringWithFormat:@"%@",[self.venderCompanyNames[indexPath.row] valueForKey:@"ContactNo"]];
    cell.lblName.textColor = [UIColor blackColor];
    cell.imgIsSelected.image = imgDefault;
    
    if (IndexSound == indexPath.row)
    {
        cell.lblName.textColor = colorSelected;
        cell.imgIsSelected.image = imgSelected;
    }
    else if(IndexSound == -1 && [cell.lblName.text isEqualToString:self.companyNameSelected]) {
        IndexSound = indexPath.row;
        cell.lblName.textColor = colorSelected;
        cell.imgIsSelected.image = imgSelected;
        
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IndexSound = indexPath.row;
    selectedCompanyName = [self.venderCompanyNames[indexPath.row] valueForKey:@"CompanyName"];
    selectedCompanyId = [[self.venderCompanyNames[indexPath.row] valueForKey:@"Id"] integerValue];

    [tableView reloadData];
}

-(IBAction)backToAddSalesRepVC:(id)sender
{
    if([selectedCompanyName isEqualToString:@"None"])
    {
        selectedCompanyName = @"";
    }
    [self.companyNameSelectionDelegate didSelectedCompanyName:selectedCompanyName SelectedCompanyID:selectedCompanyId];
    [self.navigationController popViewControllerAnimated:YES];
}


@end