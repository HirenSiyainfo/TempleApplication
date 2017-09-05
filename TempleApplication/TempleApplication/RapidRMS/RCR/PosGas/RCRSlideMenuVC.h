//
//  RCRSlideMenuVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/18/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RcrSlideMenuItem)
{
    RcrSlideMenuNoSale,
    RcrSlideMenuDrop,
    RcrSlideMenuInvoice,
    RcrSlideMenuGiftCard,
    RcrSlideMenuTaxRemove,
    RcrSlideMenuSwichUser,
    RCRSlideMenuLogOut,
    RCRSlideMenuTicketValidation,
    RCRSlideMenuEBT,
    RCRAddItemMenu,
    RCRAddToFavouriteMenu,

};
@class RCRSlideMenuVC;

@protocol RCRSlideMenuVCDelegate <NSObject>

-(void)didSelectRCRMenuItem:(RcrSlideMenuItem)rcrSlideMenuItem forRCRSlideMenuVC:(RCRSlideMenuVC *)rcrSlideMenuVC;
-(void)hideShowRCRSlideMenu:(RCRSlideMenuVC *)rcrSlideMenuVC;

@end
@interface RCRSlideMenuVC : UIViewController
{
    

}

@property(nonatomic,weak) id <RCRSlideMenuVCDelegate>rcrSlideMenuVCDelegate;

@property (nonatomic,strong) NSArray *rcrSlideMenuItemEnum;
@property (nonatomic,strong) NSArray *rcrSlideMenuNormalImages;
@property (nonatomic,strong) NSArray *rcrSlideMenuSelectedImages;
@property (nonatomic,strong) NSArray *rcrSlideMenuNames;

@property (assign) BOOL isPresentAsPopOver;

@end
