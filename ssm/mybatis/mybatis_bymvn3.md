
<!-- TOC -->

- [1.Mybatis的动态SQL语句](#1mybatis%e7%9a%84%e5%8a%a8%e6%80%81sql%e8%af%ad%e5%8f%a5)
  - [1.1 < if >标签](#11--if-%e6%a0%87%e7%ad%be)
  - [1.2 < where >标签](#12--where-%e6%a0%87%e7%ad%be)
  - [1.3 < foreach >标签](#13--foreach-%e6%a0%87%e7%ad%be)
- [2.Mybatis多表查询（一对多）](#2mybatis%e5%a4%9a%e8%a1%a8%e6%9f%a5%e8%af%a2%e4%b8%80%e5%af%b9%e5%a4%9a)
  - [2.1 一对一查询](#21-%e4%b8%80%e5%af%b9%e4%b8%80%e6%9f%a5%e8%af%a2)
  - [2.2 一对多查询](#22-%e4%b8%80%e5%af%b9%e5%a4%9a%e6%9f%a5%e8%af%a2)
- [3.Mybatis多表查询（多对多）](#3mybatis%e5%a4%9a%e8%a1%a8%e6%9f%a5%e8%af%a2%e5%a4%9a%e5%af%b9%e5%a4%9a)
  - [3.1 角色到用户](#31-%e8%a7%92%e8%89%b2%e5%88%b0%e7%94%a8%e6%88%b7)
  - [3.2 用户到角色](#32-%e7%94%a8%e6%88%b7%e5%88%b0%e8%a7%92%e8%89%b2)

<!-- /TOC -->

# 1.Mybatis的动态SQL语句
在上一章节里，Mybatis的映射文件中的SQL都是比较简单的，有时候业务逻辑复杂时，就需要使用动态的SQL语句。
## 1.1 < if >标签
我们根据实体类的不同取值，使用不同的 SQL 语句来进行查询。比如在 id 如果不为空时可以根据 id 查询， 如果 username 不同空时还要加入用户名作为条件。这种情况在我们的多条件组合查询中经常会碰到。


持久层Dao接口
```java

    /**
     * 根据用户信息。查询用户列表
     * @param user 
     * @return
     */
    List<User> findUserByCondition(User user);
```
持久层Dao映射配置
```
    <select id="findUserByCondition" parameterType="user" resultType="user">
        select * from user where 1=1
            <if test="username != null">
                and username = #{username}
            </if>
            <if test="sex != null">
                and sex = #{sex}
            </if>
    </select>
```

测试

```java
    @Test
    public void testFindByCondition(){
        User u = new User();
        u.setUsername("老王");
        u.setSex("男");
        List<User> users = userDao.findUserByCondition(u);
        for (User user : users) {
            System.out.println(user);
        }
    }
```

## 1.2 < where >标签
为了简化上面 where 1=1 的条件拼装，我们可以采用标签来简化开发


持久层Dao映射配置：
```xml
    <select id="findUserByCondition" parameterType="user" resultType="user">
        select * from user
        <where>
            <if test="username != null">
                and username = #{username}
            </if>
            <if test="sex != null">
                and sex = #{sex}
            </if>
        </where>
    </select>
```

## 1.3 < foreach >标签
* SQL 语句： select 字段 from user where id in (?)

< foreach >标签用于遍历集合，它的属性：

collection:代表要遍历的集合元素，注意编写时不要写#{}

open:代表语句的开始部分

close:代表结束部分

item:代表遍历集合的每个元素，生成的变量名

sperator:代表分隔符

* 在QueryVo中加入一个List集合用于封装参数

```java
public void QueryVo implements Seriazable{
	private List<Integer> ids;

    public List<Integer> getIds() {
        return ids;
    }

    public void setIds(List<Integer> ids) {
        this.ids = ids;
    }
}
```

持久层Dao接口
```java
	//根据id集合查询用户
    List<User> findInds(QueryVo vo);
```

持久层Dao映射配置
```xxml
    <!--根据queryVo中的Id集合实现查询用户列表-->
    <select id="findInds" resultType="user" parameterType="com.wink.domain.QueryVo">
    <!--select * from user where id in (1,2,3,4,5); --> 
        select * from user
        <where>
            <if test="ids != null and ids.size()>0">
                <foreach collection="ids" open="and id in(" close=")" item="uid" separator=",">
                    #{uid}<!--此处和上面的item对应-->
                </foreach>
            </if>
        </where>
    </select>
```

编写测试方法
```java
    @Test
    public void testFindInIds(){
        QueryVo vo = new QueryVo();
        List<Integer> list = new ArrayList<Integer>();
        list.add(1);
        list.add(2);
        list.add(5);
        vo.setIds(list);
        List<User> users = userDao.findInds(vo);
        for (User user : users) {
            System.out.println(user);
        }
    }
```

运行结果


Sql 中可将重复的 sql 提取出来，使用时用 include 引用即可，最终达到 sql 重用的目的。
定义代码片段
```xml
    <sql id="defaultSql">
        select * from user
    </sql>
```


引用代码片段
```xml
    <!-- 根据id查询用户 -->
    <select id="findById" parameterType="int" resultType="user">
        <!--select * from user where id = #{uid}-->
        <include refid="defaultSql"></include>
        where id = #{uid}
    </select>
```

# 2.Mybatis多表查询（一对多）
本次案例主要以最为简单的用户和账户的模型来分析Mybatis多表关系。用户为User 表，账户为Account 表。一个用户（User）可以有多个账户（Account）。具体关系如下：


user表使用之前创建的，下面是account表的SQL代码：


```sql
CREATE TABLE `account` (
  `id` int(11) NOT NULL COMMENT '编号',
  `uid` int(11) default NULL COMMENT '用户编号',
  `money` double default NULL COMMENT '金额',
  PRIMARY KEY  (`id`),
  KEY `FK_Reference_8` (`uid`),
  CONSTRAINT `FK_Reference_8` FOREIGN KEY (`uid`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert  into `account`(`id`,`uid`,`money`) values (11,3,1000),(12,5,1000),(13,3,2000);
```

## 2.1 一对一查询
需求 ：查询所有账户信息，关联查询下单用户信息。

注意： 因为一个账户信息只能供某个用户使用，所以从查询账户信息出发关联查询用户信息为一对一查询。如 果从用户信息出发查询用户下的账户信息则为一对多查询，因为一个用户可以有多个账户。

使用 resultMap，定义专门的 resultMap 用于映射一对一查询结果。 通过面向对象的(has a)关系可以得知，我们可以在 Account 类中加入一个 User 类的对象来代表这个账户 是哪个用户的。

1）编写sql
```sql
 select u.*,a.id as aid,a.uid,a.money from account a , user u where u.id = a.uid;
```

2）定义账户信息的实体类 ，在Account类中加入User类的对象作为Account类的一个属性。
```java
public class Account implements Serializable {
    private Integer id;
    private Integer uid;
    private Double money;
    private User user;

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
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

定义IAccountDao接口
```java
public interface IAccountDao {
    List<Account> findAll();
}
```

定义AccountDao.xml文件

```xml
<mapper namespace="com.wink.dao.IAccountDao">
    <!-- 定义封装account和user的resultMap -->
    <resultMap id="accountMap" type="account">
        <id property="id" column="aid"></id>
        <result property="uid" column="uid"></result>
        <result property="money" column="money"></result>
        <!-- 一对一的关系映射：配置封装user的内容-->
        <association property="user" javaType="user">
            <id property="id" column="id"></id>
            <result column="username" property="username"></result>
            <result column="address" property="address"></result>
            <result column="sex" property="sex"></result>
            <result column="birthday" property="birthday"></result>
        </association>
    </resultMap>
    <!-- 查询所有 -->
    <select id="findAll" resultMap="accountMap">
        select a.id as aid,a.uid,a.money,u.* from user u, account a  where u.id = a.uid;
    </select>
</mapper>
```

进行测试

```java
    @Test
    public void testFindAll(){
        List<Account> accounts = accountDao.findAll();
        for(Account account : accounts){
            System.out.println("--------每个account的信息-----------");
            System.out.println(account);
            System.out.println(account.getUser());
        }
    }
```

运行结果如下：


## 2.2 一对多查询
需求： 查询所有用户信息及用户关联的账户信息。 分析： 用户信息和他的账户信息为一对多关系，并且查询过程中如果用户没有账户信息，此时也要将用户信息查询出来。

1.编写Sql语句
```sql
SELECT
	u.*, acc.id id,
	acc.uid,
	acc.money
FROM
	USER u
LEFT JOIN account acc ON u.id = acc.uid
```



2.User类加入List< Account>


```java
public class User implements Serializable {
    private Integer id;
    private String username;
    private Date birthday;
    private String sex;
    private String address;
    private List<Account> accounts;

    public List<Account> getAccounts() {
        return accounts;
    }

    public void setAccounts(List<Account> accounts) {
        this.accounts = accounts;
    }

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

3.用户持久层 Dao 接口中加入查询方法

```java
public interface IUserDao {
    List<User> findAll();
}
```

4.用户持久层 Dao 映射文件配置
```xml
    <!--定义User的resultMap-->
    <resultMap id="userMap" type="user">
        <id property="id" column="id"></id>
        <result property="username" column="username"></result>
        <result property="birthday" column="birthday"></result>
        <result property="sex" column="sex"></result>
        <result property="address" column="address"></result>
        <!--配置user对象中的account集合的映射-->
        <!-- collection 是用于建立一对多中集合属性的对应关系
             ofType 用于指定集合元素的数据类型    -->
        <collection property="accounts" ofType="account">
            <id property="aid" column="id"></id>
            <result property="uid" column="uid"></result>
            <result property="money" column="money"></result>
        </collection>
    </resultMap>
    <!-- 查询所有 -->
    <select id="findAll" resultMap="userMap">
        select * from user u left outer join account a on u.id = a.uid
    </select>
</mapper>

```

5.进行测试
```java
    @Test
    public void testFindAll(){
        List<User> users = userDao.findAll();
        for(User user : users){
            System.out.println("--------每个User的信息----------");
            System.out.println(user);
            System.out.println(user.getAccounts());
        }
    }
```

运行结果


# 3.Mybatis多表查询（多对多）
## 3.1 角色到用户
下面通过用户和角色的关系模型演示Mybatis多表查询多对多操作


创建角色表和用户角色中间表
```sql
CREATE TABLE `role` (
  `id` int(11) NOT NULL COMMENT '编号',
  `role_name` varchar(30) default NULL COMMENT '角色名称',
  `role_desc` varchar(60) default NULL COMMENT '角色描述',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert  into `role`(`id`,`role_name`,`role_desc`) values (1,'院长','管理整个学院'),(2,'总裁','管理整个公司'),(3,'校长','管理整个学校');

CREATE TABLE `user_role` (
  `uid` int(11) NOT NULL COMMENT '用户编号',
  `rid` int(11) NOT NULL COMMENT '角色编号',
  PRIMARY KEY  (`uid`,`rid`),
  KEY `FK_Reference_10` (`rid`),
  CONSTRAINT `FK_Reference_10` FOREIGN KEY (`rid`) REFERENCES `role` (`id`),
  CONSTRAINT `FK_Reference_9` FOREIGN KEY (`uid`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert  into `user_role`(`uid`,`rid`) values (3,1),(5,1),(3,2);

```

1）实现查询所有角色并加载它所分配的用户信息
通过数据库查询可以得到如下结果：

```sql
select r.id as rid,r.role_name,r.role_desc,u.* from role r
left outer join user_role ur  on r.id = ur.rid
left outer join user u on u.id = ur.uid
```


2）编写角色实体类

```java
public class Role implements Serializable {
    private Integer roleId;
    private String roleName;
    private String roleDesc;
    //多对多的关系映射：一个角色可以赋予多个用户
    private List<User> users;

    public List<User> getUsers() {
        return users;
    }

    public void setUsers(List<User> users) {
        this.users = users;
    }

    public Integer getRoleId() {
        return roleId;
    }

    public void setRoleId(Integer roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getRoleDesc() {
        return roleDesc;
    }

    public void setRoleDesc(String roleDesc) {
        this.roleDesc = roleDesc;
    }

    @Override
    public String toString() {
        return "Role{" +
                "roleId=" + roleId +
                ", roleName='" + roleName + '\'' +
                ", roleDesc='" + roleDesc + '\'' +
                '}';
    }
}
```

编写 Role 持久层接口 ，定义一个查询所有的方法

```java
public interface IRoleDao {
    List<Role> findAll();
}
```


编写映射文件

```xml
<mapper namespace="com.wink.dao.IRoleDao">
    <!--定义 role 表的 ResultMap-->
    <resultMap id="roleMap" type="role">
        <id property="roleId" column="rid"></id>
        <result property="roleName" column="role_name"></result>
        <result property="roleDesc" column="role_desc"></result>
        <collection property="users" ofType="user">
            <id property="id" column="id"></id>
            <result property="username" column="username"></result>
            <result property="birthday" column="birthday"></result>
            <result property="sex" column="sex"></result>
            <result property="address" column="role_addressname"></result>
        </collection>
    </resultMap>
    <!--查询所有-->
    <select id="findAll" resultMap="roleMap">
        select r.id as rid,r.role_name,r.role_desc,u.* from role r
        left outer join user_role ur  on r.id = ur.rid
        left outer join user u on u.id = ur.uid
    </select>
</mapper>
```

进行测试
```java
    @Test
    public void testRoleFindAll(){
        List<Role> roles =roleDao.findAll();
        for (Role role : roles) {
            System.out.println("--------每个角色附用户的信息----------");
            System.out.println(role);
            System.out.println(role.getUsers());
        }
    }
```
可以看到运行结果和前面sql查询得到结果一致


## 3.2 用户到角色
同样的，从用户出发，一个用户可以有多个角色，实现查询所有用户信息并关联查询出每个用户的角色列表

首先需要在User实体类中添加和角色映射关系：
```java

    private List<Role> roles;

    public List<Role> getRoles() {
        return roles;
    }
    public void setRoles(List<Role> roles) {
        this.roles = roles;
    }
```

然后在持久层映射文件中配置角色集合的映射和查询分sql语句

```xml
    <select id="findAll" resultMap="userMap">
        select u.*,r.id as rid,r.role_name,r.role_desc from user u
         left outer join user_role ur  on u.id = ur.uid
         left outer join role r on r.id = ur.rid
    </select>
```

最后编写测试类进行测试

```java

    @Test
    public void testFindAll(){
        List<User> users = userDao.findAll();
        for(User user : users){
            System.out.println("-----每个用户和角色的信息------");
            System.out.println(user);
            System.out.println(user.getRoles());
        }
    }
```
