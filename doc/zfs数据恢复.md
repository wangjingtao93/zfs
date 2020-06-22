 
 # ZFS错误消息的系统报告

 报告在哪？怎么查看？？？怎么通知？？？zpool status吗？？？

除了持久跟踪池中的错误外，ZFS 还在发生相关事件时显示 syslog 消息。以下情况将
生成通知事件：
1. **设备状态转换**————如果设备变为 FAULTED 状态，则 ZFS 将记录一条消息，指出池的容
错能力可能已受到危害。如果稍后将设备联机，将池恢复正常，则将发送类似的消
息。
2. **数据损坏**————如果检测到任何数据损坏，则 ZFS 将记录一条消息，描述检测到数据损
坏的时间和位置。仅在首次检测到数据损坏时才记录此消息。后续访问不生成消息。
3. **池故障和设备故障**————如果出现池故障或设备故障，则 Fault Manager 守护进程将通过
syslog 消息以及 fmdump 命令报告这些错误。

 数据损坏－如果检测到任何数据损坏，则 ZFS 将记录一条消息，描述检测到数据损坏的时间和位置。仅在首次检测到数据损坏时才记录此消息。后续访问不生成消息

  排除故障涉及到以下步骤：
- 更换不可用设备或缺少的设备，并使其联机。
- 从备份恢复故障配置或损坏的数据。
- 使用 zpool status -x 命令验证恢复情况。
- 备份所恢复的配置（如果适用）

如果设备处于冗余配置中，则设备可能显示无法更正的错误，而镜像或RAID-Z 设备级别上不显示错误。这种情况下，ZFS 成功检索到良好的数据并试图利用现有副本修复受损数据

# 1. zpool scrub [–s] pool ...
开始一次清理。scrub 将检查指定池中的所有数据以验证其校验和是否正确。对于复制的（镜像或 raidz）设备，ZFS 会自动修复在清理过程中发现的所有损坏。zpool status 命令报告清理的进度，并在完成时汇总清理的结果。

清理和重新同步是非常相似的操作。不同之处在于，重新同步仅检查 ZFS 已知将要过期的数据（例如，在将新设备连接到某个镜像或者替换现有设备时），而清理将检查所有数据以发现由于硬件故障或磁盘故障而产生的无提示错误。

由于清理和重新同步都是 I/O 密集型操作，因此 ZFS 一次仅允许使用其中的一个。如果已经在进行清理，则后续的 zpool scrub 将返回错误，并建议使用 zpool scrub – s 取消当前的清理。如果正在进行重新同步，ZFS 将不允许启动清理，直到重新同步完成为止。



# 2. 重新同步

将数据从一个设备移动到另一个设备的过程称为重新同步

发生同步情况：
1. 一般zpool attach [–f] pool device new_device，new_device 都会立即开始重新同步。
2. zpool replace [–f] pool old_device [new_device]，new_device，会重新同步

# 3. zpool attach [–f] pool device new_device

将 new_device 连接到现有的 zpool 设备。现有设备不能是 raidz 配置的一部分。如果 device 当前不是某个镜像配置的一部分，device 将自动转换为 device 和 new_device 的双向镜像。如果 device 是某个双向镜像的一部分，则连接 new_device 将创建一个三向镜像，依此类推。无论哪种情况，new_device 都会立即开始重新同步。

–f： 强制使用 new_device，即使它显示为正在使用。并非所有设备都可以通过这种方式覆盖。

1. ZFS 仅重新同步最少量的必要数据。如果是短暂的断电（而不是设备替换），整个磁盘可以在几分钟或几秒新同步。替换整个磁盘时，重新同步过程所用的时间磁盘上所用的数据量成比例。如果只使用了池中几 GB 的磁盘空间，则替换 500 GB
的磁盘可能只需要几秒的时间。
2. 如果系统断电或者进行重新引导，则重新同步过程会准确地从它停止的位置继续，而无需手动干预。

# 4. zpool replace [–f] pool old_device [new_device]

将 old_device 替换为 new_device。该命令等效于连接 new_device，等待它重新同步，然后分离 old_device。

new_device 的大小必须大于或等于镜像配置或 raidz 配置中所有设备的最小大小。

