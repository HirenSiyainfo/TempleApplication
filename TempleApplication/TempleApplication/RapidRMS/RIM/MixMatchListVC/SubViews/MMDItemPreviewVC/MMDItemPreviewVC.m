//
//  MMDItemPreviewVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDItemPreviewVC.h"
#import "MMDItemEditingVC.h"

@interface MMDItemPreviewVC () {
    MMDItemEditingVC * xItemPreview;
    MMDItemEditingVC * yItemPreview;
}

@property (nonatomic, weak) IBOutlet UIView * viewXContainer;
@property (nonatomic, weak) IBOutlet UIView * viewYContainer;

@end

@implementation MMDItemPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self addXitemEdintView];
    [self addYitemEdintView];
}
-(void)addXitemEdintView {
    if (!xItemPreview) {
        xItemPreview =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDItemEditingVC_sid"];
        
        xItemPreview.view.frame = _viewXContainer.bounds;
        [self addChildViewController:xItemPreview];
        xItemPreview.arrItemList = self.arrXitems;
        xItemPreview.isXitemList = TRUE;
        [_viewXContainer addSubview:xItemPreview.view];
    }
}
-(void)addYitemEdintView {
    if (!yItemPreview) {
        yItemPreview =
        [[UIStoryboard storyboardWithName:@"MMDiscount"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"MMDItemEditingVC_sid"];
        
        yItemPreview.view.frame = _viewYContainer.bounds;
        [self addChildViewController:yItemPreview];
        yItemPreview.arrItemList = self.arrYitems;
        yItemPreview.isXitemList = FALSE;
        [_viewYContainer addSubview:yItemPreview.view];
    }
}

-(IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)saveNewList:(id)sender{
    if ([self.Delegate respondsToSelector:@selector(didSelectItemListEditWithNewXItems:WithNewYItems:)]) {
        [self.Delegate didSelectItemListEditWithNewXItems:self.arrXitems WithNewYItems:self.arrYitems];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
