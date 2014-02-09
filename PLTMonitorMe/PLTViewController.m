//
//  PLTViewController.m
//  PLTMonitorMe
//
//  Created by Sairam Sankaran on 2/7/14.
//  Copyright (c) 2014 Sairam Sankaran. All rights reserved.
//

#import "PLTViewController.h"
#import "PLTDevice.h"
#import "PLTReportsViewController.h"
#import "PLTDetailsViewController.h"
#import "PLTSettingsViewController.h"

@interface PLTViewController () <PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>

@property(nonatomic, strong) PLTDevice *device;
@property (weak, nonatomic) IBOutlet UILabel *helloWorldLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceWornLabel;
@property (nonatomic) NSUInteger deviceWornStatus; // 1 = worn, 0 = not worn
@property (nonatomic) NSUInteger pedometerCount;
@property (nonatomic) NSUInteger pedometerCountHistory;
@property (weak, nonatomic) IBOutlet UILabel *healthLabel;
@property (weak, nonatomic) IBOutlet UIImageView *connectedStatusImageView;


- (IBAction)alertButtonSender:(id)sender;

@end

@implementation PLTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self = [super initWithNibName:@"PLTStatusViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
        self.helloWorldLabel.text = @"No available devices!";
        self.deviceWornLabel.text = @"-";
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailableNotification:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"MonitorME";
    self.deviceWornStatus = 0;
    self.pedometerCount = 0;
    self.pedometerCountHistory = 0;
    UIImage *image = [UIImage imageNamed: @"Dot_Red.png"];
    [self.connectedStatusImageView setImage:image];
    
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(onDetailsButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(onSettingsButton)];

    self.healthLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(healthLabelTap)];
    [self.healthLabel addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNewDeviceNotificationKey];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
    
}

-(void)healthLabelTap
{
    NSLog(@"Health Label Tapped");
    PLTReportsViewController *reportsVC = [[PLTReportsViewController alloc] init];
    [[self navigationController] pushViewController:reportsVC
                                           animated:YES];
}

- (void)onDetailsButton
{
    NSLog(@"Details Button Tapped");
    PLTDetailsViewController *detailsVC = [[PLTDetailsViewController alloc] init];
    [detailsVC setStepsLabelText:self.healthLabel.text];
    [[self navigationController] pushViewController:detailsVC
                                           animated:YES];
}

- (void)onSettingsButton
{
    NSLog(@"Settings Button Tapped");
    PLTSettingsViewController *settingsVC = [[PLTSettingsViewController alloc] init];
    [[self navigationController] pushViewController:settingsVC
                                           animated:YES];
}

- (void)subscribeToInfo
{
    NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    // note: this doesn't work right.
    err = [self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceMagnetometerCalStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
    self.helloWorldLabel.text = @"Device Connected!";
    UIImage *image = [UIImage imageNamed: @"Dot_Green.png"];
    [self.connectedStatusImageView setImage:image];
    self.deviceWornLabel.text = @"Yes";
    self.helloWorldLabel.textColor = [UIColor greenColor];
    self.deviceWornLabel.textColor = [UIColor greenColor];
    
    [self subscribeToInfo];
}

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
	self.device = nil;
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
	self.device = nil;
    self.helloWorldLabel.text = @"Device Disconnected!";
    UIImage *image = [UIImage imageNamed: @"Dot_Red.png"];
    [self.connectedStatusImageView setImage:image];
    self.deviceWornLabel.text = @"No";
    self.helloWorldLabel.textColor = [UIColor redColor];
    self.deviceWornLabel.textColor = [UIColor redColor];
}

#pragma mark - PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
    
    if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
        PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
        //NSLog(@"Euler X = %f", eulerAngles.x);
        //NSLog(@"Euler Y = %f", eulerAngles.y);
        //NSLog(@"Euler Z = %f", eulerAngles.z);
	}
	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
        NSLog(@"Device worn: %@", (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"yes" : @"no"));
        self.deviceWornLabel.text = (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"Yes" : @"No");
        if ([self.deviceWornLabel.text isEqualToString:@"Yes"]) {
            self.deviceWornStatus = 1;
            self.deviceWornLabel.textColor = [UIColor greenColor];
        }
        if ([self.deviceWornLabel.text isEqualToString:@"No"]) {
            self.deviceWornStatus = 0;
            self.deviceWornLabel.textColor = [UIColor redColor];
        }
	}
	else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
		PLTProximityInfo *proximityInfp = (PLTProximityInfo *)theInfo;
        //NSLog(@"Mobile proximity = %@", NSStringFromProximity(proximityInfp.mobileProximity));
	}
	else if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
        //NSLog(@"Pedometer steps = %@", [NSString stringWithFormat:@"%lu", (unsigned long)((PLTPedometerInfo *)theInfo).steps]);
        self.pedometerCount = (unsigned long)((PLTPedometerInfo *)theInfo).steps;
        self.healthLabel.text = [NSString stringWithFormat:@"%d", (int)((self.pedometerCount - self.pedometerCountHistory)*0.5)];
        //NSLog(@"health = %@", self.healthLabel.text);
	}
	else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
		BOOL isInFreeFall = ((PLTFreeFallInfo *)theInfo).isInFreeFall;
        if (isInFreeFall) {
			//NSLog(@"Freefall = %@", (isInFreeFall ? @"yes" : @"no"));
            if (self.deviceWornStatus == 1) {
                self.healthLabel.text = @"0";
                self.pedometerCountHistory = self.pedometerCount;
            }
		}
	}
	else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
		PLTTapsInfo *tapsInfo = (PLTTapsInfo *)theInfo;
		NSString *directionString = NSStringFromTapDirection(tapsInfo.direction);
        NSLog(@"Taps Info : %@", tapsInfo);
        if (tapsInfo.taps == 1) {
            [self callEmergency];
        }
        
        //NSLog(@"Taps %@", [NSString stringWithFormat:@"%lu in %@", (unsigned long)tapsInfo.taps, directionString]);
	}
	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
        //NSLog(@"Magnetometer : %@", (((PLTMagnetometerCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no"));
	}
	else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
        //NSLog(@"Gyroscope : %@",(((PLTGyroscopeCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no" ));
	}
}


- (IBAction)alertButtonSender:(id)sender {
    [self callEmergency];
//    NSString *phoneNumber = @"1-408-203-5769"; // dynamically assigned
//    NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", phoneNumber];
//    NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
//    [[UIApplication sharedApplication] openURL:phoneURL];
}

- (void) callEmergency
{
    NSString *phoneNumber = @"1-408-203-5769"; // dynamically assigned
    NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", phoneNumber];
    NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
    [[UIApplication sharedApplication] openURL:phoneURL];
}

@end
