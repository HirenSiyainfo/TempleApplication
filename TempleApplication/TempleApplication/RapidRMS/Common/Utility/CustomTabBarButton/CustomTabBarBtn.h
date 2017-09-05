//
//  CustomTabBarBtn.h
//  POSFrontEnd
//
//  Created by Triforce consultancy on 04/02/12.
//  Copyright 2012 Triforce consultancy . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTabBarBtnDelegate 

-(void) customBarButtonClicked:(UIView *)tabBarBtn data:(NSMutableDictionary *)userInfo;

@end

@interface CustomTabBarBtn : UIView {

	id <CustomTabBarBtnDelegate> delegate;
	
	UIImageView * backgroundImage;
	UIImageView * iconImage;
	
	UILabel * titleLabel;
	UIButton * barButton;
	
	UIImage * iconImage_Normal;
	UIImage * iconImage_Highlight;
	
	BOOL checkBoxType;
	BOOL isClicked;
	
}

@property (nonatomic,assign) BOOL isClicked;
@property (nonatomic,assign) BOOL checkBoxType;

@property (nonatomic,retain) UIImageView * backgroundImage;
@property (nonatomic,retain) UIImageView * iconImage;

@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UIButton * barButton;

@property (nonatomic, retain) id <CustomTabBarBtnDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString*) title withIconImage:(UIImage*) imgIcon withBackground:(UIImage*) imgBackground withHIconImage:(UIImage*) hImgIcon andTag:(NSInteger) tagId NS_DESIGNATED_INITIALIZER;

@end
