//
//  RmsDashboardVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RmsDashboardVC : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIPopoverControllerDelegate>

-(void)loadDashBoardModuleIcons;

@end
