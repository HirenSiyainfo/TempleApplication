//
//  POGenerateOrderManuel.h
//  RapidRMS
//
//  Created by Siya10 on 10/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POmenuListDelegateVC.h"


@interface POGenerateOrderManuel : UIViewController

@property(nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;
@property(nonatomic,strong)NSMutableDictionary *selectedVendor;
@end
