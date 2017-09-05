#import "ScannerViewController.h"
#import "NSDataCrypto.h"
#import "dukpt.h"

//#define LOG_FILE

@implementation ScannerViewController

@synthesize suspendDisplayInfo;

bool scanActive=false;
NSTimer *ledTimer=nil;

-(NSString *)getLogFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"log.txt"];
}

-(void)debug:(NSString *)text
{
	NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"HH:mm:ss:SSS"];
	NSString *timeString = [dateFormat stringFromDate:[NSDate date]];
	
	if([debug length]>10000)
		[debug setString:@""];
	[debug appendFormat:@"%@-%@\n",timeString,text];

	[debugText setText:debug];
#ifdef LOG_FILE
	[debug writeToFile:[self getLogFile]  atomically:YES];
#endif
}

-(void)debugString:(NSString *)text
{
    [self debug:text];
}

-(void)displayAlert:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

-(void)updateBattery
{
    NSError *error=nil;
    
    int percent;
    float voltage;

	if([dtdev getBatteryCapacity:&percent voltage:&voltage error:&error])
    {
        [batteryButton setTitle:[NSString stringWithFormat:@"%d%%,%.1fv",percent,voltage] forState:UIControlStateNormal];
        [batteryButton setHidden:FALSE];
        if(percent<0.1)
            [batteryButton setBackgroundImage:[UIImage imageNamed:@"0.png"] forState:UIControlStateNormal];
        else if(percent<40)
            [batteryButton setBackgroundImage:[UIImage imageNamed:@"25.png"] forState:UIControlStateNormal];
        else if(percent<60)
            [batteryButton setBackgroundImage:[UIImage imageNamed:@"50.png"] forState:UIControlStateNormal];
        else if(percent<80)
            [batteryButton setBackgroundImage:[UIImage imageNamed:@"75.png"] forState:UIControlStateNormal];
        else
            [batteryButton setBackgroundImage:[UIImage imageNamed:@"100.png"] forState:UIControlStateNormal];
    }else
    {
        [batteryButton setHidden:TRUE];
    }
}

-(void)ledTimerFunc:object
{
    if(![dtdev uiControlLEDsWithBitMask:arc4random() error:nil])
    {
        [ledTimer invalidate];
        ledTimer=nil;
    }
}

-(IBAction)scanDown:(id)sender;
{
    NSError *error=nil;

	[statusImage setImage:[UIImage imageNamed:@"scanning.png"]];
	[displayText setText:@""];
	//refresh the screen
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    int scanMode;
    
    if([dtdev getSupportedFeature:FEAT_LEDS error:nil]==FEAT_SUPPORTED && ledTimer==nil)
    {
        ledTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ledTimerFunc:) userInfo:nil repeats:YES];
    }
    
    if([dtdev barcodeGetScanMode:&scanMode error:&error] && scanMode==MODE_MOTION_DETECT)
    {
        if(scanActive)
        {
            scanActive=false;
            SHOWERR([dtdev barcodeStopScan:&error]);
        }else {
            scanActive=true;
            SHOWERR([dtdev barcodeStartScan:&error]);
        }
    }else
        SHOWERR([dtdev barcodeStartScan:&error]);
}

-(IBAction)scanUp:(id)sender;
{
    NSError *error;
    
    if([dtdev getSupportedFeature:FEAT_LEDS error:nil]==FEAT_SUPPORTED)
    {
        [ledTimer invalidate];
        ledTimer=nil;
        [dtdev uiControlLEDsWithBitMask:0 error:nil];
    }
    
	[statusImage setImage:[UIImage imageNamed:@"connected.png"]];
    int scanMode;
    
    if([dtdev barcodeGetScanMode:&scanMode error:&error] && scanMode!=MODE_MOTION_DETECT)
        SHOWERR([dtdev barcodeStopScan:&error]);
}

-(IBAction)onBattery:(id)sender
{
    [self updateBattery];
}

