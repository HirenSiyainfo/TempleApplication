//
//  GenerateOrderTypePopUpVC.m
//  RapidRMS
//
//  Created by Siya on 23/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GenerateOrderTypePopUpVC.h"

@interface GenerateOrderTypePopUpVC ()
{
    NSMutableArray *arrGenerateOrderType;
}

@property (nonatomic, weak) IBOutlet UITableView *tblOrderType;

@end

@implementation GenerateOrderTypePopUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    arrGenerateOrderType = [[NSMutableArray alloc]initWithObjects:@"None",@"Daily",@"Weekly",@"Monthly",@"Quarterly",@"Yearly",@"DateWise", nil];
    [self.tblOrderType reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrGenerateOrderType.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.text=[NSString stringWithFormat: @"%@",arrGenerateOrderType[indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectGenerateOrderTypeFromArray:arrGenerateOrderType withIndexPath:indexPath];
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
