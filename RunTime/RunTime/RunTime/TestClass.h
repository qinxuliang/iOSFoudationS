//
//  TestClass.h
//  RunTime
//
//  Created by hanling on 2022/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface TestClass : NSObject
//{
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
//    Class pis;
//#pragma clang diagnostic pop
//}

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString *desc;

@end

NS_ASSUME_NONNULL_END
