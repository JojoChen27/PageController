//
//  SLSegmentBarView.m
//  PageController
//
//  Created by SuperJJ on 2017/6/27.
//  Copyright © 2017年 SuperJJ. All rights reserved.
//

#import "SLSegmentBarView.h"
#import "SLSwipeViewController.h"

static NSString * const KCellId = @"SLCollectionViewCell";

@interface SLCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) UILabel *titleLabel;
@end
@implementation SLCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [UILabel new];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}
@end


@interface SLSegmentBarView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) UICollectionView *collectionViewBar;
@property (nonatomic, weak) UIView *indicatorView;
@property (nonatomic, assign) CGFloat selectFontScale;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation SLSegmentBarView

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.titleArray = titleArray;
        [self initView];
    }
    return self;
}


- (void)initView
{
    self.animateDuration = 0.25;
    self.normalTextFont = [UIFont systemFontOfSize:15];
    self.selectedTextFont = [UIFont systemFontOfSize:18];
    self.normalTextColor = [UIColor lightGrayColor];
    self.selectedTextColor = [UIColor blackColor];
    self.itemEdge = 0;
    self.indicatorLeftColor = [UIColor blackColor];
    self.indicatorRightColor = [UIColor blackColor];
    self.indicatorHeight = 2;
    self.indicatorBottomEdge = 0;
    self.indicatorEdge = 0;
    self.barStyle = SLSegmentBarStyleProgressView;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[SLCollectionViewCell class] forCellWithReuseIdentifier:KCellId];
    [self addSubview:collectionView];
    self.collectionViewBar = collectionView;
    
    UIView *indicatorView = [[UIView alloc] init];
    [self.collectionViewBar addSubview:indicatorView];
    self.indicatorView = indicatorView;
    self.indicatorView.backgroundColor = self.indicatorLeftColor;
    [self setIndicatorViewFrameWithIndex:self.currentIndex animated:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setCellWithIndex:self.currentIndex];
    });
}

- (void)moveWithFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    [self setIndicatorViewFrameWithfromIndex:fromIndex toIndex:toIndex progress:progress];
    [self setItemTitleWithFromIndex:fromIndex toIndex:toIndex progress:progress];
    [self setCollectionViewBarOffsetWithSwipeViewOffsetX:self.swipeViewController.contentView.contentOffset.x animated:NO];
}

- (void)reloadData
{
    [self.collectionViewBar reloadData];
    self.indicatorView.backgroundColor = self.indicatorLeftColor;
    [self setIndicatorViewFrameWithIndex:self.currentIndex animated:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setCellWithIndex:self.currentIndex];
    });
}

#pragma mark - getter && setter
- (CGFloat)selectFontScale
{
    return self.selectedTextFont.pointSize / self.normalTextFont.pointSize - 1;
}

- (void)setBarStyle:(SLSegmentBarStyle)barStyle
{
    _barStyle = barStyle;
    
    self.indicatorView.hidden = (barStyle == SLSegmentBarStyleNoneView);
}

#pragma mark - set
/**
 *  设置Bar偏移
 */
- (void)setCollectionViewBarOffsetWithSwipeViewOffsetX:(CGFloat)swipeViewOffsetX animated:(BOOL)animated
{
    CGFloat ratio = (self.collectionViewBar.contentSize.width - self.frame.size.width) / (self.swipeViewController.contentView.contentSize.width - self.swipeViewController.view.frame.size.width);
    if (self.collectionViewBar.contentSize.width > self.frame.size.width) {
        CGPoint offset = self.collectionViewBar.contentOffset;
        offset.x = swipeViewOffsetX * ratio;
        [self.collectionViewBar setContentOffset:offset animated:animated];
    }
}

/**
 *  设置字体大小和颜色
 */
- (void)setItemTitleWithFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    SLCollectionViewCell *fromItem = (SLCollectionViewCell *)[self.collectionViewBar cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]];
    SLCollectionViewCell *toItem = (SLCollectionViewCell *)[self.collectionViewBar cellForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
    
    CGFloat currentTransform = self.selectFontScale * progress;
    fromItem.transform = CGAffineTransformMakeScale(1.0 + self.selectFontScale - currentTransform, 1.0 + self.selectFontScale - currentTransform);
    toItem.transform = CGAffineTransformMakeScale(1 + currentTransform, 1 + currentTransform);
    
//    NSLog(@"%f, %f", 1.0 + self.selectFontScale - currentTransform, 1 + currentTransform);
    
    CGFloat narR, narG, narB, narA;
    [self.normalTextColor getRed:&narR green:&narG blue:&narB alpha:&narA];
    CGFloat selR, selG, selB, selA;
    [self.selectedTextColor getRed:&selR green:&selG blue:&selB alpha:&selA];
    CGFloat detalR = narR - selR, detalG = narG - selG, detalB = narB - selB, detalA = narA - selA;
    fromItem.titleLabel.textColor = [UIColor colorWithRed:selR + detalR * progress green:selG + detalG * progress blue:selB + detalB * progress alpha:selA + detalA * progress];
    toItem.titleLabel.textColor = [UIColor colorWithRed:narR - detalR * progress green:narG - detalG * progress blue:narB - detalB * progress alpha:narA - detalA * progress];
}

