//
//  POPendingOrderDetail.h
//  RapidRMS
//
//  Created by Siya10 on 14/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POmenuListDelegateVC.h"

@protocol  POPendingOrderDetailDelegate <NSObject>

-(void)insertDeliveryPendingOrder;

@end

@interface POPendingOrderDetail : UIViewController

@property(nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;
@property(nonatomic, weak) id<POPendingOrderDetailDelegate> pOPendingOrderDetailDelegate;

@property(nonatomic,strong) NSMutableDictionary *pendingOrderDict;
@property(nonatomic,assign)BOOL isDelivery;
@end
