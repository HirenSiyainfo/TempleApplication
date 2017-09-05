//
//  TestViewController.m
//  RapidRMS
//
//  Created by Siya Infotech on 03/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CardSettlementVC.h"
#import "RmsDbController.h"
@interface CardSettlementVC ()
{
    NSXMLParser *revParser;
    NSMutableArray *XmlResponseArray;
    NSMutableDictionary *dictCardElement;
    NSMutableString *currentElement;
    
    // Generate order data variable
    UILabel *cardDate;
    UILabel *creditCardNumber;
    UILabel *cardType;
    UILabel *totalAmount;
    UILabel *authNumber;
    UILabel *referenceNumber;
    UILabel *invoiceNumber;
}

@property (nonatomic, weak) IBOutlet UILabel *creditCardAmount;
@property (nonatomic, weak) IBOutlet UITableView *cardSettlementTableView;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) RmsDbController *rmsDBController;

@end

@implementation CardSettlementVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDBController = [RmsDbController sharedRmsDbController];
    XmlResponseArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)btnCloseClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)getDataClicked:(id)sender
{
    //_activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tgatePost:@"GetCardTrx" data:[NSString stringWithFormat:@"UserName=%@&Password=%@&RPNum=%@&BeginDt=%@&EndDt=%@&ExcludeVoid=%@&SettleFlag=%@&PNRef=&PaymentType=&ExcludePaymentType=&TransType=&ExcludeTransType=&ApprovalCode=&Result=&ExcludeResult=&NameOnCard=&CardNum=&CardType=&ExcludeCardType=&User=&invoiceId=&SettleMsg=&SettleDt=&TransformType=&Xsl=&ColDelim=&RowDelim=&IncludeHeader=&ExtData=",@"Nira3455",@"H5493nb4",@"6768",@"2014-05-02T20:00:00",@"2014-05-05T20:00:00",@"true",@"0"]];
    });
}

-(void)tgatePost:(NSString *)function data:(NSString *)data
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://gatewaystage.itstgate.com/admin/ws/trxdetail.asmx/%@",function]];
    NSData *postData=[data dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = url;
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = postData;
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [_activityIndicator hideActivityIndicator];
    if(urlData)
    {
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDBController popupAlertFromVC:self title:@"Failed" message:[NSString stringWithFormat:@"TGate connection failed with error: %@",error.localizedDescription] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)allocCardSattlement
{
    cardDate = [[UILabel alloc] initWithFrame:CGRectMake(14, 8, 80, 40)];
    creditCardNumber = [[UILabel alloc] initWithFrame:CGRectMake(105, 10, 100, 30)];
    cardType = [[UILabel alloc] initWithFrame:CGRectMake(210, 10, 100, 30)];
    totalAmount = [[UILabel alloc] initWithFrame:CGRectMake(327, 10, 100, 30)];
    authNumber = [[UILabel alloc] initWithFrame:CGRectMake(427, 10, 100, 30)];
    referenceNumber = [[UILabel alloc] initWithFrame:CGRectMake(535, 10, 100, 30)];
    invoiceNumber = [[UILabel alloc] initWithFrame:CGRectMake(645, 10, 100, 30)];
}

-(void)labelConfiguration:(UILabel *)sender
{
    sender.numberOfLines = 0;
    sender.textAlignment = NSTextAlignmentLeft;
    sender.backgroundColor = [UIColor clearColor];
    sender.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return XmlResponseArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(XmlResponseArray.count > 0)
    {
        [self allocCardSattlement];
        
        cardDate.text = [self convertDateAndTime:[XmlResponseArray[indexPath.row] valueForKey:@"Tansactiondate"]];
        //cardDate.text = [NSString stringWithFormat:@"%@",[[XmlResponseArray objectAtIndex:indexPath.row] valueForKey:@"Tansactiondate"]];
        [self labelConfiguration:cardDate];
        cardDate.numberOfLines = 2;
        [cell addSubview:cardDate];
        
        creditCardNumber.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"CardNo"]];
        [self labelConfiguration:creditCardNumber];
        [cell addSubview:creditCardNumber];
        
        cardType.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"CardType"]];
        [self labelConfiguration:cardType];
        [cell addSubview:cardType];
        
        totalAmount.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"Amount"]];
        [self labelConfiguration:totalAmount];
        [cell addSubview:totalAmount];
        
        authNumber.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"Authentication"]];
        [self labelConfiguration:authNumber];
        [cell addSubview:authNumber];
        
        referenceNumber.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"ReferanceNo"]];
        [self labelConfiguration:referenceNumber];
        [cell addSubview:referenceNumber];
        
        invoiceNumber.text = [NSString stringWithFormat:@"%@",[XmlResponseArray[indexPath.row] valueForKey:@"InvoiceNo"]];
        [self labelConfiguration:invoiceNumber];
        [cell addSubview:invoiceNumber];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(NSString *)convertDateAndTime:(NSString *)xmlDate
{
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    inputFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *inputDate = [inputFormatter dateFromString:xmlDate];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = @"MMM dd, HH:mm a";
    NSString *outputDate = [outputFormatter stringFromDate:inputDate];
    
    return outputDate;
}

