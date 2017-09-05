//
//  ItemInfoPopupVC.m
//  RapidRMS
//
//  Created by Siya9 on 03/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ItemInfoPopupVC.h"

@interface ItemInfoPopupVC ()<UIGestureRecognizerDelegate,UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *lblNumOfProduct;
@property (nonatomic, weak) IBOutlet UILabel *lblAddedQTY;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalCost;
@end

@implementation ItemInfoPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lblNumOfProduct.text = _dictItemInfo[ItemInfoPopupVCNumOfProduct];
    self.lblAddedQTY.text = _dictItemInfo[ItemInfoPopupVCAddedQTY];
    self.lblTotalCost.text = _dictItemInfo[ItemInfoPopupVCTotalCost];
    
}
-(void)setDictItemInfo:(NSDictionary *)dictItemInfo {
    _dictItemInfo = dictItemInfo;
}
@end
