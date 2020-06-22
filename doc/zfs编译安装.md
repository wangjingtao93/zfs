
[参考](https://www.huaweicloud.com/kunpeng/software/zfs.html)

https://github.com/openzfs/zfs/wiki/Building-ZFS

```vim
[root@ecs-0001 ~]# uname -a 
Linux ecs-0001 4.14.0-115.8.1.el7a.aarch64 #1 SMP Wed Jun 5 15:01:21 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux 
[root@ecs-0001 ~]# rpm -qa |grep kernel-devel 
kernel-devel-4.14.0-115.8.1.el7a.aarch64

```

# 编译安装

sudo yum install epel-release gcc make autoconf automake libtool rpm-build dkms libtirpc-devel libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel kernel-devel-$(uname -r) python python2-devel python-setuptools python-cffi libffi-devel

sh autogen.sh
./configure --prefix=
make -s -j$(nproc)
make install(可以不用指定)
# 创建空洞文件

