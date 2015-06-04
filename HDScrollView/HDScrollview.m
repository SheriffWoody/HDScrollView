//
//  HdScrollView.m
//  ScrollView
//
//  Created by Hu Di on 13-10-11.
//  Copyright (c) 2013年 Sanji. All rights reserved.
//

#import "HDScrollview.h"
#import <CoreData/CoreData.h>
@interface HDScrollview()
{
    NSMutableArray *tempArr;
    UITapGestureRecognizer *Recognizer;
    NSTimer *timer;
    //BOOL iswaitturn; //是否在等待换页操作
}
@end
@implementation HDScrollview
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.scrollsToTop = NO;
        self.pagingEnabled=YES;
        self.bounces=NO;
        self.userInteractionEnabled=YES;
        Recognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        Recognizer.delegate=self;
        Recognizer.numberOfTapsRequired=1;
        
        if (!self.pagecontrol) {
            self.pagecontrol=[[SMPageControl alloc]init];
            self.pagecontrol.currentPage=0;//当前页数
            self.pagecontrol.userInteractionEnabled = YES;
            [self.pagecontrol addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventTouchDown];
            [self.pagecontrol addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        }
    }
    return self;
    
}

-(id)initWithFrame:(CGRect)frame withContentViews:(NSMutableArray *)contentViews
{
    self = [self initWithFrame:frame];
    if (self)
    {
        _loop=NO;
        _AutoTimeInterval=0;
        self.ContentViews=contentViews;
        
    }
    
    return self;
}

-(id)initLoopScrollWithFrame:(CGRect)frame withContentViews:(NSMutableArray *)contentViews
{
    self = [self initWithFrame:frame];
    if (self)
    {
        _loop=YES;
        self.ContentViews=contentViews;
    }
    return self;
}
-(void)setHDdelegate:(id<HDScrollviewDelegate>)HDdelegate
{
    _HDdelegate=HDdelegate;
    [self removeGestureRecognizer:Recognizer];
    if (_HDdelegate) {
        [self addGestureRecognizer:Recognizer];
    }
}
-(void)setLoop:(BOOL)loop
{
    _loop=loop;
    self.ContentViews=tempArr;
}
-(void)setAutoTimeInterval:(int)AutoTimeInterval
{
    _AutoTimeInterval=AutoTimeInterval;
    if (AutoTimeInterval>0) {
        timer=[NSTimer scheduledTimerWithTimeInterval:AutoTimeInterval target:self selector:@selector(autoscroll) userInfo:nil repeats:YES];
    }
    else
    {
        [timer invalidate];
    }
}
-(void)autoscroll
{
    //    if (iswaitturn) {
    //        return;
    //    }
    NSInteger n=self.pagecontrol.currentPage++;
    n++;
    if (n==self.pagecontrol.numberOfPages) {
        self.pagecontrol.currentPage=0;
        [self pageTurn:self.pagecontrol];
    }
    else
    {
        [self pageTurn:self.pagecontrol];
    }
    // NSLog(@"滚动完");
    //    timer=[NSTimer scheduledTimerWithTimeInterval:_AutoTimeInterval target:self selector:@selector(autoscroll) userInfo:nil repeats:NO];
    //    iswaitturn=NO;
}
-(void)setContentViews:(NSMutableArray *)ContentViews
{
    for(UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    [tempArr removeAllObjects];
    tempArr=[NSMutableArray arrayWithArray:ContentViews];
    if (ContentViews.count==0||!ContentViews) {
        tempArr = nil ;
        return;
    }
    _ContentViews=ContentViews;
    if (!self.loop) {
        NSUInteger pageCount=[ContentViews count];
        [self setContentSize:CGSizeMake(self.frame.size.width*pageCount, self.frame.size.height)];
        CGRect bounds=self.bounds;
        for (int i=0; i<pageCount; i++) {
            bounds.origin.x=bounds.size.width*i;
            UIView *view=[ContentViews objectAtIndex:i];
            view.userInteractionEnabled=YES;
            view.frame=bounds;
            [self addSubview:view];
        }
        self.pagecontrol.numberOfPages=pageCount;//总的图片页数
        //[self.pagecontrol addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        [self setContentOffset:CGPointMake(0, 0)];
    }
    else
    {
        //深拷贝imageview上的控件
        UIView *imageview1=[ContentViews objectAtIndex:([ContentViews count]-1)];
        UIView *imageview2=[ContentViews objectAtIndex:0];
        UIView *imageview3=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:imageview1]];
        UIView *imageview4=[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:imageview2]];
        [tempArr insertObject:imageview3 atIndex:0];
        [tempArr addObject:imageview4];
        imageview3=nil;
        imageview4=nil;
        NSUInteger pageCount=[tempArr count];
        [self setContentSize:CGSizeMake(self.frame.size.width*pageCount, self.frame.size.height)];
        CGRect bounds=self.bounds;
        for (int i=0; i<pageCount; i++) {
            bounds.origin.x=bounds.size.width*i;
            UIView *view=[tempArr objectAtIndex:i];
            view.userInteractionEnabled=YES;
            view.frame=bounds;
            [self addSubview:view];
        }
        self.pagecontrol.numberOfPages=pageCount-2;//总的图片页数
        //[self.pagecontrol addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        [self setContentOffset:CGPointMake(self.frame.size.width, 0)];
    }
    self.pagecontrol.currentPage=self.pagecontrol.currentPage;
    
}
-(void)pageTurn:(SMPageControl *)sender
{
    CGSize viewSize = self.frame.size;
    CGRect rect;
    if (self.loop) {
        rect = CGRectMake((sender.currentPage+1) * viewSize.width, 0, viewSize.width, viewSize.height);
    }
    else
    {
        rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
       // self.pagecontrol.currentPage=sender.currentPage;
    }
    if (self) {
        [self scrollRectToVisible:rect animated:YES];
    }
}