如果池不是冗余池，则必须要有 new_device。如果不指定 new_device，将缺省为 old_device。在现有磁盘出现故障并已进行物理更换后，这种形式的替换很有用。在这种情况下，新磁盘可能有着与旧设备相同的 /dev/dsk 路径，尽管它实际上是一个不同的磁盘。ZFS 会识别这一情况。

在 zpool status 输出中，old_device 显示在 replacing 一词下，其后附有字符串 /old。重新同步完成后，将自动移除 replacing 和 old_device。如果新设备在重新同步之前发生故障，并且有第三个设备安装在它的位置，则两个故障设备都将显示为后面附有 /old，并且重新同步过程将重新开始。重新同步完成后，两个 /old 设备将与 replacing 一词一起被移除。

–f：强制使用 new_device，即使它显示为正在使用。并非所有设备都可以通过这种方式覆盖。

# 5. zfs存储设备问题与解决方式

## 5.1. 辅助盘引导

105页

# 6. zfs 数据损坏错误

## 6.1. 常见数据问题

■ 池或文件系统空间缺失

■ 由于损坏的磁盘或控制器而导致的瞬态 I/O 错误

■ 磁盘上的数据因宇宙射线而损坏

■ 导致数据传输至错误目标或从错误源位置传输的驱动程序已知问题

■ 用户意外地覆写了物理设备的某些部分



## 6.2. 文件系统修复

对于传统的文件系统，写入数据的方法本身容易出现导致文件系统不一致的意外故障。由于传统的文件系统不是事务性的，因此可能会出现未引用的块、错误的链接计数或其他不一致的文件系统结构。添加日志记录确实解决了其中的一些问题，但是在无法回滚日志时可能会带来其他问题。<span style="border-bottom:2px dashed red;">采用 ZFS 配置的磁盘存在数据不一致的唯一原因是硬件故障（在这种情况下该池应该已经设置冗余）或者 ZFS 软件存在错误</span>

fsck 实用程序可以解决 UFS 文件系统特有的已知问题。大多数 ZFS 存储池问题一般都
与硬件故障或电源故障有关。使用冗余池可以避免许多问题。如果硬件故障或断电导致
池损坏，请参见“修复 ZFS 存储池范围内的损坏” [264]

如果没有冗余池，则始终存在因文件系统损坏而造成无法访问某些或所有数据的风险。

除了文件系统修复外，fsck 实用程序还能验证磁盘上的数据是否没有问题。过去，此任务要求取消挂载文件系统并运行 fsck 实用程序，在该过程中可能会使系统进入单用户模式。此情况导致的停机时间的长短与所检查文件系统大小成比例。<span style="border-bottom:2px dashed red;">ZFS 提供了一种对所有不一致性执行例程检查的机制，而不是要求显式实用程序执行必要的检查。此功能（称为清理）通常在内存或其他系统中使用，用于在错误导致硬件或软件故障前检测及预防这些错误。</span>

## 6.3. 显式 ZFS 数据清理

检查数据完整性的最简单方式是对该池中的数据进行显式清理。此操作对池中的所有数
据遍历一次，并验证是否可以读取所有块。尽管任何 I/O 的优先级一直低于常规操作的
优先级，但是清理以设备所允许的最快速度进行。虽然进行清理时池数据应该保持可用
而且几乎都做出响应，但是此操作可能会对性能产生负面影响。要启动显式清理，请使
用 zpool scrub 命令。例如：

```vim
# zpool scrub tank
使用 zpool status 命令可以显示当前清理操作的状态。例如：

# zpool status -v tank
pool: tank
state: ONLINE
scan: scrub in progress since Mon Jun 7 12:07:52 2010
201M scanned out of 222M at 9.55M/s, 0h0m to go
0 repaired, 90.44% done
config:
NAME STATE READ WRITE CKSUM
tank ONLINE 0 0 0
mirror-0 ONLINE 0 0 0
c1t0d0 ONLINE 0 0 0
c1t1d0 ONLINE 0 0 0

errors: No known data errors
每个池一次只能发生一个活动的清理操作。
可通过使用 -s 选项来停止正在进行的清理操作。例如：
# zpool scrub -s tank
```

