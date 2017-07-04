//
//  SLSwipeViewController.m
//  PageController
//
//  Created by SuperJJ on 2017/6/27.
//  Copyright © 2017年 SuperJJ. All rights reserved.
//

#import "SLSwipeViewController.h"
#import "SLSegmentBarView.h"

typedef NS_ENUM(NSUInteger, SLScrollDirection) {
    SLScrollDirectionLeft,
    SLScrollDirectionRight,
    SLScrollDirectionOther
};

@interface SLSwipeViewController () <UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *contentView;                      // 滚动视图
@property (nonatomic, weak) UIViewController *currentViewController;        // 当前控制器
@property (nonatomic, assign) NSUInteger currentIndex;                      // 当前索引
@property (nonatomic, assign) NSUInteger controllerCount;                   // 控制器数量
@property (nonatomic, strong) NSMutableDictionary *visibleControllers;      // 显示的控制器字典
@property (nonatomic, strong) NSCache *controllerCache;                     // 控制器缓存
@property (nonatomic, assign) NSRange visibleRange;                         // 显示范围
@property (nonatomic, assign) SLScrollDirection scrollDirection;            // 滚动方向
@property (nonatomic, assign) CGFloat preOffsetX;                           // 用来计算滚动方向
@property (nonatomic, assign) BOOL enableProgress;                          // 是否计算进度
@end

@implementation SLSwipeViewController

NS_INLINE CGRect frameForControllerAtIndex(NSInteger index, CGRect frame)
{
    return CGRectMake(index * CGRectGetWidth(frame), 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}

NS_INLINE NSRange visibleRangWithOffset(CGFloat offset,CGFloat width, NSInteger maxIndex)
{
    NSInteger startIndex = offset/width;
    NSInteger endIndex = ceil((offset + width)/width);
    if (startIndex < 0) startIndex = 0;
    if (endIndex > maxIndex) endIndex = maxIndex;
    return NSMakeRange(startIndex, endIndex - startIndex);
}

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<SLSwipeViewControllerDataSource>)dataSource
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.view.frame = frame;
        self.dataSource = dataSource;
        self.changeIndexWhenScrollProgress = 0.5;
        self.visibleControllers = [[NSMutableDictionary alloc] initWithCapacity:self.controllerCount];
        self.controllerCache = [[NSCache alloc] init];
        UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        contentView.delegate = self;
        contentView.pagingEnabled = YES;
        contentView.scrollsToTop = NO;
        contentView.bounces = NO;
        contentView.showsVerticalScrollIndicator = NO;
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.contentSize = CGSizeMake(self.controllerCount * CGRectGetWidth(contentView.frame), 0);
        [self.view addSubview:contentView];
        self.contentView = contentView;
        [self layoutContentView];
    }
    return self;
}


#pragma mark - setter getter

- (NSUInteger)controllerCount
{
    return [self.dataSource numberOfControllers];
}



#pragma mark - layout content
- (void)layoutContentView
{
    NSRange visibleRange = visibleRangWithOffset(self.contentView.contentOffset.x, self.contentView.frame.size.width, self.controllerCount);
    
    if (NSEqualRanges(visibleRange, self.visibleRange)) return;
    
    self.visibleRange = visibleRange;
    
    [self removeControllersOutOfVisibleRange:visibleRange];
    
    [self addControllersInVisibleRange:visibleRange];
}

#pragma mark - 删除控制器
- (void)removeControllersOutOfVisibleRange:(NSRange)range
{
    NSMutableArray *deleteArray = [NSMutableArray array];
    
    [self.visibleControllers enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull indexKey, UIViewController * _Nonnull viewController, BOOL * _Nonnull stop) {
        
        NSUInteger index = [indexKey unsignedIntegerValue];
        
        if (NSLocationInRange(index, range)) {
            [self addViewController:viewController atIndex:index];
        } else {
            [self removeViewController:viewController atIndex:index];
            [deleteArray addObject:indexKey];
        }
    }];
    
    [self.visibleControllers removeObjectsForKeys:deleteArray];
}

- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    if (viewController.parentViewController) {
        [self removeViewController:viewController];
        if (![self.controllerCache objectForKey:@(index)]) {
            [self.controllerCache setObject:viewController forKey:@(index)];
        }
    }
}

- (void)removeViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    [viewController didMoveToParentViewController:nil];
}

#pragma mark - 添加控制器
- (void)addViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    if (!viewController.parentViewController) {
        [viewController willMoveToParentViewController:self];
        viewController.view.frame = frameForControllerAtIndex(index, self.contentView.frame);
        [self addChildViewController:viewController];
        [self.contentView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        if (![self.visibleControllers objectForKey:@(index)]) {
            [self.visibleControllers setObject:viewController forKey:@(index)];
        }
    } else {
        viewController.view.frame = frameForControllerAtIndex(index, self.contentView.frame);
    }
}

- (void)addControllersInVisibleRange:(NSRange)range
{
    NSInteger endIndex = range.location + range.length;
    for (NSInteger idx = range.location ; idx < endIndex; ++idx) {
        UIViewController *viewController = [_visibleControllers objectForKey:@(idx)];
        if (!viewController) {
            viewController = [self.controllerCache objectForKey:@(idx)];
        }
        if (!viewController) {
            viewController = [self.dataSource swipeViewController:self controllerForIndex:idx];
        }
        [self addViewController:viewController atIndex:idx];
    }
}

#pragma mark - indexSetProgress
- (void)caculateIndex
{
    CGFloat offsetX = self.contentView.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    SLScrollDirection direction = offsetX >= self.preOffsetX ? SLScrollDirectionLeft : SLScrollDirectionRight;
    NSInteger index = 0;
    CGFloat percentChangeIndex = 1.0 - self.changeIndexWhenScrollProgress;
    if (direction == SLScrollDirectionLeft) index = offsetX / width + percentChangeIndex;
    else index = ceil(offsetX / width - percentChangeIndex);
    if (index < 0) index = 0;
    else if (index >= self.controllerCount) index = self.controllerCount - 1;
    if (index != self.currentIndex) {
        self.currentIndex = index;
        self.currentViewController = [self.visibleControllers objectForKey:@(self.currentIndex)];
    }
}

- (void)caculateIndexProgress
{
    CGFloat offsetX = self.contentView.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    CGFloat floorIndex = floor(offsetX / width);
    CGFloat progress = offsetX / width - floorIndex;
    
    if (floorIndex < 0 || floorIndex >= self.controllerCount) {
        return;
    }
    
    SLScrollDirection direction = offsetX >= self.preOffsetX ? SLScrollDirectionLeft : SLScrollDirectionRight;
    
    NSInteger fromIndex = 0, toIndex = 0;
    
    if (direction == SLScrollDirectionLeft) {
        if (floorIndex >= self.controllerCount - 1) {
            return;
        }
        fromIndex = floorIndex;
        toIndex = MIN(self.controllerCount - 1, fromIndex + 1);
    } else {
        if (floorIndex < 0 ) {
            return;
        }
        toIndex = floorIndex;
        fromIndex = MIN(self.controllerCount - 1, toIndex + 1);
        progress = 1.0 - progress;
    }
    [self.segmentBarView moveWithFromIndex:fromIndex toIndex:toIndex progress:progress];
    if ([self.delegate respondsToSelector:@selector(swipeViewController:fromIndex:toIndex:progress:)]) {
        [self.delegate swipeViewController:self fromIndex:fromIndex toIndex:toIndex progress:progress];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.contentView == scrollView && self.controllerCount > 0) {
        
        [self caculateIndex];
        
        if (self.enableProgress) {
            [self caculateIndexProgress];
        }
        
        [self layoutContentView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.contentView == scrollView) {
        self.enableProgress = YES;
        self.preOffsetX = scrollView.contentOffset.x;
    }
}
#pragma mark - 公开方法
- (void)moveToPage:(NSInteger)index animated:(BOOL)animated
{
    if (index < 0 || index >= self.controllerCount) {
        return;
    }
    self.enableProgress = NO;
    [self.contentView setContentOffset:CGPointMake(index * CGRectGetWidth(self.contentView.frame), 0) animated:animated];
}

@end










