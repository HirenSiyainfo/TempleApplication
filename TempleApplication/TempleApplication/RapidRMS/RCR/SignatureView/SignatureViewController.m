//
//  SignatureViewController.m
//
//  Created by John Montiel on 5/11/12.
//

#import "SignatureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RmsDbController.h"
#import "TipNumberPadPopupVC.h"
#import "DoubleActionCheck.h"
#import "Configuration.h"
#import "UpdateManager.h"

@interface SignatureViewController ()<TipsInputDelegate,UIPopoverPresentationControllerDelegate,UITableViewDataSource,UITableViewDelegate, UpdateDelegate>
{
    NSNumberFormatter *currencyFormat;
    CGFloat tipsAmount;
    TipNumberPadPopupVC *tipNumberPadPopupVC;
    DoubleActionCheck *manualReceiptDoubleActionCheck;
    DoubleActionCheck *doneSignatureDoubleActionCheck;
    Configuration *objConfiguration;
}
@property (nonatomic , weak) IBOutlet UILabel *lblCurrentDate;
@property (nonatomic , weak) IBOutlet UILabel *subTotalAmount;
@property (nonatomic , weak) IBOutlet UILabel *taxAmount;
@property (nonatomic , weak) IBOutlet UILabel *discountAmount;
@property (nonatomic , weak) IBOutlet UILabel *totalAmount;
@property (nonatomic , weak) IBOutlet UILabel *itemCount;

@property (nonatomic , weak) IBOutlet UILabel *cardHolderName;
@property (nonatomic , weak) IBOutlet UILabel *creditCardNumber;
@property (nonatomic , weak) IBOutlet UILabel *authCode;
@property (nonatomic , weak) IBOutlet UILabel *cardType;


@property (nonatomic , weak) IBOutlet UIView *tipView;
@property (nonatomic , weak) IBOutlet UIView *agreeView;
@property (nonatomic , weak) IBOutlet UILabel *lblAgree;
@property (nonatomic , weak) IBOutlet UIImageView *agreeImage;

@property (nonatomic , weak) IBOutlet UITableView *tipTableView;
@property (nonatomic , weak) IBOutlet UIButton *tipAmountButton;


@property (strong, nonatomic) NSData *signature;
@property (strong,nonatomic) RmsDbController *rmsDBController;
@property (nonatomic, strong) UIPopoverPresentationController *tipsPopoverController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UpdateManager *updateManager;



@end

@implementation SignatureViewController
@synthesize delegate;
@synthesize signatureTextField;
@synthesize signview;
@synthesize signature,signatureDataDict;
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    _tipView.hidden = YES;

    self.rmsDBController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDBController.managedObjectContext;
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    objConfiguration = [UpdateManager getConfigurationMoc:self.managedObjectContext];

    
    NSDictionary *dictAmountData = [self.signatureDataDict valueForKey:@"AmountInfo"];
    _totalAmount.text = [dictAmountData valueForKey:@"InvoiceTotal"];
    _subTotalAmount.text = [dictAmountData valueForKey:@"InvoiceSubTotal"];
    _taxAmount.text = [dictAmountData valueForKey:@"InvoiceTax"];
    _discountAmount.text =  [dictAmountData valueForKey:@"InvoiceDiscount"];
    _itemCount.text = [dictAmountData valueForKey:@"TotalItemCount"];

    NSDictionary *dictCardData = [self.signatureDataDict valueForKey:@"CardInfo"];
    if([[dictCardData valueForKey:@"CardHolderName"] isEqualToString:@""])
    {
        _cardHolderName.text = @"N/A";
    }
    else
    {
        _cardHolderName.text = [dictCardData valueForKey:@"CardHolderName"];
    }
    
    if([[dictCardData valueForKey:@"CardType"] isEqualToString:@""])
    {
        _cardType.text = @"N/A";
    }
    else
    {
        _cardType.text = [dictCardData valueForKey:@"CardType"];
    }
    
    _creditCardNumber.text = [dictCardData valueForKey:@"AccNo"];
    _authCode.text = [dictCardData valueForKey:@"AuthCode"];
    manualReceiptDoubleActionCheck = [[DoubleActionCheck alloc] initWithTimeInterval:2.0];
    doneSignatureDoubleActionCheck = [[DoubleActionCheck alloc] initWithTimeInterval:2.0];

    self.signatureTextField.alpha = 0.2;
    
    currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 2;
   
    if (objConfiguration.localTipsSetting.boolValue == YES) {
        _tipView.hidden = NO;
        [self updateUIForTips];
        [_tipTableView reloadData];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beganSignature:) name:kBeganSignature object:self.view];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.signview erase];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateDateLabel];
}

