//
//  CustomerSignatureAlertVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/3/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CustomerSignatureAlertDelegate
-(void)didSignatureHereWithCardInfo:(NSDictionary *)cardInfo;
-(void)didManualReceiptForCustomerDisplay;

- (void)didSignSignature:(NSData *)signature signature:(UIImage *)signatureImage withCustomerDisplayTipAmount:(CGFloat )tipAmount;
@end



@interface CustomerSignatureAlertVC : UIViewController
@property (nonatomic,strong) NSDictionary *creditCardDictionary;
@property (nonatomic,strong) NSMutableDictionary *rcdSignatureDict;
@property (nonatomic,strong) NSDictionary *billAmountDictionary;
@property (nonatomic,weak) id <CustomerSignatureAlertDelegate>customerSignatureAlertDelegate;

@end
