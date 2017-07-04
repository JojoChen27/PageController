//
//  OneViewController.m
//  PageController
//
//  Created by SuperJJ on 2017/6/21.
//  Copyright © 2017年 SuperJJ. All rights reserved.
//

#import "OneViewController.h"
#define kRandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
@interface OneViewController ()

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kRandomColor;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
