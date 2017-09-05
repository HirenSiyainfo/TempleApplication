//
//  CL_InvoiceTagVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 16/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CL_InvoiceTagVC.h"
#import "CL_InvoiceTagListCell.h"

#define TABLE_TAG_DISPLAY_LIMIT 10

@interface CL_InvoiceTagVC ()<UITableViewDelegate , UITableViewDataSource>

@property (nonatomic , weak) IBOutlet UITableView *tblInvoicetagList;

@end

@implementation CL_InvoiceTagVC
@synthesize arrInvoicetagList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSInteger intPaymentCount = arrInvoicetagList.count ;
    if (arrInvoicetagList.count > TABLE_TAG_DISPLAY_LIMIT)
    {
        intPaymentCount = TABLE_TAG_DISPLAY_LIMIT;
    }
    self.tblInvoicetagList.frame = CGRectMake(self.tblInvoicetagList.frame.origin.x, 10, self.tblInvoicetagList.frame.size.width,intPaymentCount*35);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    return 35;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrInvoicetagList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        CL_InvoiceTagListCell *tagCell = [tableView dequeueReusableCellWithIdentifier:@"CL_InvoiceTagListCell"];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor whiteColor];
        tagCell.backgroundView = selectionColor;
        
        UIView *backColor = [[UIView alloc] init];
        backColor.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
        backColor.layer.cornerRadius = 5.0;
        tagCell.selectedBackgroundView = backColor;
        
        tagCell.lblTags.text = [NSString stringWithFormat: @"%@",arrInvoicetagList[indexPath.row]];
        tagCell.backgroundColor = [UIColor clearColor];
            return tagCell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
