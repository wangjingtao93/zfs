
# 1. 描述

zfs 命令按照 zpool(1M) 中描述的方式配置 ZFS 存储池中的 ZFS 数据集。数据集由 ZFS 名称空间中的唯一路径进行标识。例如：

`pool/{filesystem,volume,snapshot}`

<span style="border-bottom:2px dashed red;">创建zfs文件系统和创建数据集是一个意思吗???

# 2. 数据集类型

- **file system**：<span style="border-bottom:2px dashed red;">filesystem 类型的 ZFS 数据集可以挂载在**标准系统名称空间**中（什么意思？？？？）</span>，并且行为与其他文件系统相似。虽然 ZFS 文件系统被设计为符合 POSIX 标准，但是在某些情况下仍然存在一些已知的妨碍符合性的问题。依赖于标准符合性的应用程序可能会在检查文件系统可用空间时由于非标准行为而失败。
- **volume**：作为原始设备或块设备导出的逻辑卷。此类型的数据集只应在特殊情况下使用。**文件系统通常适用于大多数环境。**
- **snapshot**：文件系统或卷在给定时间点的只读版本。它被指定为 filesystem@name 或 volume@name。

# 3. ZFS 文件系统分层结构

ZFS 存储池是为数据集提供空间的设备的逻辑集合。<span style="border-bottom:2px dashed red;">存储池也是 ZFS 文件系统分层结构的**根**，即pool/path。

