//
//  IntercomPopUpVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 24/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "IntercomPopUpVC.h"
#import "IntercomTableViewCell.h"
#import "AboutViewController.h"

typedef NS_ENUM(NSUInteger, Icon)
{
    MessagesIcon,
    ConversionsIcon,
    SupportWebsiteIcon,
    WhatIsRapidIcon,
};


@interface IntercomPopUpVC ()<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *tblIntercom;
    NSArray *intercomIconArray;
    AboutViewController *aboutViewController;
    UIPopoverPresentationController *intercomPopOverController;

}
@end

@implementation IntercomPopUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.borderColor = [UIColor whiteColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.cornerRadius = 15.0f;

    intercomIconArray = _intercomDisplayIconArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return intercomIconArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"IntercomCell";
    IntercomTableViewCell *intercomCell = (IntercomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    intercomCell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *iconDictionary = intercomIconArray[indexPath.row];
    intercomCell.iconView.image = [UIImage imageNamed:[iconDictionary valueForKey:@"iconImage"]];
    intercomCell.iconView.highlightedImage = [UIImage imageNamed:[iconDictionary valueForKey:@"iconhighlightedImage"]];

    intercomCell.iconText.text = [iconDictionary valueForKey:@"iconText"];
    return intercomCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.intercomDelegate didSelectIntercomOption];
    switch (indexPath.row) {
        case MessagesIcon:
            [self messagesTaped];
            break;
        case ConversionsIcon:
            [self conversionsTaped];
            break;
        case SupportWebsiteIcon:
            [self supportWebsiteTaped];
            break;
        case WhatIsRapidIcon:
            [self whatIsRapidTaped];
        default:
            break;
    }
    [tblIntercom reloadData];
}

- (void)messagesTaped
{
    [Intercom presentMessageComposer];
}

- (void)conversionsTaped
{
    [Intercom presentConversationList];
}

- (void)supportWebsiteTaped
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.rmscommunity.com"]];
}

- (void)whatIsRapidTaped
{
    [self.intercomDelegate didSelectAboutRapidRms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
