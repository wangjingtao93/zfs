dnl #
dnl # The fallocate callback was moved from the inode_operations
dnl # structure to the file_operations structure.
dnl #
AC_DEFUN([ZFS_AC_KERNEL_SRC_FALLOCATE], [

	dnl # Linux 2.6.38 - 3.x API
	ZFS_LINUX_TEST_SRC([file_fallocate], [
		#include <linux/fs.h>

		long test_fallocate(struct file *file, int mode,
		    loff_t offset, loff_t len) { return 0; }

		static const struct file_operations
		    fops __attribute__ ((unused)) = {
			.fallocate = test_fallocate,
		};
	], [])

	dnl # Linux 2.6.x - 2.6.37 API
	ZFS_LINUX_TEST_SRC([inode_fallocate], [
		#include <linux/fs.h>

		long test_fallocate(struct inode *inode, int mode,
		    loff_t offset, loff_t len) { return 0; }

		static const struct inode_operations
		    fops __attribute__ ((unused)) = {
			.fallocate = test_fallocate,
		};
	], [])
])

AC_DEFUN([ZFS_AC_KERNEL_FALLOCATE], [
	AC_MSG_CHECKING([whether fops->fallocate() exists])
	ZFS_LINUX_TEST_RESULT([file_fallocate], [
		AC_MSG_RESULT(yes)
		AC_DEFINE(HAVE_FILE_FALLOCATE, 1, [fops->fallocate() exists])
	],[
		AC_MSG_RESULT(no)
	])

	AC_MSG_CHECKING([whether iops->fallocate() exists])
	ZFS_LINUX_TEST_RESULT([inode_fallocate], [
		AC_MSG_RESULT(yes)
		AC_DEFINE(HAVE_INODE_FALLOCATE, 1, [fops->fallocate() exists])
	],[
		AC_MSG_RESULT(no)
	])
])
