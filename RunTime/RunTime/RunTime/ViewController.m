//
//  ViewController.m
//  RunTime
//
//  Created by hanling on 2022/8/30.
//

#import "ViewController.h"
#import "TestClass.h"
#import "MsgResolver.h"
#import <objc/runtime.h>

@interface TestClass2:TestClass


@end

@implementation TestClass2

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self workingWithClassTest];
    
    MsgResolver *resolver = [[MsgResolver alloc] init];
    [resolver performSelector:@selector(callInstanceMethod:) withObject:@"实例方法测试"];
    [MsgResolver performSelector:@selector(callClassMethod:) withObject:@"类方法测试"];
    // Do any additional setup after loading the view.
}

#pragma mark workingWithClass 涉及可用API 31个
- (void)workingWithClassTest{
    
    TestClass *testClass = [[TestClass alloc] init];
    testClass.name = @"TestClass";
    testClass.desc = @"这是一个测试对象";
    [self classMethodTest];
    [self instanceMethodTest:testClass];
}

-(void)classMethodTest{
    ///1、class_getName
    /// The name of the class, or the empty string if cls is Nil.
    ///  output : class_getName:TestClass
    const char *getName = class_getName([TestClass class]);
    NSLog(@"class_getName:%@",[NSString stringWithUTF8String:getName]);
    
    ///2、class_getSuperclass
    /// The superclass of the class, or Nil if cls is a root class, or Nil if cls is Nil.
    /// output : class_getSuperclass:NSObject
    Class getSuperclass = class_getSuperclass([TestClass class]);
    NSLog(@"class_getSuperclass:%@",getSuperclass);
    
    ///3、class_getSuperclass
    /// The superclass of the class, or Nil if cls is a root class, or Nil if cls is Nil.
    /// 这个有点奇怪,返回的都是 no 需要进一步探索
    BOOL isMetaClass = class_isMetaClass([NSObject class]);
    NSLog(@"class_isMetaClass:%d",isMetaClass);
    
    ///4、objc_getMetaClass
    /// The superclass of the class, or Nil if cls is a root class, or Nil if cls is Nil.
    /// 返回的依旧是当前类
    Class metaClass = objc_getMetaClass([@"TestClass" UTF8String]);
    NSLog(@"objc_getMetaClass:%@",metaClass);
    
    ///5. class_getInstanceSize 参数:类Class
    ///返回:类的实例大小
    /// class_getInstanceSize: 24     8 + name(8) +desc(8)
    size_t result = class_getInstanceSize([TestClass class]);
    NSLog(@"class_getInstanceSize:%zu",result);
    
    ///7. class_getClassVariable 参数:类Class  name
    ///返回:类的实例大小
    /// class_getClassVariable
    /// Ivar 是个结构体 参加objc源码中的 ivar_t
    /// 类名获取属性是获取不到的 只能获取Class本身的属性,就是NSObject的唯一属性 isa
    Ivar isa = class_getClassVariable([TestClass class],"isa");
    NSLog(@"class_getClassVariable:%s",ivar_getName(isa));
    
    ///8. class_copyIvarList 获取全部变量列表
    ///
    /// 获取的是当前类的属性列表 _name _desc
    
    [self printClassAllIvar:[TestClass class]];
    
    ///9. class_getIvarLayout 获取
    ///参数:类Class
    ///返回:返回值是指向 uint8_t 的指针
    /// The layout of the Ivars for cls
    ///
    const uint8_t *IvarLayout = class_getIvarLayout(TestClass.class);
    NSLog(@"class_getIvarLayout:%p",IvarLayout);
    
    /// 10.获取对象的成员变量
    ///  与8不同 8获取到的是 _name _desc 这个获取到的是 name desc
    ///
    [self printClassAllProperties:TestClass.class];
}

