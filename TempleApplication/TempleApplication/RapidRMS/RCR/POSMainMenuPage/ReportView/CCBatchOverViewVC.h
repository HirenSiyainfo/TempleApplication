//
//  CCBatchOverViewVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 7/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCCbatchReportVC.h"

@interface CCBatchOverViewVC : UIViewController
@property (nonatomic , strong) NSMutableArray *creditCardDetail;
@property (nonatomic,assign) CCBatchFooterStruct ccBatchFooterStruct;

@end
