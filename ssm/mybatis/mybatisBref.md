<!-- TOC -->

- [mybatis](#mybatis)
  - [1 MyBatis简介](#1-mybatis%e7%ae%80%e4%bb%8b)
  - [2 为什么要使用MyBatis – 现有持久化技术的对比](#2-%e4%b8%ba%e4%bb%80%e4%b9%88%e8%a6%81%e4%bd%bf%e7%94%a8mybatis-%e2%80%93-%e7%8e%b0%e6%9c%89%e6%8c%81%e4%b9%85%e5%8c%96%e6%8a%80%e6%9c%af%e7%9a%84%e5%af%b9%e6%af%94)
  - [3 不同ide下使用](#3-%e4%b8%8d%e5%90%8cide%e4%b8%8b%e4%bd%bf%e7%94%a8)
  - [4 如何下载MyBatis](#4-%e5%a6%82%e4%bd%95%e4%b8%8b%e8%bd%bdmybatis)

<!-- /TOC -->
# mybatis
## 1 MyBatis简介
*	MyBatis 是支持定制化 SQL、存储过程以及高级映射的优秀的持久层框架
*	MyBatis 避免了几乎所有的 JDBC 代码和手动设置参数以及获取结果集
*	MyBatis可以使用简单的XML或注解用于配置和原始映射，将接口和Java的POJO（Plain Old Java Objects，普通的Java对象）映射成数据库中的记录
*	半自动ORM（Object Relation Mapping`）框架

## 2 为什么要使用MyBatis – 现有持久化技术的对比
*	JDBC
*	SQL夹在Java代码块里，耦合度高导致硬编码内伤
*	维护不易且实际开发需求中sql是有变化，频繁修改的情况多见
*	Hibernate和JPA
*	长难复杂SQL，对于Hibernate而言处理也不容易
*	内部自动生产的SQL，不容易做特殊优化
*	基于全映射的全自动框架，大量字段的POJO进行部分映射时比较困难。导致数据库性能下降

*	MyBatis
*	对开发人员而言，核心sql还是需要自己优化
*	sql和java编码分开，功能边界清晰，一个专注业务、一个专注数据
## 3 不同ide下使用
* 我主要在IDEA下使用
## 4 如何下载MyBatis
*	下载网址
	https://github.com/mybatis/mybatis-3/