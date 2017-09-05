//
//  ItemSideInfoCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 04/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemSideInfoCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView * imgImage;
@property (nonatomic, weak) IBOutlet UILabel * lblValue;
@property (nonatomic, weak) IBOutlet UILabel * lblTitle;

@property (nonatomic, weak) IBOutlet UILabel * lblDisp1;
@property (nonatomic, weak) IBOutlet UILabel * lblDisp2;
@property (nonatomic, weak) IBOutlet UILabel * lblDisp3;
@property (nonatomic, weak) IBOutlet UILabel * lblDisp4;
@property (nonatomic, weak) IBOutlet UILabel * lblDisp5;
@end
