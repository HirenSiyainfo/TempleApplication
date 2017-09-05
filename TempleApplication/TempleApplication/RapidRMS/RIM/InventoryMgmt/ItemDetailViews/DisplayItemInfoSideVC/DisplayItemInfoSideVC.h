//
//  ItemInfoViewController.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DisplayItemInfoSideVCDeledate <NSObject>
    -(void)willChangeItemSelectedImage:(UIButton *)sender;
@end


@interface DisplayItemInfoSideVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIPopoverControllerDelegate>

@property (nonatomic, weak) id<DisplayItemInfoSideVCDeledate> displayItemInfoSideVCDeledate;
@property (nonatomic, strong) NSMutableDictionary *itemInfoDictionary;

-(void)didUpdateItemInfo:(NSDictionary *)updatedItemInfo;

@end