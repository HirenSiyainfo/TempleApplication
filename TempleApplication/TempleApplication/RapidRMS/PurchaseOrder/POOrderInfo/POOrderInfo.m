//
//  POOrderInfo.m
//  RapidRMS
//
//  Created by Siya10 on 14/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POOrderInfo.h"

@interface POOrderInfo ()

@property(nonatomic,weak)IBOutlet UILabel *lblTotalItem;
@property(nonatomic,weak)IBOutlet UILabel *lblTotalReOrderQTY;
@property(nonatomic,weak)IBOutlet UILabel *lblTotalCost;


@end

@implementation POOrderInfo


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setOrderInfo];
}

-(void)setOrderInfo{
    
    self.lblTotalItem.text = @"";
    self.lblTotalReOrderQTY.text = @"";
    self.lblTotalCost.text = @"";
    
    float totalQTYeach = 0.0;
    float totalCostPrice = 0.0;
    for( int iArr = 0 ; iArr < self.orderItemList.count; iArr++)
    {
        // Calculate Total CostPrice
        int iQty = [(self.orderItemList)[iArr][@"ReOrder"] intValue ];
        totalQTYeach = totalQTYeach + iQty;
        
        float iCost = [(self.orderItemList)[iArr][@"CostPrice"] floatValue ];
        totalCostPrice = totalCostPrice + (iQty * iCost);
        
        self.lblTotalItem.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.orderItemList.count];
        self.lblTotalReOrderQTY.text = [NSString stringWithFormat:@"%.0f",totalQTYeach];
        self.lblTotalCost.text = [NSString stringWithFormat:@"%.2f",totalCostPrice];
    }
    
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