-(void)connectionState:(int)state {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterLongStyle];
    
    [ledTimer invalidate];
    ledTimer=nil;
    
	switch (state) {
		case CONN_DISCONNECTED:
		case CONN_CONNECTING:
			[statusImage setImage:[UIImage imageNamed:@"disconnected.png"]];
			[displayText setText:[NSString stringWithFormat:@"Device not connected\nSDK: ver %d.%d (%@)",dtdev.sdkVersion/100,dtdev.sdkVersion%100,[dateFormat stringFromDate:dtdev.sdkBuildDate]]];
			[batteryButton setHidden:TRUE];
			[scanButton setHidden:TRUE];
			[printButton setHidden:TRUE];
			break;
		case CONN_CONNECTED:
            [debug deleteCharactersInRange:NSMakeRange(0,debug.length)];
            debugText.text=@"";
            scanActive=false;
			[statusImage setImage:[UIImage imageNamed:@"connected.png"]];
			[status setString:[NSString stringWithFormat:@"SDK: ver %d.%d (%@)\n%@ %@ connected\nHardware revision: %@\nFirmware revision: %@\nSerial number: %@",dtdev.sdkVersion/100,dtdev.sdkVersion%100,[dateFormat stringFromDate:dtdev.sdkBuildDate],dtdev.deviceName,dtdev.deviceModel,dtdev.hardwareRevision,dtdev.firmwareRevision,dtdev.serialNumber]];
			[displayText setText:status];
			[scanButton setHidden:FALSE];
            if([dtdev getSupportedFeature:FEAT_BLUETOOTH error:nil]!=FEAT_UNSUPPORTED)
                [printButton setHidden:FALSE];
            
            [self updateBattery];
			break;
	}
}

-(void)deviceButtonPressed:(int)which {
	[debug setString:@""];
	//[self cleanPrintInfo];

    if([dtdev getSupportedFeature:FEAT_LEDS error:nil]==FEAT_SUPPORTED && ledTimer==nil)
    {
        ledTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ledTimerFunc:) userInfo:nil repeats:YES];
    }
    
	[displayText setText:@""];
	[statusImage setImage:[UIImage imageNamed:@"scanning.png"]];
}

-(void)deviceButtonReleased:(int)which {
    if([dtdev getSupportedFeature:FEAT_LEDS error:nil]==FEAT_SUPPORTED)
    {
        [ledTimer invalidate];
        ledTimer=nil;
        [dtdev uiControlLEDsWithBitMask:0 error:nil];
    }
	[statusImage setImage:[UIImage imageNamed:@"connected.png"]];
}

-(void)PINEntryCompleteWithError:(NSError *)error
{
    mainTabBarController.selectedViewController=self;
    [progressViewController.view removeFromSuperview];
    if(error)
    {
        [displayText setText:[NSString stringWithFormat:@"PIN entry failed: %@",error.localizedDescription]];
    }else
    {
        //try to get the encrypted data, it will work only if the keys are already set
        NSData *pinData=[dtdev pinGetPINBlockUsingDUKPT:0 keyVariant:nil pinFormat:PIN_FORMAT_ISO1 error:&error];
////        NSData *pinData=[dtdev ppadGetPINBlockUsingFixedKey:2 keyVariant:nil pinFormat:PIN_FORMAT_ISO1 error:&error];
        if(pinData)
        {
            [displayText setText:[NSString stringWithFormat:@"PIN entry complete, encrypted data:\n%@",[self toHexString:(uint8_t *)pinData.bytes length:pinData.length space:true]]];
        }else
        {
            [displayText setText:[NSString stringWithFormat:@"PIN entry complete"]];
        }
    }
}

