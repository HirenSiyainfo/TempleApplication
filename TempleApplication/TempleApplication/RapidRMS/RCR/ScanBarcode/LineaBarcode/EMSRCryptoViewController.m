#import "EMSRCryptoViewController.h"
#import "NSDataCrypto.h"
#import <CommonCrypto/CommonDigest.h>

@implementation EMSRCryptoViewController

-(BOOL)textFieldShouldEndEditing:(UITextField *)theTextField;
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	[textField resignFirstResponder];
	return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //limit the size to 32
    int limit = 32;
    return !([textField.text length]>=limit && [string length] > range.length);
}

-(void)displayAlert:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

/**
 Loads initial key in plain text or changes existing key. Keys in plain text can be loaded only once,
 on every subsequent key change, they needs to be encrypted with KEY_EH_AES256_LOADING.
 
 KEY_EH_AES256_LOADING can be used to change all the keys in the head except for the TMK, and KEY_AES256_LOADING
 can be loaded in plain text the first time too.
 */
NSData *emsrGenerateKeyData(int keyID, int keyVersion, const uint8_t *keyData, int keyKength, const uint8_t aes256EncryptionKey[32])
{
    uint8_t data[256];
    int index=0;
	data[index++]=0x2b;
	//key to encrypt with, either KEY_AES256_LOADING or 0xff to use plain text
	data[index++]=aes256EncryptionKey?KEY_EH_AES256_LOADING:0xff;
    data[index++]=keyID; //key to set
    data[index++]=keyVersion>>24; //key version
    data[index++]=keyVersion>>16; //key version
    data[index++]=keyVersion>>8; //key version
    data[index++]=keyVersion; //key version
    int keyStart=index;
    memmove(&data[index],keyData,keyKength); //key data
    index+=keyKength;
    CC_SHA256(data,index,&data[index]); //calculate sha256 on the previous packet
	index+=CC_SHA256_DIGEST_LENGTH;
	//encrypt the data if using the encryption key
	if(aes256EncryptionKey)
	{
        NSData *encryptionKey=[NSData dataWithBytes:aes256EncryptionKey length:32];
        NSData *toEncrypt=[NSData dataWithBytes:&data[keyStart] length:index-keyStart];
        NSData *encrypted=[toEncrypt AESEncryptWithKey:encryptionKey]; //encrypt only the key, without the params before it
        
        //store the encryptd data back into the packet
        [encrypted getBytes:&data[keyStart]];
	}
    return [NSData dataWithBytes:data length:index];
}

-(IBAction)setAES256KeyEncryptionKey:(id)sender
{
	if([newAES256KeyEncryptionKey.text length]!=32 || ([oldAES256KeyEncryptionKey.text length]>0 && [oldAES256KeyEncryptionKey.text length]!=32))
	{
		[self displayAlert:NSLocalizedString(@"Wrong key",nil) message:NSLocalizedString(@"Key should be 32 symbols long",nil)];
		return;
	}
	NSData *newKeyData=[newAES256KeyEncryptionKey.text dataUsingEncoding:NSASCIIStringEncoding];
	NSData *oldKeyData=([oldAES256KeyEncryptionKey.text length]>0)?[oldAES256KeyEncryptionKey.text dataUsingEncoding:NSASCIIStringEncoding]:nil;
    NSError *error;
    
    NSData *keyData=emsrGenerateKeyData(KEY_EH_AES256_LOADING, [newAES256EncryptionKeyVersion.text intValue], (uint8_t *)newKeyData.bytes, newKeyData.length, oldKeyData!=nil?oldKeyData.bytes:nil);
    if([dtdev emsrLoadKey:keyData error:&error])
    {
        [self displayAlert:NSLocalizedString(@"Operation successful!",nil) message:NSLocalizedString(@"Key successfully set",nil)];
    }else
        ERRMSG(NSLocalizedString(@"Operation failed!",nil));
}

