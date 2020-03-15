<!-- TOC -->

- [1. MyBatis HelloWorld](#1-mybatis-helloworld)
  - [1.1. 开发环境的准备](#11-%e5%bc%80%e5%8f%91%e7%8e%af%e5%a2%83%e7%9a%84%e5%87%86%e5%a4%87)
  - [1.2. 创建测试表](#12-%e5%88%9b%e5%bb%ba%e6%b5%8b%e8%af%95%e8%a1%a8)
  - [1.3. 创建javaBean](#13-%e5%88%9b%e5%bb%bajavabean)
  - [1.4. 创建MyBatis的全局配置文件](#14-%e5%88%9b%e5%bb%bamybatis%e7%9a%84%e5%85%a8%e5%b1%80%e9%85%8d%e7%bd%ae%e6%96%87%e4%bb%b6)
  - [1.5. 创建Mybatis的sql映射文件](#15-%e5%88%9b%e5%bb%bamybatis%e7%9a%84sql%e6%98%a0%e5%b0%84%e6%96%87%e4%bb%b6)
  - [1.6. 测试](#16-%e6%b5%8b%e8%af%95)
  - [1.7. Mapper接口开发MyBatis HelloWorld](#17-mapper%e6%8e%a5%e5%8f%a3%e5%bc%80%e5%8f%91mybatis-helloworld)

<!-- /TOC -->
# 1. MyBatis HelloWorld

## 1.1. 开发环境的准备
	• 导入MyBatis框架的jar包、Mysql驱动包、log4j的jar包


myBatis-3.4.1.jar
mysql-connector-java-5.1.37-bin.jar
log4j.jar
	导入log4j 的配置文件
```xml
	<?xml version="1.0" encoding="UTF-8" ?>
	<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
	 
	<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	 
	 <appender name="STDOUT" class="org.apache.log4j.ConsoleAppender">
	   <param name="Encoding" value="UTF-8" />
	   <layout class="org.apache.log4j.PatternLayout">
	    <param name="ConversionPattern" value="%-5p %d{MM-dd HH:mm:ss,SSS} %m  (%F:%L) \n" />
	   </layout>
	 </appender>
	 <logger name="java.sql">
	   <level value="debug" />
	 </logger>
	 <logger name="org.apache.ibatis">
	   <level value="info" />
	 </logger>
	 <root>
	   <level value="debug" />
	   <appender-ref ref="STDOUT" />
	 </root>
	</log4j:configuration>
```


## 1.2. 创建测试表
```sql
-- 创建库
CREATE DATABASE test_mybatis;
-- 使用库
USE test_mybatis;
-- 创建表
CREATE TABLE tbl_employee(
   id INT(11) PRIMARY KEY AUTO_INCREMENT,
   last_name VARCHAR(50),
   email VARCHAR(50),
   gender CHAR(1)
);
```

## 1.3. 创建javaBean
```java
public class Employee {

private Integer id ; 
private String lastName; 
private String email ;
private String gender ;
public Integer getId() {
return id;
}
public void setId(Integer id) {
this.id = id;
}
public String getLastName() {
return lastName;
}
public void setLastName(String lastName) {
this.lastName = lastName;
}
public String getEmail() {
return email;
}
public void setEmail(String email) {
this.email = email;
}
public String getGender() {
return gender;
}
public void setGender(String gender) {
this.gender = gender;
}
@Override
public String toString() {
return "Employee [id=" + id + ", lastName=" + lastName + ", email=" + email + ", gender=" + gender + "]";
}
```

## 1.4. 创建MyBatis的全局配置文件
	• 参考MyBatis的官网手册
```xml
	<?xml version="1.0" encoding="UTF-8" ?>
	<!DOCTYPE configuration
	PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
	"http://mybatis.org/dtd/mybatis-3-config.dtd">
	<configuration>
	<!-- 数据库连接环境的配置 -->
	<environments default="development">
	<environment id="development">
	<transactionManager type="JDBC" />
	<dataSource type="POOLED">
	<property name="driver" value="com.mysql.jdbc.Driver" />
	<property name="url" value="jdbc:mysql://localhost:3306/mybatis_1129" />
	<property name="username" value="root" />
	<property name="password" value="1234" />
	</dataSource>
	</environment>
	</environments>
	<!-- 引入SQL映射文件,Mapper映射文件 -->
	<mappers>
	<mapper resource="EmployeeMapper.xml" />
	</mappers>
	</configuration>
```


## 1.5. 创建Mybatis的sql映射文件 
	• 参考MyBatis的官方手册
```xml
	<?xml version="1.0" encoding="UTF-8" ?>
	<!DOCTYPE mapper
	PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
	"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
	
	<mapper namespace="suibian">
	<select id="selectEmployee" resultType="com.atguigu.myabtis.helloWorld.Employee">
	select id ,last_name lastName ,email ,gender from tbl_employee where id = #{id}
	<!-- select * from tbl_employee  where id = #{id} -->
	</select>
	</mapper>

```

## 1.6. 测试
	• 参考MyBatis的官方手册
```java
	@Test
	public void test() throws Exception {
	String resource = "mybatis-config.xml";
	InputStream inputStream = Resources.getResourceAsStream(resource);
	SqlSessionFactory sqlSessionFactory = 
	new SqlSessionFactoryBuilder().build(inputStream);
	System.out.println(sqlSessionFactory);
	SqlSession session  = sqlSessionFactory.openSession();
	try {
	Employee employee = 
	session.selectOne("suibian.selectEmployee", 1001);
	System.out.println(employee);
	} finally {
	session.close();
	}
	}

```

## 1.7. Mapper接口开发MyBatis HelloWorld
	• 编写Mapper接口

```java
	public interface EmployeeMapper {
	public Employee getEmployeeById(Integer id ); 
	}
```
	• 完成两个绑定
	• Mapper接口与Mapper映射文件的绑定
	在Mppper映射文件中的<mapper>标签中的namespace中必须指定Mapper接口
	的全类名
	• Mapper映射文件中的增删改查标签的id必须指定成Mapper接口中的方法名. 
	• 获取Mapper接口的代理实现类对象

```java
	@Test
	public void test()  throws Exception{
	String resource = "mybatis-config.xml";
	InputStream inputStream =
	                 Resources.getResourceAsStream(resource);
	SqlSessionFactory sqlSessionFactory = 
	new SqlSessionFactoryBuilder()
	              .build(inputStream); 
	SqlSession session = 
	                         sqlSessionFactory.openSession();
	try {
	//Mapper接口:获取Mapper接口的 代理实现类对象
	EmployeeMapper mapper =
	                 session.getMapper(EmployeeMapper.class); 
	Employee employee = 
	                  mapper.getEmployeeById(1006);
	System.out.println(employee);
	} finally {
	session.close();
	}
	}
```