-(void)barcodeData:(NSString *)barcode isotype:(NSString *)isotype
{
    mainTabBarController.selectedViewController=self;
    
	[status setString:@""];
	[status appendFormat:@"ISO Type: %@\n",isotype];
	[status appendFormat:@"Barcode: %@",barcode];
    
	[displayText setText:status];

	[self updateBattery];
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    mainTabBarController.selectedViewController=self;
    
	[status setString:@""];

	[status appendFormat:@"Type: %d\n",type];
	[status appendFormat:@"Type text: %@\n",[dtdev barcodeType2Text:type]];
	[status appendFormat:@"Barcode: %@",barcode];
	[displayText setText:status];
    
    if([dtdev getSupportedFeature:FEAT_VIBRATION error:nil]==FEAT_SUPPORTED)
    {
        [dtdev uiEnableVibrationForTime:1.5 error:nil];
    }
    
	[self updateBattery];
}

-(void)smartCardInserted:(SC_SLOTS)slot {
    mainTabBarController.selectedViewController=self;
    
    NSData *atr=[dtdev scCardPowerOn:slot error:nil];
    if(atr)
    {
        [displayText setText:[NSString stringWithFormat:@"SmartCard Inserted\nATR: %@",[self toHexString:(void *)[atr bytes] length:[atr length] space:true]]];
        //also, if we have pinpad connected, ask for pin entry
        if([dtdev getSupportedFeature:FEAT_PIN_ENTRY error:nil]==FEAT_SUPPORTED)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PIN Entry" message:@"Do you want to enter PIN?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert show];
        }
        
    }else
    {
//        [displayText setText:@"SmartCart reset failed!"];
    }
}

-(void)smartCardRemoved:(SC_SLOTS)slot {
//    [displayText setText:@"SmartCard Removed"];
}

-(void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    mainTabBarController.selectedViewController=self;
    
	[status setString:@""];
	
	NSDictionary *card=[dtdev msProcessFinancialCard:track1 track2:track2];
	if(card)
	{
		if([card valueForKey:@"cardholderName"])
			[status appendFormat:@"Name: %@\n",[card valueForKey:@"cardholderName"]];
		if([card valueForKey:@"accountNumber"])
			[status appendFormat:@"Number: %@\n",[card valueForKey:@"accountNumber"]];
		if([card valueForKey:@"expirationMonth"])
			[status appendFormat:@"Expiration: %@/%@\n",[card valueForKey:@"expirationMonth"],[card valueForKey:@"expirationYear"]];
		[status appendString:@"\n"];
	}
	
	if(track1!=NULL)
		[status appendFormat:@"Track1: %@\n",track1];
	if(track2!=NULL)
		[status appendFormat:@"Track2: %@\n",track2];
	if(track3!=NULL)
		[status appendFormat:@"Track3: %@\n",track3];
	[displayText setText:status];
	
	int sound[]={2730,150,0,30,2730,150};
	[dtdev playSound:100 beepData:sound length:sizeof(sound) error:nil];
	[self updateBattery];
    
    //also, if we have pinpad connected, ask for pin entry
    if(card && [dtdev getSupportedFeature:FEAT_PIN_ENTRY error:nil]==FEAT_SUPPORTED)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PIN Entry" message:@"Do you want to enter PIN?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

-(NSString *)toHexString:(void *)data length:(int)length space:(bool)space
{
	const char HEX[]="0123456789ABCDEF";
	char s[2000];
	
	int len=0;
	for(int i=0;i<length;i++)
	{
		s[len++]=HEX[((uint8_t *)data)[i]>>4];
		s[len++]=HEX[((uint8_t *)data)[i]&0x0f];
        if(space)
            s[len++]=' ';
	}
	s[len]=0;
	return [NSString stringWithCString:s encoding:NSASCIIStringEncoding];
}

-(void)magneticCardRawData:(NSData *)tracks {
    mainTabBarController.selectedViewController=self;
	[status setString:[self toHexString:(void *)[tracks bytes] length:[tracks length] space:true]];
	[displayText setText:status];
	
	int sound[]={2700,150,5400,150};
	[dtdev playSound:100 beepData:sound length:sizeof(sound) error:nil];
	[self updateBattery];
}

-(uint16_t)crc16:(uint8_t *)data length:(int)length crc16:(uint16_t)crc16
{
	if(length==0) return 0;
	int i=0;
	while(length--)
	{
		crc16=(uint8_t)(crc16>>8)|(crc16<<8);
		crc16^=*data++;
		crc16^=(uint8_t)(crc16&0xff)>>4;
		crc16^=(crc16<<8)<<4;
		crc16^=((crc16&0xff)<<4)<<1;
		i++;
	}
	return crc16;
}

-(void)magneticJISCardData:(NSString *)data {
    [displayText setText:[NSString stringWithFormat:@"JIS card data:\n%@",data]];

	int sound[]={2730,150,0,30,2730,150};
	[dtdev playSound:100 beepData:sound length:sizeof(sound) error:nil];
	[self updateBattery];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
        //Ask for pin, display progress dialog, the pin result will be done via notification
        if([dtdev ppadStartPINEntry:0 startY:2 timeout:30 echoChar:'*' message:[NSString stringWithFormat:@"Amount: %.2f\nEnter PIN:",12.34] error:nil])
        {
            [progressViewController viewWillAppear:FALSE];
            [self.view addSubview:progressViewController.view];
            [progressViewController updateText:@"Please use the pinpad to complete the operation..."];
        }
	}
}