-(IBAction)setAES256EncryptionKey:(id)sender
{
	if([newAES256EncryptionKey.text length]!=32)
	{
		[self displayAlert:NSLocalizedString(@"Wrong key",nil) message:NSLocalizedString(@"Key should be 32 symbols long",nil)];
		return;
	}
	NSData *newKeyData=[newAES256EncryptionKey.text dataUsingEncoding:NSASCIIStringEncoding];
	NSData *KEKData=([newAES256KeyEncryptionKey.text length]>0)?[newAES256KeyEncryptionKey.text dataUsingEncoding:NSASCIIStringEncoding]:nil;
    NSError *error;
    
    //check to see if there was already a key in that slot, in this case an keyEncryptionKey should be provided
    int keyVer;
    [dtdev emsrGetKeyVersion:KEY_ENCRYPTION keyVersion:&keyVer error:nil];
    if(keyVer<=0)
        KEKData=nil;
    if(keyVer>0 && !KEKData)
    {
        ERRMSG(NSLocalizedString(@"Key Encryption Key must be provided",nil));
        return;
    }
    
    NSData *keyData=emsrGenerateKeyData(KEY_ENCRYPTION, [newAES256EncryptionKeyVersion.text intValue], (uint8_t *)newKeyData.bytes, newKeyData.length, KEKData!=nil?KEKData.bytes:nil);
    if([dtdev emsrLoadKey:keyData error:&error])
    {
        [self displayAlert:NSLocalizedString(@"Operation successful!",nil) message:NSLocalizedString(@"Key successfully set",nil)];
    }else
        ERRMSG(NSLocalizedString(@"Operation failed!",nil));
}

-(IBAction)setDUKPTEncryptionKey:(id)sender
{
    const uint8_t dukptKey[]=
    {
        //key
        0x82,0xDF,0x8A,0xC0,0x22,0x91,0x62,0xAF,0x04,0x0C,0xF4,0xD0,0x76,0x43,0x72,0x79,
        //serial
        0x32,0x01,0x10,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        //padding
        0x00,0x00,0x00,0x00,0x00,0x00
    };
    
	NSData *KEKData=([newAES256KeyEncryptionKey.text length]>0)?[newAES256KeyEncryptionKey.text dataUsingEncoding:NSASCIIStringEncoding]:nil;
    NSError *error;
    
    //check to see if there was already a key in that slot, in this case an keyEncryptionKey should be provided
    int keyVer;
    [dtdev emsrGetKeyVersion:KEY_EH_DUKPT_MASTER keyVersion:&keyVer error:nil];
    if(keyVer<=0)
        KEKData=nil;
    if(keyVer>0 && !KEKData)
    {
        ERRMSG(NSLocalizedString(@"Key Encryption Key must be provided",nil));
        return;
    }
    
    NSData *keyData=emsrGenerateKeyData(KEY_EH_DUKPT_MASTER, 22/*key version*/, dukptKey, sizeof(dukptKey), KEKData!=nil?KEKData.bytes:nil);
    if([dtdev emsrLoadKey:keyData error:&error])
    {
        [self displayAlert:NSLocalizedString(@"Operation successful!",nil) message:NSLocalizedString(@"Key successfully set",nil)];
    }else
        ERRMSG(NSLocalizedString(@"Operation failed!",nil));
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

-(IBAction)getEMSRInfo:(id)sender
{
    NSError *error;
    
    int emsrfwVersion,emsrSecurityVersion;
    BOOL emsrTampered;
    int aesENCVersion=-1,aesAUTHVersion=-1,aesLoadVersion=-1,dukptMasterVersion=-1,tmkVersion=-1;
    NSData *emsrSerial;

    if([dtdev emsrGetKeyVersion:KEY_ENCRYPTION keyVersion:&aesENCVersion error:nil] &&
       [dtdev emsrGetKeyVersion:KEY_AUTHENTICATION keyVersion:&aesAUTHVersion error:nil] &&
       [dtdev emsrGetKeyVersion:KEY_EH_AES256_LOADING keyVersion:&aesLoadVersion error:nil] &&
       [dtdev emsrGetKeyVersion:KEY_EH_DUKPT_MASTER keyVersion:&dukptMasterVersion error:nil] &&
       [dtdev emsrGetKeyVersion:KEY_EH_TMK_AES keyVersion:&tmkVersion error:nil] &&
       [dtdev emsrGetFirmwareVersion:&emsrfwVersion error:&error] &&
       [dtdev emsrGetSecurityVersion:&emsrSecurityVersion error:&error] &&
       [dtdev emsrIsTampered:&emsrTampered error:&error] &&
       (emsrSerial=[dtdev emsrGetSerialNumber:&error]))
    {
        NSString *emsrSerialString=@"Unknown";
        if(emsrSerial)
            emsrSerialString=[self toHexString:(uint8_t *)emsrSerial.bytes length:emsrSerial.length space:false];
    
        [self displayAlert:@"Encrypted head" message:[NSString stringWithFormat:@"Name: %@\nFW Version: %d\nSecurity Version: %d\nSerial: %@\nAES enc key version: %d\nAES auth key version: %d\nAES load key version: %d\nDUKPT key version: %d\nTMK key version: %d\nTampered: %@",
                                                      [dtdev emsrGetDeviceModel:nil],emsrfwVersion,emsrSecurityVersion,emsrSerialString,aesENCVersion,aesAUTHVersion,aesLoadVersion,dukptMasterVersion,tmkVersion,emsrTampered?@"TRUE":@"FALSE"]];
    }else
        ERRMSG(NSLocalizedString(@"Operation failed!",nil));
}

-(IBAction)enterMSData:(id)sender;
{
    [progressViewController viewWillAppear:FALSE];
    [progressViewController updateText:@"Please use the pinpad to complete the operation..."];
    [mainTabBarController.view addSubview:progressViewController.view];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        bool result=true;
        result=[dtdev ppadMagneticCardEntry:LANG_ENGLISH timeout:60 error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!result)
            {
                ERRMSG(NSLocalizedString(@"Operation failed!",nil));
            }
            [progressViewController.view removeFromSuperview];
        });
    });
}

