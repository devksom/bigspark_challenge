resource "aws_db_instance" "bsrdsmysql" {
  allocated_storage = 10
  max_allocated_storage = 500
  storage_type = "gp2"
  db_name = "db"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  username = "dbsteve"
  password = "dbpass22"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = true
  backup_retention_period= 10
  port = 3306
  skip_final_snapshot = true #to allow avoid terraform destroy from facing error
  
}