执行例程清理可以保证对系统上所有磁盘执行连续的 I/O。例程清理具有副作用，即阻
止电源管理将空闲磁盘置于低功耗模式。如果系统基本上一直在执行 I/O，或功耗不是
重要的考虑因素，则可以安全地忽略此问题。如果系统基本处于空闲状态，您希望节省
磁盘功耗，应考虑使用 cron(1M) 安排显式清理，而不使用后台清理。这仍然会执行数
据的全面清理，尽管在清理完成前会产生大量 I/O，完成时可以将磁盘作为正常状态进
行电源管理。缺点（除了增加 I/O 外）是有大量时间没有进行任何清理操作，在这些时
间段内数据损坏风险可能会增加。

## 6.4. 修复损坏的 ZFS 数据

1. “确定数据损坏的类型” [262]
2. “修复损坏的文件或目录” [263]
3. “修复 ZFS 存储池范围内的损坏” [264]

ZFS 使用**校验和、冗余和自我修复数据**来最大限度地减少出现数据损坏的风险。

可能损坏以下两种基本类型的数据：
1. **池元数据**————ZFS 需要解析一定量的数据才能打开池和访问数据集。如果此数据被损坏，则整个池或部分数据集分层结构将变得不可用
2. **对象数据**————在这种情况下，损坏发生在特定的文件或目录中。此问题可能会导致无法访问该文件或目录的一部分，或者此问题可能导致对象完全损坏

某些临时故障可能会导致数据损坏，故障结束后会自动修复

## 6.5. 修复损坏的文件或目录

如果文件或目录被损坏，则系统可能仍然正常工作，具体取决于损坏的类型。如果系统
中存在完好的数据副本，则任何损坏实际上都是不可恢复的。如果数据具有价值，必须
从备份中恢复受影响的数据。尽管这样，您也许能够从此损坏恢复而不必恢复整个池。

如果损坏出现在文件数据块中，则可以安全地删除该文件，从而清除系统中的错误。使
用 zpool status -v 命令可以显示包含持久性错误的文件名列表。例如：

```vim
# zpool status tank -v
pool: tank
state: ONLINE
status: One or more devices has experienced an error resulting in data
corruption. Applications may be affected.
action: Restore the file in question if possible. Otherwise restore the
entire pool from backup.
see: http://support.oracle.com/msg/ZFS-8000-8A
config:
NAME STATE READ WRITE CKSUM
tank ONLINE 4 0 0
c0t5000C500335E106Bd0 ONLINE 0 0 0
c0t5000C500335FC3E7d0 ONLINE 4 0 0
errors: Permanent errors have been detected in the following files:
/tank/file.1
/tank/file.2
```

包含持久性错误的文件名列表可能描述如下：

1. 如果找到文件的全路径并且已挂载数据集，则会显示该文件的全路径。例如：/monkey/a.txt
2. 如果找到文件的全路径但未挂载数据集，则会显示不带前导斜杠 (/) 的数据集名称，后面是数据集中文件的路径。例如:monkey/ghost/e.txt
3. 如果由于错误或由于对象没有与之关联的实际文件路径而导致文件路径的对象编号无法成功转换（dnode_t 便是这种情况），则会显示数据集名称，后跟该对象的编号。例如:monkey/dnode:<0x0>
4. 如果元对象集 (Metaobject Set, MOS) 中的对象损坏，则会显示特殊标签`<metadata>`，后跟该对象的编号

您可以尝试通过多次清理池和清除池错误来解决不太严重的数据损坏。如果在首次清理和清除中没有解决损坏的文件，请重新运行。例如：

```vim
# zpool scrub tank
# zpool clear tank
```
如果损坏发生在目录或文件的元数据中，<span style="border-bottom:2px dashed red;">则唯一的选择是将文件移动到别处</span>。可以安全地将任何文件或目录移动到不太方便的位置，以允许恢复原始对象。

## 6.6. 修复具有多块引用的损坏数据

## 6.7. 修复 ZFS 存储池范围内的损坏

如果池元数据发生损坏，并且该损坏导致池无法打开或导入，则可以使用以下选项：
1. 可以尝试使用 zpool clear -F 命令或 zpool import - F 命令恢复池。这些命令尝试回
滚最后几次池事务，使其回到运行状态。可以使用 zpool status 命令查看损坏的池
和建议的恢复步骤。例如：

