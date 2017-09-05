//
//  PODeliveryListScan.h
//  RapidRMS
//
//  Created by Siya10 on 21/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PODeliveryListScanDelegate <NSObject>

-(void)didSelectScanItems:(NSMutableArray *)scannedItems;

@end

@interface PODeliveryListScan : UIViewController

@property (nonatomic, strong) NSMutableArray *deliveryDetailData;
@property (nonatomic, weak) id <PODeliveryListScanDelegate> pODeliveryListScanDelegate;

@end