存储池的根可作为文件系统进行访问，例如挂载和卸载、创建快照以及设置属性。但是，**物理存储特征**(_这个词好奇怪怪？？？（_ zpool 命令管理。

## 3.1. 快照

快照是文件系统或卷的**只读副本**。<span style="border-bottom:2px dashed red;">快照可以非常快速地创建，而且最初不占用池中的其他空间</span>。当**活动数据集**（_活动数据集是指正在读或者写的数据集吗？？？，或者说是可以读写的数据集而不是正在读写的_）中的数据发生变化时，快照占用的数据多于按其他方式与活动数据集共享的数据。<span style="border-bottom:2px dashed red;">（快照与活动数据集共享数据块是什么意思？？？,为什么快照和数据集是共享数据，快照不该是复制过来的吗？）

快照可以具有任意名称。卷的快照可进行克隆或回滚，但是不能单独访问。
。<span style="border-bottom:2px dashed red;">快照会自动根据需要进行挂载</span>，并可以按固定的间隔卸载。.zfs 目录的可见性可由 snapdir 属性控制

# 4. 克隆

克隆是**可写的卷或文件系统**，其初始内容与其他数据集相同。<span style="border-bottom:2px dashed red;">与快照一样，创建克隆也几乎是即时的，而且最初不占用其他空间。</span>

**克隆只能从快照创建**。在克隆快照时，会在父项与子项之间创建隐式相关性。即使克隆是在数据集分层结构中的某个其他位置创建的，但只要存在克隆，就无法销毁原始快照(_测试时加,删除克隆加上-r貌似可以将原始快照删除？？？）_。<span style="border-bottom:2px dashed red;">origin 属性显示此相关性</span>，而 destroy 命令会列出任何此类相关性（如果存在）。

使用 promote 子命令，可以颠倒克隆父项-子项相关性关系。这将导致“原始”文件系统成为所指定文件系统的克隆，从而可能销毁创建克隆时所基于的文件系统。(_测试时，直接加-R好像也可以直接删除原始文件系统_)

# 5. 挂载点

创建 ZFS 文件系统是一项简单的操作，<span style="border-bottom:2px dashed red;">**因此每个系统可能有多个文件系统**</span>。为处理这种情况，<span style="border-bottom:2px dashed red;">ZFS 自动管理文件系统的挂载和卸载，而不需要编辑 /etc/vfstab 文件(_并没有找到这个文件？？？）_</span>。所有自动管理的文件系统均由 ZFS 在引导时挂载。

<span style="border-bottom:2px dashed red;">缺省情况下，文件系统挂载在 /path 下，其中 path 是 ZFS 名称空间中文件系统的名称</span>。

文件系统也可以在 mountpoint 属性中设置挂载点。此目录会根据需要进行创建；在调用 zfs mount -a 命令时，ZFS 将自动挂载文件系统（无需编辑 /etc/vfstab）。mountpoint 属性可以继承，因此如果 pool/home 有一个挂载点 /export/stuff，则 pool/home/user 会自动继承挂载点 /export/stuff/user。

通过为 zfs mount 命令指定 –o mountpoint=value 选项，可以在文件系统的**持久性挂载点**以外的位置临时挂载文件系统（_拗口？？？）_。仅允许对具有**非先前挂载点**的文件系统执行此操作。

文件系统的 mountpoint 属性 none 可防止挂载此文件系统。

如果需要，也可以用传统工具（mount、umount、/etc/vfstab）来管理 ZFS 文件系统。如果将文件系统的挂载点设置为 legacy，则 ZFS 不会尝试管理文件系统，并且管理员将负责挂载和卸载文件系统。

# 6. 区域

_这部分是不是可以暂时不用考虑如何设置_？？？

添加的文件系统的**物理属性**由**全局管理员**控制。但是，**区域管理员**可以根据添加的**文件系统的挂载方式**_（分为哪几种挂载方式？？？，是指mountpoint=legacy,none的属性吗）_，在该文件系统中创建、修改或销毁文件。

【使用 zonecfg add dataset 子命令也可以将数据集委托给非全局区域。您不能将数据集委托给一个区域，也不能将同一数据集的子项委托给另一个区域】（_说的啥？？？？，可以又不可以的_）。区域管理员可以更改数据集或其任何子项的属性。但是，**quota 属性由全局管理员控制**。

通过 zonecfg add device 子命令，可以将 ZFS 卷作为一个设备添加到非全局区域。但是，只有全局管理员才可修改其物理属性。

有关 zonecfg 语法的更多信息，请参见 zonecfg(1M)。

将数据集委托给非全局区域后，将自动设置 zoned 属性。在全局区域中，只能通过使用临时的 mountpoint 属性（请参见“临时挂载点属性”）挂载区域文件系统。

全局管理员可强制清除 zoned 属性，但是完成此操作应非常谨慎。全局管理员应在清除该属性前确认所有挂载点是可接受的。

# 7. 重复数据删除

重复数据删除是在**块级别**删除冗余数据以减少存储的总数据量的过程。<span style="border-bottom:2px dashed red;">重复数据删除面向存储池范围</span>；每个数据集都可以使用自己的 dedup 属性增减内容。如果文件系统启用了 **dedup** 属性，<span style="border-bottom:2px dashed red;">则在**写入时**将同步删除重复数据块</span>。因此，在存储池已启用 dedup 的所有数据集中只会存储唯一的数据，并且会在这些数据集的文件中共享公共组件。

_会对raptor三副本机制有影响吗？单机有影响，集群可能没有影响因为故障域是rack的缘故？？？_

# 8. 加密

_暂时加密不做考虑？？？_

有关 ZFS 加密和 ZFS 加密语法的完整描述，请参见 zfs_encrypt(1M)。

# 9. 用户属性

_还是不清楚用户属性怎么使用？？？_

除了标准的本机属性外，ZFS 还支持任意用户属性。<span style="border-bottom:2px dashed red;">用户属性对 ZFS 行为没有影响，但是应用程序或管理员可以使用这些属性来注释数据集（文件系统、卷和快照）。

用户属性名称必须含有一个冒号`(:)` 字符，以便与本机属性区分。这些名称可包含小写字母、数字和以下标点符号：冒号 (`:`)、破折号 (-)、句号 (.) 和下划线 (_)。预期约定是将属性名称分为两部分，例如 module:property，但是 ZFS 并不强制执行这种名称空间。用户属性名称最多可有 256 个字符，不能以破折号 (-) 开头。

在程序中使用用户属性时，强烈建议对属性名的 module 部分使用反向 DNS 域名，以尽量避免两个独立开发的软件包将同一属性名用于不同用途。在 Oracle Solaris 发行版中，为 beadm 命令和库保留了 com.oracle 用户属性。

用户属性的值是任意字符串，始终会继承但是从不会验证这些值。对属性执行操作的所有命令（如 zfs list、zfs get、zfs set 等）都可用来处理本机属性和用户属性。使用 zfs inherit 命令可清除用户属性。如果任意父数据集中均未定义该属性，则会将其完全删除。属性值仅限于 1024 个字符。

# 10. ZFS 卷作为交换设备或转储设备

_暂时不学习此部分_

初始安装期间，将会在 ZFS 根池的 ZFS 卷上创建交换设备和转储设备。必须将单独的 ZFS 卷用于交换区域和转储设备。在 ZFS 文件系统中，不要交换到文件。不支持 ZFS 交换文件配置。

通过为该设备指定 encryption 属性，以及在 vfstab(4) 中指定 encrypted 选项，可以对用作交换设备的 ZFS 卷进行加密。有关加密属性的更多信息，请参见 zfs_encrypt.1m。

如果您需要在安装或升级系统后更改交换区域或转储设备，请使用 swap(1M) 和 dumpadm(1M) 命令。如果需要更改交换区域或转储设备的大小，请参见在 Oracle Solaris 11.2 中管理 ZFS 文件系统 。

# 11. zfs共享文件系统

## 11.1. 描述

通过设置 **share.nfs** 或 **share.smb** 属性，可以为 ZFS 文件系统**创建 NFS 共享或 SMB** 共享。也可以使用 zfs share 和 zfs unshare 命令发布或取消发布 ZFS 共享。

通过设置或继承 share.nfs=on 或 share.smb=on 属性值可以共享文件系统。例如：

```vim
# zfs set share.nfs=on tank/home
# zfs set share.smb=on tank/data
```

上述简单语法自动创建和发布文件系统共享。此方法称为自动共享。有关更多信息，请参见“示例”部分。

自动共享是只读的，从父文件系统继承其所有属性。此方法允许单独通过继承启用共享（如果需要），而不必为每个后代文件系统创建共享。自动共享的发布共享名称 share.name 根据数据集挂载点生成。

例如，tank/home 的 share.name 为 tank_home。

文件系统的自动共享名称显示为 filesystem%。例如，tank/home%。

也可以使用 zfs share 命令创建和发布共享，如下所示：

```vim
# zfs share -o share.smb=on sandbox/myfs%myshare
```

上述语法创建并发布指定的共享。当您需要通过 NFS 或 SMB 协议共享文件系统中的子目录时，这种方法更为灵活。有关更多信息，请参见“示例”部分。

## 11.2. 本机共享文件系统属性

文件系统属性分为两种类型：本机属性和用户定义的（或用户）属性。本机属性用于显示信息或控制 ZFS 行为。此外，本机属性分为可编辑属性和只读属性。

属性继承自父项，但子项所覆盖的除外。有些属性仅适用于某些类型的数据集（文件系统、卷或快照）。

以下本机属性可用于更改 ZFS 文件系统的行为，共享某个文件系统时通常会使用这些本机属性。

具体属性参见[本机共享文件系统属性](zfs+zpool参数配置.md)

## 11.3. 特定的 NFS 或 SMB 属性

除了本机属性和用户属性以外，您还可以指定控制文件系统共享方式的属性。以下这一组与共享相关的属性可分为 3 个类别：全局属性（适用于 NFS 和 SMB 共享）、特定于 NFS 的属性以及特定于 SMB 的属性。

全局共享属性大部分为只读属性，也有少部分例外。以下全局共享属性适用于 NFS 或 SMB 共享或者已共享或即将共享的文件系统：

| 属性               | 说明                                                     | 可继承 | 值                          |
|------------------|--------------------------------------------------------|-----|----------------------------|
| share\.desc      | 该可编辑属性提供用户定义的说明，可以在文件系统或共享上进行设置。缺省值为无说明。               | 是   | string                     |
| share\.fs        | 该只读属性标识共享的文件系统名称。                                      | 否   | filesystem                 |
| share\.name      | 该只读属性标识共享的共享名称。                                        | 否   | share\-name                |
| share\.auto      | 该可编辑属性启用自动共享，只能在要共享的文件系统上进行设置。                         | 否   | on 或 off                   |
| share\.path      | 该可编辑属性设置共享的共享路径。                                       | 否   | mountpoint\-relative\-path |
| share\.point     | 该只读属性标识现有共享的绝对路径，该路径根据 share\.path 属性的当前值，相对于数据集挂载点派生。 | 否   | path                       |
| share\.protocols | 该只读属性标识为文件系统或共享建立的协议。                                  | 否   | protocol\-list             |
| share\.state     | 该只读属性标识共享的当前状态。                                        | 否   | unshared、shared 或 failed   |

以下共享属性特定于 NFS 协议。所有特定于 NFS 共享的属性均可编辑和继承。其中大部分属性的缺省值为 off，除非另行说明。

以下是 NFS 共享属性说明。
后续整理

SMB 共享属性说明:
| 属性                        | 说明                                                             | 值                          |
|---------------------------|----------------------------------------------------------------|----------------------------|
| share\.smb                | 确定是否通过 SMB 协议共享文件系统。缺省值为 off。                                  | on 或 off                   |
| share\.smb\.ad\-container | 允许在 AD 容器中发布 SMB 共享。缺省值为 off（关闭）。                              | string                     |
| share\.smb\.abe           | 启用基于访问权限的枚举 \(Access\-Based Enumeration, ABE\) 支持。缺省值为 "off"。  | share\-name                |
| share\.smb\.csc           | 启用客户端缓存支持。缺省值为 disabled。                                       | disabled、manual、auto 或 vdo |
| share\.smb\.catia         | 启用 CATIA 转换支持。缺省值为 off（关闭）。                                    | on 或 off                   |
| share\.smb\.dfsroot       | 启用 DFS 根支持。缺省值为 off（关闭）。                                       | on 或 off                   |
| share\.smb\.guestok       | 启用来宾访问。缺省值为 off（关闭）。                                           | on 或 off                   |
| share\.smb\.ro            | 将 SMB 共享设置为只读。可以指定 on、off 或名称列表 \(access\-list\)。缺省值为 off（关闭）。 | access\-list               |
| share\.smb\.rw            | 将 SMB 共享设置为读写。可以指定 on、off 或名称列表 \(access\-list\)。缺省值为 on。      | access\-list               |
| share\.smb\.none          | 将 access\-list 中指定用户的 SMB 共享设置为 off。                           | access\-list               |
# 12. 其他知识点汇总

## 12.1. LVM

待学习