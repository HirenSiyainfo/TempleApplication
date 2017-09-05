//
//  POFilterType.m
//  RapidRMS
//
//  Created by Siya10 on 18/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POFilterType.h"
#import "RmsDbController.h"
#import "SupplierCompany+Dictionary.h"
#import "Department+Dictionary.h"
#import "RapidFilterMasterTypeCell.h"
#import "POFilterTypItem.h"
#import "POManualFilterItems.h"


@interface POFilterType ()<UpdateDelegate>


@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView *filterTypeTable;

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;

@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSArray *filterType;


@end

@implementation POFilterType

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.deptArray);
    self.filterType = @[@"Department",@"Supplier",@"Manual"];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.manageObjectContext = self.rmsDbController.managedObjectContext;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RapidFilterMasterTypeCell *cell = (RapidFilterMasterTypeCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.lblTitle.text = self.filterType[indexPath.row];
    cell.lblSubDetail.text = @"";
    UIView * viewBG = [[UIView alloc]init];
    viewBG.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];
    cell.selectedBackgroundView = viewBG;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
    POFilterTypItem *poFilterTypeItem = [storyBoard instantiateViewControllerWithIdentifier:@"POFilterTypItem"];
    if(indexPath.row == 0){
        poFilterTypeItem.itemList = self.deptArray;
    }
    else if(indexPath.row == 1){
        poFilterTypeItem.itemList = self.suppArray;
    }
    else if(indexPath.row == 2){
        
        [self.filterTypedelegate didloadManualFilterOption];
        return;
    }
    if(poFilterTypeItem.itemList.count >0 ){
        [self.navigationController pushViewController:poFilterTypeItem animated:YES];
    }
    
}
-(IBAction)applyFilterButton:(id)sender{
    
    [self.filterTypedelegate applyFilterButton:self.deptArray withSup:self.suppArray];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
