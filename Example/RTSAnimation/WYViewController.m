//
//  WYViewController.m
//  RTSAnimation
//
//  Created by fangwenyu on 12/12/2016.
//  Copyright (c) 2016 fangwenyu. All rights reserved.
//

#import "WYViewController.h"
#import "GiftAnimationViewController.h"

@interface WYViewController ()
@property(nonatomic, strong)GiftAnimationViewController *giftAnimationViewController;
@end

@implementation WYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    GiftModel *model = [[GiftModel alloc] init];
    model.animation = @"520";
    
    [self.giftAnimationViewController.view setBounds:self.view.bounds];
    [self.view addSubview:self.giftAnimationViewController.view];
    self.giftAnimationViewController.view.userInteractionEnabled = NO;
    [self.giftAnimationViewController addAnimationWithGiftModel:model];
}

- (GiftAnimationViewController *)giftAnimationViewController {
    if (!_giftAnimationViewController) {
        _giftAnimationViewController = [[GiftAnimationViewController alloc] init];
        [self addChildViewController:_giftAnimationViewController];
    }
    return _giftAnimationViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
