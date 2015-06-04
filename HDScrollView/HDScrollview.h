//
//  HdScrollView.h
//  ScrollView
//
//  Created by Hu Di on 13-10-11.
//  Copyright (c) 2013年 Sanji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"
@class HDScrollview;
@protocol HDScrollviewDelegate <NSObject>
-(void)TapView:(HDScrollview *)scrollview AtIndex:(NSInteger)index;
@end

@interface HDScrollview : UIScrollView<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) NSMutableArray *ContentViews;
@property (nonatomic,assign) BOOL loop;
@property (nonatomic,assign) int AutoTimeInterval;
@property (nonatomic,strong) SMPageControl *pagecontrol;
@property (nonatomic,assign) NSInteger currentPageIndex;
@property (assign,nonatomic) id<HDScrollviewDelegate> HDdelegate;
/**
 *	@brief	不循环
 */
-(id)initWithFrame:(CGRect)frame withContentViews:(NSMutableArray *)contentViews;

/**
 *	@brief	循环滚动
 */
-(id)initLoopScrollWithFrame:(CGRect)frame withContentViews:(NSMutableArray *)contentViews;
-(void)HDscrollViewDidScroll;
-(void)HDscrollViewDidEndDecelerating;
-(void)pageTurn:(SMPageControl *)sender;
-(void)Dealloc;
@end



