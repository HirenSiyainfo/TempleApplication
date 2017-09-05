//
//  MMDAddDiscountTypeVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 19/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDAddDiscountTypeVC.h"
#import "MMDOfferListVC.h"
#import "MMDQTYItemListVC.h"
#import "MMDQTYMixAndMItemListVC.h"

@interface MMDAddDiscountTypeVC (){
    MMDOfferListVC * mMDOfferListVC;
}
@property (nonatomic, weak) IBOutlet UIView * viewOfferDetail;
@property (nonatomic, weak) IBOutlet UIButton * btnQTY;
@property (nonatomic, weak) IBOutlet UIButton * btnMixAndMathch;
@property (nonatomic, weak) IBOutlet UIButton * btnDefineManualD;

@end
@implementation MMDAddDiscountTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadValueToView];
    if (!mMDOfferListVC) {
        mMDOfferListVC = [[UIStoryboard storyboardWithName:@"MMDiscount"
                                                    bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDOfferListVC_sid"];
        mMDOfferListVC.view.frame = _viewOfferDetail.bounds;
        [self addChildViewController:mMDOfferListVC];
        [_viewOfferDetail addSubview:mMDOfferListVC.view];
    }
    
}
-(void)loadValueToView {
    switch ((MMDDiscountType)self.objMixMatch.discountType.intValue) {
        case MMDDiscountTypeQuantity: {
            _btnQTY.selected = TRUE;
            break;
        }
        case MMDDiscountTypeMandM: {
            _btnMixAndMathch.selected = TRUE;
            break;
        }
        case MMDDiscountTypeSD: {
            _btnDefineManualD.selected = TRUE;
            break;
        }
        default:{
            _btnQTY.selected = TRUE;
            self.objMixMatch.discountType = @(1);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions -

-(IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)changeDiscountType:(UIButton *)sender {
    _btnQTY.selected = FALSE;
    _btnMixAndMathch.selected = FALSE;
    _btnDefineManualD.selected = FALSE;
    sender.selected = TRUE;
    self.objMixMatch.discountType = @((int)sender.tag);
}

-(IBAction)btnSaveOrNext:(id)sender {

    switch ((MMDDiscountType)self.objMixMatch.discountType.intValue) {
        case MMDDiscountTypeQuantity: {
            MMDQTYItemListVC * mMDQTYItemListVC =
            [[UIStoryboard storyboardWithName:@"MMDiscount"
                                       bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDQTYItemListVC_sid"];
            mMDQTYItemListVC.moc = self.moc;
            mMDQTYItemListVC.objMixMatch = self.objMixMatch;
            [self.navigationController pushViewController:mMDQTYItemListVC animated:YES];
            break;
        }
        case MMDDiscountTypeMandM: {
            MMDQTYMixAndMItemListVC * mMDQTYMixAndMItemListVC  =
            [[UIStoryboard storyboardWithName:@"MMDiscount"
                                       bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDQTYMixAndMItemListVC_sid"];
            
            mMDQTYMixAndMItemListVC.moc = self.moc;
            mMDQTYMixAndMItemListVC.objMixMatch = self.objMixMatch;
            [self.navigationController pushViewController:mMDQTYMixAndMItemListVC animated:YES];
            break;
        }
        case MMDDiscountTypeSD: {
            break;
        }
    }
}
@end
