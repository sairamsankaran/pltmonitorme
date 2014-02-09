//
//  PLTDetailsViewController.m
//  PLTMonitorMe
//
//  Created by Sairam Sankaran on 2/8/14.
//  Copyright (c) 2014 Sairam Sankaran. All rights reserved.
//

#import "PLTDetailsViewController.h"
#import "PLTModel.h"

@interface PLTDetailsViewController ()

@end

@implementation PLTDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.stepsLabel.text = self.stepsLabelText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self updateNod];
    [self updateSteps];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateNod {
    self.headGestureLabel.text = [[PLTModel instance] headNod];
    [self performSelector:@selector(updateNod) withObject:self afterDelay:0.1];
}

- (void)updateSteps {
    self.stepsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[PLTModel instance] pedometerCount]];
    [self performSelector:@selector(updateSteps) withObject:self afterDelay:0.1];
}

@end
