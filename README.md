tf-aws-lambda-rds-snapshot
========================

Takes snapshots of an RDS instance on a schedule.

This module is to be used as an alternative or in conjunction with RDS automated backups.
This module will take snapshots of an RDS Databse instance based on a cron schedule that you specify, it will also cleanup snapshots older than _n_ number of days using the variable `delete_snapshot_older_than`. 

##### Use cases
> Automated snapshots are purged on DB instance deletion whereas manual snapshots are retained.

> Automated snapshot retention is limited to 35 days whereas you can have up to 100 manual snapshots in a given region.

> Can call the module multiple times to have more than one snapshot per day if required

<br />
Usage
-----

```js
module "rds_snapshots" {
  source                     = "../modules/tf-aws-lambda-rds-snapshot"
  name                       = "${var.customer}"
  envname                    = "${var.envname}"
  cron_start_schedule        = "cron(00 12 * * ? *)"
  db_id                      = "${module.database.identifier}"
  db_instance_name           = "dev-rds"
  delete_snapshot_older_than = "25"
}
```

Variables
---------
_Variables marked with **[*]** are mandatory._

- `name` - The prefix for resources created by this module. **[*]**
- `envname` - Interpolated into the name of resources created by this module in position 2.  **[*]**
- `cron_start_schedule` - The schedule for taking RDS snapshots, specified in a cron or rate expression. For more information on expressions please see the [AWS User Docs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html). **[*]**
- `db_id` - The ID of the RDS instance you wish to take snapshots of. **[*]**
- `db_instance_name` - The name of the RDS instance you wish to take snapshots of. **[*]**
- `delete_snapshot_older_than` - The number of days that you want to retain RDS snapshots for. **[*]**
<br />

Outputs
-------
_None_
<br />

Future development tasks
--------
* Post backup completion and deletion messages to customers slack channel
* Multiple cron schedules
