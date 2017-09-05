//
//  PODeliveryPendingDetail.h
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POmenuListDelegateVC.h"

@protocol PODeliveryPendingDetailDelegate <NSObject>

-(void)didUpdateDeliveryList;

@end

@interface PODeliveryPendingDetail : UIViewController

@property(nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;
@property(nonatomic, weak) id<PODeliveryPendingDetailDelegate> poDeliveryPendingDetailDelegate;

@property(nonatomic,strong) NSMutableDictionary *deliveryOrderDict;

@end
