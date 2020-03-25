
<!-- TOC -->

- [1. mybatis延迟加载](#1-mybatis延迟加载)
    - [1.1 使用assocation实现延迟加载](#11-使用assocation实现延迟加载)
    - [1.2 使用Collection实现延迟加载](#12-使用collection实现延迟加载)
- [2.mybatis缓存](#2mybatis缓存)
    - [2.1 一级缓存](#21-一级缓存)
    - [2.2 二级缓存](#22-二级缓存)
- [3.mybatis注解开发](#3mybatis注解开发)
    - [3.1 使用mybatis注解实现基本CRUD](#31-使用mybatis注解实现基本crud)
    - [3.2 使用注解实现复杂关系映射开发](#32-使用注解实现复杂关系映射开发)
        - [3.2.1 复杂关系映射的注解说明](#321-复杂关系映射的注解说明)
        - [3.2.2 使用注解实现一对多复杂关系映射](#322-使用注解实现一对多复杂关系映射)
    - [3.3 mybatis基于注解的二级缓存](#33-mybatis基于注解的二级缓存)

<!-- /TOC -->

# 1. mybatis延迟加载
什么是延迟加载？

__延迟加载__： 就是在需要用到数据时才进行加载，不需要用到数据时就不加载数据。延迟加载也称懒加载。

**优点**：先从单表查询，需要时再从关联表去关联查询，大大提高数据库性能，因为查询单表要比关联查询多张表速 度要快。

**缺点**： 因为只有当需要用到数据时，才会进行数据库查询，这样在大批量数据查询时，因为查询工作也要消耗 时间，所以可能造成用户等待时间变长，造成用户体验下降。

- 注意：延迟加载的应用要求：关联对象的查询与主加载对象的查询必须是分别进行的select语句，不能是使用多表连接所进行的select查询。因为，多表连接查询，实质是对一张表的查询，对由多个表连接后形成的一张表的查询。会一次性将多张表的所有信息查询出来。
  
mybatis可以使用assocation和collection 实现延迟加载

assocation通常用来映射一对一的关系

collection 通常用来映射一对多的关系


*.jpg*
![](https://img-blog.csdnimg.cn/20200224113131557.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)

根据mybatis官方文档可以知道，我们需要在SqlMapConfig.xml中添加延迟加载的配置，开启Mybatis延迟加载的支持
```xml
    <settings>
        <!--开启Mybatis支持延迟加载-->
        <setting name="lazyLoadingEnabled" value="true"/>
        <setting name="aggressiveLazyLoading" value="false"/>
    </settings>
```

## 1.1 使用assocation实现延迟加载
编写实体类持久层的映射配置文件

```xml
<mapper namespace="com.wink.dao.IAccountDao">
    <resultMap id="accountUserMap" type="account">
        <id property="id" column="id"></id>
        <result property="uid" column="uid"></result>
        <result property="money" column="money"></result>
        
        <!-- select属性指定的内容：查询用户的唯一标识：
        column属性指定的内容：用户根据id查询时，所需要的参数的值-->
        <association 
        property="user" column="uid" javaType="user"
        select="com.wink.dao.IUserDao.findById">
        </association>
    </resultMap>

    <!-- 根据用户id查询账户列表 -->
    <select id="findAccountByUid" resultType="account">
        select * from account where uid = #{uid}
    </select>
</mapper>
```

## 1.2 使用Collection实现延迟加载
编写实体类持久层的映射配置文件

```xml
<mapper namespace="com.wink.dao.IUserDao">
    <resultMap id="userAccountMap" type="user">
        <id property="id" column="id"></id>
        <result property="username" column="username"></result>
        <result property="address" column="address"></result>
        <result property="sex" column="sex"></result>
        <result property="birthday" column="birthday"></result>
        
        <!-- collection 是用于建立一对多中集合属性的对应关系   
         ofType 用于指定集合元素的数据类型   
         select 是用于指定查询的唯一标识（dao全限定类名加上方法名称）    
         column 是用于指定使用哪个字段的值作为条件查询--> 
        <collection 
	        property="accounts" ofType="account" column="id"
	        select="com.wink.dao.IAccountDao.findAccountByUid" >
        </collection>
    </resultMap>
    
    <!-- 根据id查询用户 -->
    <select id="findById" parameterType="INT" resultType="user">
        select * from user where id = #{uid}
    </select>
```

# 2.mybatis缓存
Mybatis中的缓存分为一级缓存和二级缓存

![](https://img-blog.csdnimg.cn/20200224114440470.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)


* 一级缓存：它指的是Mybatis中SqlSession对象的缓存。当我们执行查询之后，查询的结果会同时存入到SqlSession为我们提供一块区域中。该区域的结构是一个Map。当我们再次查询同样的数据，mybatis会先去sqlsession中查询是否有，有的话直接拿出来用。当SqlSession对象消失时，mybatis的一级缓存也就消失了。

* 二级缓存: 它指的是Mybatis中SqlSessionFactory对象的缓存。由同一个SqlSessionFactory对象创建的SqlSession共享其缓存。
 
二级缓存的使用步骤：

第一步：让Mybatis框架支持二级缓存（如:SqlMapConfig.xml中配置）

第二步：让当前的映射文件支持二级缓存（如：IUserDao.xml中配置）

第三步：让当前的操作支持二级缓存（如：select标签中配置）


## 2.1 一级缓存
一级缓存是 SqlSession 范围的缓存，当调用 SqlSession 的修改，添加，删除，commit()，close()等方法时，就会清空一级缓存。
![](https://img-blog.csdnimg.cn/20200224115102106.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)

第一次发起查询用户 id 为 1 的用户信息，先去找缓存中是否有 id 为 1 的用户信息，如果没有，从数据库查 询用户信息。得到用户信息，将用户信息存储到一级缓存中。

       如果 sqlSession 去执行 commit 操作（执行插入、更新、删除），清空 SqlSession 中的一级缓存，这样 做的目的为了让缓存中存储的是最新的信息，避免脏读。

       第二次发起查询用户 id 为 1 的用户信息，先去找缓存中是否有 id 为 1 的用户信息，缓存中有，直接从缓存 中获取用户信息。

使用sqlSession的clearCache()方法可以清空缓存


## 2.2 二级缓存
二级缓存是 mapper 映射级别的缓存，多个 SqlSession 去操作同一个 Mapper 映射的 sql 语句，多个 SqlSession 可以共用二级缓存，二级缓存是跨 SqlSession 的。

![](https://img-blog.csdnimg.cn/20200224115736445.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)

      首先开启 mybatis 的二级缓存。

      sqlSession1 去查询用户信息，查询到用户信息会将查询数据存储到二级缓存中。

      如果 SqlSession3 去执行相同 mapper 映射下 sql，执行 commit 提交，将会清空该 mapper 映射下的二 级缓存区域的数据。

      sqlSession2 去查询与 sqlSession1 相同的用户信息，首先会去缓存中找是否存在数据，如果存在直接从 缓存中取出数据。

二级缓存的开启与关闭

1）在SqlMapConfig.xml文件开启二级缓存
```xml
    <!-- 开启二级缓存的支持 -->
    <settings>
        <setting name="cacheEnabled" value="true"/>
    </settings>
```

2）配置相关的Mapper映射文件

```xml
<mapper namespace="com.wink.dao.IUserDao">
    <!--开启user支持二级缓存-->
    <cache></cache>
    
    <sql id="defaultSql">
        select * from user
    </sql>
    <!-- 根据id查询用户 -->
    <!--设置 useCache=”true”代表当前这个 statement 要使用 二级缓存，如果不使用二级缓存可以设置为 false。 -->
    <select id="findById" resultType="user" parameterType="int" useCache="true">
        <include refid="defaultSql"></include>
         where id = #{uid}
    </select>
</mapper>
```


3）二级缓存测试
```java

    @Test
    public void testCache(){
        //5.执行操作
        SqlSession sqlSession1 = factory.openSession();
        IUserDao dao1 = sqlSession1.getMapper(IUserDao.class);
        User user1 = dao1.findById(1);
        System.out.println(user1);
        sqlSession1.close();//一级缓存消失

        SqlSession sqlSession2 = factory.openSession();
        IUserDao dao2 = sqlSession2.getMapper(IUserDao.class);
        User user2 = dao2.findById(1);
        System.out.println(user2);
        sqlSession2.close();
        System.out.println(user1 == user2);
    }
```


![](https://img-blog.csdnimg.cn/2020022414010640.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)
经过上面的测试，我们发现执行了两次查询，并且在执行第一次查询后，我们关闭了一级缓存，再去执行第二 次查询时，我们发现并没有对数据库发出 sql 语句，所以此时的数据就只能是来自于我们所说的二级缓存。

# 3.mybatis注解开发

mybatis常用注解：

@Insert:实现新增

@Update:实现更新

@Delete:实现删除

@Select:实现查询

@Result:实现结果集封装

@Results:可以与@Result 一起使用，封装多个结果集

@ResultMap :实现引用@Results 定义的封装

@One:实现一对一结果集封装

@Many:实现一对多结果集封装

@SelectProvider: 实现动态 SQL 映射

@CacheNamespace:实现注解二级缓存的使用


## 3.1 使用mybatis注解实现基本CRUD
编写实体类
```java
public class User implements Serializable {
    private Integer userId;
    private String userName;
    private String userSex;
    private Date userBirthday;
    private String userAddress;

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserSex() {
        return userSex;
    }

    public void setUserSex(String userSex) {
        this.userSex = userSex;
    }

    public Date getUserBirthday() {
        return userBirthday;
    }

    public void setUserBirthday(Date userBirthday) {
        this.userBirthday = userBirthday;
    }

    public String getUserAddress() {
        return userAddress;
    }

    public void setUserAddress(String userAddress) {
        this.userAddress = userAddress;
    }

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", userName='" + userName + '\'' +
                ", userSex='" + userSex + '\'' +
                ", userBirthday=" + userBirthday +
                ", userAddress='" + userAddress + '\'' +
                '}';
    }
}

```


使用注解实现持久层接口

```java
public interface IUserDao {
    //查询所有用户
    @Select("select * from user")
    @Results(id = "userMap",value = {
            @Result(id = true,column = "id",property = "userId"),
            @Result(column = "username",property = "userName"),
            @Result(column = "sex",property = "userSex"),
            @Result(column = "address",property = "userAddress"),
            @Result(column = "birthday",property = "userBirthday")
    })
    List<User> findAll();

    //根据 id 查询一个用户
    @Select("select * from user where id = #{uid}")
    @ResultMap("userMap")
    User findById(Integer userId);

    //保存操作
    @Insert("insert into user(username,sex,birthday,address)values(#{userName},#{userSex},#{userBirthday},#{userAddress})")
    @SelectKey(keyColumn = "id",keyProperty = "userId",resultType = Integer.class,
            before = false,statement = {"select last_insert_id()"})
    int saveUser(User user);
    
    //更新操作
    @Update("update user set username = #{userName},sex = #{userSex},birthday = #{userBirthday},address = #{userAddress} where id=#{userId}")
    void updateUser(User user);

    //删除用户
    @Delete("delete from user where id = #{uid}")
    int deleteUser(Integer userId);

    //查询使用聚合函数
    @Select("select count(*) from user")
    int findTotal();

    //模糊查询
    @Select("select * from user where username like #{userName}")
    List<User> findByName(String name);
}
```

上面内容有以下几点需要注意：

1）由于实体类中和数据库表的列名不同，在此处使用别名的方式，使用@Results和@Result注解进行配置

2）在保存操作中，@SelectKey注解非必须，此处是为了演示生成主键的操作。

SelectKey的两大作用：生成主键 和 获取刚刚插入数据的主键;

statement是要运行的SQL语句，它的返回值通过resultType来指定；

before表示查询语句statement运行的时机；

keyProperty表示查询结果赋值给代码中的哪个对象，keyColumn表示将查询结果赋值给数据库表中哪一列

before=true，插入之前进行查询，可以将查询结果赋给keyProperty和keyColumn，赋给keyColumn相当于更改数据库（不推荐使用）

before=false，先插入，再查询，这时只能将结果赋给keyProperty


编写SqlMapConfig配置文件

```xml
<configuration>
    <properties resource="jdbcConfig.properties"/>

    <typeAliases>
        <package name="com.wink.domain"/>
    </typeAliases>

    <environments default="mysql">
        <environment id="mysql">
            <transactionManager type="JDBC"></transactionManager>
            <dataSource type="POOLED">
                <property name="driver" value="${jdbc.driver}"/>
                <property name="url" value="${jdbc.url}"/>
                <property name="username" value="${jdbc.username}"/>
                <property name="password" value="${jdbc.password}"/>
            </dataSource>
        </environment>
    </environments>

    <mappers>
        <package name="com.wink.dao"/>
    </mappers>
</configuration>
```

编写测试方法

```java
public class AnnocationTest {
    private InputStream is;
    private SqlSessionFactory factory;
    private SqlSession session;
    private IUserDao userDao;

    @Before
    public void init() throws Exception{
        is = Resources.getResourceAsStream("SqlMapConfig.xml");
        factory = new SqlSessionFactoryBuilder().build(is);
        session = factory.openSession();
        userDao = session.getMapper(IUserDao.class);
    }

    @After
    public void destory() throws Exception{
        session.commit();
        session.close();
        is.close();
    }
    @Test
    public void testFindAll(){
        List<User> users = userDao.findAll();
        for (User user : users) {
            System.out.println(user);
        }
    }

    @Test
    public void testfindById(){
        System.out.println(userDao.findById(2));
    }

    @Test
    public void testsaveUser(){
        User user = new User();
        user.setUserName("annocation");
        user.setUserSex("男");
        user.setUserAddress("广西南宁");
        user.setUserBirthday(new Date());
        int rows = userDao.saveUser(user);
        System.out.println("影响数据库记录的行数:"+rows);
        System.out.println("插入的主键值："+user.getUserId());
    }

    @Test
    public void testupdate(){
        User user = userDao.findById(1);
        user.setUserName("好饿呀");
    }

    @Test
    public void testDelete(){
        int res = userDao.deleteUser(5);
        System.out.println(res);
    }

    @Test
    public void testfindTotal(){
        int res = userDao.findTotal();
        System.out.println(res);
    }

    @Test
    public void testFindByName(){
        List<User> users = userDao.findByName("%王%");
        for (User user:users){
            System.out.println(user);
        }
    }
}
```


## 3.2 使用注解实现复杂关系映射开发
### 3.2.1 复杂关系映射的注解说明

* @Results 注解

    代替的是标签< resultMap>

    该注解中可以使用单个@Result 注解，也可以使用@Result 集合

    @Results（{@Result（），@Result（）}）或@Results（@Result（））


* @Result 注解

    代替了 < id>标签和< result>标签

    @Result 中 属性介绍：

           id 是否是主键字段

           column 数据库的列名

           property 需要装配的属性名

           one 需要使用的@One 注解（@Result ( one=@One) ( ) ) )

           many 需要使用的@Many 注解（@Result ( many=@many) ( ) ) )

* @One注解（一对一）
代替了标签，是多表查询的关键，在注解中用来指定子查询返回单一对象。

    One注解属性介绍：

    select 指定用来多表查询的 sqlmapper

    fetchType 会覆盖全局的配置参数 lazyLoadingEnabled。。

    使用格式：@Result(column=" “,property=”",one=@One(select=""))


* @Many注解（多对一）
    代替了标签,是是多表查询的关键，在注解中用来指定子查询返回对象集合。
    <div style="color:red">     
    注意：聚集元素用来处理“一对多”的关系。需要指定映射的 Java 实体类的属性，属性的 javaType （一般为 ArrayList）但是注解中可以不定义;
    </div>

    使用格式：@Result(property="",column="",many=@Many(select=""))


### 3.2.2 使用注解实现一对多复杂关系映射
需求：

       查询用户信息时，也要查询他的账户列表。使用注解方式实现。

分析：

       一个用户具有多个账户信息，所以形成了用户(User)与账户(Account)之间的一对多关系。


创建Account实体类
```java
public class Account implements Serializable {
    private Integer id;
    private Integer uid;
    private Double money;
    //多对一关系映射：从表方应该包含一个主表方的对象引用
    private User user;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUid() {
        return uid;
    }

    public void setUid(Integer uid) {
        this.uid = uid;
    }

    public Double getMoney() {
        return money;
    }

    public void setMoney(Double money) {
        this.money = money;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @Override
    public String toString() {
        return "Account{" +
                "id=" + id +
                ", uid=" + uid +
                ", money=" + money +
                '}';
    }
}

```


在User实体类加入List< Account>

```java
    //一对多关系映射：主表方法应该包含一个从表方的集合引用
    private List<Account> accounts;

    public List<Account> getAccounts() {
        return accounts;
    }

    public void setAccounts(List<Account> accounts) {
        this.accounts = accounts;
    }


```

编写用户的持久层接口并使用注解配置

```java
@CacheNamespace(blocking = true)
public interface IUserDao {

    //查询所有用户
    @Select("select * from user")
    @Results(id="userMap",value={
            @Result(id=true,column = "id",property = "userId"),
            @Result(column = "username",property = "userName"),
            @Result(column = "address",property = "userAddress"),
            @Result(column = "sex",property = "userSex"),
            @Result(column = "birthday",property = "userBirthday"),
            @Result(property = "accounts",column = "id",
                    many = @Many(select = "com.wink.dao.IAccountDao.findAccountByUid",
                            fetchType = FetchType.LAZY))
    })
    List<User> findAllUser();

    //根据id查询用户
    @Select("select * from user  where id=#{id} ")
    @ResultMap("userMap")
    User findById(Integer userId);
}
```


编写账户的持久层接口并使用注解配置

```java
public interface IAccountDao {
    //查询所有账户，并且获取每个账户所属的用户信息
    @Select("select * from account")
    @Results(id="accountMap",value = {
            @Result(id=true,column = "id",property = "id"),
            @Result(column = "uid",property = "uid"),
            @Result(column = "money",property = "money"),
            @Result(property = "user",column ="uid",
            one = @One(select="com.wink.dao.IUserDao.findById",fetchType= FetchType.EAGER))
    })
    List<Account> findAllAccount();

    // 根据用户id查询账户信息
    @Select("select * from account where uid = #{userId}")
    List<Account> findAccountByUid(Integer userId);


```


添加测试方法

```java
public class AnnocationTest {
    private InputStream is;
    private SqlSessionFactory factory;
    private SqlSession session;
    private IUserDao userDao;
    private IAccountDao accountDao;

    @Before
    public void init() throws Exception{
        is = Resources.getResourceAsStream("SqlMapConfig.xml");
        factory = new SqlSessionFactoryBuilder().build(is);
        session = factory.openSession();
        userDao = session.getMapper(IUserDao.class);
        accountDao = session.getMapper(IAccountDao.class);
    }

    @After
    public void destory() throws Exception{
        session.commit();
        session.close();
        is.close();
    }

    @Test
    public void testfindAllU(){
        List<User> users = userDao.findAllUser();
        for (User user : users) {
            System.out.println("-----每个用户的内容-----");
            System.out.println(user);
            System.out.println(user.getAccounts());
        }
    }

    @Test
    public void testfindAllA(){
        List<Account> accounts = accountDao.findAllAccount();
        for (Account account : accounts) {
            System.out.println("-----每个用户的内容-----");
            System.out.println(account);
            System.out.println(account.getUser());
        }
    }
}

```

运行结果：
![](https://img-blog.csdnimg.cn/20200224210327227.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/20200224210351557.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxNDYwMzgz,size_16,color_FFFFFF,t_70)

## 3.3 mybatis基于注解的二级缓存

在 SqlMapConfig 中开启二级缓存支持
```xml
<!-- 配置二级缓存 -->
 <settings> 
	 <!-- 开启二级缓存的支持 -->  
 	 <setting name="cacheEnabled" value="true"/>
  </settings>

```

在持久层接口中使用注解配置二级缓存
```java
@CacheNamespace(blocking=true)//mybatis 基于注解方式实现配置二级缓存 
```