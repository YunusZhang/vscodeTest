# mybatis 
1) MyBatis简介
	•	MyBatis 是支持定制化 SQL、存储过程以及高级映射的优秀的持久层框架
	•	MyBatis 避免了几乎所有的 JDBC 代码和手动设置参数以及获取结果集
	•	MyBatis可以使用简单的XML或注解用于配置和原始映射，将接口和Java的POJO（Plain Old Java Objects，普通的Java对象）映射成数据库中的记录
	•	半自动ORM（Object Relation Mapping`）框架

2) 为什么要使用MyBatis – 现有持久化技术的对比
	•	JDBC
	•	SQL夹在Java代码块里，耦合度高导致硬编码内伤
	•	维护不易且实际开发需求中sql是有变化，频繁修改的情况多见
	•	Hibernate和JPA
	•	长难复杂SQL，对于Hibernate而言处理也不容易
	•	内部自动生产的SQL，不容易做特殊优化
	•	基于全映射的全自动框架，大量字段的POJO进行部分映射时比较困难。导致数据库性能下降

	•	MyBatis
	•	对开发人员而言，核心sql还是需要自己优化
	•	sql和java编码分开，功能边界清晰，一个专注业务、一个专注数据

3) 如何下载MyBatis
	•	下载网址
	https://github.com/mybatis/mybatis-3/