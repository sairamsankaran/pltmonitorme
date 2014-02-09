//
//  PLTDetailsViewController.m
//  PLTMonitorMe
//
//  Created by Sairam Sankaran on 2/8/14.
//  Copyright (c) 2014 Sairam Sankaran. All rights reserved.
//

#import "PLTDetailsViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
