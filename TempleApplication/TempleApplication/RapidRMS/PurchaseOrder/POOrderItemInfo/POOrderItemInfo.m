//
//  POOrderItemInfo.m
//  RapidRMS
//
//  Created by Siya10 on 15/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POOrderItemInfo.h"


@interface POOrderItemInfo ()

@property(nonatomic,weak)IBOutlet UILabel *itemCost;
@property(nonatomic,weak)IBOutlet UILabel *itemPrice;
@property(nonatomic,weak)IBOutlet UILabel *lastSold;
@property(nonatomic,weak)IBOutlet UILabel *lastWeek;
@property(nonatomic,weak)IBOutlet UILabel *last1Month;
@property(nonatomic,weak)IBOutlet UILabel *last6Month;
@property(nonatomic,weak)IBOutlet UILabel *last1Year;
@end

@implementation POOrderItemInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setItemInfo];
    // Do any additional setup after loading the view.
}
-(void)setItemInfo{
    
    self.itemCost.text = [NSString stringWithFormat:@"%@",self.orderitemInfo[@"Cost"]];
    self.itemPrice.text = [NSString stringWithFormat:@"%@",self.orderitemInfo[@"Price"]];
    self.lastSold.text = [NSString stringWithFormat:@"%@",self.orderitemInfo[@"LastSoldDate"]];
    self.lastWeek.text = [NSString stringWithFormat:@"%@",self.orderitemInfo[@"WeeklySoldQty"]];
    self.lastWeek.text = [NSString stringWithFormat:@"%@",self.orderitemInfo[@"WeeklySoldQty"]];
    self.last1Month.text = [NSString stringWithFormat:@"%@",self.orderitemInfo[@"MonthlySoldQty"]];
    self.last6Month.text = [NSString stringWithFormat:@"%@",self.orderitemInfo[@"SixMonthlySoldQty"]];
    self.last1Year.text = [NSString stringWithFormat:@"%@",self.orderitemInfo[@"YrarlySoldQty"]];
    
    
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