- (void)updateUIForTips
{
    [self setFrameToView:_agreeView accordingView:_tipView];
    [self setFrameToView:signview accordingView:_tipView];
    [self setFrameToImageView:_agreeImage accordingView:_tipView];
    [self setFrameToLabel:_lblAgree accordingView:_tipView];
}

- (void)setFrameToView:(UIView *)aView accordingView:(UIView *)bView
{
    CGRect frame = aView.frame;
    frame.origin.x = bView.frame.origin.x + bView.frame.size.width + 15;
    frame.size.width = 815;
    aView.frame = frame;
}

- (void)setFrameToImageView:(UIImageView *)aImageView accordingView:(UIView *)bView
{
    CGRect frame = aImageView.frame;
    frame.size.width = 815;
    aImageView.frame = frame;
}

- (void)setFrameToLabel:(UILabel *)aLabel accordingView:(UIView *)bView
{
    CGRect frame = aLabel.frame;
    frame.size.width = 815;
    aLabel.frame = frame;
}


- (IBAction)tipAmountClicked:(id)sender
{
    _tipAmountButton.selected = YES;
    [self showTipPopUp:sender];
}

- (void)showTipPopUp:(id)sender
{
    UIButton *button = (UIButton *)sender;
    CGRect btnFrame = CGRectMake(button.frame.origin.x + button.frame.size.width / 2 - 60, button.frame.origin.y+105, button.frame.size.width, button.frame.size.height);
    tipNumberPadPopupVC = [[TipNumberPadPopupVC alloc] initWithNibName:@"TipNumberPadPopupVC" bundle:nil];
    tipNumberPadPopupVC.tipsInputDelegate = self;
    
    // Present the view controller using the popover style.
    tipNumberPadPopupVC.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:tipNumberPadPopupVC animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    _tipsPopoverController = [tipNumberPadPopupVC popoverPresentationController];
    _tipsPopoverController.delegate = self;
    tipNumberPadPopupVC.preferredContentSize = CGSizeMake(340, 580);
    _tipsPopoverController.permittedArrowDirections = UIPopoverArrowDirectionLeft;
    _tipsPopoverController.sourceView = self.view;
    _tipsPopoverController.sourceRect = btnFrame;
}

-(void)didEnterTip:(CGFloat)tipValue
{
    tipsAmount = tipValue;
    
    if (_tipAmountButton.selected == YES) {
        [tipNumberPadPopupVC dismissViewControllerAnimated:YES completion:nil];
        NSNumber *tipSales = [NSNumber numberWithFloat:tipValue];
        NSString *strTipValue = [currencyFormat stringFromNumber:tipSales];
        strTipValue = [strTipValue stringByReplacingOccurrencesOfString:@"," withString:@""];
        [_tipAmountButton setTitle:strTipValue forState:UIControlStateNormal];
        _tipAmountButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:20.0];
        [_tipTableView reloadData];
    }
    
    _totalAmount.text = @"";
    _totalAmount.text = [[self.signatureDataDict  valueForKey:@"AmountInfo"] valueForKey:@"InvoiceTotal"];
    CGFloat total = [_totalAmount.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue + tipValue;
    NSNumber *tipSales = [NSNumber numberWithFloat:total];
    NSString *strTipValue = [currencyFormat stringFromNumber:tipSales];
    _totalAmount.text = [strTipValue stringByReplacingOccurrencesOfString:@"," withString:@""];
}
-(void)didCancelTip
{
    
}

