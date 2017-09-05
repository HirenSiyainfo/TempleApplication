//
//  CCBatchForBridgePay.h
//  RapidRMS
//
//  Created by Siya-mac5 on 22/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCBatchForBridgePayDelegate <NSObject>
- (void)currentTransactionResponse:(id)response error:(NSError *)error;
- (void)deviceBatchDataForBridgePay:(NSMutableArray *)deviceBatchDataArray;
- (void)didErrorOccurredWhileGettingDeviceBatchDataThroughBridgePay;
- (void)didConnectionDroppedWhileGettingDeviceBatchDataThroughBridgePay;
- (void)didBatchSettledWithBatchSummry:(NSArray *)batchSummryArray batchInfo:(NSString *)batchInfo result:(NSInteger)result response:(NSString *)responseString;
- (void)errorOccurredInTipAdjustmentThroughRapidConnectServerWithMessage:(NSString *)message withTitle:(NSString *)title;
- (void)didErrorOccurredInBatchSettlementProcessWithMessage:(NSString *)responseMessage withTitle:(NSString *)title;
- (void)didTipsAdjustedSuccessfullyWithMessage:(NSString *)message withTitle:(NSString *)title;
- (void)startActivityIndicatorForBridgePay;
- (void)stopActivityIndicatorForBridgePay;
@end

@interface CCBatchForBridgePay : NSObject

@property (nonatomic, weak) id <CCBatchForBridgePayDelegate> cCBatchForBridgePayDelegate;
@property (nonatomic, strong) NSString *transctionServer;

- (void)getCurrentTransactionDataThroughBridgePayForDate:(NSString *)date;
- (void)deviceBatchDataForBridgePay;
- (void)tipsAdjustmentForBridgePayWithTipAmount:(CGFloat)tipAmount withTipsDictionary:(NSDictionary *)tipsDictionary;
- (void)batchSettlementProcessForBridgePay;
@end
