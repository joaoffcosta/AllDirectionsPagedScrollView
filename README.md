AllDirectionsPagedScrollView
=======================

A *custom implementation of UIScrollView pagination* which allows *only up or down movements* (never diagonal)

#### Why would I need this?

Have you ever tried to do an UIScrollView with horizontal and vertical pagination? No? Try to create one and set these to true:
```
[scrollView setPagingEnabled:YES];
[scrollView setDirectionalLockEnabled:YES];
```

Did you notice how it allows diagonal pagination? Unfortunatelly (to my knowledge) there is no easy way to solve this. So I just implemented everything from scratch!

