#spring的坑们
1)获取核心容器对象时，路径写法问题
```java
//错误的写法：
ApplicationContext ac = new FileSystemXmlApplicationContext("/Users/wangyu/Desktop/bean.xml");
/* 
此时会报错Caused by: java.nio.file.NoSuchFileException: Users/wangyu/Desktop/bean.xml
*/

//查看源码发现,FileSystemXmlApplicationContext方法对路径进行了处理；用绝对路径时,第一个斜杠会被去掉(不知道为什么)
@Override
	protected Resource getResourceByPath(String path) {
		if (path.startsWith("/")) {
			path = path.substring(1);
		}
		return new FileSystemResource(path);
	}
//解决方法：在绝对路径前再加个斜杠   

ApplicationContext ac = new FileSystemXmlApplicationContext("//Users/wangyu/Desktop/bean.xml");
```


2）完整的代码

```java
package com.baidu.ui;

import com.baidu.dao.IAccountDao;
import com.baidu.service.IAccountService;
import com.baidu.service.impl.AccountServiceImpl;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

/**
 * @ClassName: Client
 * @Program:
 * @Description:
 * @Author: Wang clk
 * @Create: 2020/3/17
 * @Version: 1.0
 **/
public class Client {
    /*
     * @author: wangyu
     * @Description: 获取spring的ioc核心容器，并根据id获取对象
     * @Param: [args]
     * @return: void
     **/

    /*  ApplicationContext三个常用实现类：
        ClassPathXmlApplicationContext:
        FileSystemXmlApplicationContext:
        AnnotationConfigApplicationContext:
    *
    *
    * */
    public static void main(String[] args) {
        //1获取核心容器对象
        //ApplicationContext ac = new ClassPathXmlApplicationContext("bean.xml");
        ApplicationContext ac = new FileSystemXmlApplicationContext("//Users/wangyu/Desktop/bean.xml");
        //2根据id获取bean对象

        IAccountService as = (IAccountService) ac.getBean("accountService");
        IAccountDao adao = ac.getBean("accountDao", IAccountDao.class);


        System.out.println(as);
        System.out.println(adao);
        as.saveAccount();
    }
}


```