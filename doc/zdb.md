> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://www.freebsd.org/cgi/man.cgi?query=zdb&sektion=8&manpath=FreeBSD+12.1-RELEASE+and+Ports

```vim
ZDB(8)			  BSD System Manager's Manual			ZDB(8)

NAME
     zdb -- display zpool debugging and	consistency information(显示zpool调试和一致性信息)

SYNOPSIS（概述）
     zdb [-AbcdDFGhikLMPsvX] [-e [-V] [-p path ...]] [-I inflight I/Os]	[-o
	 var=value]... [-t txg]	[-U cache] [-x dumpdir]
	 [poolname [object ...]]
     zdb [-AdiPv] [-e [-V] [-p path ...]] [-U cache] dataset [object ...]
     zdb -C [-A] [-U cache]
     zdb -E [-A] word0:word1:...:word15
     zdb -l [-Aqu] device
     zdb -m [-AFLPX] [-e [-V] [-p path ...]] [-t txg] [-U cache] poolname
	 [vdev [metaslab ...]]
     zdb -O dataset path
     zdb -R [-A] [-e [-V] [-p path ...]] [-U cache] poolname
	 vdev:offset:size[:flags]
     zdb -S [-AP] [-e [-V] [-p path ...]] [-U cache] poolname

DESCRIPTION
     The zdb utility displays information about	a ZFS pool useful for debug-
     ging and performs some amount of consistency checking.  It	is a not a
     general purpose tool and options (and facilities) may change.  This is
     neither a fsck(8) nor an fsdb(8) utility.zdb实用程序显示对调试调试有用的ZFS池的信息，并执行一些一致性检查。它不是一个通用的工具和选项(和设施)可能会改变。这既不是fsck(8)也不是fsdb(8)实用程序。

     The output	of this	command	in general reflects the	on-disk	structure of a
     ZFS pool, and is inherently unstable.  The	precise	output of most invoca-
     tions is not documented, a	knowledge of ZFS internals is assumed.该命令的输出通
     常反映了ZFS池的磁盘结构，并且天生就不稳定。大多数调用的精确输出没有文档记录，假设您了
     解ZFS的内部原理。

     If	the dataset argument does not contain any "/" or "@" characters, it is
     interpreted as a pool name.  The root dataset can be specified as pool/
     (pool name	followed by a slash).
     果dataset参数不包含任何“/”或“@”字符，则将其解释为池名。可以将根数据集指定为池/(池名后
     跟斜线)。

     When operating on an imported and active pool it is possible, though un-
     likely, that zdb may interpret inconsistent pool data and behave errati-
     cally.当操作一个已经导入的和活动的池是可能的，虽然不太可能zdb可能会解释不一致的池数
     据，并表现出错误的行为

OPTIONS
     Display options:

     -b	     Display statistics	regarding the number, size (logical, physical
	     and allocated) and	deduplication of blocks.显示有关块的数量、大小(逻辑的、物理
              的和已分配的)和重复数据删除的统计信息。

     -c	     Verify the	checksum of all	metadata blocks	while printing block
	     statistics	(see -b).在打印块统计信息时，验证所有元数据块的校验和

	     If	specified multiple times, verify the checksums of all blocks.
            如果指定多次，验证所有块的校验和

     -C	     Display information about the configuration.  If specified	with
	     no	other options, instead display information about the cache
	     file (/boot/zfs/zpool.cache).  To specify the cache file to dis-
	     play, see -U.
         显示有关配置的信息。如果没有指定其他选项，则显示有关缓存文件(/boot/zfs/
         zpool.cache)的信息。要指定要dis- play的缓存文件，请参见- u。

	     If	specified multiple times, and a	pool name is also specified
	     display both the cached configuration and the on-disk configura-
	     tion.  If specified multiple times	with -e	also display the con-
	     figuration	that would be used were	the pool to be imported.
         如果多次指定，并且指定了池名，则同时显示缓存的配置和磁盘上的configura- tion。
         如果使用-e多次指定，还将显示导入池时将使用的配置。

     -d	     Display information about datasets.  Specified once, displays ba-
	     sic dataset information: ID, create transaction, size, and	object
	     count.
         显示有关数据集的信息。指定一次后，将显示ba- sic数据集信息:ID、创建事务、
         大小和对象计数。

	     If	specified multiple times provides greater and greater ver-
	     bosity.
         如果多次指定，则提供越来越大的带宽。

	     If	object IDs are specified, display information about those spe-
	     cific objects only.
         如果指定了对象id，则仅显示那些特定对象的信息。

     -D	     Display deduplication statistics, including the deduplication ra-
	     tio (dedup), compression ratio (compress),	inflation due to the
	     zfs copies	property (copies), and an overall effective ratio
	     (dedup * compress / copies).
         显示重复数据删除统计数据，包括重复数据删除数据(dedup)、压缩比(compress)、
         由zfs拷贝属性引起的膨胀(copies)和总有效比(dedup * compress / copies)。

     -DD     Display a histogram of deduplication statistics, showing the al-
	     located (physically present on disk) and referenced (logically
	     referenced	in the pool) block counts and sizes by reference
	     count.

     -DDD    Display the statistics independently for each deduplication ta-
	     ble.

     -DDDD   Dump the contents of the deduplication tables describing dupli-
	     cate blocks.

     -DDDDD  Also dump the contents of the deduplication(重复) tables	describing
	     unique blocks.

     -E	word0:word1:...:word15
	     Decode and	display	block from an embedded block pointer specified
	     by	the word arguments.
         从由字参数指定的嵌入块指针解码和显示块。

     -h	     Display pool history similar to zpool history, but	include	inter-
	     nal changes, transaction, and dataset information
         显示与zpool历史类似的池历史，但包括内部更改、事务和数据集信息。.

     -i	     Display information about intent log (ZIL)	entries	relating to
	     each dataset.  If specified multiple times, display counts	of
	     each intent log transaction（事务） type.
         显示关于与每个数据集相关的intent log (ZIL)条目的信息。如果多次指定，则显示每个
         intent日志事务类型的计数。

     -k	     Examine the checkpointed state of the pool.  Note,	the on disk
	     format of the pool	is not reverted	to the checkpointed state.
         检查池的检查点状态。注意，池的磁盘格式没有恢复到检查点状态。

     -l	device
	     Read the vdev labels from the specified device.  zdb -l will re-
	     turn 0 if valid label was found, 1	if error occurred, and 2 if no
	     valid labels were found.
         从指定的设备读取vdev标签。如果发现有效标签，zdb -l将返回0;如果发现错误，将返回1;如果没有发现有效标签，将返回2。

	     If	the -q option is also specified, don't print the labels.

	     If	the -u option is also specified, also display the uberblocks（超级快）
	     on	this device.

     -L	     Disable leak tracing and the loading of space maps.  By default,
	     zdb verifies that all non-free blocks are referenced, which can
	     be	very expensive.
         禁用泄漏跟踪和空间映射的加载，默认情况下，zdb验证引用了所有非空闲块，这可能非常昂贵。

     -m	     Display the offset, spacemap, and free space of each metaslab.

     -mm     Also display information about the	on-disk	free space histogram
	     associated	with each metaslab.

     -mmm    Display the maximum contiguous free space,	the in-core free space
	     histogram,	and the	percentage of free space in each space map.

     -mmmm   Display every spacemap record.

     -M	     Display the offset, spacemap, and free space of each metaslab.

     -MM     Also display information about the	maximum	contiguous free	space
	     and the percentage	of free	space in each space map.

     -MMM    Display every spacemap record.

     -O	dataset	path
	     Look up the specified path	inside of the dataset and display its
	     metadata and indirect blocks.  Specified path must	be relative to
	     the root of dataset.  This	option can be combined with -v for in-
	     creasing verbosity.
         查找数据集内部的指定路径，并显示其元数据和间接块。指定的路径必须相对于
         数据集的根。此选项可与-v组合，用于增加冗余。

     -R	poolname vdev:offset:size[:flags]
	     Read and display a	block from the specified device.  By default
	     the block is displayed as a hex dump, but see the description of
	     the r flag, below.
         从指定设备读取并显示一个块。默认情况下，块显示为十六进制转储，但请参见下面的r标记说明。
         

	     The block is specified in terms of	a colon-separated tuple	vdev
	     (an integer vdev identifier) offset (the offset within the	vdev)
	     size (the size of the block to read) and, optionally, flags (a
	     set of flags, described below).
         块是根据冒号分隔的元组vdev(一个整数vdev标识符)偏移量(vdev中的偏移量)
         大小(要读取的块的大小)和标记(可选)(一组标记，如下所述)来指定的。

	     b offset  Print block pointer
	     d	       Decompress the block
	     e	       Byte swap the block
	     g	       Dump gang block header
	     i	       Dump indirect block
	     r	       Dump raw	uninterpreted block data

     -s	     Report statistics on zdb I/O.  Display operation counts, band-
	     width, and	error counts of	I/O to the pool	from zdb.
         报告zdb I/O的统计数据。显示从zdb到池的操作计数、带宽和I/O的错误计数。

     -S	     Simulate the effects of deduplication, constructing a DDT and
	     then display that DDT as with -DD.
         模拟重复数据删除的效果，构造一个DDT，然后用-DD显示DDT。

     -u	     Display the current uberblock.
            显示当前uberblock。
     Other options:

     -A	     Do	not abort should any assertion fail.

     -AA     Enable panic recovery, certain errors which would otherwise be
	     fatal are demoted to warnings.

     -AAA    Do	not abort if asserts fail and also enable panic	recovery.

     -e	[-p path ...]
	     Operate on	an exported pool, not present in
	     /boot/zfs/zpool.cache.  The -p flag specifies the path under
	     which devices are to be searched.

     -x	dumpdir
	     All blocks	accessed will be copied	to files in the	specified di-
	     rectory.  The blocks will be placed in sparse files whose name is
	     the same as that of the file or device read.  zdb can be then run
	     on	the generated files.  Note that	the -bbc flags are sufficient
	     to	access (and thus copy) all metadata on the pool.

     -F	     Attempt to	make an	unreadable pool	readable by trying progres-
	     sively older transactions.

     -G	     Dump the contents of the zfs_dbgmsg buffer	before exiting zdb.
	     zfs_dbgmsg	is a buffer used by ZFS	to dump	advanced debug infor-
	     mation.

     -I	inflight I/Os
	     Limit the number of outstanding checksum I/Os to the specified
	     value.  The default value is 200.	This option affects the	per-
	     formance of the -c	option.

     -o	var=value ...
	     Set the given global libzpool variable to the provided value.
	     The value must be an unsigned 32-bit integer.  Currently only
	     little-endian systems are supported to avoid accidentally setting
	     the high 32 bits of 64-bit	variables.

     -P	     Print numbers in an unscaled form more amenable to	parsing, eg.
	     1000000 rather than 1M.
         以更易于解析的无标度形式打印数字

     -t	transaction
	     Specify the highest transaction to	use when searching for
	     uberblocks.  See also the -u and -l options for a means to	see
	     the available uberblocks and their	associated transaction num-
	     bers.
         确定在搜索uberblocks时要使用的最高事务。请参阅-u和-l选项，以查看可用的uberblocks及其相关的事务编号。

     -U	cachefile
	     Use a cache file other than /boot/zfs/zpool.cache.

     -v	     Enable verbosity.	Specify	multiple times for increased ver-
	     bosity.
         启用冗长。多次指定以增加流量。

     -V	     Attempt verbatim import.  This mimics the behavior	of the kernel
	     when loading a pool from a	cachefile.  Only usable	with -e.
         尝试逐字导入。这模拟了从缓存文件加载池时内核的行为。

     -X	     Attempt "extreme" transaction rewind, that	is attempt the same
	     recovery as -F but	read transactions otherwise deemed too old.
         尝试“极端”事务回退，即尝试与-F相同的恢复，但读取被认为太旧的事务。

     Specifying	a display option more than once	enables	verbosity for only
     that option, with more occurrences	enabling more verbosity.
     不止一次地指定一个显示选项只会使该选项变得冗长，出现次数越多，
     则会使该选项变得更冗长。

     If	no options are specified, all information about	the named pool will be
     displayed at default verbosity.
     如果没有指定选项，则有关指定池的所有信息都将以默认的详细方式显示。

EXAMPLES
     Example 1 Display the configuration of imported pool rpool

	     # zdb -C rpool

	     MOS Configuration:
		     version: 28
		     name: 'rpool'
	      ...

     Example 2 Display basic dataset information about rpool

	     # zdb -d rpool
	     Dataset mos [META], ID 0, cr_txg 4, 26.9M,	1051 objects
	     Dataset rpool/swap	[ZVOL],	ID 59, cr_txg 356, 486M, 2 objects
	      ...

     Example 3 Display basic information about object 0	in rpool/export/home

	     # zdb -d rpool/export/home	0
	     Dataset rpool/export/home [ZPL], ID 137, cr_txg 1546, 32K,	8 objects

		 Object	 lvl   iblk   dblk  dsize  lsize   %full  type
		      0	   7	16K    16K  15.0K    16K   25.00  DMU dnode

     Example 4 Display the predicted effect of enabling	deduplication on rpool
     显示在rpool上启用重复数据删除的预期效果

	     # zdb -S rpool
	     Simulated DDT histogram:

	     bucket		 allocated			 referenced
	     ______   ______________________________   ______________________________
	     refcnt   blocks   LSIZE   PSIZE   DSIZE   blocks	LSIZE	PSIZE	DSIZE
	     ------   ------   -----   -----   -----   ------	-----	-----	-----
		  1	694K   27.1G   15.0G   15.0G	 694K	27.1G	15.0G	15.0G
		  2    35.0K   1.33G	699M	699M	74.7K	2.79G	1.45G	1.45G
	      ...
	     dedup = 1.11, compress = 1.80, copies = 1.00, dedup * compress / copies = 2.00

SEE ALSO
     zfs(8), zpool(8)

BSD			       October 06, 2017				   BSD
```

* * *
