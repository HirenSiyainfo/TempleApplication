//
//  ItemInfoViewController.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayItemInfo : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>
{
}
@property (nonatomic,strong) NSMutableDictionary *itemInfoDictionary;
@property (nonatomic,strong) AsyncImageView * itemImage_Item;

@end
