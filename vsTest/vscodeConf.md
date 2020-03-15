

==测试文件== 
`public class stu{}`

<div>
</div>


#创建ssh key、配置git

1. 设置username和email（github每次commit都会记录他们）

```
git config --global user.name "yourname"
git config --global user.email "youremail@qq.com"
```

2. 通过终端命令创建ssh key
```
ssh-keygen -t rsa -C "youremail@qq.com"
```
3. 用cat命令查看，并复制里面的key
```
cd ~/.ssh
ssh yourname$ cat id_rsa.pub
```
4. 链接验证
```
ssh -T git@github.com 

```
