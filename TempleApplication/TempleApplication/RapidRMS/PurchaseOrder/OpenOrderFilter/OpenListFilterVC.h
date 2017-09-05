//
//  OpenListViewController.h
//  I-RMS
//
//  Created by Siya Infotech on 06/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POmenuListDelegateVC.h"
#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif

@interface OpenListFilterVC : UIViewController


@property (nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;


@end
