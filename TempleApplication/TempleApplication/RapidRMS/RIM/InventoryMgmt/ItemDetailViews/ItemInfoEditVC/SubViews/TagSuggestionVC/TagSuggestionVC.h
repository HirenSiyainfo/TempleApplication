//
//  TagSuggestionViewController.h
//  RapidRMS
//
//  Created by Siya on 30/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"
@protocol TagSuggestionDelegate <NSObject>

-(void)didSelectTagfromList:(NSString *)strSelectedTag;

@end

@interface TagSuggestionVC : PopupSuperVC


@property (nonatomic, weak) id<TagSuggestionDelegate> tagSuggestionDelegate;

@property (nonatomic, strong) NSString *strSearchTagText;

-(void)reloadTableWithSearchItem;
@end

#pragma mark - Cell -
@interface TagSuggestionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * lblTitle;
@end