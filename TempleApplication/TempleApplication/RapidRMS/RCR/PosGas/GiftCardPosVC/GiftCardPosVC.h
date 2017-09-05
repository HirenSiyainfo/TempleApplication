//
//  GiftCardPosVC.h
//  RapidRMS
//
//  Created by Siya on 28/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GiftCardPosDelegate <NSObject>

-(void)successfullDone:(NSString *)strAmount;
-(void)successfullDoneWithCardDetail:(NSMutableDictionary *)cardDetail;
-(void)didCancelGiftCard;
-(void)didSuccessfullGiftCardWithAccountNo:(NSString *)strAccno;

@end

@interface GiftCardPosVC : UIViewController
- (IBAction)GiftCardAutoGenerateNumber:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *GiftCadAutoGenerateBtn;

@property(nonatomic, weak)id <GiftCardPosDelegate>giftCardPosDelegate;
@property(nonatomic,weak)IBOutlet UITextField *txtGiftCardNo;
@property(nonatomic,weak)IBOutlet UITextField *txtLoadAmount;

@property(nonatomic,strong)NSMutableDictionary *dictCustomerInfo;
@property(nonatomic,strong)NSString *custName;
@property(nonatomic,strong) NSString *strInvoiceNo;

@property(nonatomic,assign)BOOL isLoad;
@property(nonatomic,assign)BOOL isFromTender;
@property(nonatomic,assign)BOOL isRefund;

@end
