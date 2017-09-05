//
//  KitchenPrintDisplayVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/20/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "KitchenPrintDisplayVC.h"

@interface KitchenPrintDisplayVC ()
{
    
}
@property (nonatomic,weak) IBOutlet UIWebView *kitchenPrintDiplay;
@property (nonatomic,strong) NSString *htmlToDiplayKitchenItem;


@end

@implementation KitchenPrintDisplayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_kitchenPrintDiplay loadHTMLString:self.htmlToDiplayKitchenItem baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)backButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}


@end
