//
//  MMDItemSectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 22/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DidSelectItemSectionTitleDelegate <NSObject>
-(void)didItemSectionTitleSelect:(NSString *) strTitleName;
@end

@interface MMDItemSectionVC : UIViewController

@property (nonatomic, strong)NSArray * arrSectionTitle;
@property (nonatomic, strong)NSString * defaultSelectedTitle;
@property (nonatomic, weak) id<DidSelectItemSectionTitleDelegate> Delegate;
@end
