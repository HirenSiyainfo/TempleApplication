//
//  CustomTabBarBtn.m
//  POSFrontEnd
//
//  Created by Triforce consultancy on 04/02/12.
//  Copyright 2012 Triforce consultancy . All rights reserved.
//

#import "CustomTabBarBtn.h"
#import "CustomBadge.h"


@implementation CustomTabBarBtn

@synthesize delegate;
@synthesize isClicked,checkBoxType;
@synthesize backgroundImage, iconImage;
@synthesize titleLabel, barButton;

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString*) title withIconImage:(UIImage*) imgIcon withBackground:(UIImage*) imgBackground withHIconImage:(UIImage*) hImgIcon andTag:(NSInteger) tagId {
    
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 49)];
    if (self) {
		
		self.backgroundColor = [UIColor clearColor];
		
		iconImage_Normal = imgIcon;
		iconImage_Highlight = hImgIcon;
		
		checkBoxType = NO;
		
		self.tag = tagId;
		
        // Initialization code.
		backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		backgroundImage.contentMode = UIViewContentModeScaleToFill;
		backgroundImage.layer.cornerRadius = 5;
		[backgroundImage setImage:nil];
		[self addSubview:backgroundImage];
		
		iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-15)];
		iconImage.contentMode = UIViewContentModeCenter;
		iconImage.image = imgIcon;
		[self addSubview:iconImage];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-10, self.frame.size.width, 10)];
		titleLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.text = title;
		[self addSubview:titleLabel];
		
		barButton = [UIButton buttonWithType:UIButtonTypeCustom];
		barButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
		if (!checkBoxType) {
			[barButton addTarget:self action:@selector(barButtonStartClicked:) forControlEvents:UIControlEventTouchDown];
		}
		[barButton addTarget:self action:@selector(barButtonClecked:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:barButton];
		
    }
    return self;
}

- (void) barButtonStartClicked:(id)sender {
	iconImage.image = iconImage_Highlight;
	backgroundImage.backgroundColor = [UIColor whiteColor];
	backgroundImage.alpha = 0.30;
}

-(IBAction) barButtonClecked:(id)sender {
	if (checkBoxType) {
		if(self.isClicked ==NO){
			self.isClicked =YES;
			iconImage.image = iconImage_Highlight;
			backgroundImage.backgroundColor = [UIColor whiteColor];
			backgroundImage.alpha = 0.30;
			
		}else{
			self.isClicked =NO;
			iconImage.image = iconImage_Normal;
			backgroundImage.backgroundColor = [UIColor clearColor];
			backgroundImage.alpha = 1.0;
		}	
	} else {
		iconImage.image = iconImage_Normal;
		backgroundImage.backgroundColor = [UIColor clearColor];
		backgroundImage.alpha = 1.0;
	}
	
	NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
	userInfo[@"self"] = self;
	if (isClicked) {
		userInfo[@"isClicked"] = @"YES";
	} else {
		userInfo[@"isClicked"] = @"NO";
	}

	[delegate customBarButtonClicked:nil data:userInfo];
	//[delegate customBarButtonClicked:userInfo];
}

- (void)dealloc {
//    [super dealloc];
}


@end
