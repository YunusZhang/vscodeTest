<!-- TOC -->

- [1.框架概述](#1%e6%a1%86%e6%9e%b6%e6%a6%82%e8%bf%b0)
  - [1.1什么是框架](#11%e4%bb%80%e4%b9%88%e6%98%af%e6%a1%86%e6%9e%b6)
  - [1.2MyBatis框架概述](#12mybatis%e6%a1%86%e6%9e%b6%e6%a6%82%e8%bf%b0)
- [2.快速入门](#2%e5%bf%ab%e9%80%9f%e5%85%a5%e9%97%a8)
  - [2.1 开发准备](#21-%e5%bc%80%e5%8f%91%e5%87%86%e5%a4%87)
  - [2.2 User实体类](#22-user%e5%ae%9e%e4%bd%93%e7%b1%bb)
  - [2.3 持久层接口IUserDao](#23-%e6%8c%81%e4%b9%85%e5%b1%82%e6%8e%a5%e5%8f%a3iuserdao)
  - [2.4 持久层接口的映射文件IUserDao.xml](#24-%e6%8c%81%e4%b9%85%e5%b1%82%e6%8e%a5%e5%8f%a3%e7%9a%84%e6%98%a0%e5%b0%84%e6%96%87%e4%bb%b6iuserdaoxml)
  - [2.5 SqlMapConfig.xml配置文件](#25-sqlmapconfigxml%e9%85%8d%e7%bd%ae%e6%96%87%e4%bb%b6)
  - [2.6 进行测试](#26-%e8%bf%9b%e8%a1%8c%e6%b5%8b%e8%af%95)
- [3.补充（基于注解的mybatis使用）](#3%e8%a1%a5%e5%85%85%e5%9f%ba%e4%ba%8e%e6%b3%a8%e8%a7%a3%e7%9a%84mybatis%e4%bd%bf%e7%94%a8)
  - [3.1 在持久层接口中添加注解](#31-%e5%9c%a8%e6%8c%81%e4%b9%85%e5%b1%82%e6%8e%a5%e5%8f%a3%e4%b8%ad%e6%b7%bb%e5%8a%a0%e6%b3%a8%e8%a7%a3)
  - [3.2 修改SqlMapConfig.xml](#32-%e4%bf%ae%e6%94%b9sqlmapconfigxml)
- [4.注意事项](#4%e6%b3%a8%e6%84%8f%e4%ba%8b%e9%a1%b9)

<!-- /TOC -->

# 1.框架概述
## 1.1什么是框架
什么是框架

框架（Framework）是整个或部分系统的可重用设计，表现为一组抽象构件及构件实例间交互的方法;另一种 定义认为，框架是可被应用开发者定制的应用骨架。前者是从应用方面而后者是从目的方面给出的定义。

框架要解决的问题

框架要解决的最重要的一个问题是技术整合的问题。框架一般处在低层应用平台（如 J2EE）和高层业务逻辑之间的中间层。框架的重要性在于它实现了部分功能，并且能够很好的将低层应用平台和高层业务逻辑进行了缓和。

## 1.2MyBatis框架概述
基本信息

mybatis是一个优秀的基于 java 的持久层框架，它内部封装了 jdbc，使开发者只需要关注 sql语句本身， 而不需要花费精力去处理加载驱动、创建连接、创建 statement 等繁杂的过程。

mybatis通过xml 或注解的方式将要执行的各种statement配置起来，并通过java对象和statement 中 sql 的动态参数进行映射生成最终执行的 sql 语句，最后由 mybatis 框架执行 sql 并将结果映射为 java 对象并 返回。

采用 ORM 思想解决了实体和数据库映射的问题，对 jdbc进行了封装，屏蔽了 jdbc api 底层访问细节，使我 们不用与 jdbc api 打交道，就可以完成对数据库的持久化操作。

MyBatis的功能架构：

1)API接口层：提供给外部使用的接口API，开发人员通过这些本地API来操纵数据库。接口层一接收到调用请求就会调用数据处理层来完成具体的数据处理。

2)数据处理层：负责具体的SQL查找、SQL解析、SQL执行和执行结果映射处理等。它主要的目的是根据调用的请求完成一次数据库操作。

3)基础支撑层：负责最基础的功能支撑，包括连接管理、事务管理、配置加载和缓存处理，这些都是共用的东西，将他们抽取出来作为最基础的组件。为上层的数据处理层提供最基础的支撑。

MyBatis的优缺点

优点：

简单易学，灵活

解除sql与程序代码的耦合

提供xml标签，支持编写动态sql

缺点：

编写SQL语句时工作量很大，尤其是字段多、关联表多时，更是如此
SQL语句依赖于数据库，导致数据库移植性差

# 2.快速入门
## 2.1 开发准备

创建数据库和用户表，接着插入数据，SQL语句如下:

```sql

CREATE DATABASE test;

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL COMMENT '用户名称',
  `birthday` datetime DEFAULT NULL COMMENT '生日',
  `sex` char(1) DEFAULT NULL COMMENT '性别',
  `address` varchar(256) DEFAULT NULL COMMENT '地址',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;


INSERT INTO `user` VALUES ('1', '李一', '2020-02-01 17:47:08', '男', '北京');
INSERT INTO `user` VALUES ('2', '刘二', '2020-02-02 15:09:37', '女', '上海');
INSERT INTO `user` VALUES ('3', '张三', '2020-03-03 11:34:34', '女', '广东');
INSERT INTO `user` VALUES ('4', '赵四', '2020-03-04 12:04:06', '男', '杭州');
INSERT INTO `user` VALUES ('5', '王五', '2020-03-05 17:37:26', '男', '深圳');

```


从mybatis官网中下载mybatis的开发包（这里我使用的坂本是3.4.5）

创建一个maven工程，项目名为mybatis_01，项目信息如下：

1、直接点击Create New Project创建一个工程

2、点击Next

3、填写项目中的GroupId和ArtifactId，点击下一步

4.下面是该项目的目录结构


在pom.xml文件中添加Mybatis3.4.5的坐标，代码如下：
```xml
    <dependencies>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.4.5</version>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.6</version>
        </dependency>
        <dependency>
            <groupId>log4j</groupId>
            <artifactId>log4j</artifactId>
            <version>1.2.17</version>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>
    </dependencies>
```

## 2.2 User实体类
编写一个用户的实体类
```java
public class User implements Serializable{

    private Integer id;
    private String username;
    private Date birthday;
    private String sex;
    private String address;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Date getBirthday() {
        return birthday;
    }

    public void setBirthday(Date birthday) {
        this.birthday = birthday;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", birthday=" + birthday +
                ", sex='" + sex + '\'' +
                ", address='" + address + '\'' +
                '}';
    }
}
```

## 2.3 持久层接口IUserDao
创建接口IUserDao，为了演示此处只定义一个查询所有的方法

```java
public interface IUserDao {

    /**
     * 查询所有
     * @return
     */
    List<User> findAll();
}
```


## 2.4 持久层接口的映射文件IUserDao.xml
要求：创建位置必须和持久层接口在相同的包中

           必须以持久层接口名称命名文件名，扩展名是.xml

完整代码如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
 <mapper namespace="com.wink.dao.IUserDao">
    <!-- 配置查询所有-->
    <select id="findAll" resultType="com.wink.domain.User">
        select * from user
    </select>
</mapper>

```

## 2.5 SqlMapConfig.xml配置文件
下面通过xml配置mybatis的一些环境

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<!-- mybatis的主配置文件-->
<configuration>
    <!-- 配置环境-->
    <environments default="mysql">
        <!-- 配置mysql的环境-->
        <environment id="mysql">
            <!-- 配置事务的类型-->
            <transactionManager type="JDBC"></transactionManager>
            <!-- 配置数据源（连接池）-->
            <dataSource type="POOLED">
                <!-- 配置连接数据库的基本信息-->
                <property name="driver" value="com.mysql.jdbc.Driver"></property>
                <property name="url" value="jdbc:mysql:///test"></property>
                <property name="username" value="root"></property>
                <property name="password" value="root"></property>
            </dataSource>
        </environment>
    </environments>

    <!-- 指定映射配置文件的位置，映射配置文件指的是每个dao独立的配置文件-->
    <mappers>
        <mapper resource="com/wink/dao/IUserDao.xml"></mapper>
    </mappers>
</configuration>

```

## 2.6 进行测试
编写一个Mybatis的测试类，测试上述查询所有的方法，这里直接使用main方法测试：

第一步：读取配置文件

第二步：创建SqlSessionFactory工厂

第三步：创建SqlSession

第四步：创建Dao接口的代理对象

第五步：执行dao中的方法

第六步：释放资源

```java
public class MybatisTest {

    /**
     * 入门案例
     * @param args
     */
    public static void main(String[] args)throws Exception {
        //1.读取配置文件
        InputStream in = Resources.getResourceAsStream("SqlMapConfig.xml");
        //2.创建SqlSessionFactory工厂
        SqlSessionFactoryBuilder builder = new SqlSessionFactoryBuilder();
        SqlSessionFactory factory = builder.build(in);
        //3.使用工厂生产SqlSession对象
        SqlSession session = factory.openSession();
        //4.使用SqlSession创建Dao接口的代理对象
        IUserDao userDao = session.getMapper(IUserDao.class);
        //5.使用代理对象执行方法
        List<User> users = userDao.findAll();
        for(User user : users){
            System.out.println(user);
        }
        //6.释放资源
        session.close();
        in.close();
    }
}

```

下面执行MybatisTest，可以看到成功运行


# 3.补充（基于注解的mybatis使用）
mybatis基于注解的入门案例

把IUserDao.xml移除，在dao接口的方法上使用@Select注解，并且指定SQL语句。同时需要在SqlMapConfig.xml中的mapper配置时，使用class属性指定dao接口的全限定类名

## 3.1 在持久层接口中添加注解

```java
public interface IUserDao {
    /**
     * 查询所有操作
     * @return
     */
    @Select("select * from user")
    List<User> findAll();
}

```

## 3.2 修改SqlMapConfig.xml

```xml
<!-- 告知 mybatis 映射配置的位置 --> 
<mappers> 
   <mapper class="com.wink.dao.IUserDao"/>
</mappers> 

```

注意：在使用基于注解的 Mybatis 配置时，需要移除 xml 的映射配置（IUserDao.xml）


# 4.注意事项
在搭建环境时：

1、创建IUserDao.xml 和 IUserDao.java时名称是为了和我们之前的知识保持一致。在Mybatis中它把持久层的操作接口名称和映射文件也叫做：Mapper。所以：IUserDao 和 IUserMapper是一样的

2、mybatis的映射配置文件位置必须和dao接口的包结构相同

3、映射配置文件的mapper标签namespace属性的取值必须是dao接口的全限定类名

在测试代码中：

不要忘记在映射配置中告知mybatis要封装到哪个实体类中

配置的方式：指定实体类的全限定类名








