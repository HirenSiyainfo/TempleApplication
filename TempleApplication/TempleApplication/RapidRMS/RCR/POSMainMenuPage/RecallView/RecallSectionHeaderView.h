
//
//  RecallSectionHeaderView.h
//  RapidRMS
//
//  Created by siya-IOS5 on 10/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecallSectionHeaderView : UIView
{
    IBOutlet UILabel *sectionTitle;
    IBOutlet UIImageView *sectionBackGroundImage;
}
-(instancetype)initWithFrame:(CGRect)frame  withHeaderTitle:(NSString *)headerTitle NS_DESIGNATED_INITIALIZER;

@end