- (void)instanceMethodTest:(id)instance{
    
    ///6. class_getInstanceVariable 参数:类Class  name
    ///返回:类的实例大小
    /// class_getInstanceVariable: 24
    /// Ivar 是个结构体 参加objc源码中的 ivar_t
    /// 
    /// 属性需要添加 _  必须使用类名 不是对象实例
    Ivar _name = class_getInstanceVariable([instance class],"_name");
    NSLog(@"class_getInstanceVariable:%s",ivar_getName(_name));
    
    ///8. class_addIvar
    ///This function may only be called after objc_allocateClassPair and before objc_registerClassPair
    ///The class must not be a metaclass. Adding an instance variable to a metaclass is not supported.
    /// Adding an instance variable to an existing class is not supported.
    
    BOOL addIvar = class_addIvar([instance class], "test", sizeof(NSString *), log(sizeof(NSString *)), "i");
    NSLog(@"class_getInstanceVariable:%d",addIvar);
    [self _class_addIvar];
    
    
}

#pragma mark - 遍历某个对象的成员变量
- (void)printClassAllIvar:(Class)cls{
    NSLog(@"*********************");
    unsigned int outCount = 0;
    Ivar * ivars = class_copyIvarList(cls, &outCount);
    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        const char * type = ivar_getTypeEncoding(ivar);
        NSLog(@"类型为 %s 的 %s ",type, name);
    }
    free(ivars);
}

#pragma mark - 遍历某个对象的成员变量
- (void)printClassAllProperties:(Class)cls{
    NSLog(@"*********************");
    unsigned int outCount = 0;
    objc_property_t *properties  =class_copyPropertyList(cls, &outCount);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:outCount];
    for (int i = 0; i<outCount; i++){
        // objc_property_t 属性类型
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char *cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [propertiesArray addObject:name];
        NSLog(@"属性: %@",name);
    }
    
    free(properties);
}

#pragma mark - 遍历类以及子类
- (void)printClasses:(Class)cls{
    
    // 注册类的总数
    int count = objc_getClassList(NULL, 0);
    // 创建一个数组， 其中包含给定对象
    NSMutableArray *mArray = [NSMutableArray arrayWithObject:cls];
    // 获取所有已注册的类
    Class* classes = (Class*)malloc(sizeof(Class)*count);
    objc_getClassList(classes, count);
    for (int i = 0; i<count; i++) {
        if (cls == class_getSuperclass(classes[i])) {
            [mArray addObject:classes[i]];
        }
    }
    free(classes);
    NSLog(@"classes = %@", mArray);
}

#pragma mark - 遍历某个类的方法
- (void)printClassAllMethod:(Class)cls{
    NSLog(@"*********************");
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(cls, &count);
    for (int i = 0; i<count; i++) {
        Method method = methodList[i];
        SEL sel = method_getName(method);
        IMP imp = class_getMethodImplementation(cls, sel);
        NSLog(@"%@-%p",NSStringFromSelector(sel),imp);
    }
    free(methodList);
}


#pragma mark class_addIvar的正确用法

- (void)_class_addIvar{
    Class CreatClass0 = objc_allocateClassPair([NSObject class], "CreatClass0", 0);
    class_addIvar(CreatClass0, "_attribute0", sizeof(NSString *), log(sizeof(NSString *)), "i");
    Ivar ivar = class_getInstanceVariable(CreatClass0, "_attribute0");//获取变量,如果没获取到说明不存在
    
    NSLog(@"对齐前:%p",class_getIvarLayout(CreatClass0));
    NSLog(@"对齐前大小:%zu",class_getInstanceSize(CreatClass0));
    ///10. class_setIvarLayout  设置内存对齐格式
    ///参数:1.类Class 2.const uint8_t *
    /// The layout of the Ivars for cls
    /// Can't set ivar layout for already-registered class
    uint8_t u = 16;
    const uint8_t *u8  = &u;
    class_setIvarLayout(CreatClass0, u8);
    NSLog(@"对齐后:%p",class_getIvarLayout(CreatClass0));
    NSLog(@"对齐后大小:%zu",class_getInstanceSize(CreatClass0));

    NSLog(@"_class_addIvar:%@",[NSString stringWithUTF8String:ivar_getName(ivar)]);
    objc_registerClassPair(CreatClass0);
    
}

@end
