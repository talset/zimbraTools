zimbraTools
===========

Scripts Zimbra

#sizeAccount.pl

Find instantly account size with mysql size_checkpoint.
You have to fix the following variables if necessary.

##Example of use:

```bash
  ssh zimbra@domain.com
  su - zimbra
  ./sizeAccount.pl
```

#restoreDirMailbox.pl

Can restore a directory from a backup into an account.
Restore an account in account_bak, copy a directory into account and delete account_bak.

##Example of use:
```bash
  restoreDirMailbox.pl <account@domain.com> <LabelBackup> <dir/subdir...>
```
