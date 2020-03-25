
<!-- TOC -->

- [1.基于代理Dao实现CRUD操作](#1%e5%9f%ba%e4%ba%8e%e4%bb%a3%e7%90%86dao%e5%ae%9e%e7%8e%b0crud%e6%93%8d%e4%bd%9c)
  - [1.1 编写实体类和持久层接口](#11-%e7%bc%96%e5%86%99%e5%ae%9e%e4%bd%93%e7%b1%bb%e5%92%8c%e6%8c%81%e4%b9%85%e5%b1%82%e6%8e%a5%e5%8f%a3)
  - [1.2 编写主配置文件](#12-%e7%bc%96%e5%86%99%e4%b8%bb%e9%85%8d%e7%bd%ae%e6%96%87%e4%bb%b6)
  - [1.3 编写映射配置文件](#13-%e7%bc%96%e5%86%99%e6%98%a0%e5%b0%84%e9%85%8d%e7%bd%ae%e6%96%87%e4%bb%b6)
  - [1.4 编写测试类](#14-%e7%bc%96%e5%86%99%e6%b5%8b%e8%af%95%e7%b1%bb)
- [2.SqlMapConfig.xml配置文件](#2sqlmapconfigxml%e9%85%8d%e7%bd%ae%e6%96%87%e4%bb%b6)
  - [2.1 配置内容和顺序](#21-%e9%85%8d%e7%bd%ae%e5%86%85%e5%ae%b9%e5%92%8c%e9%a1%ba%e5%ba%8f)
  - [2.2 properties属性](#22-properties%e5%b1%9e%e6%80%a7)
  - [2.3 typeAliases（类型别名）](#23-typealiases%e7%b1%bb%e5%9e%8b%e5%88%ab%e5%90%8d)
  - [2.4 mappers（映射器）](#24-mappers%e6%98%a0%e5%b0%84%e5%99%a8)
- [3.Mybatis的参数深入](#3mybatis%e7%9a%84%e5%8f%82%e6%95%b0%e6%b7%b1%e5%85%a5)
  - [3.1 parameterType配置参数](#31-parametertype%e9%85%8d%e7%bd%ae%e5%8f%82%e6%95%b0)
  - [3.2 传递pojo包装对象](#32-%e4%bc%a0%e9%80%92pojo%e5%8c%85%e8%a3%85%e5%af%b9%e8%b1%a1)

<!-- /TOC -->
# 1.基于代理Dao实现CRUD操作

从上一文章中可以知道mybatis环境搭建的步骤：

第一步：创建 maven 工程

第二步：导入坐标

第三步：编写必要代码（实体类和持久层接口）

第四步：编写 SqlMapConfig.xml

第五步：编写映射配置文件

第六步：编写测试类

## 1.1 编写实体类和持久层接口
首先，创建一个maven工程，配置pom.xml，然后编写一个用户的实体类（上章有相关配置）

下面创建持久层接口，定义一些方法：查询所有方法、根据ID查询、插入、更新、根据Id删除用户、根据名称模糊查询和聚合函数查询

IUserDao.java

```java
public interface IUserDao {
    /**
     * 查询所有
     * @return
     */
    List<User> findAll();

    /**
     * 根据Id查询用户
     * @param userId
     */
    User findById(Integer userId);

    /**
     * 保存用户
     * @param user
     */
    void saveUser(User user);
    /**
     * 更新用户
     * @param user
     */
    void  updateUser(User user);

    /**
     * 根据Id删除用户
     * @param userId
     */
    void deleteUser(Integer userId);

    /**
     * 根据名称模糊查询
     * @param username
     * @return
     */
    List<User> findByName(String username);

    /**
     * 查询总记录数
     * @return
     */
    Integer findtotal();
}
```

## 1.2 编写主配置文件
数据库配置文件
```
jdbcConfig.properties
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql:///test
jdbc.username=root
jdbc.password=root
```

mybatis的主配置文件SqlMapConfig.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<!--mybatis的主配置文件-->
<configuration>
    <!-- 配置properties-->
    <properties resource="jdbcConfig.properties"></properties>
    <!-- 配置环境 -->
    <environments default="mysql">
        <!-- 配置mysql的环境-->
        <environment id="mysql">
            <!-- 配置事务的类型-->
            <transactionManager type="JDBC"></transactionManager>
            <!--配置连接池-->
            <dataSource type="POOLED">
                <property name="driver" value="${jdbc.driver}"></property>
                <property name="url" value="${jdbc.url}"></property>
                <property name="username" value="${jdbc.username}"></property>
                <property name="password" value="${jdbc.password}"></property>
            </dataSource>
        </environment>
    </environments>
    <mappers>
        <mapper resource="com/wink/dao/IUserDaoMapper.xml"></mapper>
    </mappers>
</configuration>
```

## 1.3 编写映射配置文件
在用户的映射配置文件中配置用户的持久层中相关方法

1.根据Id查询

```xml
    <select id="findById" parameterType="java.lang.Integer" resultType="com.wink.domain.User">
        select * FROM USER where id = #{id}
    </select>
```

resultType属性：用于指定结果集的类型

parameterType属性：用于指定传入参数的类型

sql 语句中使用#{}字符：

它代表占位符，相当于原来 jdbc 部分所学的?，都是用于执行语句时替换实际的数据。具体的数据是由#{}里面的内容决定的。


2.保存操作

```xml
    <insert id="saveUser" parameterType="com.wink.domain.User">
        <!--配置插入操作之后，获取插入数据的id-->
        <selectKey keyProperty="id" keyColumn="id" order="AFTER" resultType="int" >
            select last_insert_id()
        </selectKey>
        insert into user(username,birthday,sex,address) values(#{username},#{birthday},#{sex},#{address})
    </insert>
```


\#{}中内容的写法：

由于我们保存方法的参数是 一个 User 对象，此处要写 User 对象中的属性名称。 它用的是 ognl 表达式。

ognl表达式

它是 apache 提供的一种表达式语言，全称是： Object Graphic Navigation Language 对象图导航语言 它是按照一定的语法格式来获取数据的。 语法格式就是使用 #{对象.对象}的方式

\#{user.username}它会先去找 user 对象，然后在 user 对象中找到 username 属性，并调用 getUsername()方法把值取出来。但是我们在 parameterType 属性上指定了实体类名称，所以可以省略 user. 而直接写 username。


此处的selectKey并非必须，是为了演示新增用户后，返回当前新增用户的id值，因为id是由数据库的自动增长来实现的，所以就相 当于我们要在新增后将自动增长 auto_increment 的值返回。
![](https://img-blog.csdnimg.cn/20200220221420170.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)


3.更新操作

```xml
    <update id="updateUser" parameterType="com.wink.domain.User">
        update user set username=#{username},birthday=#{birthday},sex=#{sex},address=#{address} where id = #{id}
    </update>
```

4.删除操作
```xml

    <delete id="deleteUser" parameterType="java.lang.Integer">
        delete from user where id=#{uid}
    </delete>
```


5.模糊查询
```xml
    <select id="findByName" parameterType="String" resultType="com.wink.domain.User">
        select * from user where username like #{username}
    </select>
```


若使用上述配置方法，我们在配置文件中没有加入%来作为模糊查询的条件，所以在传入字符串实参时，就需要给定模糊查询的标识%。配置文件中的#{username}也只是一个占位符，所以 SQL 语句显示为“？”执行效果如下：
![](https://img-blog.csdnimg.cn/20200220215634163.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)

这里有两种配置方法，另一种是 select * from user where username like ‘%${value}%’
![](https://img-blog.csdnimg.cn/20200220215755325.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)

可以发现，我们在程序代码中就不需要加入模糊查询的匹配符%了，这两种方式的实现效果是一样的，但执行 的语句是不一样的。

__#{}和${}的区别__

\#{}表示一个占位符，${}表示拼接sql串

通过#{}可以实现 preparedStatement 向占位符中设置值，自动进行 java 类型和 jdbc 类型转换， #{}可以有效防止 sql 注入。 #{}可以接收简单类型值或 pojo 属性值。 如果 parameterType 传输单个简单类 型值，#{}括号中可以是 value 或其它名称。


通过$ {}可以将 parameterType 传入的内容拼接在 sql中且不进行 jdbc 类型转换， $ {}可以接收简 单类型值或 pojo 属性值，如果 parameterType 传输单个简单类型值，${}括号中只能是 value


6.聚合函数
```xml
    <select id="findtotal" resultType="Integer">
        select count(*) from user
    </select>
```

下面是IUSerDaoMapper.xml的代码

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.wink.dao.IUserDao">
    <!-- 查询所有-->
    <select id="findAll" resultType="com.wink.domain.User">
        select * FROM USER
    </select>

    <!--根据Id查询-->
    <select id="findById" parameterType="java.lang.Integer" resultType="com.wink.domain.User">
        select * FROM USER where id = #{id}
    </select>

    <!-- 保存用户-->
    <insert id="saveUser" parameterType="com.wink.domain.User">
        <!--配置插入操作之后，获取插入数据的id-->
        <selectKey keyProperty="id" keyColumn="id" order="AFTER" resultType="int" >
            select last_insert_id()
        </selectKey>
        insert into user(username,birthday,sex,address) values(#{username},#{birthday},#{sex},#{address})
    </insert>

    <!-- 更新用户-->
    <update id="updateUser" parameterType="com.wink.domain.User">
        update user set username=#{username},birthday=#{birthday},sex=#{sex},address=#{address} where id = #{id}
    </update>

    <!--删除用户-->
    <delete id="deleteUser" parameterType="java.lang.Integer">
        delete from user where id=#{uid}
    </delete>

    <!-- 根据名称模糊查询-->
    <select id="findByName" parameterType="String" resultType="com.wink.domain.User">
        select * from user where username like #{username}
        <!--select * from user where username like '%${value}%'-->
    </select>

    <!-- 查询总记录数-->
    <select id="findtotal" resultType="Integer">
        select count(*) from user
    </select>
</mapper>

```

## 1.4 编写测试类

MybatisTest.java

```java
public class MybatisTest {

    private InputStream is;
    private SqlSession Sqlsession;
    private IUserDao userDao;

    @Before//用在测试方法执行之前
    public void init() throws Exception{
        //1.读取配置文件,生成字节流
        is = Resources.getResourceAsStream("SqlMapConfig.xml");
        //2.获取SqlSessionFactory
        SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(is);
        //3.获取SqlSession对象
        Sqlsession = factory.openSession();
        //4.获取dao的代理对象
        userDao = Sqlsession.getMapper(IUserDao.class);
    }

    @After//用在测试方法执行之后
    public void destory() throws Exception{
        //提交事务(不然操作不能正常执行)
        Sqlsession.commit();
        //6.释放资源
        Sqlsession.close();
        is.close();
    }

    @Test
    public void TestfindAll() {
        //5.使用代理对象执行方法
        List<User> users = userDao.findAll();
        for (User user : users) {
            System.out.println(user);
        }
    }

    @Test
    public void TestfindById(){
        System.out.println(userDao.findById(1));
    }

    @Test
    public void TestsaveUser(){
        User user = new User();
        user.setUsername("保存");
        user.setBirthday(new Date());
        user.setSex("男");
        user.setAddress("南京");
        System.out.println("保存之前"+user);
        //5.执行保存方法
        userDao.saveUser(user);
        System.out.println("保存之后"+user);
    }

    @Test
    public void TestupdateUser(){
        User user = userDao.findById(1);
        user.setSex("女");
        userDao.updateUser(user);
    }

    @Test
    public void TestdeleteUser(){
        userDao.deleteUser(9);
    }

    @Test
    public void TestfindByName(){
        List<User> users = userDao.findByName("%王%");
//        List<User> users = userDao.findByName("王");
        for (User user : users) {
            System.out.println(user);
        }
    }
    
    @Test
    public void Testfindtotal(){
        System.out.println("总条数="+userDao.findtotal());
    }
}

```

注意：

1.我们在实现增删改时一定要去控制事务的提交，Sqlsession.commit();否则会出现程序通过运行，却未改变数据
![](https://img-blog.csdnimg.cn/20200220220645653.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)

# 2.SqlMapConfig.xml配置文件

## 2.1 配置内容和顺序
```
-properties(属性)
	--property
-settings（全局配置参数）
	--setting
-typeAliases（类型别名） 
	--typeAliase
	--package
-typeHandlers（类型处理器） 
-objectFactory（对象工厂） 
-plugins（插件） 
-environments（环境集合属性对象）  
	--environment（环境子属性对象）   
		---transactionManager（事务管理）   
		---dataSource（数据源）
 -mappers（映射器）  
 	--mapper  
 	--package 
```

## 2.2 properties属性
```xml
<!-- 配置properties
    可以在标签内部配置连接数据库的信息。也可以通过属性引用外部配置文件信息
    resource属性： 常用的
        用于指定配置文件的位置，是按照类路径的写法来写，并且必须存在于类路径下。
    url属性：
        是要求按照Url的写法来写地址
        URL：Uniform Resource Locator 统一资源定位符。它是可以唯一标识一个资源的位置。
        它的写法：
            http://localhost:8080/mybatisserver/Servlet01
            协议      主机     端口       URI
        URI:Uniform Resource Identifier 统一资源标识符。它是在应用中可以唯一定位一个资源的。
-->
```

## 2.3 typeAliases（类型别名）
使用typeAliases配置别名，它只能配置实体类中类的别名
```xml
    <typeAliases>
        typeAlias用于配置别名。type属性指定的是实体类全限定类名。alias属性指定别名，当指定了别名就不再区分大小写
        <typeAlias type="com.wink.domain.User" alias="user"></typeAlias>
         /*用于指定要配置别名的包，当指定之后，该包下的实体类都会注册别名，并且类名就是别名，不再区分大小写
        	<package name="com.wink.domain"></package>
        */
    </typeAliases>
```

## 2.4 mappers（映射器）

* < mapper resource=" ">< /mapper>

使用相对类路径的资源，如：

< mapper resource=“com/wink/dao/IUserDaoMapper.xml”></ mapper>

* < mapper class=""></ mapper>
  
使用接口类路径，如：

< mapper class=“com.wink.dao.UserDao”></ mapper>

注意：此种方法要求 mapper 接口名称和 mapper 映射文件名称相同，且放在同一个目录中。

* < package name=" "/>

注册指定包下的所有 mapper 接口 ，如：

< package name=“com.wink.mybatis.mapper”/>

注意：此种方法要求 mapper 接口名称和 mapper 映射文件名称相同，且放在同一个目录中。

# 3.Mybatis的参数深入
## 3.1 parameterType配置参数

上面案例可以知道SQL 语句传参，使用标签的 parameterType 属性来设定。该属性的取值可以使基本类型，引用类型（例如：String类型），还可以是实体类型（POJO类），同时也可以使用实体类的包装类。

注意： 基本类型和 String 我们可以直接 写类型名称 ，也可以使用包名 . 类名的方式 ，例如 ： java.lang.String

实体类类型，目前只能使用全限定类名

是因为mybaits 在加载时已经把常用的数据类型注册了别名，从而我们在使用时可以不写包名， 而我们的是实体类并没有注册别名，所以必须写全限定类名

## 3.2 传递pojo包装对象
开发中通过 pojo 传递查询条件 ，查询条件是综合的查询条件，不仅包括用户查询条件还包括其它的查询条件，这时可以使用包装对象传递输入参数。 Pojo 类中包含 pojo。

通过下面案例展示：根据用户名查询用户信息，查询条件放到 QueryVo 的 user 属性中。

编写QueryVo.java
```java
public class QueryVo {
    private User user;

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
```

编写持久层接口
```java
	public interface IUserDao{
    	List<User> findUserByVo(QueryVo vo);
    }
```


持久层接口的映射文件
```xml
    <select id="findUserByVo" parameterType="com.wink.domain.QueryVo" resultType="com.wink.domain.User">
        select * from user where username like #{user.username}
    </select>
```

测试包装类作为参数
```java
    @Test
    public void testFindByQueryVo() {
        QueryVo vo = new QueryVo();
        User user = new User();
        user.setUsername("%王%");
        vo.setUser(user);
        List<User> users = userDao.findUserByVo(vo);
        for(User u : users) {
            System.out.println(u);  }
    }
```

结果如下
![](https://img-blog.csdnimg.cn/20200221172946336.png)