tf-aws-lambda-rds-snapshot
========================

This module is to be used as an alternative or in conjunction with rds automated backups



Usage
-----

Declare a module in your Terraform file, for example:

## module for RDS Snapshots

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

- `name`                       - name of customer `(Required)`
- `envname`                    - name of environment `(Required)`
- `cron_start_schedule`        - use cron expression - default schedule is "cron(0 7   ? )" `(Required)`
- `aws_region`                 - default region is "eu-west-1"
- `db_id`                      - id of the rds instance `(Required)`
- `db_instance_name`           - name of the rds instance `(Required)`
- `delete_snapshot_older_than` - number of days that you want to retain rds snapshots `(Required)`


Outputs
-------

