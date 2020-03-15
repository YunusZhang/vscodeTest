<!-- TOC -->

- [第4章 MyBatis 映射文件](#第4章-mybatis-映射文件)
    - [4.1 Mybatis映射文件简介](#41-mybatis映射文件简介)
    - [4.2 Mybatis使用insert|update|delete|select完成CRUD](#42-mybatis使用insertupdatedeleteselect完成crud)
        - [4.2.1 select](#421-select)
        - [4.2.2 insert](#422-insert)
        - [4.2.3  update](#423 -update)
        - [4.2.4  delete](#424 -delete)
    - [4.3 主键生成方式、获取主键值](#43-主键生成方式获取主键值)
        - [4.3.1 主键生成方式](#431-主键生成方式)
        - [4.3.2 获取主键值](#432-获取主键值)
    - [4.4 参数传递](#44-参数传递)
        - [4.4.1 参数传递的方式](#441-参数传递的方式)
        - [4.4.2 参数传递源码分析](#442-参数传递源码分析)
        - [4.4.3 参数处理](#443-参数处理)
        - [4.4.4 参数的获取方式](#444-参数的获取方式)
    - [4.5 select查询的几种情况](#45-select查询的几种情况)
    - [4.6 resultType自动映射](#46-resulttype自动映射)
    - [4.7 resultMap自定义映射](#47-resultmap自定义映射)
        - [4.7.1  id&result](#471 -idresult)
        - [4.7.2  association](#472 -association)
        - [4.7.3  association 分步查询](#473 -association-分步查询)
        - [4.7.4  association 分步查询使用延迟加载](#474 -association-分步查询使用延迟加载)
        - [4.7.5 collection](#475-collection)
        - [4.7.6 collection 分步查询](#476-collection-分步查询)
        - [4.7.7 collection 分步查询使用延迟加载](#477-collection-分步查询使用延迟加载)
        - [4.7.8 扩展: 分步查询多列值的传递](#478-扩展-分步查询多列值的传递)
        - [4.7.9 扩展: association 或 collection的 fetchType属性](#479-扩展-association-或-collection的-fetchtype属性)

<!-- /TOC -->

#第4章 MyBatis 映射文件
##4.1 Mybatis映射文件简介
	• MyBatis 的真正强大在于它的映射语句，也是它的魔力所在。由于它的异常强大，映射器的 XML 文件就显得相对简单。如果拿它跟具有相同功能的 JDBC 代码进行对比，你会立即发现省掉了将近 95% 的代码。MyBatis 就是针对 SQL 构建的，并且比普通的方法做的更好。
	• SQL 映射文件有很少的几个顶级元素（按照它们应该被定义的顺序）：
cache – 给定命名空间的缓存配置。
cache-ref – 其他命名空间缓存配置的引用。
resultMap – 是最复杂也是最强大的元素，用来描述如何从数据库结果集中来加 载对象。
parameterMap – 已废弃！老式风格的参数映射。内联参数是首选,这个元素可能 在将来被移除，这里不会记录。
sql – 可被其他语句引用的可重用语句块。
insert – 映射插入语句
update – 映射更新语句
delete – 映射删除语句
select – 映射查询语

##4.2 Mybatis使用insert|update|delete|select完成CRUD

###4.2.1 select
	• Mapper接口方法
	public Employee getEmployeeById(Integer id );
	• Mapper映射文件
	<select id="getEmployeeById" 
	          resultType="com.atguigu.mybatis.beans.Employee" 
	          databaseId="mysql">
	select * from tbl_employee where id = ${_parameter}
	</select>

###4.2.2 insert
	• Mapper接口方法
	public Integer  insertEmployee(Employee employee);
	• Mapper映射文件
	<insert id="insertEmployee" 
	parameterType="com.atguigu.mybatis.beans.Employee"  
	databaseId="mysql">
	insert into tbl_employee(last_name,email,gender) values(#{lastName},#{email},#{gender})
	</insert>

###4.2.3  update
	• Mapper接口方法
	public Boolean  updateEmployee(Employee employee);
	• Mapper映射文件
	<update id="updateEmployee" >
	update tbl_employee set last_name = #{lastName},
	    email = #{email},
	    gender = #{gender}
	    where id = #{id}
	</update>

###4.2.4  delete
	• Mapper接口方法
	public void  deleteEmployeeById(Integer id );
	• Mapper映射文件
	<delete id="deleteEmployeeById" >
	delete from tbl_employee where id = #{id}
	</delete>
##4.3 主键生成方式、获取主键值

###4.3.1 主键生成方式
	• 支持主键自增，例如MySQL数据库
	• 不支持主键自增，例如Oracle数据库
###4.3.2 获取主键值
	• 若数据库支持自动生成主键的字段（比如 MySQL 和 SQL Server），则可以设置 useGeneratedKeys=”true”，然后再把 keyProperty 设置到目标属性上。
	<insert id="insertEmployee" parameterType="com.atguigu.mybatis.beans.Employee"  
	databaseId="mysql"
	useGeneratedKeys="true"
	keyProperty="id">
	insert into tbl_employee(last_name,email,gender) values(#{lastName},#{email},#{gender})
	</insert>

##4.4 参数传递
###4.4.1 参数传递的方式
	• 单个普通(基本/包装+String)参数
这种情况MyBatis可直接使用这个参数，不需要经过任 何处理。
取值:#{随便写}
	• 多个参数
任意多个参数，都会被MyBatis重新包装成一个Map传入。Map的key是param1，param2，或者0，1…，值就是参数的值
取值: #{0 1 2 …N / param1  param2  ….. paramN}
	• 命名参数
为参数使用@Param起一个名字，MyBatis就会将这些参数封装进map中，key就是我们自己指定的名字
取值: #{自己指定的名字 /  param1  param2 … paramN}
	• POJO
当这些参数属于我们业务POJO时，我们直接传递POJO
取值: #{POJO的属性名}
	• Map
我们也可以封装多个参数为map，直接传递
取值: #{使用封装Map时自己指定的key}
	• Collection/Array
会被MyBatis封装成一个map传入, Collection对应的key是collection,Array对应的key是array. 如果确定是List集合，key还可以是list.
取值:  
Array: #{array}
Collection(List/Set): #{collection}
List : #{collection / list}

###4.4.2 参数传递源码分析
	• 以命名参数为例:
```java
	public Employee getEmployeeByIdAndLastName
	(@Param("id")Integer id, @Param("lastName")String lastName);

```
	• 源码:
前提:  args=[1024,苍老师]    names={0=id ,1=lastName}

```java
	public Object getNamedParams(Object[] args) {
	    final int paramCount = names.size();
	    if (args == null || paramCount == 0) {
	      return null;
	    } else if (!hasParamAnnotation && paramCount == 1) {
	      return args[names.firstKey()];
	    } else {
	      final Map<String, Object> param = new ParamMap<Object>();
	      int i = 0;
	      for (Map.Entry<Integer, String> entry : names.entrySet()) {
	        param.put(entry.getValue(), args[entry.getKey()]);
	        // add generic param names (param1, param2, ...)
	        final String genericParamName = GENERIC_NAME_PREFIX + String.valueOf(i + 1);
	        // ensure not to overwrite parameter named with @Param
	        if (!names.containsValue(genericParamName)) {
	          param.put(genericParamName, args[entry.getKey()]);
	        }
	        i++;
	      }
	      return param;
	    }
	  }

```

###4.4.3 参数处理
	• 参数位置支持的属性:
javaType、jdbcType、mode、numericScale、resultMap、typeHandler、jdbcTypeName、expression
	• 实际上通常被设置的是：可能为空的列名指定 jdbcType ,例如:
	insert into orcl_employee(id,last_name,email,gender) values(employee_seq.nextval,#{lastName, ,jdbcType=NULL },#{email},#{gender})    --Oracle

###4.4.4 参数的获取方式
	• #{key}：可取单个普通类型、 POJO类型 、多个参数、 集合类型
        获取参数的值，预编译到SQL中。安全。 PreparedStatement
	• ${key}：可取单个普通类型、POJO类型、多个参数、集合类型. 
    注意: 取单个普通类型的参数，${}中不能随便写，必须使用 _parameter
              _parameter 是Mybatis的内置参数. 
        获取参数的值，拼接到SQL中。有SQL注入问题。 Statement
原则: 能用#{}取值就优先使用#{},#{}解决不了的可以使用${}.
  例如: 原生的JDBC不支持占位符的地方，就可以使用${}
  Select  column1 ,column2… from 表 where 条件group by   组标识 having  条件 order by 排序字段  desc/asc  limit  x, x 

##4.5 select查询的几种情况 
	• 查询单行数据返回单个对象
	public Employee getEmployeeById(Integer id );
	• 查询多行数据返回对象的集合
	public List<Employee> getAllEmps();
	• 查询单行数据返回Map集合
	public Map<String,Object> getEmployeeByIdReturnMap(Integer id );
	• 查询多行数据返回Map集合
	@MapKey("id") // 指定使用对象的哪个属性来充当map的key
	public Map<Integer,Employee>  getAllEmpsReturnMap();

##4.6 resultType自动映射 
	• autoMappingBehavior默认是PARTIAL，开启自动映射的功能。唯一的要求是列名和javaBean属性名一致
	• 如果autoMappingBehavior设置为null则会取消自动映射
	• 数据库字段命名规范，POJO属性符合驼峰命名法，如A_COLUMNaColumn，我们可以开启自动驼峰命名规则映射功能，mapUnderscoreToCamelCase=true

##4.7 resultMap自定义映射
	• 自定义resultMap，实现高级结果集映射
	• id ：用于完成主键值的映射
	• result ：用于完成普通列的映射
	• association ：一个复杂的类型关联;许多结果将包成这种类型
	• collection ： 复杂类型的集

###4.7.1  id&result 

```xml
<select id="getEmployeeById" resultMap="myEmp">
select id, last_name,email, gender from tbl_employee where id =#{id}
</select>

<resultMap type="com.atguigu.mybatis.beans.Employee" id="myEmp">
<id column="id"  property="id" />
<result column="last_name" property="lastName"/>
<result column="email" property="email"/>
<result column="gender" property="gender"/>
</resultMap>
```

###4.7.2  association
	• POJO中的属性可能会是一个对象,我们可以使用联合查询，并以级联属性的方式封装对象.使用association标签定义对象的封装规则
```java
	public class Department {
	private Integer id ; 
	private String departmentName ;
	//  省略 get/set方法
	}


public class Employee {
private Integer id ; 
private String lastName; 
private String email ;
private String gender ;
private Department dept ;
    // 省略 get/set方法
}

```
	• 使用级联的方式:
```xml
	<select id="getEmployeeAndDept" resultMap="myEmpAndDept" >
	SELECT e.id eid, e.last_name, e.email,e.gender ,d.id did, d.dept_name FROM tbl_employee e , tbl_dept d   WHERE e.d_id = d.id  AND e.id = #{id}
	</select>
	<resultMap type="com.atguigu.mybatis.beans.Employee" id="myEmpAndDept">
	<id column="eid" property="id"/>
	<result column="last_name" property="lastName"/>
	<result column="email" property="email"/>
	<result column="gender" property="gender"/>
	    <!-- 级联的方式 -->
	<result column="did" property="dept.id"/>
	<result column="dept_name" property="dept.departmentName"/>
	</resultMap>
	• Association‘
	<resultMap type="com.atguigu.mybatis.beans.Employee" id="myEmpAndDept">
	<id column="eid" property="id"/>
	<result column="last_name" property="lastName"/>
	<result column="email" property="email"/>
	<result column="gender" property="gender"/>
	<association property="dept" javaType="com.atguigu.mybatis.beans.Department">
	<id column="did" property="id"/>
	<result column="dept_name" property="departmentName"/>
	</association>
	</resultMap>

```

###4.7.3  association 分步查询
	• 实际的开发中，对于每个实体类都应该有具体的增删改查方法，也就是DAO层， 因此
对于查询员工信息并且将对应的部门信息也查询出来的需求，就可以通过分步的方式
完成查询。
	• 先通过员工的id查询员工信息
	• 再通过查询出来的员工信息中的外键(部门id)查询对应的部门信息. 

```xml
	<select id="getEmployeeAndDeptStep" resultMap="myEmpAndDeptStep">
	select id, last_name, email,gender,d_id  from tbl_employee where id =#{id}
	</select>
	<resultMap type="com.atguigu.mybatis.beans.Employee" id="myEmpAndDeptStep">
	<id column="id"  property="id" />
	<result column="last_name" property="lastName"/>
	<result column="email" property="email"/>
	<result column="gender" property="gender"/>
	<association property="dept" select="com.atguigu.mybatis.dao.DepartmentMapper.getDeptById" 
	column="d_id" fetchType="eager">
	</association>
	</resultMap>
```


###4.7.4  association 分步查询使用延迟加载
	• 在分步查询的基础上，可以使用延迟加载来提升查询的效率，只需要在全局的
Settings中进行如下的配置:
```xml
<!-- 开启延迟加载 -->
<setting name="lazyLoadingEnabled" value="true"/>
<!-- 设置加载的数据是按需还是全部 -->
<setting name="aggressiveLazyLoading" value="false"/>

```

###4.7.5 collection
	• POJO中的属性可能会是一个集合对象,我们可以使用联合查询，并以级联属性的方式封装对象.使用collection标签定义对象的封装规则

```java
	public class Department {
	private Integer id ; 
	private String departmentName ;
	private List<Employee> emps ;
	}

```
	• Collection
```xml
	<select id="getDeptAndEmpsById" resultMap="myDeptAndEmps">
	SELECT d.id did, d.dept_name ,e.id eid ,e.last_name ,e.email,e.gender 
	FROM tbl_dept d  LEFT OUTER JOIN tbl_employee e ON  d.id = e.d_id 
	WHERE d.id = #{id}
	</select>
	<resultMap type="com.atguigu.mybatis.beans.Department" id="myDeptAndEmps">
	<id column="did" property="id"/>
	<result column="dept_name" property="departmentName"/>
	<!-- 
	property: 关联的属性名
	ofType: 集合中元素的类型
	-->
	<collection property="emps"  ofType="com.atguigu.mybatis.beans.Employee">
	<id column="eid" property="id"/>
	<result column="last_name" property="lastName"/>
	<result column="email" property="email"/>
	<result column="gender" property="gender"/>
	</collection>
	</resultMap>
```

###4.7.6 collection 分步查询
	• 实际的开发中，对于每个实体类都应该有具体的增删改查方法，也就是DAO层， 因此
对于查询部门信息并且将对应的所有的员工信息也查询出来的需求，就可以通过分步的方式完成查询。
	• 先通过部门的id查询部门信息
	• 再通过部门id作为员工的外键查询对应的部门信息. 

```xml
	<select id="getDeptAndEmpsByIdStep" resultMap="myDeptAndEmpsStep">
	select id ,dept_name  from tbl_dept where id = #{id}
	</select>
	<resultMap type="com.atguigu.mybatis.beans.Department" id="myDeptAndEmpsStep">
	<id column="id" property="id"/>
	<result column="dept_name" property="departmentName"/>
	<collection property="emps" 
	select="com.atguigu.mybatis.dao.EmployeeMapper.getEmpsByDid"
	column="id">
	</collection>
	 </resultMap>

```

###4.7.7 collection 分步查询使用延迟加载
###4.7.8 扩展: 分步查询多列值的传递
	• 如果分步查询时，需要传递给调用的查询中多个参数，则需要将多个参数封装成
Map来进行传递，语法如下: {k1=v1, k2=v2....}
	• 在所调用的查询方，取值时就要参考Map的取值方式，需要严格的按照封装map
时所用的key来取值. 


###4.7.9 扩展: association 或 collection的 fetchType属性 
	• 在<association> 和<collection>标签中都可以设置fetchType，指定本次查询是否要使用延迟加载。默认为 fetchType=”lazy” ,如果本次的查询不想使用延迟加载，则可设置为
fetchType=”eager”.
	• fetchType可以灵活的设置查询是否需要使用延迟加载，而不需要因为某个查询不想使用延迟加载将全局的延迟加载设置关闭.
