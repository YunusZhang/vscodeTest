<!-- TOC -->

- [第3章 MyBatis全局配置文件](#第3章-mybatis全局配置文件)
    - [3.1 MyBatis全局配置文件简介](#31-mybatis全局配置文件简介)
    - [3.2 properties属性](#32-properties属性)
    - [3.3 settings设置](#33-settings设置)
    - [3.4 typeAliases 别名处理](#34-typealiases-别名处理)
    - [3.5 environments 环境配置](#35-environments-环境配置)
    - [3.6 mappers 映射器](#36-mappers-映射器)

<!-- /TOC -->

#第3章 MyBatis全局配置文件
##3.1 MyBatis全局配置文件简介
	• The MyBatis configuration contains settings and properties that have a dramatic effect on how MyBatis behaves. 
MyBatis 的配置文件包含了影响 MyBatis 行为甚深的设置（settings）和属性（properties）信息。
	• 文件结构如下:
	configuration 配置 
		properties 属性
		settings 设置
		typeAliases 类型命名
		typeHandlers 类型处理器
		objectFactory 对象工厂
		plugins 插件
		environments 环境 
		environment 环境变量 
			transactionManager 事务管理器
			dataSource 数据源
		databaseIdProvider 数据库厂商标识
		mappers 映射器


##3.2 properties属性 
	• 可外部配置且可动态替换的，既可以在典型的 Java 属性文件中配置，亦可通过 properties 元素的子元素来配置
```xml
    <properties>
	     <property name="driver" value="com.mysql.jdbc.Driver" />
	     <property name="url" 
	             value="jdbc:mysql://localhost:3306/test_mybatis" />
	     <property name="username" value="root" />
	     <property name="password" value="1234" />
	 </properties>
```
	• 然而properties的作用并不单单是这样，你可以创建一个资源文件，名为jdbc.properties的文件,将四个连接字符串的数据在资源文件中通过键值 对(key=value)的方式放置，不要任何符号，一条占一行
	jdbc.driver=com.mysql.jdbc.Driver
	jdbc.url=jdbc:mysql://localhost:3306/mybatis_1129
	jdbc.username=root
	jdbc.password=1234


<!-- 
properties: 引入外部的属性文件
resource: 从类路径下引入属性文件 
url:  引入网络路径或者是磁盘路径下的属性文件
-->
```xml
<properties resource="db.properties" ></properties>
```

3)在environment元素的dataSource元素中为其动态设置
```xml
<environments default="oracle">
<environment id="mysql">
<transactionManager type="JDBC" />
<dataSource type="POOLED">
<property name="driver" value="${jdbc.driver}" />
<property name="url" value="${jdbc.url}" />
<property name="username" value="${jdbc.username}" />
<property name="password" value="${jdbc.password}" />
</dataSource>
</environment>
</environments>
```

##3.3 settings设置
	• 这是 MyBatis 中极为重要的调整设置，它们会改变 MyBatis 的运行时行为。
	• 包含如下的setting设置:
```xml
	<settings>
	<setting name="cacheEnabled" value="true"/>
	<setting name="lazyLoadingEnabled" value="true"/>
	<setting name="multipleResultSetsEnabled" value="true"/>
	<setting name="useColumnLabel" value="true"/>
	<setting name="useGeneratedKeys" value="false"/>
	<setting name="autoMappingBehavior" value="PARTIAL"/>
	<setting name="autoMappingUnknownColumnBehavior" value="WARNING"/>
	<setting name="defaultExecutorType" value="SIMPLE"/>
	<setting name="defaultStatementTimeout" value="25"/>
	<setting name="defaultFetchSize" value="100"/>
	<setting name="safeRowBoundsEnabled" value="false"/>
	<setting name="mapUnderscoreToCamelCase" value="false"/>
	<setting name="localCacheScope" value="SESSION"/>
	<setting name="jdbcTypeForNull" value="OTHER"/>
	<setting name="lazyLoadTriggerMethods"
	           value="equals,clone,hashCode,toString"/>
	</settings>

```

##3.4 typeAliases 别名处理
	• 类型别名是为 Java 类型设置一个短的名字，可以方便我们引用某个类。
	<typeAliases>
	<typeAlias type="com.atguigu.mybatis.beans.Employee"
	                   alias="emp"/>
	</typeAliases>
	• 类很多的情况下，可以批量设置别名这个包下的每一个类创建一个默认的别名，就是简单类名小写
	<typeAliases>
	<package name="com.atguigu.mybatis.beans"/>
	</typeAliases>
	• MyBatis已经取好的别名

##3.5 environments 环境配置

	• MyBatis可以配置多种环境，比如开发、测试和生产环境需要有不同的配置
	• 每种环境使用一个environment标签进行配置并指定唯一标识符
	• 可以通过environments标签中的default属性指定一个环境的标识符来快速的切换环境
	• environment-指定具体环境
id：指定当前环境的唯一标识
transactionManager、和dataSource都必须有

```xml
<environments default="oracle">
<environment id="mysql">
<transactionManager type="JDBC" />
<dataSource type="POOLED">
<property name="driver" value="${jdbc.driver}" />
<property name="url" value="${jdbc.url}" />
<property name="username" value="${jdbc.username}" />
<property name="password" value="${jdbc.password}" />
</dataSource>
</environment>
<environment id="oracle">
<transactionManager type="JDBC"/> 
<dataSource type="POOLED">
<property name="driver" value="${orcl.driver}" />
<property name="url" value="${orcl.url}" />
<property name="username" value="${orcl.username}" />
<property name="password" value="${orcl.password}" />
</dataSource>
</environment> 
</environments>

```

	
•transactionManager
type：  JDBC | MANAGED | 自定义
JDBC：使用了 JDBC 的提交和回滚设置，依赖于从数据源得到的连接来管理事务范   围。 JdbcTransactionFactory
MANAGED：不提交或回滚一个连接、让容器来管理事务的整个生命周期（比如 JEE   应用服务器的上下文）。 ManagedTransactionFactory
自定义：实现TransactionFactory接口，type=全类名/别名

• dataSource
type：  UNPOOLED | POOLED | JNDI | 自定义
UNPOOLED：不使用连接池， UnpooledDataSourceFactory
POOLED：使用连接池， PooledDataSourceFactory
JNDI： 在EJB 或应用服务器这类容器中查找指定的数据源
自定义：实现DataSourceFactory接口，定义数据源的获取方式。
	• 实际开发中我们使用Spring管理数据源，并进行事务控制的配置来覆盖上述配置



##3.6 mappers 映射器

	• 用来在mybatis初始化的时候，告诉mybatis需要引入哪些Mapper映射文件
	• mapper逐个注册SQL映射文件
resource : 引入类路径下的文件 
url :      引入网络路径或者是磁盘路径下的文件
class :    引入Mapper接口.
有SQL映射文件 , 要求Mapper接口与 SQL映射文件同名同位置. 
没有SQL映射文件 , 使用注解在接口的方法上写SQL语句.

```xml
<mappers>
<mapper resource="EmployeeMapper.xml" />
<mapper class="com.atguigu.mybatis.dao.EmployeeMapper"/>
<package name="com.atguigu.mybatis.dao"/>
</mappers>

```
* 使用批量注册，这种方式要求SQL映射文件名必须和接口名相同并且在同一目录下
```xml
	<mappers>
	<package name="com.atguigu.mybatis.dao"/>
	</mappers>
```
