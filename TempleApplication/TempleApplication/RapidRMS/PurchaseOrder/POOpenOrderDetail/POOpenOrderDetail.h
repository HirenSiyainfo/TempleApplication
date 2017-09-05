//
//  POOpenOrderDetail.h
//  RapidRMS
//
//  Created by Siya10 on 14/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POmenuListDelegateVC.h"

@protocol POOpenOrderDetailDelegate <NSObject>
-(void)didCreateOpenOrder;
@end

@interface POOpenOrderDetail : UIViewController

@property(nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;
@property(nonatomic, weak) id<POOpenOrderDetailDelegate> pOOpenOrderDetailDelegate;

@property(nonatomic,strong) NSMutableDictionary *openOrderDict;
@property (nonatomic, strong) NSMutableArray *openOrderDetailData;
@property (nonatomic, strong) NSMutableArray *globalopenOrderDetailData;
-(void)addFilter:(NSMutableArray *)arrtempPoDataTempG;
@end
