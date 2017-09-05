//
//  ManualItemReceiveVC.h
//  RapidRMS
//
//  Created by Siya on 12/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoDataObject.h"

@interface ManualItemReceiveVC : UIViewController {
    
}

@property (nonatomic, strong) ItemInfoDataObject *itemInfoDataObject;
@property (nonatomic, strong) ManualReceivedItem *manualItemReceive;

@property (nonatomic, strong) NSString *manualPoID;

@end