/**
 *  设置指示器
 */
- (void)setIndicatorViewFrameWithfromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    if (self.indicatorView.isHidden || self.titleArray == 0) {
        return;
    }
    
    CGRect fromCellFrame = [self cellFrameWithIndex:fromIndex];
    CGRect toCellFrame = [self cellFrameWithIndex:toIndex];
    CGFloat fromLREdge = self.indicatorWidth ? (fromCellFrame.size.width - self.indicatorWidth) / 2 : self.indicatorEdge;
    CGFloat toLREdge = self.indicatorWidth ? (toCellFrame.size.width - self.indicatorWidth) / 2 : self.indicatorEdge;
    CGFloat y = toCellFrame.size.height - self.indicatorHeight - self.indicatorBottomEdge;
    CGFloat x = 0.f, w = 0.f;
    
    if (self.barStyle == SLSegmentBarStyleProgressView) {
        x = (toCellFrame.origin.x + toLREdge - (fromCellFrame.origin.x + fromLREdge)) * progress + fromCellFrame.origin.x + fromLREdge;
        w = (toCellFrame.size.width - 2 * toLREdge) * progress + (fromCellFrame.size.width - 2 * fromLREdge) * (1 - progress);
    }

    
    self.indicatorView.frame = CGRectMake(x, y, w, self.indicatorHeight);
    
}

- (void)setIndicatorViewFrameWithIndex:(NSInteger)index animated:(BOOL)animated
{
    if (self.indicatorView.isHidden || self.titleArray.count == 0) {
        return;
    }
    CGRect cellFrame = [self cellFrameWithIndex:index];
    CGFloat LREdge = self.indicatorWidth ? (cellFrame.size.width - self.indicatorWidth) / 2 : self.indicatorEdge;
    CGFloat x = cellFrame.origin.x + LREdge;
    CGFloat y = cellFrame.size.height - self.indicatorHeight - self.indicatorBottomEdge;
    CGFloat w = cellFrame.size.width - 2 * LREdge;
    CGFloat h = self.indicatorHeight;
    
    if (animated) {
        [UIView animateWithDuration:self.animateDuration animations:^{
            self.indicatorView.frame = CGRectMake(x, y, w, h);
        }];
    } else {
        self.indicatorView.frame = CGRectMake(x, y, w, h);
    }
}

- (void)setCellWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    SLCollectionViewCell *cell = (SLCollectionViewCell *)[self.collectionViewBar cellForItemAtIndexPath:indexPath];
    cell.transform = CGAffineTransformMakeScale(1 + self.selectFontScale, 1 + self.selectFontScale);
    cell.titleLabel.textColor = self.selectedTextColor;
    [self.collectionViewBar.visibleCells enumerateObjectsUsingBlock:^(__kindof SLCollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != cell) {
            obj.transform = CGAffineTransformIdentity;
            obj.titleLabel.textColor = self.normalTextColor;
        }
    }];
}


#pragma mark - UICollectionView
- (CGRect)cellFrameWithIndex:(NSInteger)index
{
    if (index >= self.titleArray.count) {
        return CGRectZero;
    }
    UICollectionViewLayoutAttributes * cellAttrs = [self.collectionViewBar layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cellAttrs.frame;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:KCellId forIndexPath:indexPath];
    cell.titleLabel.frame = cell.bounds;
    cell.titleLabel.text = self.titleArray[indexPath.item];
    cell.titleLabel.font = self.normalTextFont;
    cell.titleLabel.textColor = self.normalTextColor;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemWidth) {
        return CGSizeMake(self.itemWidth, CGRectGetHeight(self.collectionViewBar.frame));
    }
    NSString *title = self.titleArray[indexPath.item];
    CGFloat width = [title boundingRectWithSize:CGSizeMake(300, 100) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName:self.selectedTextFont } context:nil].size.width + self.itemEdge * 2;
    return CGSizeMake(width, CGRectGetHeight(self.collectionViewBar.frame));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndex = indexPath.item;
    [self setIndicatorViewFrameWithIndex:indexPath.item animated:YES];
    [self setCellWithIndex:indexPath.item];
    [self setCollectionViewBarOffsetWithSwipeViewOffsetX:self.swipeViewController.contentView.frame.size.width * indexPath.item animated:YES];
    [self.swipeViewController moveToPage:indexPath.item animated:YES];
    if ([self.delegate respondsToSelector:@selector(segmentBarView:didSelectItemAtIndex:)]) {
        [self.delegate segmentBarView:self didSelectItemAtIndex:indexPath.item];
    }
}

@end
