//
//  ItemInfoTagCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 21/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemInfoTagDetailDelegate <NSObject>
    -(void)didAddNewTag:(NSString *)newTag;
@end
@interface ItemInfoTagCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblCellName;
@property (nonatomic, weak) IBOutlet UITextField *txtTagName;
@property (nonatomic, weak) IBOutlet UIButton * btnAddTag;
@property (nonatomic, weak) id<ItemInfoTagDetailDelegate> ItemInfoTagDetailDelegate;
@end
