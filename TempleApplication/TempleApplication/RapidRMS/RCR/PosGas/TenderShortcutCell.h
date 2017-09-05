//
//  TenderShortcutCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 10/31/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface TenderShortcutCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *tenderPaymentName;
@property (nonatomic, weak) IBOutlet UIButton *btnTenderShortCut;
@property (nonatomic, weak) IBOutlet AsyncImageView *tenderShortcutImage;

@end