//demo by sending encrypted data to tgate servers for processing
#define POST_TGATE
//demo by sending encrypted data to element express servers for processing
//element express code is incomplte
//#define POST_ELEMENTEXPRESS

#ifdef POST_TGATE
-(void)tgatePost:(NSString *)function data:(NSString *)data
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://gatewaystage.itstgate.com/SmartPayments/transact3.asmx/%@",function]];
    NSData *postData=[data dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [progressViewController viewWillAppear:FALSE];
	[self.view addSubview:progressViewController.view];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[progressViewController.view removeFromSuperview];
    if(urlData)
    {
        [self displayAlert:@"TGate response" message:[[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding]];
    }else {
        [self displayAlert:@"Error" message:[NSString stringWithFormat:@"TGate connection failed with error: %@",error.localizedDescription]];
    }
}
#endif
#ifdef POST_ELEMENTEXPRESS
-(void)eePost:(NSString *)data
{
    NSURL *url=[NSURL URLWithString:@"https://certtransaction.elementexpress.com/"];
    NSData *postData=[data dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [progressViewController viewWillAppear:FALSE];
	[self.view addSubview:progressViewController.view];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[progressViewController.view removeFromSuperview];
    if(urlData)
    {
        [self displayAlert:@"TGate response" message:[[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding]];
    }else {
        [self displayAlert:@"Error" message:[NSString stringWithFormat:@"TGate connection failed with error: %@",error.localizedDescription]];
    }
}
#endif

-(void)magneticCardDUKPT:(NSData *)data
{
    //find the tracks, turn to ascii hex the data
    int index=0;
    uint8_t *bytes=(uint8_t *)[data bytes];
    
    index++; //card encoding type
    index++; //track status
    int t1Len=bytes[index++]; //track 1 unencrypted length
    int t2Len=bytes[index++]; //track 2 unencrypted length
    int t3Len=bytes[index++]; //track 3 unencrypted length
    NSString *t1masked=[[NSString alloc] initWithBytes:&bytes[index] length:t1Len encoding:NSASCIIStringEncoding];
    index+=t1Len; //track 1 masked
    NSString *t2masked=[[NSString alloc] initWithBytes:&bytes[index] length:t2Len encoding:NSASCIIStringEncoding];
    index+=t2Len; //track 2 masked
    NSString *t3masked=[[NSString alloc] initWithBytes:&bytes[index] length:t3Len encoding:NSASCIIStringEncoding];
    index+=t3Len; //track 3 masked
    uint8_t *encrypted=&bytes[index]; //encrypted
    int encLen=[data length]-index-10-40;
    index+=encLen;
    index+=20; //track1 sha1
    index+=20; //track2 sha1
    uint8_t *dukptser=&bytes[index]; //dukpt serial number
    
    [status appendFormat:@"IDTECH card format\n"];
    [status appendFormat:@"Track1: %@\n",t1masked];
    [status appendFormat:@"Track2: %@\n",t2masked];
    [status appendFormat:@"Track3: %@\n",t3masked];
    [status appendFormat:@"\r\nEncrypted: %@\n",[self toHexString:encrypted length:encLen space:true]];
    [status appendFormat:@"KSN: %@\n\n",[self toHexString:dukptser length:10 space:true]];
    
    //try decrypting the data
    //calculate the IPEK based on the BDK and serial number
    //insert your own BDK here and calculate the IPEK, for the demo we are using predefined IPEK, that is loaded on the test units
//    uint8_t bdk[16]=TGATE_DUKPT_BDK;
    uint8_t ipek[16]={0x82,0xDF,0x8A,0xC0,0x22,0x91,0x62,0xAF,0x04,0x0C,0xF4,0xD0,0x76,0x43,0x72,0x79};
    //derive ipek from bdk
//    dukptDeriveIPEK(bdk,dukptser,ipek);
    //calculate the key based on the serial number and IPEK
    uint8_t idtechKey[16]={0};
    dukptCalculateDataKey(dukptser,ipek,idtechKey);
    
    //decrypt the data with the calculated key
    uint8_t decrypted[512];
    trides_crypto(kCCDecrypt,0,encrypted,encLen,decrypted,idtechKey);
    NSString *t1=@"";
    NSString *t2=@"";
    if(t1Len)
        t1=[[NSString alloc] initWithBytes:&decrypted[0] length:t1Len encoding:NSASCIIStringEncoding];
    if(t2Len)
        t2=[[NSString alloc] initWithBytes:&decrypted[t1Len] length:t2Len encoding:NSASCIIStringEncoding];
    if([t1 hasPrefix:@"%B"])
        [status appendFormat:@"Decrypted T1: %@\n",t1];
    else
        [status appendFormat:@"Decrypting T1 failed"];
    if([t2 hasPrefix:@";"])
        [status appendFormat:@"Decrypted T2: %@\n",t2];
    else
        [status appendFormat:@"Decrypting T2 failed"];
    
    if(t1masked.length>0 && [dtdev msProcessFinancialCard:t1masked track2:t2masked])
    {//if the card is a financial card, try sending to a processor for verification
#ifdef POST_TGATE
#define TGATE_USER @""
#define TGATE_PASS @""
        NSString *extData=[NSString stringWithFormat:@"<Track1>%@</Track1><SecureFormat>SecureMag</SecureFormat><SecurityInfo>%@</SecurityInfo>",
                           [self toHexString:encrypted length:encLen space:false],
                           [self toHexString:dukptser length:10 space:false]];
        //[self tgatePost:@"GenerateCardToken" data:[NSString stringWithFormat:@"UserName=%@&Password=%@&CardNumber=&ExtData=%@",TGATE_USER,TGATE_PASS,extData]];
        [self tgatePost:@"ProcessCreditCard" data:[NSString stringWithFormat:@"UserName=%@&Password=%@&TransType=Auth&CardNum=&ExpDate=&MagData=&NameOnCard=&Amount=0.01&InvNum=&PNRef=&Zip=&Street=&CVNum=&ExtData=%@",TGATE_USER,TGATE_PASS,extData]];
#endif
#ifdef POST_ELEMENTEXPRESS
        NSMutableString *s=[[NSMutableString alloc] init];
        [s appendFormat:@"<HealthCheck xmlns='https://transaction.elementexpress.com'>"];
        [s appendFormat:@"<Credentials>"];
        [s appendFormat:@"<AccountID>%d</AccountID>",1009617];
        [s appendFormat:@"<AccountToken>%@</AccountToken>",@"782C61317113B722B9AEEE0DA3C1450B6AF6021C12A48699710F115E3AE5D7D9D4B3ED01"];
        [s appendFormat:@"<AcceptorID>%d</AcceptorID>",3928907];
        [s appendFormat:@"</Credentials>"];
        [s appendFormat:@"<Application>"];
        [s appendFormat:@"<ApplicationID>%d</ApplicationID>",1360];
        [s appendFormat:@"<ApplicationName>HealthCheck</ApplicationName>"];
        [s appendFormat:@"<ApplicationVersion>1.0</ApplicationVersion>"];
        [s appendFormat:@"</Application>"];
        [s appendFormat:@"</HealthCheck>"];
        [self eePost:s];
#endif
    }
}

-(bool)magneticCardAES:(NSData *)data
{
	//last used decryption key is stored in preferences
	NSString *decryptionKey=[[NSUserDefaults standardUserDefaults] objectForKey:@"DecryptionKey"];
	if(decryptionKey==nil || decryptionKey.length!=32)
		decryptionKey=@"11111111111111111111111111111111"; //sample default
    
    NSData *decrypted=[data AESDecryptWithKey:[decryptionKey dataUsingEncoding:NSASCIIStringEncoding]];
    //basic check if the decrypted data is valid
    if(decrypted)
    {
        uint8_t *bytes=(uint8_t *)[decrypted bytes];
        for(int i=0;i<([decrypted length]-2);i++)
        {
            if(i>(4+16) && !bytes[i])
            {
                uint16_t crc16=[self crc16:bytes length:(i+1) crc16:0];
                uint16_t crc16Data=(bytes[i+1]<<8)|bytes[i+2];
                
                if(crc16==crc16Data)
                {
                    int snLen=0;
                    for(snLen=0;snLen<16;snLen++)
                        if(!bytes[4+snLen])
                            break;
                    NSString *sn=[[NSString alloc] initWithBytes:&bytes[4] length:snLen encoding:NSASCIIStringEncoding];
                    //do something with that serial number
                    //crc matches, extract the tracks then
                    int dataLen=i;
                    //check for JIS card
                    if(bytes[4+16]==0xF5)
                    {
                        NSString *data=[[NSString alloc] initWithBytes:&bytes[4+16+1] length:(dataLen-4-16-2) encoding:NSASCIIStringEncoding];
                        //pass to the non-encrypted function to display JIS card
                        [self magneticJISCardData:data];
                    }else
                    {
                        int t1=-1,t2=-1,t3=-1,tend;
                        NSString *track1=nil,*track2=nil,*track3=nil;
                        //find the tracks offset
                        for(int j=(4+16);j<dataLen;j++)
                        {
                            if(bytes[j]==0xF1)
                                t1=j;
                            if(bytes[j]==0xF2)
                                t2=j;
                            if(bytes[j]==0xF3)
                                t3=j;
                        }
                        if(t1!=-1)
                        {
                            if(t2!=-1)
                                tend=t2;
                            else
                                if(t3!=-1)
                                    tend=t3;
                                else
                                    tend=dataLen;
                            track1=[[NSString alloc] initWithBytes:&bytes[t1+1] length:(tend-t1-1) encoding:NSASCIIStringEncoding];
                        }
                        if(t2!=-1)
                        {
                            if(t3!=-1)
                                tend=t3;
                            else
                                tend=dataLen;
                            track2=[[NSString alloc] initWithBytes:&bytes[t2+1] length:(tend-t2-1) encoding:NSASCIIStringEncoding];
                        }
                        if(t3!=-1)
                        {
                            tend=dataLen;
                            track3=[[NSString alloc] initWithBytes:&bytes[t3+1] length:(tend-t3-1) encoding:NSASCIIStringEncoding];
                        }
                        
                        //pass to the non-encrypted function to display tracks
                        [self magneticCardData:track1 track2:track2 track3:track3];
                    }
                    return true;
                }
            }
        }
    }
    [status setString:NSLocalizedString(@"Card data cannot be decrypted, possibly key is invalid",nil)];
    return false;
}

//the new notification, sent by 1.75+ sdk
-(void)magneticCardEncryptedData:(int)encryption tracks:(int)tracks data:(NSData *)data track1masked:(NSString *)track1masked track2masked:(NSString *)track2masked track3:(NSString *)track3
{
    mainTabBarController.selectedViewController=self;
    
	[status setString:@""];
    
    if(tracks!=0)
    {
        //you can check here which tracks are read and discard the data if the requred ones are missing
        // for example:
        //if(!(tracks&2)) return; //bail out if track 2 is not read
    }
	
    if(encryption==ALG_AES256 || encryption==ALG_EH_AES256)
    {
        if(![self magneticCardAES:data] && (track1masked || track2masked))
        {//if data can't or is not supposed to be decrypted on the device, work with masked card data to display
            //pass to the non-encrypted function to display tracks
            [self magneticCardData:track1masked track2:track2masked track3:track3];
        }
    }
    if(encryption==ALG_EH_IDTECH)
    {
        [self magneticCardDUKPT:data];
    }
    if(encryption==ALG_EH_RSA_OAEP)
    {
        [status setString:[NSString stringWithFormat:@"RSA Magnetic Card Data:\n%@",[self toHexString:(uint8_t *)data.bytes length:data.length space:YES]]];
        int sound[]={2730,150,0,30,2730,150};
        [dtdev playSound:100 beepData:sound length:sizeof(sound) error:nil];
    }
	[displayText setText:status];
}

-(IBAction)onPrint:(id)sender
{
    NSError *error;
    
	NSString *selectedPrinterAddress=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedPrinterAddress"];
    
    if(!selectedPrinterAddress || ![selectedPrinterAddress length])
	{
        [self displayAlert:@"Bluetooth printing" message:@"Please discover and select bluetooth printer from the settings."];
        return;
	}
	
    if(displayText.text.length<1)
	{
        [self displayAlert:@"Bluetooth printing" message:@"Nothing to print, scan barcode or magnetic card first"];
        return;
	}
	
    [progressViewController viewWillAppear:FALSE];
	[self.view addSubview:progressViewController.view];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    
    if([dtdev btConnectSupportedDevice:selectedPrinterAddress pin:@"0000" error:&error])
    {
        [dtdev prnPrintText:displayText.text error:&error];
        [dtdev prnFeedPaper:0 error:&error];
        [dtdev btDisconnect:selectedPrinterAddress error:&error];
    }else
        ERRMSG(@"Bluetooth connect failed");
    
	[progressViewController.view removeFromSuperview];
}


- (void)viewWillAppear:(BOOL)animated
{
	//update display according to current dtdev state
    if(!self.suspendDisplayInfo)
        [self connectionState:dtdev.connstate];
    self.suspendDisplayInfo=false;
}

- (void)viewDidLoad
{
    self.suspendDisplayInfo=false;
    scannerViewController=self;
	status=[[NSMutableString alloc] init];
	debug=[[NSMutableString alloc] init];
#ifdef LOG_FILE
	NSFileManager *fileManger = [NSFileManager defaultManager];
	if ([fileManger fileExistsAtPath:[self getLogFile]])
	{
		[debug appendString:[[NSString alloc] initWithContentsOfFile:[self getLogFile]]];
		[debugText setText:debug];
	}
#endif
	debugText.font=[debugText.font fontWithSize:8];
	dtdev=[DTDevices sharedDevice];
	[dtdev addDelegate:self];
    
    [super viewDidLoad];
}


@end
