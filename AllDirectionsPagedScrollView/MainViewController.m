#import "MainViewController.h"

#define HOR_PAGES 5
#define VER_PAGES 5

enum ScrollDirection {
    ScrollUp, ScrollRight, ScrollDown, ScrollLeft
};

@interface MainViewController ()

@property(assign) CGPoint initialOffset;
@property(assign) enum ScrollDirection scrollDirection;
@property(assign) BOOL waitingFirstScroll;

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
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.initialOffset = scrollView.contentOffset;
    self.waitingFirstScroll = YES;
    NSLog(@"Offset before drag starts: (%f,%f)", scrollView.contentOffset.x, scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.waitingFirstScroll) {
        self.waitingFirstScroll = NO;
        self.scrollDirection = [self scrollDirectionForOffset:scrollView.contentOffset];
    }
    
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

@end
