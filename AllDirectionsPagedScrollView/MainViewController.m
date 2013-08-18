#import "MainViewController.h"

#define HOR_PAGES 5
#define VER_PAGES 5

enum ScrollDirection {
    ScrollUp, ScrollRight, ScrollDown, ScrollLeft
};

@interface MainViewController ()

@property(assign) CGPoint initialOffset;
@property(assign) CGPoint targetOffset;
@property(assign) enum ScrollDirection scrollDirection;
@property(assign) BOOL waitingFirstScroll;
@property(assign) BOOL isDragging;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGSize scrollSize = CGSizeMake(self.view.frame.size.width  * HOR_PAGES,
                                   self.view.frame.size.height * VER_PAGES);
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [scrollView setBackgroundColor:[UIColor yellowColor]];
    [scrollView setContentSize:scrollSize];
    [scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
    
    for (int h = 0; h < HOR_PAGES; h++) {
        for (int v = 0; v < VER_PAGES; v++) {
            CGRect frame = CGRectMake(scrollView.frame.size.width  * h,
                                      scrollView.frame.size.height * v,
                                      scrollView.frame.size.width,
                                      scrollView.frame.size.height);
            
            UILabel *view = [[UILabel alloc] initWithFrame:frame];
            [view setBackgroundColor:[UIColor colorWithRed:1.0
                                                     green:1.0 * h / HOR_PAGES
                                                      blue:1.0 * v / VER_PAGES
                                                     alpha:1.0]];
            [view setTextAlignment:NSTextAlignmentCenter];
            [view setFont:[UIFont fontWithName:@"Courier" size:70]];
            [view setText:[NSString stringWithFormat:@"%d,%d", h+1, v+1]];
            [scrollView addSubview:view];
        }
    }
    
    self.waitingFirstScroll = NO;
    self.isDragging = NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == self.targetOffset.x && scrollView.contentOffset.y == self.targetOffset.y) {
        self.initialOffset = scrollView.contentOffset;
        self.waitingFirstScroll = YES;
    } else {
        self.initialOffset = self.targetOffset;
    }
    self.isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.waitingFirstScroll) {
        self.waitingFirstScroll = NO;
        self.scrollDirection = [self scrollDirectionForOffset:scrollView.contentOffset];
    }
    
    if (self.isDragging) {
        if ([self isHorizontalScroll]) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x,
                                                     self.initialOffset.y)
                                animated:NO];
        } else {
            [scrollView setContentOffset:CGPointMake(self.initialOffset.x,
                                                     scrollView.contentOffset.y)
                                animated:NO];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isDragging = NO;
    
    if (!decelerate) {
        // user dropped scrollView without any acceleration
        self.targetOffset = [self pageOffsetForOffset:scrollView.contentOffset
                                           scrollView:scrollView];
        [scrollView setContentOffset:self.targetOffset animated:YES];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.targetOffset = [self pagePositionForOffset:*targetContentOffset
                                          frameSize:scrollView.frame.size];
    targetContentOffset->x = self.targetOffset.x;
    targetContentOffset->y = self.targetOffset.y;
}

#pragma mark - Helper Methods

- (BOOL)isHorizontalScroll
{
    return self.scrollDirection == ScrollLeft || self.scrollDirection == ScrollRight;
}

- (enum ScrollDirection)scrollDirectionForOffset:(CGPoint)offset
{
    float xDiff = offset.x - self.initialOffset.x;
    float yDiff = offset.y - self.initialOffset.y;
    
    if (ABS(xDiff) > ABS(yDiff)) {
        // horizontal scroll
        if (xDiff >= 0) {
            return ScrollRight;
        } else {
            return ScrollLeft;
        }
    } else {
        // vertical scroll
        if (yDiff >= 0) {
            return ScrollDown;
        } else {
            return ScrollUp;
        }
    }
}

- (float)pageOffsetForOffset:(float)offset
                    pageSize:(float)pageSize
                    numPages:(int)numPages
{
    float exactPositionInPages = (offset + pageSize / 2.0) / pageSize;
    return MAX(0,MIN(numPages - 1, floorf(exactPositionInPages))) * pageSize;
}

- (CGPoint)pageOffsetForOffset:(CGPoint)offset scrollView:(UIScrollView*)scrollView
{
    float pageWidth   = scrollView.frame.size.width;
    float pageHeight  = scrollView.frame.size.height;
    float numHorPages = scrollView.contentSize.width / pageWidth;
    float numVerPages = scrollView.contentSize.height / pageHeight;
    float pagePosX    = [self pageOffsetForOffset:offset.x pageSize:pageWidth numPages:numHorPages];
    float pagePosY    = [self pageOffsetForOffset:offset.y pageSize:pageHeight numPages:numVerPages];
    
    return CGPointMake(pagePosX, pagePosY);
}

- (CGPoint)pagePositionForOffset:(CGPoint)offset frameSize:(CGSize)size
{
    CGPoint pageOffset = self.initialOffset;
    
    if ([self isHorizontalScroll]) {
        // is an horizontal scroll
        if (offset.x > self.initialOffset.x) {
            // and now is going to the right
            pageOffset.x = [self pageOffsetForOffset:pageOffset.x + size.width
                                            pageSize:size.width
                                            numPages:HOR_PAGES];
        } else if (offset.x < self.initialOffset.x) {
            // and now is going to the left
            pageOffset.x = [self pageOffsetForOffset:pageOffset.x - size.width
                                            pageSize:size.width
                                            numPages:HOR_PAGES];
        }
    } else {
        // is a vertical scroll
        if (offset.y > self.initialOffset.y) {
            // and now is going down
            pageOffset.y = [self pageOffsetForOffset:pageOffset.y + size.height
                                            pageSize:size.height
                                            numPages:VER_PAGES];
        } else if (offset.y < self.initialOffset.y) {
            // and now is going up
            pageOffset.y = [self pageOffsetForOffset:pageOffset.y - size.height
                                            pageSize:size.height
                                            numPages:VER_PAGES];
        }
    }
    return pageOffset;
}

@end