- (void)updateDateLabel
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    _lblCurrentDate.text = [formatter stringFromDate:date];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBeganSignature object:self.view];
    [self setView:nil];
    [self setSignatureTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return YES;
//}

- (IBAction)signatureClearTapped:(id)sender 
{
    [self.signview erase];
    
//    [UIView animateWithDuration:0.6 animations:^
//     {
//         [self.signatureTextField setAlpha:1.0];
//     }];
}

- (IBAction)manualRecriptTapped:(id)sender
{
    if (manualReceiptDoubleActionCheck.quickTap) {
        NSLog(@"You are too quick dear");
        return;
    }

    [self dismissViewControllerAnimated:TRUE completion:^{
        [self.delegate manualReceipt];
    }];
}

- (IBAction)signatureSignTapped:(id)sender 
{
    if (doneSignatureDoubleActionCheck.quickTap) {
        NSLog(@"You are too quick dear");
        return;
    }

    [self checkSign];
}

-(void)checkSign
{
    if ((self.signature = UIImagePNGRepresentation(self.signview.signatureImage)))
    {
        
        [self dismissViewControllerAnimated:TRUE completion:^{
            [self.delegate signatureViewController:self didSign:nil signature:self.signview.signatureImage withCustomerDisplayTipAmount:tipsAmount];
        }];
        
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDBController popupAlertFromVC:self title:@"Signature" message:@"Please sign" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (void)beganSignature:(NSNotification *)notification
{
    if (notification.object == self.signview)
    {
        [UIView animateWithDuration:0.6 animations:^
         {
             self.signatureTextField.alpha = 0.2;
         }];
    }
}

# pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[signatureDataDict valueForKey:@"TipInfo"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TipsCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TipsCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor grayColor];
    cell.selectedBackgroundView = selectionColor;
    
    UIView *backGroundColorView = [[UIView alloc] init];
    backGroundColorView.backgroundColor = [UIColor whiteColor];
    cell.backgroundView = backGroundColorView;
    
    NSDictionary *tipDict = [signatureDataDict valueForKey:@"TipInfo"][indexPath.row];
    
    UILabel *lblTipsPercenatge = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, 65, 21)];
    lblTipsPercenatge.text = [NSString stringWithFormat:@"%@%%",[tipDict valueForKey:@"TipsPercentage"]];
    lblTipsPercenatge.font = [UIFont fontWithName:@"Lato-Bold" size:17.0];
    lblTipsPercenatge.textAlignment = NSTextAlignmentRight;
    lblTipsPercenatge.textColor = [UIColor colorWithRed:252.0/255.0 green:160.0/255.0 blue:2.0/255.0 alpha:1.0];
    [cell addSubview:lblTipsPercenatge];
    
    UILabel *lblTipsAmount = [[UILabel alloc] initWithFrame:CGRectMake(75, 11, 78, 21)];
    NSString *strTipAmount = [NSString stringWithFormat:@"%@",[tipDict valueForKey:@"TipsAmount"]];
    lblTipsAmount.text = [self.rmsDBController applyCurrencyFomatter:strTipAmount];
    lblTipsAmount.font = [UIFont fontWithName:@"Lato-Light" size:17.0];
    lblTipsAmount.textAlignment = NSTextAlignmentLeft;
    lblTipsAmount.textColor = [UIColor blackColor];
    [cell addSubview:lblTipsAmount];
    
    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 162, 1)];
    seperatorView.backgroundColor = [UIColor grayColor];
    [cell addSubview:seperatorView];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tipAmountButton.selected = NO;
    [_tipAmountButton setTitle:@"ENTER AMOUNT" forState:UIControlStateNormal];
    _tipAmountButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:15.0];
    NSDictionary *tipDict = [signatureDataDict valueForKey:@"TipInfo"][indexPath.row];
    [self didEnterTip:[[tipDict valueForKey:@"TipsAmount"] floatValue]];
}




@end