-(IBAction)enterPIN:(id)sender;
{
    [progressViewController viewWillAppear:FALSE];
    [progressViewController updateText:@"Please use the pinpad to complete the operation..."];
    [mainTabBarController.view addSubview:progressViewController.view];
    
    //Ask for pin, display progress dialog, the pin result will be done via notification
    NSError *error;
    bool result=[dtdev ppadStartPINEntry:0 startY:2 timeout:30 echoChar:'*' message:[NSString stringWithFormat:@"Amount: %.2f\nEnter PIN:",12.34] error:&error];
    if(!result)
    {
        [progressViewController.view removeFromSuperview];
        ERRMSG(NSLocalizedString(@"Operation failed!",nil));
    }
}


static NSString * FORMATS[]={
    @"AES 256",
    @"IDTECH 3",
    @"MAGTEK 1",
    @"3DES",
    @"RSA-OAEP",
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"MS Encryption Format",nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sizeof(FORMATS)/sizeof(NSString *);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError *error;
    
    if(dtdev.connstate==CONN_CONNECTED && ![dtdev emsrSetEncryption:indexPath.row+ALG_EH_AES256 params:nil error:&error])
    {
        ERRMSG(NSLocalizedString(@"Operation failed!",nil));
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:indexPath.row+ALG_EH_AES256] forKey:@"emsrAlgorithm"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [emsrAlgorithmTable reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CryptoCell"];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int emsrAlgorithm=[[prefs objectForKey:@"emsrAlgorithm"] intValue];
    if(emsrAlgorithm<ALG_EH_AES256)
        emsrAlgorithm=ALG_EH_AES256;

    if(indexPath.row==(emsrAlgorithm-ALG_EH_AES256))
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    
    [cell.textLabel setText:FORMATS[indexPath.row]];
	return cell;
}


-(void)viewWillAppear:(BOOL)animated
{
}

-(void)viewWillDisappear:(BOOL)animated
{
}

-(void)viewDidLoad
{
    [self.view addSubview:cryptoView];
    ((UIScrollView *)self.view).contentSize=CGSizeMake(cryptoView.frame.size.width, cryptoView.frame.size.height);
	
	//we don't care about dtdev notifications here, so won't add the delegate
	dtdev=[DTDevices sharedDevice];
    [super viewDidLoad];
}



@end