#pragma mark - XML Parsging

-(NSMutableArray*) parseCCResponse:(NSString *)xml
{
    xml = [xml stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    xml = [xml stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    xml = [xml stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    
    revParser = [[NSXMLParser alloc] initWithData:data];
    revParser.delegate = self;
    [revParser setShouldProcessNamespaces:NO];
    [revParser setShouldReportNamespacePrefixes:NO];
    [revParser setShouldResolveExternalEntities:NO];
    [revParser parse];
    
    // return array to called function
    return XmlResponseArray;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.cardSettlementTableView reloadData];
    //NSPredicate *deactive = [NSPredicate predicateWithFormat:@"Amount == %d", temp];
    //self.deactiveDevResult = [[activeDevice filteredArrayUsingPredicate:deactive] mutableCopy ];
    
    float sum = [[XmlResponseArray valueForKeyPath:@"@sum.Amount"] floatValue];
    _creditCardAmount.text = [self.rmsDBController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",sum]];
    
}

- (void) parser: (NSXMLParser *) parser parseErrorOccurred: (NSError *) parseError
{
    
}

//Calls when it finds the opening Tag
- (void) parser: (NSXMLParser *) parser didStartElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName
     attributes: (NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:@"TrxDetailCard"]) {
        dictCardElement = [[NSMutableDictionary alloc] init];
    }
}

//Calls and have value of particular Tag so here what we do recognize the tag and then retrieve its value

- (void) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qName
{
    // insert element result in dictionary
    
    if([elementName isEqualToString:@"TRX_HD_Key"])
    {
        NSString* RespMSG = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dictCardElement[@"ReferanceNo"] = RespMSG;
    }
    if([elementName isEqualToString:@"Invoice_ID"])
    {
        NSString* Message = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dictCardElement[@"InvoiceNo"] = Message;
    }
    if([elementName isEqualToString:@"Date_DT"])
    {
        NSString* Message1 = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dictCardElement[@"Tansactiondate"] = Message1;
    }
    if([elementName isEqualToString:@"Payment_Type_ID"])
    {
        NSString* AuthCode = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dictCardElement[@"CardType"] = AuthCode;
    }
    if([elementName isEqualToString:@"Trans_Type_ID"])
    {
        NSString* PNRef = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dictCardElement[@"TransType"] = PNRef;
    }
    if([elementName isEqualToString:@"Auth_Amt_MN"])
    {
        NSString* HostCode = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dictCardElement[@"Amount"] = HostCode;
    }
    if([elementName isEqualToString:@"Approval_Code_CH"])
    {
        NSString* GetCommercialCard = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dictCardElement[@"Authentication"] = GetCommercialCard;
    }
    if([elementName isEqualToString:@"Acct_Num_CH"])
    {
        NSString* GetCommercialCard = [currentElement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        dictCardElement[@"CardNo"] = GetCommercialCard;
    }
    if ([elementName isEqualToString:@"TrxDetailCard"]) {
        // insert dictionary in array
        [XmlResponseArray addObject:dictCardElement];
    }
    currentElement = nil;
}

- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string{
    
    if(!currentElement)
        currentElement = [[NSMutableString alloc] initWithString:string];
    else
        [currentElement appendString:string];
    
}

-(IBAction)settlementClicked:(id)sender
{
    if(XmlResponseArray.count > 0)
    {
//        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self settlementData:@"ProcessCreditCard" data:[NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=%@&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=&InvNum=&PNRef=&Zip=&Street=&CVNum=&ExtData=%@",@"Nira3455",@"H5493nb4",@"CaptureAll",@"<CardType>ALL</CardType>"]];
        });
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDBController popupAlertFromVC:self title:@"Info" message:@"Please get Data for Settlement" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(void)settlementData:(NSString *)function data:(NSString *)data
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://gatewaystage.itstgate.com/SmartPayments/transact.asmx/%@",function]];
    NSData *postData=[data dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = url;
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = postData;
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [_activityIndicator hideActivityIndicator];
    if(urlData)
    {
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDBController popupAlertFromVC:self title:@"Info" message:[NSString stringWithFormat:@"TGate connection failed with error: %@",error.localizedDescription] buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
