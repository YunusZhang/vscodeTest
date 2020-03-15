<!-- TOC -->

- [第4章 MyBatis 动态SQL](#%e7%ac%ac4%e7%ab%a0-mybatis-%e5%8a%a8%e6%80%81sql)
	- [4.1 MyBatis动态SQL简介](#41-mybatis%e5%8a%a8%e6%80%81sql%e7%ae%80%e4%bb%8b)
	- [4.2 if  where](#42-if-where)
	- [4.3 trim](#43-trim)
	- [4.4 set](#44-set)
	- [4.5 choose(when、otherwise)](#45-choosewhenotherwise)
	- [4.6 foreach](#46-foreach)
	- [4.7 sql](#47-sql)

<!-- /TOC --> 

# 第4章 MyBatis 动态SQL

## 4.1 MyBatis动态SQL简介
	• 动态 SQL是MyBatis强大特性之一。极大的简化我们拼装SQL的操作
	• 动态 SQL 元素和使用 JSTL 或其他类似基于 XML 的文本处理器相似
	• MyBatis 采用功能强大的基于 OGNL 的表达式来简化操作
if
choose (when, otherwise)
trim (where, set)
foreach
	• OGNL（ Object Graph Navigation Language ）对象图导航语言，这是一种强大的
表达式语言，通过它可以非常方便的来操作对象属性。 类似于我们的EL，SpEL等
访问对象属性： person.name
调用方法：     person.getName()
调用静态属性/方法： @java.lang.Math@PI 
        @java.util.UUID@randomUUID()
调用构造方法： new com.atguigu.bean.Person(‘admin’).name
运算符：     +,-*,/,%
逻辑运算符： in,not in,>,>=,<,<=,==,!=
注意：xml中特殊符号如”,>,<等这些都需要使用转义字符

## 4.2 if  where
	• If用于完成简单的判断.
	• Where用于解决SQL语句中where关键字以及条件中第一个and或者or的问题 

```xml
	<select id="getEmpsByConditionIf" resultType="com.atguigu.mybatis.beans.Employee">
	select id , last_name ,email  , gender  
	from tbl_employee 
	<where>
	<if test="id!=null">
	and id = #{id}
	</if>
	<if test="lastName!=null &amp;&amp; lastName!=&quot;&quot;">
	and last_name = #{lastName}
	</if>
	<if test="email!=null and email.trim()!=''">
	and email = #{email}
	</if>
	<if test="&quot;m&quot;.equals(gender) or &quot;f&quot;.equals(gender)">
	and gender = #{gender}
	</if>
	</where>
	</select>

```

## 4.3 trim 
	• Trim 可以在条件判断完的SQL语句前后 添加或者去掉指定的字符
prefix: 添加前缀
prefixOverrides: 去掉前缀
suffix: 添加后缀
suffixOverrides: 去掉后缀

```xml
<select id="getEmpsByConditionTrim" resultType="com.atguigu.mybatis.beans.Employee">
select id , last_name ,email  , gender  
from tbl_employee 
<trim prefix="where"  suffixOverrides="and">
<if test="id!=null">
id = #{id} and
</if>
<if test="lastName!=null &amp;&amp; lastName!=&quot;&quot;">
last_name = #{lastName} and
</if>
<if test="email!=null and email.trim()!=''">
email = #{email} and
</if>
<if test="&quot;m&quot;.equals(gender) or &quot;f&quot;.equals(gender)">
gender = #{gender}
</if>
</trim>
</select>


```

## 4.4 set 
	• set 主要是用于解决修改操作中SQL语句中可能多出逗号的问题
```xml
	<update id="updateEmpByConditionSet">
	update  tbl_employee  
	<set>
	<if test="lastName!=null &amp;&amp; lastName!=&quot;&quot;">
	last_name = #{lastName},
	</if>
	<if test="email!=null and email.trim()!=''">
	email = #{email} ,
	</if>
	<if test="&quot;m&quot;.equals(gender) or &quot;f&quot;.equals(gender)">
	gender = #{gender} 
	</if>
	</set>
	where id =#{id}
	</update>

```

## 4.5 choose(when、otherwise) 
	• choose 主要是用于分支判断，类似于java中的switch case,只会满足所有分支中的一个
```xml
	<select id="getEmpsByConditionChoose" resultType="com.atguigu.mybatis.beans.Employee">
	select id ,last_name, email,gender from tbl_employee
	<where>
	<choose>
	<when test="id!=null">
	id = #{id}
	</when>
	<when test="lastName!=null">
	last_name = #{lastName}
	</when>
	<when test="email!=null">
	email = #{email}
	</when>
	<otherwise>
	gender = 'm'
	</otherwise>
	</choose>
	</where>
	</select>

```

## 4.6 foreach 
	• foreach 主要用户循环迭代
collection: 要迭代的集合
item: 当前从集合中迭代出的元素
open: 开始字符
close:结束字符
separator: 元素与元素之间的分隔符
index:
迭代的是List集合: index表示的当前元素的下标
迭代的Map集合:  index表示的当前元素的key

```xml

<select id="getEmpsByConditionForeach" resultType="com.atguigu.mybatis.beans.Employee">
select id , last_name, email ,gender from tbl_employee where  id in 
<foreach collection="ids" item="curr_id" open="(" close=")" separator="," >
#{curr_id}
</foreach>
</select>

```

## 4.7 sql 
	• sql 标签是用于抽取可重用的sql片段，将相同的，使用频繁的SQL片段抽取出来，单独定义，方便多次引用.
	• 抽取SQL: 
```xml
	<sql id="selectSQL">
	select id , last_name, email ,gender from tbl_employee
	</sql>
	• 引用SQL:
	<include refid="selectSQL"></include>  
```
