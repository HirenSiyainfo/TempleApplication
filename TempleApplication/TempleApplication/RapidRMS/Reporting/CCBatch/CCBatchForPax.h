//
//  CCBatchForPax.h
//  RapidRMS
//
//  Created by Siya-mac5 on 22/07/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InitializeResponse.h"
#import "LocalTotalReportResponse.h"
#import "BatchCloseResponse.h"
#import "LocalDetailReportResponse.h"
#import "DoCreditResponse.h"

@protocol CCBatchForPaxDelegate <NSObject>
- (void)currentTransactionResponse:(id)response error:(NSError *)error;
- (void)statusForOtherPaxDeviceConnection:(NSString *)paxDeviceStatus withPaxSerialNo:(NSString *)serialNo;
- (void)deviceSummaryDataThroughPax:(NSMutableArray *)deviceSummaryArray;
- (void)updateProgressStatusForFetchingPaxData:(CGFloat)percentage;
- (void)deviceBatchDataForPax:(NSMutableArray *)deviceBatchDataArray;

- (void)didBatchSettledWithDetails:(NSString *)batchJsonString totalTransactionCount:(NSInteger)totalTransactionCount totalAmount:(NSString *)totalAmount cCBatchNo:(NSString *)cCBatchNo batchMessage:(NSString *)batchMessage batchDictionary:(NSMutableDictionary *)batchDict;

- (void)didErrorOccurredInBatchSettlementProcessWithMessage:(NSString *)responseMessage;
- (void)paxDeviceFailedWhileBatchSettlementWithMessage:(NSString *)responseMessage;
- (void)paxDeviceFailedWhileGettingDeviceBatchDataWithMessage:(NSString *)responseMessage;
- (void)paxDeviceFailedDueToErrorWithMessage:(NSString *)responseMessage;
- (void)startActivityIndicatorForPax;
- (void)stopActivityIndicatorForPax;
- (void)processAfterVoidThroughPax;
@end

@interface CCBatchForPax : NSObject

@property (nonatomic, weak) id <CCBatchForPaxDelegate> cCBatchForPaxDelegate;

- (void)getCurrentTransactionDataThroughPaxForDate:(NSString *)date withPaxSerialNo:(NSString *)paxSerialNo;
- (void)deviceSummaryDataForPax;
- (void)deviceBatchDataForPax;
- (void)batchSettlementProcessForPax;
- (void)requestForConnectOtherPaxDevice;
- (void)paxTotalReport;
- (void)configureIPAndPortOfPaxDeviceAsPerSetting;
- (void)configureIPAndPortOfOtherPaxDevice:(NSDictionary *)paxDictionary;
- (NSDictionary *)paxInfoDictionary;
- (void)paxVoidTransactionProcessWithDictionary:(NSDictionary *)creditDictionary;
- (void)paxForceTransactionProcessWithDictionary:(NSDictionary *)creditDictionary withCaptureAmt:(NSString *)strCaptureAmt;
@end
