//
//  SlidingManuVC.m
//  RapidRMS
//
//  Created by Siya on 21/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "SlidingManuVC.h"

@interface SlidingManuVC ()

@property (nonatomic, strong) NSMutableArray *arrayManulist;
@end

@implementation SlidingManuVC
@synthesize manuSelecteItemDelegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.arrayManulist = [[NSMutableArray alloc]initWithObjects:@"NEW",@"RECALL",@"HISTORY",@"ABOUT US",@"LOGOUT", nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayManulist.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[cell viewWithTag:500]removeFromSuperview];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *lblManutitle = [[UILabel alloc]initWithFrame:CGRectMake(30.0, 10.0, 100.0, 30.0)];
    lblManutitle.tag = 500;
    lblManutitle.textColor = [UIColor whiteColor];
    lblManutitle.backgroundColor = [UIColor clearColor];
    lblManutitle.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    lblManutitle.text=(self.arrayManulist)[indexPath.row];
    [cell addSubview:lblManutitle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    [manuSelecteItemDelegate didSelectManu:(self.arrayManulist)[indexPath.row]];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
