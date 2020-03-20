<!-- TOC -->

- [maven配置的坑](#maven%e9%85%8d%e7%bd%ae%e7%9a%84%e5%9d%91)
  - [1 maven的settings.xml配置文件详解](#1-maven%e7%9a%84settingsxml%e9%85%8d%e7%bd%ae%e6%96%87%e4%bb%b6%e8%af%a6%e8%a7%a3)
  - [2 idea集成maven](#2-idea%e9%9b%86%e6%88%90maven)
    - [2.1 idea集成maven的配置](#21-idea%e9%9b%86%e6%88%90maven%e7%9a%84%e9%85%8d%e7%bd%ae)
      - [2.1.1 idea基础环境配置](#211-idea%e5%9f%ba%e7%a1%80%e7%8e%af%e5%a2%83%e9%85%8d%e7%bd%ae)
      - [2.1.2 pom.xml文件导包的时候不会自动提示](#212-pomxml%e6%96%87%e4%bb%b6%e5%af%bc%e5%8c%85%e7%9a%84%e6%97%b6%e5%80%99%e4%b8%8d%e4%bc%9a%e8%87%aa%e5%8a%a8%e6%8f%90%e7%a4%ba)
      - [2.1.3 maven仓库索引](#213-maven%e4%bb%93%e5%ba%93%e7%b4%a2%e5%bc%95)
      - [2.1.4 maven仓库镜像](#214-maven%e4%bb%93%e5%ba%93%e9%95%9c%e5%83%8f)

<!-- /TOC -->
# maven配置的坑
## 1 maven的settings.xml配置文件详解
参考：https://www.cnblogs.com/jingmoxukong/p/6050172.html

1 首先，setting.xml一般存在与两个地方：maven的安装目录/conf/，和${user.home}/.m2/下。他们的区别是在maven安装目录下的setting.xml是所有用户都可以应用的配置，而user.home下的可想而知就是针对某一用户的配置（推荐是在user.home下）。如果两个都进行了配置，则在应用的时候会将两个配置文件进行中和，而且user.home下的setting.xml优先级大于maven安装目录下的。

2 setting.xml文件中顶层元素一览：

```xml
<span style="font-family:Microsoft YaHei;"><settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
            http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository/>
    <interactiveMode/>
    <usePluginRegistry/>
    <offline/>
    <pluginGroups/>
    <servers/>
    <mirrors/>
    <proxies/>
    <profiles/>
    <activeProfiles/>
</settings></span>
```

下面对各个元素进行解析：

2.1 localRepository

建构系统本地仓库的路径，不设置的话默认是在{user.home}/.m2/repository/下，如果想要系统所有用户共用一个本地仓库，则可以在maven安装目录下的setting.xml中进行设置

2.2 interactiveMode

指定Maven是否试图与用户交互来得到输入，默认是true

2.3 usePluginRegistry

如果设置为true，则在{user.home}/.m2下需要有一个plugin-registry.xml来对plugin的版本进行管理。默认是false

2.4 offline

如果不想每次编译的时候都去查找远程中心仓库，就需要设置为true，但前提是本地仓库中已有需要的jar包，默认是false

2.5 pluginGroups

该元素包含一系列的pluginGroup元素，每个pluginGroup又有一个groupId，当一个plugin被使用而在命令行中哦给没有指定groupId的时候，就会查询这个列表
作用：当插件的组织id（groupId）没有显式提供时，供搜寻插件组织Id（groupId）的列表。
该元素包含一个pluginGroup元素列表，每个子元素包含了一个组织Id（groupId）。
当我们使用某个插件，并且没有在命令行为其提供组织Id（groupId）的时候，Maven就会使用该列表。默认情况下该列表包含了org.apache.maven.plugins和org.codehaus.mojo。
```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
  ...
  <pluginGroups>
    <!--plugin的组织Id（groupId） -->
    <pluginGroup>org.codehaus.mojo</pluginGroup>
  </pluginGroups>
  ...
</settings>
```

2.6 Servers

maven除了一般的本地仓库和中央仓库之外，还有一种是远程仓库，一般部署在局域网中供Maven用户使用（成为私服），当maven需要下载构件的时候，它先从私服中请求，如果没有，再到外部的中央仓库中下载，同时下载的构件会在下载到私服中供以后使用，或者用户可以将将构件上传到私服中。

私服还有一个好处就是存放组织内部自己生成的私有构件，这类构件不可能从外部的中央仓库获取，但是组织内部用户又需要共享使用，这个时候就需要私服了。

一般私服建立完毕之后不需要认证就可以访问，但是处于安全方面的考虑，需要提供认证信息才能访问这些私服，这时就需要使用servers元素（需要注意的是配置私服的信息是在pom文件中，但是认证信息则是在setting.xml中，这是因为pom文件往往是被提交到代码仓库中供所有成员访问的，而setting.xml是存放在本地的，这样是安全的）。

而maven是根据pom中的repositories和distributionMnagement元素来决定，然后运行maven clean deploy，这样maven就根据pom中的配置将自己的第三方构件部署在私服上供组织内其他用户使用（注意maven clean deploy和maven clean install的区别：deploy是将该构件部署在私服中，而install是将构件存入自己的本地仓库中）。



2.7 morriors

显而易见，镜像，也供maven下载jar包

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
  ...
  <mirrors>
    <!-- 给定仓库的下载镜像。 -->
    <mirror>
      <!-- 该镜像的唯一标识符。id用来区分不同的mirror元素。 -->
      <id>planetmirror.com</id>
      <!-- 镜像名称 -->
      <name>PlanetMirror Australia</name>
      <!-- 该镜像的URL。构建系统会优先考虑使用该URL，而非使用默认的服务器URL。 -->
      <url>http://downloads.planetmirror.com/pub/maven2</url>
      <!-- 被镜像的服务器的id。例如，如果我们要设置了一个Maven中央仓库（http://repo.maven.apache.org/maven2/）的镜像，就需要将该元素设置成central。这必须和中央仓库的id central完全一致。 -->
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
  ...
</settings>
```

2.8 proxies

当用户 用代理登录下载时需要配置（但是我现在是在使用代理，可是还是没有作用，原因未知?）
```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
  ...
  <proxies>
    <!--代理元素包含配置代理时需要的信息 -->
    <proxy>
      <!--代理的唯一定义符，用来区分不同的代理元素。 -->
      <id>myproxy</id>
      <!--该代理是否是激活的那个。true则激活代理。当我们声明了一组代理，而某个时候只需要激活一个代理的时候，该元素就可以派上用处。 -->
      <active>true</active>
      <!--代理的协议。 协议://主机名:端口，分隔成离散的元素以方便配置。 -->
      <protocol>http</protocol>
      <!--代理的主机名。协议://主机名:端口，分隔成离散的元素以方便配置。 -->
      <host>proxy.somewhere.com</host>
      <!--代理的端口。协议://主机名:端口，分隔成离散的元素以方便配置。 -->
      <port>8080</port>
      <!--代理的用户名，用户名和密码表示代理服务器认证的登录名和密码。 -->
      <username>proxyuser</username>
      <!--代理的密码，用户名和密码表示代理服务器认证的登录名和密码。 -->
      <password>somepassword</password>
      <!--不该被代理的主机名列表。该列表的分隔符由代理服务器指定；例子中使用了竖线分隔符，使用逗号分隔也很常见。 -->
      <nonProxyHosts>*.google.com|ibiblio.org</nonProxyHosts>
    </proxy>
  </proxies>
  ...
</settings>
```
2.9 profiles（？？）

2.10 activeProfiles（？？）
作用：手动激活profiles的列表，按照profile被应用的顺序定义activeProfile。
该元素包含了一组activeProfile元素，每个activeProfile都含有一个profile id。任何在activeProfile中定义的profile id，不论环境设置如何，其对应的 profile都会被激活。如果没有匹配的profile，则什么都不会发生。
例如，env-test是一个activeProfile，则在pom.xml（或者profile.xml）中对应id的profile会被激活。如果运行过程中找不到这样一个profile，Maven则会像往常一样运行。
```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
  ...
  <activeProfiles>
    <!-- 要激活的profile id -->
    <activeProfile>env-test</activeProfile>
  </activeProfiles>
  ...
</settings>
```

## 2 idea集成maven
### 2.1 idea集成maven的配置
#### 2.1.1 idea基础环境配置
1）打开IntelliJ IDEA->configure->preference->Build->Build Tools->Maven
新建一个maven项目的时候，在new project界面设置在每次新建项目的全局范围下，配置好三个参数；这样的话，以后每次新建maven项目的时候，就会用这个配置，而不必重新配

2）主要配置我上图圈的这三个内容，开始的时候IDEA会用自己的一个Maven，点击后面的按钮开始选择路径，这时候你发现你找不到usr了，你按一下comman+shift+.即可显示隐藏内容，或者直接手动输入 /usr/local/apache-maven3.3.9即可。

3）在开始之前，将后面两个打钩，第二项内容这边选择setting.xml 即 选择你在上一个路径下面的/usr/local/apache-maven3.3.9/conf下面的settings文件

4）第三个文件也就是本地仓库文件，在上一步配置Maven的时候我们已经在这个路径下面配置并且下载了一些中央库里面的包，所以选择该路径下面的repository即可

5）也可以进入到具体的项目里后，点击配置按钮（小扳手）设置当前项目的三大参数，以及当前项目用到的本地库和远程库

#### 2.1.2 pom.xml文件导包的时候不会自动提示
1）原因：maven仓库索引没有更新

2）解决办法

打开Settings界面，依次找到“Build,Execution,Deployment——>Bulid Tools——>Maven——>Repositories”。

点击如图update按钮，更新Maven仓库索引

3）关于在个人偏好（设置）界面没有仓库索引的选项

经过各种验证，是idea版本问题；2019.2版本的bug；解决办法，升级到2019.3

#### 2.1.3 maven仓库索引
一.那么问题来了

在使用idea过程中经常遇到这个问题:maven仓库索引更新错误
索引更新不下来，在pom中写依赖的时候就无法获得提示，网上试了很多的方法，用处都不大，这索引的下载完全看心情，时好时坏，idea已经知道这个异常了，但是好像还是没有修复。所以，我决定深挖到底，看看到底是怎么回事。

二.环境:win10，mac

之前只在windows环境下找到了索引文件的位置，mac没找到，我给idea发了邮件询问linux环境下索引文件位置，但是没有回复（万恶的资本主义）。后来发现了。

三.索引文件的位置

windows：~/.IntelliJIdea2017.3/system/Maven

mac：~/Library/Caches/IntelliJIdea2018.2/Maven

注：~是用户根目录，.IntelliJIdea2017.3是个隐藏文件夹，后面的日期是idea的版本，每个人可能不一样。
在indices文件夹中可以看到index0，index1.......这种文件夹，这些根据你设置的仓库来区分，从文件夹里面的一个

index.propertes中可以看出：
```
#Sat Apr 20 07:48:51 CST 2019
version=4
pathOrUrl=https\://repo.maven.apache.org/maven2
dataDirName=data0
failureMessage=java.lang.RuntimeException\: java.io.FileNotFoundException\: Resource nexus-maven-repository-index.properties does not exist
kind=REMOTE
id=central
```
值得注意的是:idea会自动去下载中央仓库的索引。当然，如果你创建这么一个中央仓库的index.properties，它就不会去更新了。

index(x)文件下除了index.properties之外，还有data0，data1.。。。。这类文件，这些文件下context文件中包含的内容就是索引的关键了。

参考文档：

https://blog.csdn.net/zy190903/article/details/89412318
https://www.cnblogs.com/lly001/p/9732201.html
https://www.cnblogs.com/lly001/p/9732485.html

https://blog.csdn.net/ZZQ928000/article/details/89980916


#### 2.1.4 maven仓库镜像
参考文章：

https://www.cnblogs.com/shaoke123/p/5035924.html
https://my.oschina.net/aiguozhe/blog/101537?fromerr=kOXkYkdf

https://www.oschina.net/question/865382_2273305
https://bbs.csdn.net/topics/395031552
https://help.aliyun.com/document_detail/102512.html?spm=a2c40.aliyun_maven_repo.0.0.36183054mZ1uA6

https://www.jianshu.com/p/dddc8b8c5c74

之前是更新本地已有的索引，这样在编写pom文件的时候，可以自动提示，但如果我们能够把整个中央仓库的索引更新下来，那不是更方便啦

1）更新远程仓库索引的注意事项
* 保持网络状态良好。注意，由于中央仓库位于国外，而且索引文件大概八百多兆，请确定网络条件良好，否则很容易更新失败
* 在更新时，会更新失败，提示找不到  nexus-maven-repository-index.properties ；原因：自己本地maven配置了阿里云私服，而最近阿里云私服改版，暂时没提供nexus-maven-repository-index.properties文件，而idea虽然显示的是中央仓库的地址但是还是走的阿里云私服，所以更新不下来，将自己maven的setting文件中的mirror全部注释掉，然后更新，成功。
* 关闭本地防火墙，不然会各种下载失败
  
2）配置国内镜像
* 选择阿里云的镜像，在settings.xml文件中添加(注意：要在更新完远程仓库索引之后再添加国内镜像)
  ```xml
  <mirror>
      <id>aliyunmaven</id>
      <mirrorOf>*</mirrorOf>
      <name>阿里云公共仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  ```

3）具体步骤

1、下载最新maven bin包，及环境变量配置

2、创建本地仓库，修改IDEA Setting，---File--- setting ---Maven ----各个路径及勾选修改

3、修改maven包下conf---- setting.xml相关配置，setting.xml

4、cmd，pom.xml中测试相关配置


最后遇到问题是：

1. 不能自动补全包名
   
   解决： Setting---Maven---Repositories----update，此时只能成功更新local ，Remote提示Error，于是只能补全仓库中已下载的依赖包
查知，能自动补全是因为已下载依赖包索引，不同于仓库中的依赖包，update remote 即可下载
2. remote  repository 无法更新，即无法下载中央仓库索引
   
    解决：setting中注释掉使用的镜像，更新完再加上镜像。只是我的机器上如此，其他人有镜像也能更新，无法描述的问题及原因，总之，最后这样解决了问题。

    本地索引位置C:\Users\Echo\.IntelliJIdea2018.2\system\Maven\Indices

操作完以上，可以自动补全使用过和未使用过的依赖包了，pom中代码配置时也是使用的速度较快的阿里云仓库




