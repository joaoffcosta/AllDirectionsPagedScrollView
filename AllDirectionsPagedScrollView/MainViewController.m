#import "MainViewController.h"

#define HOR_PAGES 5
#define VER_PAGES 5

@interface MainViewController ()

@property(assign) CGPoint initialOffset;

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
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.initialOffset = scrollView.contentOffset;
    NSLog(@"Offset before drag starts: (%f,%f)", scrollView.contentOffset.x, scrollView.contentOffset.y);
}

@end
