//
//  POFilterTypItem.m
//  RapidRMS
//
//  Created by Siya10 on 18/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POFilterTypItem.h"
#import "RapidFilterMasterTypeCell.h"
#import "RmsDbController.h"


@interface POFilterTypItem ()

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) IBOutlet UITableView *filterTypeTable;
@property (nonatomic, strong) NSMutableArray * arrFilterTypesSelectedItems;


@end

@implementation POFilterTypItem

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrFilterTypesSelectedItems = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.itemList.count;
}
-(IBAction)btnBackTapped:(id)sender{
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RapidFilterMasterTypeCell *cell = (RapidFilterMasterTypeCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *itemDict = self.itemList[indexPath.row];
    if(itemDict[@"Suppid"]){
       cell.lblTitle.text = itemDict[@"SuppName"];
    }
    else if(itemDict[@"DeptId"]){
         cell.lblTitle.text = itemDict[@"DeptName"];
    }
    cell.lblSubDetail.text = @"";
    UIView * viewBG = [[UIView alloc]init];
    viewBG.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];
    cell.selectedBackgroundView = viewBG;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if ([itemDict[@"selection"] integerValue] == 1)
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];
        cell.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];

    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *itemSelectionDict = self.itemList[indexPath.row];
    if ([itemSelectionDict[@"selection"] integerValue] == 1)
    {
       itemSelectionDict[@"selection"] = @"0";
    }
    else {
        itemSelectionDict[@"selection"] = @"1";
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
