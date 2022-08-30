//
//  ViewController.m
//  RunTime
//
//  Created by hanling on 2022/8/30.
//

#import "ViewController.h"
#import "TestClass.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self workingWithClassTest];
    // Do any additional setup after loading the view.
}

#pragma mark workingWithClass 涉及可用API 31个
- (void)workingWithClassTest{
    
    ///1、class_getName
    /// The name of the class, or the empty string if cls is Nil.
    ///  class_getName:ViewController
    const char *getName = class_getName([ViewController class]);
    NSLog(@"class_getName:%@",[NSString stringWithUTF8String:getName]);
    
    ///1、class_getSuperclass
    /// The superclass of the class, or Nil if cls is a root class, or Nil if cls is Nil.
    ///
    Class getSuperclass = class_getSuperclass([ViewController class]);
    NSLog(@"class_getName:%@",getSuperclass);
}


@end