```vim
# zpool status
pool: tpool
state: UNAVAIL
status: The pool metadata is corrupted and the pool cannot be opened.
action: Recovery is possible, but will result in some data loss.
Returning the pool to its state as of Fri Jun 29 17:22:49 2012
should correct the problem. Approximately 5 seconds of data
must be discarded, irreversibly. Recovery can be attempted
by executing 'zpool clear -F tpool'. A scrub of the pool
is strongly recommended after recovery.
see: http://support.oracle.com/msg/ZFS-8000-72
scrub: none requested
config:

NAME STATE READ WRITE CKSUM
tpool UNAVAIL 0 0 1 corrupted data
c1t1d0 ONLINE 0 0 2
c1t3d0 ONLINE 0 0 4
```

前面的输出中描述的恢复过程要使用以下命令：

```vim
# zpool clear -F tpool
```

如果您尝试导入损坏的存储池，将会看到类似如下的消息：

```vim
# zpool import tpool
cannot import 'tpool': I/O error
Recovery is possible, but will result in some data loss.
Returning the pool to its state as of Fri Jun 29 17:22:49 2012
should correct the problem. Approximately 5 seconds of data
must be discarded, irreversibly. Recovery can be attempted
by executing 'zpool import -F tpool'. A scrub of the pool
is strongly recommended after recovery
```

前面的输出中描述的恢复过程要使用以下命令：

```vim
# zpool import -F tpool
Pool tpool returned to its state as of Fri Jun 29 17:22:49 2012.
Discarded approximately 5 seconds of transactions
```

如果损坏的池位于 zpool.cache 文件中，则系统引导时会发现该问题，并通过 zpool
status 命令报告损坏的池。如果该池不在 zpool.cache 文件中，它将无法成功导入或
打开，当您尝试导入该池时，会看到池受损消息。

2.  您可以在只读模式下导入受损的池。此方法使您可以导入该池，从而可以访问数据。
例如：

`# zpool import -o readonly=on tpool`

有关在只读模式下导入池的更多信息，请参见“在只读模式下导入池” [82]。

3. <span style="border-bottom:2px dashed red;">您可以使用 zpool import -m 命令导入缺少日志设备的池。有关更多信息，请参见“导
入缺少日志设备的池” [80]

4. 如果无法使用上述池恢复方法恢复池，则必须从备份副本中恢复池及其所有数据。所
用的机制通常随池配置和备份策略的不同而有很大差别。首先，保存 zpool status
命令所显示的配置，以便在销毁池后可以重新创建它。然后，使用 zpool destroy -f
命令销毁池。

此外，将描述数据集布局以及各个本地设置的属性的文件保存在某个安全位置，否则
如果池出现无法访问的情况，将无法访问这些信息。使用池配置和数据集布局，可以
在销毁池后重新构造完整的配置。然后可以使用任何备份或恢复策略填充数据。

## 6.8. 修复损坏的 ZFS 配置

ZFS 在根文件系统中维护活动池及其配置的高速缓存。如果此高速缓存文件损坏或者
不知何故变得与磁盘上所存储的配置信息不同步，则无法再打开池。虽然底层存储设备
的质量始终可能会带来任意的损坏，但是 ZFS 会尽量避免出现此情况。此情况通常会
导致池从系统中消失（它原本应该是可用的）。此情况还可能表现为不是一个完整的配
置，缺少数量不明的顶层虚拟设备。在这两种情况下，都可以通过导出池（如果它确实
可见）再重新导入池来恢复配置。
有关导入和导出池的信息，请参见“迁移 ZFS 存储池” [76]

# 案例

https://yq.aliyun.com/articles/118300

https://yo.zgserver.com/freebsdzfs.html

https://wiki2.xbits.net:4430/storage:zfs:zpool%E7%BB%B4%E6%8A%A4%E6%93%8D%E4%BD%9C%E5%AE%9E%E4%BE%8B#%E6%9B%BF%E6%8D%A2raidz3%E4%B8%AD%E7%9A%84%E6%95%85%E9%9A%9C%E7%A3%81%E7%9B%98

https://zhuanlan.zhihu.com/p/109041197

https://blog.csdn.net/dazuiba008/article/details/70799907

https://blog.csdn.net/beiya123/article/details/104652013

https://blog.51cto.com/199818/665182

https://blog.csdn.net/aaron_2019/article/details/94577584

https://docs.oracle.com/cd/E56344_01/html/E54077/zdb-1m.html#scrolltoc