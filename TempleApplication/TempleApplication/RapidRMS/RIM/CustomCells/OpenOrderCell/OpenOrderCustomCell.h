//
//  OpenOrderCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 20/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenOrderCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *OpenOrderBgImage;
@property (nonatomic, weak) IBOutlet UILabel *OpenOrderDate;
@property (nonatomic, weak) IBOutlet UILabel *OpenOrderTime;
@property (nonatomic, weak) IBOutlet UILabel *OpenOrderTitle;
@property (nonatomic, weak) IBOutlet UILabel *OpenOrderType;
@property (nonatomic, weak) IBOutlet UILabel *OpenOrderUser;

@property (nonatomic, weak) IBOutlet UIButton *btnExportEmail;
@property (nonatomic, weak) IBOutlet UIButton *btnExportPreview;

@end
