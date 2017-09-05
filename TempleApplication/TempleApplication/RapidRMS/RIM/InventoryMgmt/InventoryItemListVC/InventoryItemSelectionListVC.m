//
//  InventoryItemSelectionListVC.m
//  RapidRMS
//
//  Created by Siya9 on 16/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "InventoryItemSelectionListVC.h"

@interface InventoryItemSelectionListVC ()
@property (nonatomic, strong) NSIndexPath *indSingleSelectedItem;

@property (nonatomic, weak) IBOutlet UIButton *btnAddItems;

@end

@implementation InventoryItemSelectionListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isItemInSelectMode = TRUE;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.strNotSelectionMsg) {
        self.strNotSelectionMsg = @"You can't select this item";
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)btnAddItemsClick:(id)sender {
    [self.delegate didSelectedItems:self.arrItemSelected];
}
-(IBAction)btnCloseClick:(id)sender {
    [self.arrItemSelected removeAllObjects];
    [self.delegate didSelectedItems:self.arrItemSelected];
}

#pragma mark - Table view data source OverWrite -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSingleSelection) {
        [self.arrItemSelected removeAllObjects];
        if (self.indSingleSelectedItem) {
            [tableView reloadRowsAtIndexPaths:@[self.indSingleSelectedItem] withRowAnimation:UITableViewRowAnimationNone];
        }
        self.indSingleSelectedItem = [indexPath copy];
    }
    Item * anItem = [self.itemListRC objectAtIndexPath:indexPath];
    if ([self.arrNotSelectedItemCodes containsObject:anItem.itemCode]) {
        [self showMessage:self.strNotSelectionMsg];
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    }
    else{
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    self.btnAddItems.enabled = (self.arrItemSelected.count > 0);
}
@end
