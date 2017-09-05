//
//  POItemReceiveDetail.h
//  RapidRMS
//
//  Created by Siya10 on 15/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoDataObject.h"
#import "ItemInfoVC.h"

@protocol POItemReceiveDetailDelegate <NSObject>

-(void)didChangeItemDetail:(NSDictionary *)itemDetail;
-(void)didupdateItemInformation;
@end

@interface POItemReceiveDetail : UIViewController

@property (nonatomic, weak) id <POItemReceiveDetailDelegate>itemDetailDelegate;
@property (nonatomic, strong) ItemInfoDataObject * itemInfoDataObject;
@property (nonatomic, strong) NSMutableArray *itemPricingSelection;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) NSString *headeTitle;
@property (nonatomic, strong) NSMutableDictionary *receivePoDetail;
@property (nonatomic, strong) NSMutableDictionary *receiveItemDetail;
@property (nonatomic, strong) NSString *moduleCode;
@property (nonatomic, assign) BOOL isDelivery;

@end
