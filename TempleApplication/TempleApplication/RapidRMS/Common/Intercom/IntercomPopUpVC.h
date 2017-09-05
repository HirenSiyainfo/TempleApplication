//
//  IntercomPopUpVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 24/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol IntercomPopUpVCDelegate <NSObject>
- (void)didSelectIntercomOption;
- (void)didSelectAboutRapidRms;
@end
@interface IntercomPopUpVC : UIViewController
@property (nonatomic,weak) id<IntercomPopUpVCDelegate> intercomDelegate;
@property (nonatomic,strong) NSMutableArray *intercomDisplayIconArray;
@end
