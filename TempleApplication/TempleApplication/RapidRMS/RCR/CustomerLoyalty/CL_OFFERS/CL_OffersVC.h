//
//  CL_OffersVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 27/11/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OffersVCDelegate <NSObject>
@end

@interface CL_OffersVC : UIViewController
@property (nonatomic ,weak) id<OffersVCDelegate> offersVCDelegate;


@end
