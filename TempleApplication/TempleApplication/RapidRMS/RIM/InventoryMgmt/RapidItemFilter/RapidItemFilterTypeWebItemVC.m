//
//  RapidItemFilterTypeWebItemVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 15/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RapidItemFilterTypeWebItemVC.h"

@interface RapidItemFilterTypeWebItemVC () {
    NSArray * arrItemDisplauList;
}

@end

@implementation RapidItemFilterTypeWebItemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    arrItemDisplauList = [[NSArray alloc]initWithArray:self.arrAllItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lblMasterTitle.text = [NSString stringWithFormat:@"%@",[arrMasterTitle[self.filterType] uppercaseString]];
    self.lblMasterCount.text = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)self.arrFilterTypesSelectedItems.count,(unsigned long)self.arrAllItem.count];
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    [self.tblMasterList reloadData];
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return arrItemDisplauList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary * objMasterInfo = arrItemDisplauList[indexPath.row];
    cell.textLabel.text = [objMasterInfo valueForKey:@"name"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];

    if ([self.arrFilterTypesSelectedItems containsObject:objMasterInfo]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];
        cell.backgroundColor = [UIColor colorWithRed:0.220 green:0.494 blue:0.584 alpha:1.000];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id objMasterInfo = arrItemDisplauList[indexPath.row];
    if ([self.arrFilterTypesSelectedItems containsObject:objMasterInfo]) {
        [self.arrFilterTypesSelectedItems removeObject:objMasterInfo];
    }
    else {
        [self.arrFilterTypesSelectedItems addObject:objMasterInfo];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.lblMasterCount.text = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)self.arrFilterTypesSelectedItems.count,(unsigned long)self.arrAllItem.count];
}

@end
