//
//  CL_StatisticInfoCollectionVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 08/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CL_StatisticInfoCollectionVC.h"
#import "CL_StatisticDetailCell.h"
#import "RmsDbController.h"

typedef NS_ENUM(NSInteger, CS_Stataics) {
    CS_PaymentType,
    CS_PurchaseDate,
    CS_YTDPurchase,
    CS_AVGTicket,
    CS_AVGQty,
};


@interface CL_StatisticInfoCollectionVC ()<UICollectionViewDataSource , UICollectionViewDelegate>
{
    NSArray *enumArray;
    NSMutableArray *arrPaymentInfo;
    NSString *strAvgTicket;
    NSString *strAvgQTY;
    NSString *strPurched;
    NSString *strLastPurched;

}

@property (nonatomic, weak) IBOutlet UICollectionView *infoCollectionView;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong)     CS_Statistics *cs_Statistic;

@end

@implementation CL_StatisticInfoCollectionVC



- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    enumArray = @[@(CS_PaymentType),@(CS_PurchaseDate),@(CS_YTDPurchase),@(CS_AVGTicket),@(CS_AVGQty)];
    [self.infoCollectionView reloadData];

    // Do any additional setup after loading the view.
}

-(void)setStatisticInfoDetail:(CS_Statistics*)statisticDetail
{
    self.cs_Statistic = statisticDetail;
    arrPaymentInfo = statisticDetail.paymentType;

    [self.infoCollectionView reloadData];
}
-(NSAttributedString *)purchaseFormatDate:(NSString *)strDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *date  = [dateFormatter dateFromString:strDate];
    
    NSDateFormatter *stringDateFormatter = [[NSDateFormatter alloc]init];
    stringDateFormatter.dateFormat = @"dd MMMM";
    NSString *strDateString = [stringDateFormatter stringFromDate:date];
    
    NSDateFormatter *stringTimeFormatter = [[NSDateFormatter alloc]init];
    stringTimeFormatter.dateFormat = @"HH:mm EEEE";
    NSString *timeString = [stringTimeFormatter stringFromDate:date];
    
    NSAttributedString *dateString  = [self getAttributedLastPurchaseDate:strDateString forBottomTitle:timeString];
    return dateString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return enumArray.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"CL_StatisticDetailCell";

    CL_StatisticDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *headervalue = @"";
    
    CS_Stataics cs_Stataics = [enumArray[indexPath.row] integerValue];
    switch (cs_Stataics) {
            
        case CS_PaymentType:
            headervalue = @"PAYMENT TYPES";
            if (arrPaymentInfo.count>0)
            {
                cell.detailOfCell.attributedText = [self paymentDetailString];
            }
            else
            {
                cell.detailOfCell.text = @"---";
            }
            cell.imgInfo.image = [UIImage imageNamed:@"paymenttypesicon.png"];
            cell.backgroundColor = [UIColor colorWithRed:0.902 green:0.592 blue:0.184 alpha:1.000];
            break;
            
        case CS_PurchaseDate:
            headervalue = @"LAST PURCHASE";
            cell.imgInfo.image = [UIImage imageNamed:@"lastpurchase.png"];
            
            if ((self.cs_Statistic.lastPurchaseDateTime != nil) && (![self.cs_Statistic.lastPurchaseDateTime isEqualToString:@""]))
            {
                cell.detailOfCell.attributedText = [self purchaseFormatDate:self.cs_Statistic.lastPurchaseDateTime];
            }
            else
            {
                cell.detailOfCell.text = @"---";
            }
            cell.backgroundColor = [UIColor colorWithRed:0.788 green:0.416 blue:0.114 alpha:1.000];

            break;
            
        case CS_YTDPurchase:
            headervalue = @"PURCHASE";
            cell.detailOfCell.attributedText = [self getAttributeStringForValue:self.cs_Statistic.purchaseItem.stringValue forBottomTitle:@"ITEM PURCHASED"];
            cell.imgInfo.image = [UIImage imageNamed:@"ytdicon.png"];
            cell.backgroundColor = [UIColor colorWithRed:0.443 green:0.663 blue:0.945 alpha:1.000];


            
            break;
        case CS_AVGTicket:
            headervalue = @"AVERAGE TICKET";
            cell.detailOfCell.attributedText = [self getAttributeStringForValue:[NSString stringWithFormat:@"%.2f",self.cs_Statistic.avgTickets.floatValue] forBottomTitle:@"SPENT"];
            cell.imgInfo.image = [UIImage imageNamed:@"ticketicon.png"];
            cell.backgroundColor = [UIColor colorWithRed:0.443 green:0.651 blue:0.682 alpha:1.000];


            
            break;
        case CS_AVGQty:
            headervalue = @"AVERAGE QTY";
            cell.detailOfCell.attributedText = [self getAttributeStringForValue:self.cs_Statistic.avgQty.stringValue forBottomTitle:@"ITEMS PER VISIT"];
            cell.imgInfo.image = [UIImage imageNamed:@"qtyicon.png"];
            cell.backgroundColor = [UIColor colorWithRed:0.341 green:0.416 blue:0.722 alpha:1.000];


            break;
            
        default:
            break;
    }
    cell.headerOfCell.text = headervalue;
    cell.layer.cornerRadius = cell.frame.size.width/2;
    
    return cell;
}
-(NSString*)strDateTime
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM/dd/yyyy";
    
    NSDate *now = [self.rmsDbController getDateFromJSONDate:strLastPurched];
    NSString *dateString = [format stringFromDate:now];

    return dateString;
}
-(NSAttributedString *)paymentDetailString
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"PaymentPer"
                                                 ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    arrPaymentInfo = [[arrPaymentInfo sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    NSInteger intpaymentCount = arrPaymentInfo.count;
    NSMutableArray *arrPayment = [NSMutableArray array];
    if (intpaymentCount>3)
    {
        intpaymentCount = 3;
    }
    for (int i = 0; i < intpaymentCount; i++)
    {
        [arrPayment addObject:arrPaymentInfo[i]];
    }
   
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
   
    for (NSDictionary *dictionary  in arrPayment) {
        
        NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
        attributesDictionary[NSFontAttributeName] = [UIFont fontWithName:@"Lato" size:12.0];
        attributesDictionary[NSForegroundColorAttributeName] = [UIColor whiteColor];
        attributesDictionary[NSParagraphStyleAttributeName] = paragraphStyle;
        
        NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:[dictionary valueForKey:@"PaymentName"] attributes:attributesDictionary];
        
        
        
        NSMutableDictionary *attributesDictionary1 = [NSMutableDictionary dictionary];
        attributesDictionary1[NSFontAttributeName] = [UIFont fontWithName:@"Lato" size:14.0];
        
        attributesDictionary1[NSForegroundColorAttributeName] = [UIColor whiteColor];
        attributesDictionary1[NSParagraphStyleAttributeName] = paragraphStyle;
        
        
        NSString *strPaymentPercentage = [NSString stringWithFormat:@"%.2f%%",[[dictionary valueForKey:@"PaymentPer"] floatValue]];
        NSAttributedString *attributedString1 = [[NSAttributedString alloc]initWithString:strPaymentPercentage attributes:attributesDictionary1];
        
        NSAttributedString *attributedString2 = [[NSAttributedString alloc]initWithString:@" " attributes:attributesDictionary1];

        NSMutableAttributedString *nextLine = [[NSMutableAttributedString alloc] initWithString:@"\n"];
        [string appendAttributedString:attributedString1];
        [string appendAttributedString:attributedString2];
        [string appendAttributedString:attributedString];
        [string appendAttributedString:nextLine];
    }
    
    return string;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(NSAttributedString *)getAttributeStringForValue:(NSString *)value forBottomTitle:(NSString *)bottomTitle
{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSMutableDictionary *attributesDictionary = [NSMutableDictionary dictionary];
    attributesDictionary[NSFontAttributeName] = [UIFont fontWithName:@"Lato" size:40.0];

    attributesDictionary[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attributesDictionary[NSParagraphStyleAttributeName] = paragraphStyle;
    if (value !=nil)
    {
       NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:value attributes:attributesDictionary];
        NSMutableDictionary *attributesDictionary1 = [NSMutableDictionary dictionary];
        attributesDictionary1[NSFontAttributeName] = [UIFont fontWithName:@"Lato" size:10.0];
        attributesDictionary1[NSParagraphStyleAttributeName] = paragraphStyle;
        attributesDictionary1[NSForegroundColorAttributeName] = [UIColor whiteColor];
        
        NSAttributedString *attributedString1 = [[NSAttributedString alloc]initWithString:bottomTitle attributes:attributesDictionary1];
        
        NSMutableAttributedString *nextLine = [[NSMutableAttributedString alloc] initWithString:@"\n"];
        [string1 appendAttributedString:attributedString];
        [string1 appendAttributedString:nextLine];
        [string1 appendAttributedString:attributedString1];

    }
       return string1;
}


-(NSAttributedString *)getAttributedLastPurchaseDate:(NSString *)dateString forBottomTitle:(NSString *)timeString
{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *finalDateAndTimeAttributeString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSMutableDictionary *dateStringattributesDictionary = [NSMutableDictionary dictionary];
    dateStringattributesDictionary[NSFontAttributeName] = [UIFont fontWithName:@"Lato" size:16.0];
    dateStringattributesDictionary[NSForegroundColorAttributeName] = [UIColor whiteColor];
    dateStringattributesDictionary[NSParagraphStyleAttributeName] = paragraphStyle;
    
    
    NSMutableDictionary *timeStringAttributesDictionary = [NSMutableDictionary dictionary];
    timeStringAttributesDictionary[NSFontAttributeName] = [UIFont fontWithName:@"Lato" size:13.0];
    timeStringAttributesDictionary[NSForegroundColorAttributeName] = [UIColor whiteColor];
    timeStringAttributesDictionary[NSParagraphStyleAttributeName] = paragraphStyle;

    
    
    NSAttributedString *dateAttributedString = [[NSAttributedString alloc]initWithString:dateString attributes:dateStringattributesDictionary];
  
    NSAttributedString *timeAttributedString = [[NSAttributedString alloc]initWithString:timeString attributes:timeStringAttributesDictionary];
    
    NSMutableAttributedString *nextLine = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    [finalDateAndTimeAttributeString appendAttributedString:dateAttributedString];
    [finalDateAndTimeAttributeString appendAttributedString:nextLine];
    [finalDateAndTimeAttributeString appendAttributedString:timeAttributedString];
    
    return finalDateAndTimeAttributeString;
}



@end
