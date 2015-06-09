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
@property (weak, nonatomic) IBOutlet UILabel *label;
@property NSUInteger pageIndex;
@property NSString *labelText;
@property NSString *imageFile;

@end
