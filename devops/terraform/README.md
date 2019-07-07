# Terraform

## Important Links

1. [Why we use Terraform and not Chef, Puppet, Ansible, SaltStack, or CloudFormation](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c) - By Yevgeniy Brikman
2. [An Introduction to Terraform](https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180) - By Yevgeniy Brikman
3. [How to manage Terraform state](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa) - By Yevgeniy Brikman
4. [How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d) - By Yevgeniy Brikman
5. [Usful Scripts](https://github.com/wardviaene/terraform-course)
6. [Terraform Documentation](https://www.terraform.io/docs/configuration-0-11/index.html)
7. [Terraform AWS Documentation](https://www.terraform.io/docs/providers/aws/index.html)
8. [Terraform Built-in Function list](https://www.terraform.io/docs/configuration/functions.html)
9. [Terraform AWS Community Modules](https://github.com//terraform-aws-modules/)

## General Information

- Infrastructure as code
- Automation of your infrastracture
- Keep your infrastructure in a certain state
- e.g. 2 web instances with 2 volumes, and 1 load balancer
- Make your infrastucture auditable
- You can keep your infra change history in a version control system like GIT
- Ansible, Chef, Puppet, Saltstack have a focus on automating the installation
and configuration of software
- Keeping the machines in compliance, in a certain stage
- Terraform can automate provisioning of the infra itself
- e.g. Using the AWS, DigitalOcean, Azure API
- Works well with automation software like ansible to install software after
the infra is provisioned

## Installation

- Go to the terraform website, download for your os, move the executable to a PATH folder

## AWS

- Spinning up an instance on AWS
- Example:

    ```terraform
    provider "aws" {
        region = "us-east-1"
    }

    resource "aws_instance" "example"{
        ami = "AMI_ID"
        instance_type = "t2.micro"
    }
    ```
- To run: `terraform apply`
- To destory: `terraform destroy`

## Variables

- Everything in one file is not great
- Use variables to hide secrets
- You dont want the AWS credentials in your git repository
- Use variables for elements that might change
- AMIs are different per region
- Use variables to make it yourself easier to reuse terraform files
- current main.tf file:
    ```terraform
     provider "aws" {
         region = "us-east-1"
     }

      resource "aws_instance" "example"{
         ami = "AMI_ID"
         instance_type = "t2.micro"
     }
     ```
- To access variables, the syntax is: `${var.VARNAME}`
- main.tf will be splitted into four files: provider.tf, vars.tf, terraform.tfvars, instance.tf
- provider.tf (version < 0.12):
    ```terraform
    provider "aws" {
        access_key = "${var.AWS_ACCESS_KEY}"
        secret_key = "${var.AWS_SECRET_KEY}"
        region = "${var.AWS_REGION}"
    }
    ```
- provider.tf (version > 0.12):
    ```terraform
    provider "aws" {
        access_key = var.AWS_ACCESS_KEY
        secret_key = var.AWS_SECRET_KEY
        region = var.AWS_REGION
    }
    ```
- vars.tf (version < 0.12):
    ```terraform
    variable "AWS_ACCESS_KEY" {}
    variable "AWS_SECRET_KEY" {}
    variable "AWS_REGION" {
        default = "us-east-1"
    }
    variable "AMIS" {
        type = "map"
        default = {
            us-east-1 = "AMI1"
            us-west-2 = "AMI2"
            eu-west-1 = "AMI3"
        }
    }
    ```
- vars.tf (version > 0.12):
    ```terraform
    variable "AWS_ACCESS_KEY" {}
    variable "AWS_SECRET_KEY" {}
    variable "AWS_REGION" {
        default = "us-east-1"
    }
    variable "AMIS" {
        type = map(string)
        default = {
            us-east-1 = "AMI1"
            us-west-2 = "AMI2"
            eu-west-1 = "AMI3"
        }
    }
    ```
- terraform.tfvars:
    ```terraform
    AWS_ACCESS_KEY=""
    AWS_SECRET_KEY=""
    AWS_REGION=""
    ```
- instance.tf (version < 0.12):
    ```terraform
    resource "aws_intance" "example" {
        ami = "${lookup(var.AMIS, var.AWS_REGION)}"
        instance_type = "t2.micro"
    }
    ```
- instance.tf (version > 0.12):
    ```terraform
    resouce "aws_instance" "example" {
        ami = var.AMIS[var.AWS_REGION]
        instance_type = "t2.micro"
    }
    ```

## Software Provisioning

- There are 2 ways to probision software on your instances
- You can build your own custom AMI and bundle your software with the image
    - Packer is a great tool to do this
- Another way is to boot standardied AMIs, and then install the software on it you need
    - Using file uploads
    - Using remote exec
    - Using automation tools

### File Uploads

- There is an option to add a 'file upload' provisioner:

    ```terraform
    provisioner "file" {
        source = "app.conf"
        destination = "/etc/myapp.conf"
    }
    ```
- File uploads is an easy way to upload a file or a script
- Can be used in conjunction with remote-exec to execute a script
- The provisioner may use SSH or WinRM
- To override the SSH defaults, you can use "connection" (version < 0.12):
    ```terraform
    provisioner "file" {
        source = "script.sh"
        destination = "/opt/script.sh"
        connection {
            user = "${var.instance_username}"
            password = "${var.instance_password}"
        }
    }
    ```
- connection (version > 0.12):
    ```terraform
    provisioner "file" {
        source = "script.sh"
        destination = "/opt/script.sh"
        connection {
            user = var.instance_username
            password = var.instance_password
        }
    }
    ```
- When spinning up instances on AWS, ec2-user is the default user for Amazon Linux and ubuntu for Ubuntu Linux.
- Typically on AWS, you'll use SSH keypairs (version < 0.12):
    ```terraform
    resource "aws_key_pair" "evya-key" {
        key_name = "mykey"
        public_key = "ssh-rsa my-public-key"
    }

    resource "aws_instance" "example" {
        ami = "${lookup(var.AMIS, var.AWS_REGION)}"
        instance_type = "t2.micro"
        key_name = "${aws_key_pair.mykey.key_name}"

        provisioner "file" {
            source = "script.sh"
            destination = "/opt/script.sh"
            connection {
                user = "${var.instance_username}"
                private_key = "${file(${var.path_to_private_key})}"
            }
        }
    }
    ```
- SSH keypairs (version > 0.12):
    ```terraform
    resource "aws_key_pair" "evya-key" {
        key_name = "mykey"
        public_key = "ssh-rsa my-public-key"
    }

    resource "aws_instance" "example" {
        ami = var.AMIS[var.AWS_REGION]
        instance_type = "t2.micro"
        key_name = aws_key_pair.mykey.key_name

        provisioner "file" {
            source = "script.sh"
            destination = "/opt/script.sh"
            connection {
                user = var.instance_username
                private_key = file(var.path_to_private_key)
            }
        }
    }
    ```
- After you uploaded a script, you'll want to execute it
- You can execute a script using remote-exec:
    ```terraform
    ...
    provisioner "remote-exec" {
        inline = [
            "chmod +x /opt/script.sh",
            "/opt/script.sh arguments"
        ]
    }
    ...
    ```

## Output

-  Terraform keeps attributes of all resources you create
- e.g the aws_instance resource has the attribute public_ip
- Those attributes can be queried and outputted
- This can be useful just to output valuable information or to feed information to external software
- Use output to display the public IP address of an AWS resource:

    ```terraform
    output "ip" {
        value = "${aws_instance.example.public_ip}"
    }
    ```
    or
    ```terraform
    output "ip" {
        value = aws_instance.example.public_ip
    }
    ```
- You can refer to any attribute by specifying the following elements in your variable:
    - The resource type: aws_instance
    - The resource name: example
    - The attribute name: public_ip
- You can also use the attributes in a script
- Useful for instance to start automation scripts after infra provisioning
- You can populate the IP addresses in an ansible host file
- Or another possibility: execute a script (with attributes as argument) which will take care of a mapping of resource nam and the IP address

## Terraform State

- Terraform keeps the remote stat of the infra
- It stores it in a file called `terraform.tfstate`
- There is also a backup of the previous state in `terraform.tfstate.backup`
- When you execute terraform apply, a new terraform.tfstate and backup is written
- This is how terraform keeps track of the remote state
- If the remote state changes and you hit terraform apply again, terraform will make changes to meet the correct remote state again.
- e.g. you terminate an instance that is managed by terraform, after terraform apply it will be started again.
- You can keep the terraform.tfstate in version control
- It gives you a history of your terraform.tfstate file
- It allows you to collaborate with other team members
- Unfortunately you can get conflicts when 2 people work at the same time
- Local state works well in the beginning, but when your project becomes bigger, you might want to store your state remotely.
- The terraform state can be saved remotely, using the backend functionality in terraform
- The default is a local backend
- Other backends include:
    - S3 (with a locking mechanism using dynamoDB)
    - Consul
    - Terraform Enterprise
- Using the backend functionality has definitely benfints:
    - Working in a team: it allows for collaboration, the remote state will always be available for the whole team
    - The state file is not stored locally. Possible sensitive information is now only stored in the remote state
    - Some backends will enable remote operations. The terraform apply will then run completely remote. Therese are called the enhanced backends.
- There are 2 steps to configure a remote state:
    - Add the backend code to a .tf file
    - Run the initalization process
- To configure a consul remote store, you can add a file `backend.tf` with the following contents:

    ```terraform
    terraform {
        backend "consul" {
            address = "demo.consul.io"
            path = "terraform/myproject"
        }
    }
    ```
- You can only store your state in S3:

    ```terraform
    terraform {
        backend "s3" {
            bucket = "mybucket"
            key = "terraform/myproject"
            region = "us-east-1"
        }
    }
    ```
- When using an S3 remote state, it's best to configure the aws credentials
- Using a remote store for terraform state will ensure that you always have the latest version of the state
- It avoids having to commit and push the terraform.tfstate to version control
- Terraform remote stores dont always support locking
    - The documentation always mentions if locking is available for a remote store
    - S3 and Consul support it

## Datasources

- For certain providers (like AWS), terraform provides datasources
- Datasources provide you with dynamic information
- A lot of data is available by AWS in a structured format using their API
- Terraform also exposes this information using datas sources
- Examples
    - List of AMIs
    - List of Availability Zones
- Another greate example is the datasource that gives you all IP addresses in use by AWS
- This is great if you want to filter traffic based on an AWS region
    - e.g. allow all traffic from amazon instances in Europe
- Filtering traffic in AWS can be done using security groups
    - Incoming and outgoing traffic can be filtered by protocol, IP range, and port
    - Similar to iptables or a firewall appliance
- Example:

    ```terraform
    data "aws_ip_ranges" "europe_ec2" {
        regions = ["eu-west-1", "eu-central-1"]
        services = ["ec2"]
    }

    resource "aws_security_group" "from_europe" {
        name = "from_europe"

        ingress {
            from_port = "443"
            to_port = "443"
            protocol = "tcp"
            cidr_blocks = [ "${data.aws_ip_ranges.europe_ec2.cidr_blocks}" ]
        }
        tags {
            CreateDate = "${data.aws_ip_ranges.europe_ec2.create_date}"
            SyncToken = "${data.aws_ip_ranges.europe_ec2.sync_token}"
        }
    }
    ```

## Template Provider

- The template provider can help creating customized configuration files
- You can build templates based on variables from terraform resource attributes
- The result is a string that can be used as a variable in terraform
    - The string contains a template
    - e.g. a configuration file
- Can be used to create a generic templates or cloud init configs.
- In AWS, you can pass commands that need to be executed when the instance starts for the first time
- In AWS this is called "user-data"
- If you want to pass user-data that depends on other information in terraform, you can use the provider template
- further explanatioln on the matter will come later on.
- First you create a template file:

    ```bash
    echo "database-ip = ${myip}" >> /etc/myapp.config
    ```
- Then you create a template_file resource that will read the template file and replace ${myip} with the IP address of an AWS instance created by terraform:
    ```terraform
    data "template_file" "my-template" {
        template = "${file("templates/init.tpl")}"

        vars {
            myip = "${aws_instance.database1.private_ip}"
        }
    }
    ```
- Then you can use the my-template resource when creating a new instance:

    ```terraform
    resource "aws_instance" "web" {
        user_data = "${data.template_file.my-template.rendered}"
    }
    ```
- When terraform runs, it will see that it first needs to spin up the database1 instance, then generate the template, and only then spin up the web instance.
- The web instance will have the template injected in the user_data, and when it launches, the user-data will create a file /etc/myapp.config with the Ip address of the database.

## Modules

- You can use modules to make your terraform more organized
- Use third party modules
    - Modules from github
- Reuse parts of your code
    - e.g. to set up network in AWS - The VPC
- To use a module from git:

    ```terraform
    module "module-example"{
        source = "github.com/user/project"
    }
    ```

- To use a module from local folder:

    ```terraform
    module "module-example"{
        source = "./folder-name"
    }
    ```

- Pass arguments to the module

    ```terraform
    module "module-example" {
        source = "./folder-name"
        region = "us-east-1"
        ip-range = "10.0.0.0/8"
        cluster-size = "3"
    }
    ```
- Use the output from the module in the main part of your code:

    ```terraform
    output "some-output" {
        value = "${module.module-example.aws-cluster}"
    }
    ```

### Module Development

- Terraform modules are a powerful way to reuse code
- You can either use external modules, or write modules yourself
- External modules can help you setting up infrastructure without much effor
    - When modules are managed by the community, you'll get updates and fixes for free
    - Please check the link at the top of the page for Terraform's AWS community modules
    - A few popular modules are:
        - A module to create VPC resources
        - A module to create an Application Load Balancer
        - A module to create a Kubernetes cluster (EKS)
- Writing modules yourself gives you full flexibility
- If you maintain the module in a git repo, you can even reuse the module over multiple projects

## Creating VPC

- On amazon AWS, you have a default VPC (Virtual Private Network) created for you by AWS to launch instances in
- Up until now we used this default VPC
- VPC isolates the instances on a network level
    - It's like your own private network in the cloud
- Best practice is to always launch your instances in a VPC
    - Either a default VPC
    - Or a custom one (recommended to be managed by terraform)
- There is also EC2-Classic, which is basically one big network where all AWS customers could launch their instances in.
- For smaller to medium setups, one VPC (per region) will be suitable for your needs
- An instance launched in one VPC can never communicate with an instance in an other VPC using their private IP addresses
    - They could communicate still, but using their public IP (not recommended)
    - You could also link 2 VPCs, called peering

### Private Subnets

- Whenever you are going to setup a VPC, you are going to see that the ip addresses that you can use are all private subnets (private ip addresses).
- Those subnets/ip addresses cannot be used on the internet, they are only to be used within a vpc.
- There are only a few private subnets:
    - 10.0.0.0/8
    - 172.16.0.0/12
    - 192.168.0.0/16
- Every availability zone has its own public and private subnet

## EC2 Instance

- Spinning up an EC2 instance is easy, some examples have been shown.
- To specify a vpc for an instance we need to supply security group and subnet
- A secuirty group is just like a firewall, managed by AWS
- You specify ingress (incoming) and egress (outgoing) traffic rules
- For example, if you want to access SSh (port 22), then you could create a security group that:
    - Allows ingress port 22 on IP address range 0.0.0.0/0 (Which means all IPs)
        - It is best practice to only allow your work/home/office IP address
    - Allows all outgoing traffic from the instance to 0.0.0.0/0 (all IPs)
- Example for security_group.tf

    ```terraform
    resource "aws_security_group" "allow-ssh" {
        vpc_id = "${aws_vpc.main.id}"
        # or
        vpc_id = "ID"
        name = "allow-ssh"
        description = "security group that allows ssh and all egress traffic"
        egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }

        ingress{
            from_port = 22
            to_port = 22
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }

        tags{
            Name = "Allow-SSH"
        }
    }
    ```

- To be able to login, the last step is to make sure AWS installs our public key pair on the instance
- Our EC2 instance already refers to a `aws_key_pair.mykeypair.key_name`, you just need to decalre it in the terraform:

    ```terraform
    resource "aws_key_pair" "mykeypair" {
        key_name = "mykeypair"
        public_key = "${file("keys/mykeypair.pub")}"
    }
    ```

- They keys/mykeypair.pub will be uploaded to AWS and will allow an instance to be launched with this public key installed on it
- **You never upload your private key!!** You use your private key to login to the instace

## EBS Storage

- The `t2.micro` instance with some particular AMI will automatically add 8 GB of EBS storage (Elastic Block Storage)
- Some instance types have local storage on the instance itself
    - This is called `ephemeral` storage
    - This type of storage is always lost when the instance terminates
- The 8 GB EBS root volume storage that comes with the instance is also set to be automatically removed when the instance is terminated
    - You could still instruct AWS not to do so, but that would be counter-intuitive (anti-pattern)
- In most cases the 8GB for the OS suffices
- Extra volumes can be used for log files, any read data that is put on the instance.
- That data will be pesisted until you instruct AWS to remove it
- EBS storage can be added using a terraform resource and then attached to our instance
- Example:

    ```terraform
    resource "aws_instance" "example" {
        ...
    }

    resource "aws_ebs_volume" "ebs-volume-1" {
        availability_zone = "us-east-1a"
        size = 20
        type = "gp2" # General Purpose storage, can also be standard or io1 or st1
        tags {
            Name = "extra volume data"
        }
    }

    resource "aws_volume_attachment" "ebs-volume-1-attachment" {
        device_name = "/dev/xvdh"
        volume_id = "${aws_ebs_volume.ebs-volume-1.id}"
        instance_id = "${aws_instance.example.id}"
    }
    ```

- This example will add an extra volume
    - Meaning the root volume of 8GB still exists
- If you want to increase the storage or type of the root volume, you can use `root_block_device` within the `aws_instance` resource:

    ```terraform
    resource "aws_instance" "example" {
        ...
        root_block_device {
            volume_size = 16
            volume_type = "gp2"
            delete_on_termination = true # whether to delete the root block device when the instance gets terminated or not
        }
    }
    ```

## UserData

- Userdata in aws can be used to do any customization at launch:
    - You can install extra software
    - Prepare the instance to join a cluster
        - e.g. consul cluster, ECS cluster (docker orchestration)
    - Execute commands / scripts
    - Mount volumes
- Userdata is only executed at the creation of the instance, not when the instance reboots
- Terraform allows you to add userdata to the `aws_instance` resource
    - Just as a string (for simple commands)
    - Using templates (for more complex instructions)
- Example for userdata usage to install OpenVPN app at boot time:

    ```terraform
    resource "aws_instance" "example" {
        ...

        user_data = <<-EOF
                    #!/bin/bash
                    wget http://swupdate.openvpn.org/as/openvpn-as-2.1.2-Ubuntu14.amd_64.deb
                    dpkg -i openvpn-as-2.1.2-Ubuntu14.amd_64.deb
                    EOF
    }
    ```

- Another better example is to use the template system of terraform:

    ```terraform
    resource "aws_instance" "example" {
        ...

        user_data = "${data.template.name.rendered}"
    }
    ```

## Static IPs & DNS

- Private IP addresses will be auto-assigned to EC2 instances
- Every subnet within the VPC has its own range
- By specifying the private ip, you can make sure the EC2 instance will alaways uses the same IP address.

    ```terraform
    resource "aws_instance" "example" {
        ...
        private_ip = "10.0.0.14" # Assuming the ip is in the range of the subnet
    }
    ```

- To use a public IP address, you can use EIPs (Elastic IP Addresses)
- This is a public, static IP address that you can attach to your instance

    ```terraform
    resource "aws_eip" "example-eip" {
        instance = "${aws_instance.example.id}"
        vpc = true
    }
    ```

- You can use `aws_eip.example-eip.public_ip` attribute with the output resource to show the IP address after `terraform apply`

### Route53

- Typically, you'll not use IP addresses, but hostnames
- This is where Route53 comes in
- You can host a domain name on AWS using Route53
- You first need to register a domain name using AWS or any accredited registrar
- You can then create a zone in Route53 (e.g example.com) and add DNS records (e.g. server1.example.com)
- Adding a zone and records can also be done in terraform:

    ```terraform
    resource "aws_route53_zone" "exmaple-com" {
        name = "example.com"
    }

    resource "aws_route53_record" "server1-record" {
        zone_id = "${aws_route53_zone.example-com.zone_id}"
        name = "server1.example.com"
        type = "A"
        ttl = "300"
        records = ["${aws_eip.example-eip.public_ip}"]
    }
    ```

- When you register your domain name, you need to add the AWS nameservers to that domain
    - Route53 has a lot of nameservers. To know your nameservers for your particular domain, you can use the output resource to output property `aws_route53_zone.example-com.name_servers`

## RDS

- RDS stands for Relational Database Services
- It's a managed database solution:
    - You can easily setup replication (HA)
    - Automated snapshots (for backups)
    - Automated security updates
    - Easy instance replacement (for vertical scaling)
- Supported databases are:
    - MySQL
    - MariaDB
    - PostgreSQL
    - Microsoft SQL
    - Oracle
- Steps to create an RDS instance:
    - Create a subnet group
        - Allows you to specify in what subnets the datbase will be in (e.g. us-east-1a and us-east-1b)
    - Create a Parameter group
        - Allows you to specify parameters to change settings in the databse
    - Create a security group that allows incoming traffic to the RDS instance
    - Create the RDS instance(s) itself
- First the Parameter group:

    ```terraform
    resource "aws_db_parameter_group" "mariadb-parameters" {
        name = "mariadb-parameters"
        family = "mariadb10.1"
        description = "MariaDB parameter group"

        parameter {
            name = "max_allowed_packet"
            value = "16777216"
        }
    }
    ```

- Second, we specify the subnet:

    ```terraform
    resource "aws_db_subnet_group" "mariadb-subnet" {
        name = "mariadb-subnet"
        description = "RDS subnet group"
        subnet_ids = ["ID1", "ID2"]
    }
    ```

- This subnet group specifies that the RDS will be put in the private subnets
- The RDS will only be accessible from other instances within the same subnet, not from the internet
- Third, the security group:

    ```terraform
    resource "aws_security_group" "allow-mariadb" {
        ...

        ingress {
            from_port = 3306
            to_port = 3306
            protocol = "tcp"
            security_groups = ["${aws_security_group.example.id}"]
        }
        egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            self = true
        }

        ...
    }
    ```

- Finally, we specify the RDS resource:

    ```terraform
    resource "aws_db_instance" "mariadb" {
        alloated_storage = 100 # 100 GB of storage
        engine = "mariadb"
        engine_version = "10.1.14"
        instance_class = "db.t2.small"
        identifier = "mariadb"
        name = "mariadb"
        username = "root"
        password = "some-password"
        db_subnet_group_name = "${aws_db_subnet_group.mariadb-subnet.name}"
        parameter_group_name = "mariadb-parameters"
        multi_az = "false" # set to true to have HA
        vpc_security_group_ids = ["${aws_security_group.allow-mariadb.id}"]
        storage_type = "gp2"
        backup_retention_period = 30 # How long you're going to keep your backups
        availability_zone = "AZ"
        tags {
            Name = "mariadb-instance"
        }
    }
    ```

## IAM

- IAM is AWS Identity & Access Management
- It's a service that helps you control access to your AWS resources
- In AWS you can create:
    - Groups
    - Users
    - Roles
- Users can have groups
    - For instance "Administrators" group can give admin privileges to users
- Users can authenticate
    - Using a login / password
        - Optionally using a token: MFA using Google Authenticator compatible software
    - An access key and secret key (the API keys)

### IAM Roles

- Roles can give users / services (temporary) access that they normally would'nt have
- The roles can be fore instance attached to EC2 instances
    - From that instance, a user or service can obtain access credentials
    - Using those access credentials the user or service can assume the role, which gives them permission to do something.
- Example:
    - You create a role `mybucket-access` and assign the role to an EC2 instance at boot time
    - You give the role the permission to read and write items in `mybucket`
    - When you log in, you can now assume this `mybucket-access` role, without using your own credentials - you will be given temporary access credentials wich just look like normal credentials
    - You can now read and write items in `mybucket`
- Instead of a user using AWS-CLI, a service also assume a role
- The service needs to implement the AWS SDK
- When trying to access the S3 bucket, an API call to AWS will occur
- If roles are configured for ths EC2 instance, the AWS API will give temporary access keys which can be used to assume this role
- After that, the SDK can be used just like when you would have normal credentials
- This really happens in the background and you dont see much of it
- IAM roles only work on EC2 instances, and not for instance outside AWS
- The temporary access credentials also need to be renewed, they're only valid for a predefined amount of time.
    - This is also something the AWS SDK will take care of
- To create an IAM administrator group in AWS, you can create the group and attach the AWS managed Administrator policy to it.

    ```terraform
    resource "aws_iam_group" "administrators" {
        name = "administrators"
    }

    resource "aws_iam_policy_attachment" "administrators-attach" {
        name = "administrators-attach"
        groups = ["${aws_iam_group.administrators.name}"]
        policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
    ```

- You can also create your own custom policy. This one does the same:

    ```terraform
    resource "aws_iam_group_policy" "my_developer_policy" {
        name = "my_administartos_policy"
        group = "${aws_iam_group.administartors.id}"
        policy = <<EOF
        {
            "Version" : "version-number",
            "Statement" : [
                {
                    "Effect" : "Allow",
                    "Action" : "*",
                    "Resource" : "*"
                }
            ]
        }
        EOF
    }
    ```

- Next, create a user and attach it to a group:

    ```terraform
    resource "aws_iam_user" "admin1" {
        name = "admin1"
    }

    resource "aws_iam_user" "admin2" {
        name = "admin2"
    }

    resource "aws_iam_group_membership" "admins" {
        name = "admin-users"
        users = [
            "${aws_iam_user.admin1.name}",
            "${aws_iam_user.admin2.name}"
        ]
        group = "${aws_iam_group.administrators.name}"
    }
    ```

## Autoscaling

- In AWS autoscaling groups can be created to automatically add/remove instances when certain thresholds are reached
    - e.g. your application layer can be scaled out when you have more visitors
- To setup autoscaling in AWS you need to setup at least 2 resources
    - An AWS Launch Configuration
        - Specifies the properties of the instance to be launched (AMI ID, security group, etc)
    - An autoscaling group
        - Specifies the scaling properties (min instances, max instances, health checks)
- Once the autoscaling group is setup, you can create autoscaling policies
    - A policy is triggered based on a threshold (CloudWatch Alarm)
    - An adjustment will be executed
        - e.g. if the average CPU utilization is more than 20%, then scale up by +1 instances
        - e.g. if the average CPU utilization is less then 5%, then scale down by -1 instances
- First the launch configuration and the autoscaling group needs to be created:

    ```terraform
    resource "aws_launch_configuration" "example-launchconfig {
        name_prefix = "exmaple-launchconfig"
        image_id = "${lookup(var.AMIS, var.AWS_REGION)}"
        instance_type = "t2.micro"
        key_name = "${aws_key_pair.mykeypair.key_name}"
        security_groups = ["${aws_security_group.allow-ssh.id}"]
    }

    resource "aws_autoscaling_group" "example-autoscaling" {
        name = "example-autoscaling"
        vpc_zone_identifier = ["VPCID1", "VPCID2"] # For HA
        launch_configuration = "${aws_launch_configuration.example-launchconfig.name}"
        min_size = 1
        max_size = 2
        health_check_grace_period = 300
        health_check_type = "EC2"
        force_delete = true

        tag {
            key = "Name"
            value = "ec2 instance"
            propagate_at_launch = true
        }
    }
    ```

- For dynamic scaling, create an `aws_autoscaling_policy`:

    ```terraform
    resource "aws_autoscaling_policy" "example-cpu-policy" {
        name = "example-cpu-policy"
        autoscaling_group_name = "${aws_autoscaling_group.example-autoscaling.name}"
        adjustment_type = "ChangeInCapacity"
        scaling_adjustment = "1" # To decrease enter -1
        cooldown = "300"
        policy_type = "SimpleScaling"
    }
    ```

- Then, you can create a CloudWatch alarm which will trigger the autoscaling policy:

    ```terraform
    resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
        alarm_name = "example-cpu-alarm"
        alarm_description = "example-cpu-alarm"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods = "2"
        metric_name = "CPUUtilization"
        namespace = "AWS/EC2"
        period = "120"
        statistic = "Average"
        threshold = "30"

        dimensions = {
            "AutoScalingGroupName" = "${aws_autoscaling_group.example-autoscaling.name}"
        }

        actions_enabled = true
        alarm_actions = ["${aws_autoscaling_policy.example-cpu-policy.arn}"]
    }
    ```

- If you want to receive an alert (e.g. email) when autoscaling is invoked, you need to create a SNS topic (Simple Notification Service):

    ```terraform
    resource "aws_sns_topic" "example-cpu-sns" {
        name = "sg-cpu-sns"
        display_name = "example ASG SNS topic"
    }
    ```

- That SNS topic needs to be attached to the autoscaling group:

    ```terraform
    resource "aws_autoscaling_notification" "example-notify" {
        group_names = ["${aws_autoscaling_group.example-autoscaling.name}"]
        topic_arn = "${aws_sns_topic.example-cpu-sns.arn}"
        notifications = [
            "autoscaling:EC2_INSTANCE_LAUNCH",
            "autoscaling:EC2_INSTANCE_TERMINATE",
            "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
        ]
    }
    ```

## Elasic Load Balancer (ELB)

- Now that you've autoscaled instances, you might want to put a load balancer in front of it
- The AWS Elastic Load Balancer (ELB) automatically distributes incoming traffic across multiple EC2 instances
    - The ELB itself scales when you receive more traffic
    - The ELB will healthcheck your instances
    - If an instance fails its healthcheck, no traffic will be sent to it
    - If a new instance is added by the autoscaling group, the ELB will automatically add the new instances and will start healthchecking it
- The ELB can also be used as SSL terminator
    - It can offload the encryption away from the EC2 instances
    - AWS can even manage the SSL certificates for you
- ELBs can be spread over multiple AZ for higher fault tolerance
- You will in general achieve higher levels of fault tolerance with an ELB routing the traffic for your application
- ELB is comparable to an nginx / haproxy, but then provided as a service
- AWS provides 2 different types of load balancers:
    - The Classic Load Balancer (ELB)
        - Routes traffic based on network information
        - e.g. forwards all traffic from port 80 to port 8080
    - The Application Load Balancer (ALB)
        - Routes traffic based on application level information
        - e.g. can route `/api` and `/website` to different EC2 instances

### Classic Load Balancer

- Example:

    ```terraform
    resource "aws_elb" "my-elb" {
        name = "my-elb"
        subnets = ["ID1", "ID2"]
        security_groups = ["${aws_security_group.elb-securitygroup.id}"]

        listener {
            instance_port = 80
            instance_protocol = "http"
            lb_port = 80
            lb_protocol = "http"
        }

        health_check {
            healthy_threshold = 2
            unhealthy_threshold = 2
            timeout = 3 # In seconds
            target = "HTTP:80/" # Can be any target
            interval = 30
        }

        instances = ["${aws_instance.example-instance.id}"] # optional, you can also attach an ELB to an autoscaling group
        cross_zone_load_balancing = true
        connection_draining = true
        connection_draining_timout = 400
        tags {
            Name = "my-elb"
        }
    }
    ```

- You can attach the ELB to an autoscaling group:

    ```terraform
    resource "aws_launch_configuration" "example-launchconfig {
        name_prefix = "exmaple-launchconfig"
        image_id = "${lookup(var.AMIS, var.AWS_REGION)}"
        instance_type = "t2.micro"
        key_name = "${aws_key_pair.mykeypair.key_name}"
        security_groups = ["${aws_security_group.allow-ssh.id}"]
    }

    resource "aws_autoscaling_group" "example-autoscaling" {
        name = "example-autoscaling"
        vpc_zone_identifier = ["VPCID1", "VPCID2"] # For HA
        launch_configuration = "${aws_launch_configuration.example-launchconfig.name}"
        min_size = 1
        max_size = 2
        health_check_grace_period = 300
        health_check_type = "ELB" # This is new
        force_delete = true
        load_balancers = ["${aws_elb.my-elb.name}"] # This is new

        tag {
            key = "Name"
            value = "ec2 instance"
            propagate_at_launch = true
        }
    }

### Application Load Balancer

- For an application load balancer, you first define the general settings:

    ```terraform
    resource "aws_alb" "my-alb" {
        name = "my-alb"
        subnets = ["ID1", "ID2"]
        security_groups = ["${aws_security_group.elb-securitygroup.id}"]
        
        tag {
            Name = "my-alb"
        }
    }
    ```

- Then, you specify a target group:

    ```terraform
    resource "aws_alb_target_group" "fe-target-group" {
        name = "alb-target-group"
        port = 80
        protocol = "HTTP"
        vpc_id = "${aws_vpc.main.id}"
    }
    ```

- You can attach instances to targets:

    ```terraform
    resource "aws_alb_target_group_attachment" "fe-attachment-1" {
        target_group_arn = "${aws_alb_taget_group.fe-taget-group.arn}"
        target_id = "${aws_instance.example-instance.id}"
        port = 80
    }

    resource "aws_alb_target_group_attachment" "fe-attachment-2" {
        ...
    }
    ```

- You also need to specify the listeners separately:

    ```terraform
    resource "aws_alb_listener" "fe-listeners" {
        load_balancer_arn = "${aws_alb.my-alb.arn}"
        port = "80"

        default_action {
            target_group_arn = "${aws_alb_taget_group.fe-target-group.arn}"
            type = "forward"
        }
    }
    ```

- The default action matches always if you havent specified any other rules
- With ALBs, you can specify multiple rules to send traffic to another target:

    ```terraform
    resource "aws_alb_listener_rule" "alb-rule" {
        listener_arn = "${aws_alb_listener.fe-listeners.arn}"
        priority = 100

        action {
            type = "forward"
            target_group_arn = "${aws_alb_target_group.new-target-group.arn}"
        }

        condition {
            field = "path-pattern"
            values = ["/static/"]
        }
    }
    ```

## AWS EKS

- Amazon Elastic Container Service for Kubernetes is a highly available, scalable and secure kubernetes service
- AWS EKS provides managed Kubernetes master nodes
    - There's no master nodes to manage
    - The master nodes are multi-AZ to provide redundancy
    - The master nodes will scale automatically when necessary
        - If you'd run your own Kubernetes cluster, you'd have to scale it when having more worker nodes
    - Secure by default: EKS integrates with IAM

### EKS vs ECS

- AWS charges money to run an EKS cluster ($0.20 per hour)
    - For smaller setups, ECS is cheaper
- Kubernetes is much more popular than ECS, so if you'r planning to deploy on more cloud providers / on-prem, it's a more natural choice
- Kubernetes has more features, but is also much more complicated than ECS - to deploy simpler apps/solutions, ECS is perferable
- ECS has very tight integration with other AWS services, but it's expected that EKS will also be tightly integrated over time

    ![AWS EKS Terraform Plan](https://i.imgur.com/hm5g4c6.png "AWS EKS Terraform Plan")

## Elastic Beanstalk

- Elastic Beanstalk is AWS's Platform as a Service (PaaS) solution
- It's a platform where you launch your app on without having to maintain the underlying infrastructure
    - You are still responsible for the EC2 instances, by AWS will provide you with updates you can apply
        - Updates can be applied manually or automatically
        - The EC2 instances run Amazon Linux
- Elastic Beanstalk can handle application scaling for you
    - Underlying it uses a Load Balancer and an Autoscaling group to achieve this
    - You can schedule scaling events or enable autoscaling based on a metric
- It's similar to Heroku (another PaaS solution)
- You can have an application running just in a few clicks using the AWS Console
    - Or using the elasticbeanstalk resources in terraform

## Interpolation

- In terraform, you can interpolate other values, using the syntax `${...}`
- You can use simple math functions, refer to other variablers, or use conditionals (if-else)
- Variables: `${var.VAR_NAME}` refers to a variable
- Resources : `${aws_instance.name.id}` (type.resource-name.attr)
- Data Sources: `${data.template_file.name.rendered}` (data.type.resource-name.attr)

### Interpolation - Variables

- String variable: 
    - `var.name` = `${var.VAR_NAME}`
- Map variable:
    - `var.MAP["key"]`:
        - `${var.AMIS["us-east-1"]}`
        - `${lookup(var.AMIS, var.AWS_REGION)}`
- List variable:
    - `var.LIST, var.LIST[i]`:
        - `${var.subnets[i]}`
        - `${join(",",var.subnets)}`

### Interpolation - Various

- Outputs of a module:
    - `module.NAME.output` = `${module.aws_vpc.vpcid}`
- Count information:
    - `count.FIELD` = When using the attribute count = number in a resource, you can use `${count.index}`
- Path information:
    - `path.TYPE`:
        - `path.cwd` (current directory)
        - `path.module` (module path)
        - `path.root` (root module path)
- Meta information:
    - `terraform.FIELD` = `terraform.env` shows active workspace
- Math:
    - `+,-,*,/` for float types
    - `+,-,*,/,%` for integer types

## Conditionals

- Interpolations may contain conditionals
- The syntax is the following: `CONDITION ? TRUEVAL : FALSEVAL`
- For example:

    ```terraform
    resource "aws_instance" "myinstance" {
        ...
        count = "{var.env == "prod" ? 2 : 1}"
        # Meaning, if the var.env value is prod, return 2, else return 1
    }
    ```

- The supported operators are:
    - Equality: `==` and `!=`
    - Numerical comparison: `>,<,>=,<=`
    - Boolean logic: `&&, ||, !`

## Functions

- You can use built-in functions in your terraform resources
- The functions are called with the syntax `name(arg1, arg2, ...)` and wrapped with `${}`
    - For example `${file("mykey.pub")}` would read the contents of the public key file
    - Please refer to [Terraform's Built-in Function list](https://www.terraform.io/docs/configuration/functions.html) For more details.

    | Function | Description | Example |
    | -------- | ----------- | ------- |
    | basename(path) | Returns the filename (last element) of a path | `basename("/home/evya/file.txt")` returns `file.txt` |
    | coalesce(string1, string2, ...) or coalescelist(list1, list2, ...) | Returns the first non-empty value or Returns the first non-empty list | `coalesce("","","hello")` returns `hello` |
    | element(list, index) | Returns a single element from a list at the given index | `element(module.vpc.public_subnets, count.index)` |
    | format(format, args, ...) or formatlist(format, args, ...) | Formats a string/list according to the given format | `format("server-%03d", count.index + 1)` returns `server-001, server-002` |
    | index(list, element) | Finds the index of a given element in a list | `index(aws_instance.foo.*.tags.Env, "prod")` |
    | join(delim, list) | Joins a list together with a delimiter | `join(",", var.AMIS)` returns `"ami-123,ami-456,ami-789"` |
    | list(item1, item2, ...) | Create a new list | `join(":", list("a","b","c"))` returns `a:b:c` |
    | lookup(map, key, [default]) | Perform a lookup on a map, using "key". Returns value representing "key" in the map | `lookup(map("k","v"), "k", "not found")` returns `"v"` |
    | lower(string) | Returns lowercase value of "string" | `lower("Hello")` returns `hello` |
    | upper(string) | Returns uppercased string | `upper("string")` returns `STRING` |
    | map(key, value, ...) | Returns a new map using key:value | `map("key1", "value1", "key2", "value2")` returns `{ "key1" : "value1", "key2" : "value2" }` |
    | merge(map1, marp2, ...) | Merges maps (union) | `merge(map("k","v"), map("k2","v2"))` returns `{ "k" : "v", "k2" : "v2" }` |
    | replace(string, search, replace) | Performs a search and replace on string | `replace("aaab", "a", "b")` returns `bbbb` |
    | split(delim, string) | Splits a string into a list | `split(",", "a,b,c,d")` returns `["a","b","c","d"]` |
    | substr(string, offset, length) | Extract substring from string | `substr("abcde", -3, 3)` returns `cde` |
    | timestamp() | Returns RFC 3339 timestamp | `Server started at ${timestamp()}` returns `Server Started at 2019-06-16T9:50:32Z` |
    | uuid() | Returns a UUID string in RFC 4122 v4 format | `uuid()` returns `65b8cf0a-685d-4295-73c1-1393ef71bcd6` |
    | values(map) | Returns values of a map | `values(map("k","v","k2","v2"))` returns `["v","v2"]` |

## Project Structure

- When starting with terraform on production environment, you quickly realize that you need a decent project structure
- Ideally, you want to seperate your development and production environments completely
    - That way, if you always test terraform changes in development first, mistakes will be caught before they can have an impact on production
    - For complete isolation, it's best to create multiple AWS accounts, and use one account for dev, one for prod and another for billing.
    - Splitting out terraform in multiple projects will also reduce the resources that you'll need to manage during one `terraform apply`