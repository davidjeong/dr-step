//
//  HistoryContentViewController.h
//  SmartSole
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <UIKit/UIKit.h>

@interface HistoryContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property NSUInteger pageIndex;
@property NSString *imageFile;

@end
