//
//  RapidFilterSelectedListCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 08/03/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RapidFilterSelectedListCell.h"
@interface RapidFilterSelectedListCell ()<MPTagListDelegate> {
    NSMutableArray * arrFilterTypes;
    RapidItemFilterType filterType;
}

@end
@implementation RapidFilterSelectedListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)configureCellToItem:(NSArray *)arrItem withMasterType:(RapidItemFilterType) filter_Type withTitle:(NSString *) strTitle{
    arrFilterTypes = [[NSMutableArray alloc]initWithArray:arrItem];
    filterType = filter_Type;
    _lblTitle.text = strTitle;
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    arrFilterTypes = [[arrFilterTypes sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];

    [_itemList setTags:[arrFilterTypes valueForKey:@"name"]];
    _itemList.tagDelegate = self;
    [_itemList setAutomaticResize:YES];
    [_itemList setTagBackgroundColor:[UIColor clearColor]];
    [_itemList setTagTextColor:[UIColor whiteColor]];
    [_itemList setTagImagesColor:[UIImage imageNamed:@"RIM_Filter_Close"]];
}

- (void)selectedTag:(NSString*)tagName withTabView:(id) tagView{
    [arrFilterTypes removeObjectAtIndex:((MPTagView *)tagView).tag];
    [_itemList setTags:[arrFilterTypes valueForKey:@"name"]];
    if ([self.deledate respondsToSelector:@selector(willCellChangeSelectedFilterTypeItemlist:withFilterType:)]) {
        [self.deledate willCellChangeSelectedFilterTypeItemlist:arrFilterTypes withFilterType:filterType];
    }
}

-(void)configureCellToPhone:(NSArray *)arrItem withTitle:(NSString *) strTitle{
    arrFilterTypes = [[NSMutableArray alloc]initWithArray:arrItem];
    filterType = (RapidItemFilterType)nil;
    _lblTitle.text = strTitle;

    [_itemList setTags:arrItem];
    [_itemList setAutomaticResize:YES];
    [_itemList setTagBackgroundColor:[UIColor clearColor]];
    [_itemList setTagTextColor:[UIColor blackColor]];
}
@end
