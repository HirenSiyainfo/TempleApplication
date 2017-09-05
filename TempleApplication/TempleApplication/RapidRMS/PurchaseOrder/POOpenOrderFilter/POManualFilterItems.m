//
//  POManualFilterItems.m
//  RapidRMS
//
//  Created by Siya10 on 20/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POManualFilterItems.h"
#import "POBackOrderCell.h"

@interface POManualFilterItems ()

@property(nonatomic,weak)IBOutlet UITableView *tblManualFilter;
@property(nonatomic,strong)NSMutableArray *selectedOrders;

@end

@implementation POManualFilterItems


- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedOrders = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  115;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.manualFilterItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POBackOrderCell *poBackOrderCell = (POBackOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"POBackOrderCell"];
    poBackOrderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    poBackOrderCell.itemName.text=[NSString stringWithFormat:@"%@",[(self.manualFilterItems)[indexPath.row] valueForKey:@"ItemName"]];
    
    poBackOrderCell.barcode.text=[NSString stringWithFormat:@"%@",[(self.manualFilterItems)[indexPath.row] valueForKey:@"Barcode"]];
    
    poBackOrderCell.soldQty.text=[NSString stringWithFormat:@"%@",[(self.manualFilterItems)[indexPath.row] valueForKey:@"Sold"]];
    
    poBackOrderCell.availabeQty.text=[NSString stringWithFormat:@"%@",[(self.manualFilterItems)[indexPath.row] valueForKey:@"avaibleQty"]];
    
    poBackOrderCell.singleQty.text=[NSString stringWithFormat:@"%@",[(self.manualFilterItems)[indexPath.row] valueForKey:@"ReOrder"]];
    
    [poBackOrderCell.imgSelection setImage:[UIImage imageNamed:@"po_check.png"]];
    
    if([self.selectedOrders containsObject:indexPath]){
        [poBackOrderCell.imgSelection setImage:[UIImage imageNamed:@"po_check_selected.png"]];
    }
    
    poBackOrderCell.caseQty.text=@"0";
    
    poBackOrderCell.packQty.text=@"0";
    
    return poBackOrderCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedOrders containsObject:indexPath]){
        [self.selectedOrders removeObject:indexPath];
    }
    else{
        [self.selectedOrders addObject:indexPath];
    }
    [self.tblManualFilter reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
-(IBAction)saveManualFilterOption:(id)sender{
    
    [self.poManualFilterItemsDelegate didsaveWithSelectedItems:self.selectedOrders];
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)closeManualFilterOption:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
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