-(void)HDscrollViewDidScroll
{
    if (self.loop) {
        CGFloat pageWidth = self.frame.size.width;
        int page = floor((self.contentOffset.x - pageWidth / 2) / pageWidth)+1;
        self.currentPageIndex=page;
        self.pagecontrol.currentPage=(page-1);
        //如果没等待则执行新的计时器
        //        if (!iswaitturn) {
        //            timer=[NSTimer scheduledTimerWithTimeInterval:_AutoTimeInterval target:self selector:@selector(autoscroll) userInfo:nil repeats:NO];
        //            iswaitturn=YES;
        //        }
    }
}

-(void)HDscrollViewDidEndDecelerating
{
    if (self.loop) {
        if (0==self.currentPageIndex) {
            [self setContentOffset:CGPointMake([self.ContentViews count]*self.bounds.size.width, 0)];
        }
        if (([self.ContentViews count]+1)==self.currentPageIndex) {
            [self setContentOffset:CGPointMake(self.bounds.size.width, 0)];
        }
        //        iswaitturn=YES;
        //        [self performSelector:@selector(settrue) withObject:nil afterDelay:_AutoTimeInterval];
        //        iswaitturn=YES;
        //        timer=[NSTimer scheduledTimerWithTimeInterval:_AutoTimeInterval target:self selector:@selector(autoscroll) userInfo:nil repeats:NO];
        //        iswaitturn=YES;
    }
    else
    {
        //更新UIPageControl的当前页
        CGPoint offset = self.contentOffset;
        CGRect bounds = self.frame;
        [self.pagecontrol setCurrentPage:offset.x / bounds.size.width];
    }
    
}
//-(void)settrue
//{
//    iswaitturn=NO;
//    [self autoscroll];
//}
-(void)tap
{
    if ([self.delegate conformsToProtocol:@protocol(HDScrollviewDelegate)]) {
        if ([self.HDdelegate respondsToSelector:@selector(TapView:AtIndex:)]) {
            [self.HDdelegate TapView:self AtIndex:self.pagecontrol.currentPage];
        }
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPage"]) {
      //  if ([object isFault]) {
            [self pageTurn:self.pagecontrol];
            [self.pagecontrol removeObserver:self forKeyPath:@"currentPage"];
      //  }
    }
}
-(void)Dealloc
{
    NSLog(@"HDScroll dealloc");
  //  [self.pagecontrol removeObserver:self forKeyPath:@"currentPage"];
    [timer invalidate];
    
}
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]&&self.HDdelegate) {
//        return NO;
//    }
//    return YES;
//}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
