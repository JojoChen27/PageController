//
//  ViewController.m
//  PageController
//
//  Created by SuperJJ on 2017/6/21.
//  Copyright © 2017年 SuperJJ. All rights reserved.
//

#import "ViewController.h"
#import "SLSwipeViewController.h"
#import "SLSegmentBarView.h"
#import "OneViewController.h"

@interface ViewController () <SLSwipeViewControllerDataSource, SLSwipeViewControllerDelegate, SLSegmentBarViewDelegate>
@property (nonatomic, strong) SLSwipeViewController *swipeVc;
@property (nonatomic, strong) SLSegmentBarView *barView;
@property (nonatomic, strong) NSArray *array;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.array = @[@"ShoesLives", @"深圳罗湖园", @"静", @"Coca Cola", @"淘宝", @"微博A", @"京CD东", @"天CBD猫", @"a百度a", @"腾讯", @"网易", @"新浪", @"王者荣耀", @"英雄联盟"];
    self.swipeVc = [[SLSwipeViewController alloc] initWithFrame:CGRectMake(50, 100, 250, 500) dataSource:self];
    self.barView = [[SLSegmentBarView alloc] initWithFrame:CGRectMake(50, 50, 250, 44) titleArray:self.array];
    self.swipeVc.segmentBarView = self.barView;
    self.barView.swipeViewController = self.swipeVc;
    self.swipeVc.delegate = self;
    self.barView.delegate = self;
    [self.view addSubview:self.barView];
    [self.view addSubview:self.swipeVc.view];
    self.barView.normalTextFont = [UIFont systemFontOfSize:15];
    self.barView.selectedTextFont = [UIFont systemFontOfSize:18];
    self.barView.normalTextColor = [UIColor blueColor];
    self.barView.selectedTextColor = [UIColor orangeColor];
    self.barView.indicatorHeight = 2;
    self.barView.indicatorBottomEdge = 2;
    self.barView.indicatorEdge = 2;
    [self.barView reloadData];
}


#pragma mark - SLSegmentBarViewDelegate
- (void)segmentBarView:(SLSegmentBarView *)segmentBarView didSelectItemAtIndex:(NSInteger)index
{
//    NSLog(@"%zd", index);
}


#pragma mark - SLSwipeViewControllerDelegate
- (void)swipeViewController:(SLSwipeViewController *)swipeViewController fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
//    NSLog(@"%zd, %zd, %f", fromIndex, toIndex, progress);
}

#pragma mark - SLSwipeViewControllerDataSource
- (NSUInteger)numberOfControllers
{
    return self.array.count;
}

- (UIViewController *)swipeViewController:(SLSwipeViewController *)swipeViewController controllerForIndex:(NSUInteger)index
{
    return [[OneViewController alloc] init];
}


@end
