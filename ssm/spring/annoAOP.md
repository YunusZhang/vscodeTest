<!-- TOC -->

- [注解方式实现AOP](#注解方式实现aop)
    - [1 需求](#1-需求)
    - [2 实现步骤](#2-实现步骤)
        - [2.1 分析纯bean.xml配置的方式](#21-分析纯beanxml配置的方式)
        - [2.2 分析注解方式配置](#22-分析注解方式配置)
            - [2.2.1 注解方式的xml代码：](#221-注解方式的xml代码)
            - [2.2.2 注解方式的事务管理类TransferManager：](#222-注解方式的事务管理类transfermanager)
            - [2.2.3 和jdk动态代理实现的BeanFactory以及cglib动态代理的对比](#223-和jdk动态代理实现的beanfactory以及cglib动态代理的对比)

<!-- /TOC -->
# 注解方式实现AOP
## 1 需求

需求分析：把事务控制作为AOP切入，使用注解的方式，以达到在转账的功能实现的过程中实现事务控制

## 2 实现步骤
### 2.1 分析纯bean.xml配置的方式
纯bean.xml配置代码：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd">


    <!--配置代理的Service对象-->
    <bean id="proxyAccountService" factory-bean="beanFactory" factory-method="getAccountService"></bean>
    <!--配置beanfactory-->
    <bean id="beanFactory" class="com.baidu.factory.BeanFactory">
        <!--注入service-->
        <property name="accountService" ref="accountService"></property>

        <!--注入事务管理器-->
        <property name="txManager" ref="txManager"></property>
    </bean>

    <!--业务层对象
    配置Service
    -->
    <bean id="accountService" class="com.baidu.service.impl.AccountServiceImpl">
        <!--注入dao-->
        <property name="accountDao" ref="accountDao"></property>


        <!--注入事务管理器
        <property name="txManager" ref="txManager"></property>-->
    </bean>

    <!--配置Dao对象-->
    <bean id="accountDao" class="com.baidu.dao.impl.AccountDaoImpl">
        <!--注入queryrunner-->
        <property name="runner" ref="runner"></property>

        <!--注入ConnectionUtils-->
        <property name="connectionUtils" ref="connectionUtils"></property>
    </bean>


    <!--配置QueryRunner-->
    <bean id="runner" class="org.apache.commons.dbutils.QueryRunner" scope="prototype">
        <!--分析：
        如果Dao中在执行方法的同时，给QueryRunner注入了connection之后，就会从连接池拿一个连接；
        而现在显然不希望他从连接中取一个；于是这里就不要给它注入数据源
        但是当我们不提供connection对象的时候，就会发现Dao里面的操作就会没有connection;如何解决？？
        解决办法：在Dao实现类中加一个新的对象，private ConnectionUtils connectionUtils;
        -->
        <!--注入数据源
        <constructor-arg name="ds" ref="dataSource"></constructor-arg>-->
    </bean>

    <!--配置数据源-->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <!--注入连接数据库的必备信息-->
        <property name="driverClass" value="com.mysql.jdbc.Driver"></property>
        <property name="jdbcUrl" value="jdbc:mysql://localhost:3306/eesy"></property>
        <property name="user" value="root"></property>
        <property name="password" value="root"></property>
    </bean>

    <!--配置Connection的工具类，ConnectionUtils-->
    <bean id="connectionUtils" class="com.baidu.utils.ConnectionUtils">
        <!--注入数据源-->

        <property name="dataSource" ref="dataSource">

        </property>
    </bean>

    <!--配置事务管理器-->
    <bean id="txManager" class="com.baidu.utils.TransactionManager">
        <!--注入ConnectionUtils-->
        <property name="connectionUtils" ref="connectionUtils"></property>
    </bean>



</beans>
```

纯xml配置注意以下几点：

1）约束搜索为xmlns:

2）流程为
* 配置业务层对象（service对象）：如果使用动态代理则要配置代理的Service对象
* 配置Dao对象
* 配置QueryRunner
* 配置数据源
* 配置Connection的工具类，ConnectionUtils
* 配置事务管理器

3）配置对象（service，dao等）的时候；如果有属性需要注入，则要在对应的类中添加set方法；然后再xml中注入相应的属性property；例如
```xml
<!--配置Dao对象-->
    <bean id="accountDao" class="com.baidu.dao.impl.AccountDaoImpl">
        <!--注入queryrunner-->
        <property name="runner" ref="runner"></property>

        <!--注入ConnectionUtils-->
        <property name="connectionUtils" ref="connectionUtils"></property>
    </bean>
```

4）在配置配置QueryRunner的时候，不注入数据源，而是把权利给Dao实现类，在Dao实现类中加一个新的对象，private ConnectionUtils connectionUtils; 让他在执行Dao操作的时候再去从连接中取一个

5）配置QueryRunner的时候保证他是多例的，scope="prototype"

6）配置QueryRunner和配置数据源也可以用注解的方式，但是最好用xml，因为QueryRunner是别人提供的类，改动较麻烦



### 2.2 分析注解方式配置
#### 2.2.1 注解方式的xml代码：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/aop
        http://www.springframework.org/schema/aop/spring-aop.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">

    <!--配置Spring创建容器时要扫描的包-->
    <context:component-scan base-package="com.baidu"></context:component-scan>


   <!-- 配置QueryRunner-->
    <bean id="runner" class="org.apache.commons.dbutils.QueryRunner" scope="prototype">
        <!--分析：
        如果Dao中在执行方法的同时，给QueryRunner注入了connection之后，就会从连接池拿一个连接；
        而现在显然不希望他从连接中取一个；于是这里就不要给它注入数据源
        但是当我们不提供connection对象的时候，就会发现Dao里面的操作就会没有connection;如何解决？？
        解决办法：在Dao实现类中加一个新的对象，private ConnectionUtils connectionUtils;
        -->
        <!--注入数据源
        <constructor-arg name="ds" ref="dataSource"></constructor-arg>-->
    </bean>

    <!--配置数据源-->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <!--注入连接数据库的必备信息-->
        <property name="driverClass" value="com.mysql.jdbc.Driver"></property>
        <property name="jdbcUrl" value="jdbc:mysql://localhost:3306/eesy"></property>
        <property name="user" value="root"></property>
        <property name="password" value="root"></property>
    </bean>

    <aop:aspectj-autoproxy></aop:aspectj-autoproxy>



</beans>
```

注解配置注意以下几点：

1）约束搜索为xmlns:context

2）流程为
* 配置Spring创建容器时要扫描的包
* 配置QueryRunner
* 配置数据源
* 添加切面识别<aop:aspectj-autoproxy></aop:aspectj-autoproxy>


3）配置对象（service，dao等）的时候；直接在相应的对象上面加注解；如果有属性需要注入，则要在对应的类中的属性上加注解@Autowired；对应的类中添加set方法要注释掉（不需要在xml中注入）；


#### 2.2.2 注解方式的事务管理类TransferManager：

```java
package com.baidu.utils;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.sql.SQLException;

/**
 * @ClassName: TransactionManager
 * @Program:
 * @Description: 和事务管理相关的工具类，它包含了开启事务，提交事务，回滚事务，和释放连接
 * @Author: Wang clk
 * @Create: 2020/3/21
 * @Version: 1.0
 **/

@Component("transactionManager")
@Aspect //表示当前类是一个切面
public class TransactionManager {

    @Autowired
    private ConnectionUtils connectionUtils;

    /*public void setConnectionUtils(ConnectionUtils connectionUtils) {
        this.connectionUtils = connectionUtils;
    }*/

    @Pointcut("execution(* com.baidu.service.impl.*.*(..))")
    private void pt1() {

    }

    /* 开启事务
    * */
    //@Before("pt1()")
    public void beginTransaction() {
        System.out.println("before...");

        try {
            connectionUtils.getThreadConnection().setAutoCommit(false);
        } catch (Exception e) {
            e.printStackTrace();
        }


    }

    /*提交事务
    * */
    //@AfterReturning("pt1()")
    public void commit() {
        System.out.println("after...");

        try {
            connectionUtils.getThreadConnection().commit();
        } catch (Exception e) {
            e.printStackTrace();
        }



    }

    /*回滚事务

    出现bug的原因：@After会出现在@AfterThrowing或者@AfterReturning的前面；那么当@After（释放连接）执行的时候，？？？？？？
     * */
    //@AfterThrowing("pt1()")
    public void rollback() {

        System.out.println("exception...");

        try {
            connectionUtils.getThreadConnection().rollback();
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    /*释放连接
    * */

    //@After("pt1()")
    public void release() {
        System.out.println("finally...");

        try {
            connectionUtils.getThreadConnection().close(); //还回连接池中

            connectionUtils.removeConnection();

        } catch (Exception e) {
            e.printStackTrace();
        }

    }


    @Around("pt1()")
    public Object aroundPrintLog(ProceedingJoinPoint pjp) {
        Object rtValue = null;
        try {
            Object[] args = pjp.getArgs();

            System.out.println("aroundPrintLog--the method printLog in the class Logger start to do the log...before");
            connectionUtils.getThreadConnection().setAutoCommit(false);
            rtValue = pjp.proceed(args);//明确调用业务层方法（切入点方法）
            System.out.println("aroundPrintLog--the method printLog in the class Logger start to do the log...after");

            connectionUtils.getThreadConnection().commit();
            return rtValue;

        } catch (Throwable throwable) {
            System.out.println("aroundPrintLog--the method printLog in the class Logger start to do the log...exception");
            try {
                connectionUtils.getThreadConnection().rollback();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            throw new RuntimeException(throwable);
        } finally {
            System.out.println("aroundPrintLog--the method printLog in the class Logger start to do the log...finally");
            try {
                connectionUtils.getThreadConnection().close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            connectionUtils.removeConnection();

        }
    }
}

```

注意事项：

1）类上注解

@Component("transactionManager")

@Aspect //表示当前类是一个切面

2）属性上注解

```java
    @Autowired
    private ConnectionUtils connectionUtils;


    

```

3）切入点表达式：表示给哪个业务功能增强

```java
@Pointcut("execution(* com.baidu.service.impl.*.*(..))")
    private void pt1() {

    }
```

4）空指针报错问题解析

出现bug的原因：@After会出现在@AfterThrowing或者@AfterReturning的前面；那么当@After（释放连接）执行的时候，？？？？？？

<div style="color: red">
当@After（释放连接）执行的时候，会执行connectionUtils.removeConnection();表示把当前连接移除；那么当@AfterReturning（提交事务）再执行的时候，里面的connectionUtils.getThreadConnection()方法又会从连接池里拿一个新的连接；那么这时的连接的提交方式就是默认的自动提交；所以会出现报错；
</div>


解决办法：使用环绕注解，在相应的位置加入事务控制方法

```java
@Around("pt1()")
    public Object aroundPrintLog(ProceedingJoinPoint pjp) {
        Object rtValue = null;
        try {
            Object[] args = pjp.getArgs();

            System.out.println("aroundPrintLog--the method printLog in the class Logger start to do the log...before");
            connectionUtils.getThreadConnection().setAutoCommit(false);
            rtValue = pjp.proceed(args);//明确调用业务层方法（切入点方法）
            System.out.println("aroundPrintLog--the method printLog in the class Logger start to do the log...after");

            connectionUtils.getThreadConnection().commit();
            return rtValue;

        } catch (Throwable throwable) {
            System.out.println("aroundPrintLog--the method printLog in the class Logger start to do the log...exception");
            try {
                connectionUtils.getThreadConnection().rollback();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            throw new RuntimeException(throwable);
        } finally {
            System.out.println("aroundPrintLog--the method printLog in the class Logger start to do the log...finally");
            try {
                connectionUtils.getThreadConnection().close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            connectionUtils.removeConnection();

        }
    }

```


#### 2.2.3 和jdk动态代理实现的BeanFactory以及cglib动态代理的对比


jdk动态代理的BeanFactory类：

```java
package com.baidu.factory;

import com.baidu.domain.Account;
import com.baidu.service.IAccountService;
import com.baidu.utils.TransactionManager;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/**
 * @ClassName: BeanFactory
 * @Program:
 * @Description: 用于创建Service代理对象工厂
 * @Author: Wang clk
 * @Create: 2020/3/22
 * @Version: 1.0
 **/
public class BeanFactory {
    private IAccountService accountService;
    private TransactionManager txManager;

    public void setTxManager(TransactionManager txManager) {
        this.txManager = txManager;
    }

    public final void setAccountService(IAccountService accountService) {
        this.accountService = accountService;
    }

    /*获取Service的代理对象
     * */
    public IAccountService getAccountService() {
        return (IAccountService) Proxy.newProxyInstance(accountService.getClass().getClassLoader(),
                accountService.getClass().getInterfaces(),
                new InvocationHandler() {

                    /*添加事务的支持
                     * */
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {

                        if ("test".equals(method.getName())) {
                            return method.invoke(accountService, args);
                        }
                        Object rtValue = null;
                        try {
                            //1开启事务
                            txManager.beginTransaction();
                            //2执行操作
                            rtValue = method.invoke(accountService, args);
                            //3提交事务
                            txManager.commit();
                            //4返回结果
                            return rtValue;
                        } catch (Exception e) {
                            //回滚操作
                            txManager.rollback();
                            throw new RuntimeException(e);//如果产生了异常程序不再执行？？


                        } finally {
                            //释放连接
                            txManager.release();

                        }

                    }
                });
    }

}

```


cglib动态代理的案例：

```java
package com.baidu.cglib;

import com.baidu.proxy.IProducer;
import net.sf.cglib.proxy.Enhancer;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/**
 * @ClassName: Client
 * @Program:
 * @Description: 模拟一个消费者
 * @Author: Wang clk
 * @Create: 2020/3/22
 * @Version: 1.0
 **/
public class Client {
    public static void main(String[] args) {
        final Producer producer = new Producer();
        //producer.saleProduct(10000);

        /*动态代理：
        特点：字节码随用随创建，随用随加载
        作用：不修改源码的基础上对方法增强
        分类：
            基于接口的动态代理
            基于子类的动态代理

        基于子类的动态代理：
            涉及的类：Enhancer
            提供者：第三方cglib库

        如何创建代理对象
        使用newProxyInstance()方法

        创建代理对象的要求：
        被代理类不能是最终类

   create方法的参数
    Class:类加载器
        他是用于指定被代理对象的字节码


    Callback:用于提供增强的代码
        他是让我们写如何代理，我们一般都是写一个该接口的实现类，通常情况下都是匿名内部类，但不是必须的
        此接口的实现类都是谁用谁写
        我们一般写的都是该接口的子接口的实现类，MethodInterceptor
        * */


        Producer cglibProducer = (Producer) Enhancer.create(producer.getClass(), new MethodInterceptor() {
            /*
             * @author: wangyu
             * @Description: 执行被代理对象的任何方法都会经过该方法
             * @Param: [o, method, objects, methodProxy]
             *
             * methodProxy:当前执行方法的代理对象
             * @return: java.lang.Object
             **/
            public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {

                //提供增强的代码
                Object returnValue = null;

                //1获取方法执行的参数
                Float money = (Float) objects[0];

                //判断当前方法是不是销售
                if ("saleProduct".equals(method.getName())) {

                    returnValue = method.invoke(producer, money * 0.8f);
                }
                return returnValue;

            }
        });

        cglibProducer.saleProduct(20000);

    }

}

```









