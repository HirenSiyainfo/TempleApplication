//
//  XCCbatchReportVC.h
//  RapidRMS
//
//  Created by Siya on 24/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

////asdfasdfasdfas


typedef struct {
    void *totalTransction;
    void *totalTransctionAmount;
    void *totalAmount;
    void *totalTipAmount;
    void *totalAvgTicket;
    
}CCBatchFooterStruct;

@protocol XCCbatchReportDelegate
-(void)cancelCCBatchReport ;
@end


@interface XCCbatchReportVC : UIViewController <UITableViewDataSource,UITableViewDelegate, UIPickerViewDataSource,UIPickerViewDelegate,NSXMLParserDelegate>
{
    NSMutableArray *arrSettlement;
    NSMutableDictionary *dictSettlement;
}
@property(nonatomic,strong)NSString *parseingFunCall;
@property (nonatomic, weak) id <XCCbatchReportDelegate> xCCbatchReportDelegate;

@property(nonatomic,strong)NSNumber *isTipsApplicable;

@end
