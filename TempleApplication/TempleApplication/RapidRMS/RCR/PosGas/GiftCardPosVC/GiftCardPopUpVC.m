//
//  GiftCardPopUpVC.m
//  RapidRMS
//
//  Created by Siya on 19/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GiftCardPopUpVC.h"

@interface GiftCardPopUpVC ()

@property (nonatomic , weak) IBOutlet UIButton *btnLoadTitle;

@end

@implementation GiftCardPopUpVC
@synthesize isRefund;

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.isRefund){
        [_btnLoadTitle setTitle:@"Refund Balance" forState:UIControlStateNormal];
    }
    else{
        [_btnLoadTitle setTitle:@"Load Balance" forState:UIControlStateNormal];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loadBalance:(id)sender{
    
    [self.giftCardPopUpDelegate opengiftCardView:YES withRefund:isRefund];
}

-(IBAction)checkBalance:(id)sender{
 
    [self.giftCardPopUpDelegate opengiftCardView:NO withRefund:NO];
}

@end
