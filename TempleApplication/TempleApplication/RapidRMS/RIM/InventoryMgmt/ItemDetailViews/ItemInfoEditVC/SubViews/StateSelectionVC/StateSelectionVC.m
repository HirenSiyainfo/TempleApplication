//
//  StateSelectionVC.m
//  RapidRMS
//
//  Created by Siya on 18/03/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "StateSelectionVC.h"
#import "UITableView+AddBorder.h"
#import "DepartmentSelectionCell.h"

@interface StateSelectionVC () <UITableViewDataSource,UITableViewDelegate>
{
    NSInteger IndexSound;
    UIColor * colorDefault;
    UIColor * colorSelected;
    UIImage * imgDefault;
    UIImage * imgSelected;
}

@property (nonatomic, weak) IBOutlet UITableView *statesTableview;
@property (nonatomic, strong) NSMutableArray *stateSelectionArray;

@end

@implementation StateSelectionVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.stateSelectionArray = [[NSMutableArray alloc] initWithObjects:
                                @"None",@"Alabama",@"Alaska",@"Arizona",@"Arkansas",@"California",@"Colorado",
                                @"Connecticut",@"Delaware",@"District of Columbia",@"Florida",@"Georgia",
                                @"Hawaii",@"Idaho",@"Illinois",@"Indiana",@"Iowa",@"Kansas",@"Kentucky",@"Louisiana",
                                @"Maine",@"Maryland",@"Massachusetts",@"Michigan",@"Minnesota",@"Mississippi",
                                @"Missouri",@"Montana",@"Nebraska",@"Nevada",@"New Hampshire",@"New Jersey",
                                @"New Mexico",@"New York",@"North Carolina",@"North Dakota",@"Ohio",@"Oklahoma",
                                @"Oregon",@"Pennsylvania",@"Rhode Island",@"South Carolina",@"South Dakota",
                                @"Tennessee",@"Texas",@"Utah",@"Vermont",@"Virginia",@"Washington",@"West Virginia",
                                @"Wisconsin",@"Wyoming",nil];
    
    IndexSound = -1;
    colorDefault = [UIColor blackColor];
    colorSelected = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
    imgDefault = [UIImage imageNamed:@"radiobtn.png"];
    imgSelected = [UIImage imageNamed:@"radioselected.png"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:nil WithStockColor:nil borderWidth:1.0f bottomBorderSpace:RIMLeftMargin()];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stateSelectionArray.count;
}

- (void)setSelectedStateForLabel:(UILabel *)stateName
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DepartmentSelectionCell * cell=(DepartmentSelectionCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[DepartmentSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.lblDeptName.text = [NSString stringWithFormat:@"%@",(self.stateSelectionArray)[indexPath.row]];
    cell.lblDeptName.textColor = colorDefault;
    cell.imgIsSelected.image = imgDefault;
    if (IndexSound == indexPath.row)
    {
        cell.imgIsSelected.image = imgSelected;
        cell.lblDeptName.textColor = colorSelected;
    }
    
    if([cell.lblDeptName.text isEqualToString:_selectedState])
    {
        IndexSound = indexPath.row;
        cell.imgIsSelected.image = imgSelected;
        cell.lblDeptName.textColor = colorSelected;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IndexSound = indexPath.row;
    _selectedState = (self.stateSelectionArray)[indexPath.row];
    [self.statesTableview reloadData];
}

-(IBAction)backToAddVenderVC:(id)sender
{
    if([_selectedState isEqualToString:@"None"])
    {
        _selectedState = @"";
    }
    [self.stateSelectionDelegate selectedState:_selectedState];
    [self.navigationController popViewControllerAnimated:YES];
}


@end