CloudEncryptedCync S3 Adapter
=============================

An Amazon S3 adapter for the [CloudEncryptedSync](https://github.com/jsgarvin/cloud_encrypted_sync) Ruby gem.

This gem works in tandem with [CloudEncryptedSync](https://github.com/jsgarvin/cloud_encrypted_sync) (CES) to backup
encrypted copies of files in a local folder to a bucket on Amazon S3.

In addition to arguments required by [CES](https://github.com/jsgarvin/cloud_encrypted_sync), this adapter also requires
the following...

* `--bucket BUCKETNAME` The name of the S3 bucket that files are to be written to
* `--access-key ACCESSKEY` Your Amazon S3 Access Key
* `--access_key_id KEYID` Your Amazon S3 Access Key ID

Please refer to the [CES](https://github.com/jsgarvin/cloud_encrypted_sync) gem for additional information.