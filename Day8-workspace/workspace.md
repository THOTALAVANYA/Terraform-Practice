\##### Terraform worksapce \###

This is part 1 of the How to manage multiple environments with Terraform
blog post series. In this post, I'll show you how to manage multiple
environments with Terraform using workspaces:

Setting up environments using workspaces

Switching between environments

Using different configurations in each environment

Using different backends in each environment

Advantages of workspaces

Drawbacks of workspaces

Conclusion

Note: Terraform Cloud and Terraform Enterprise also support a concept
called workspaces, which is not the same as the CLI workspaces concept
discussed in this post, but it's similar, and has many of the same
trade-offs.

Setting up environments using workspaces

Let's say you have the following Terraform configuration:

provider \"aws\" {

region = \"us-east-2\"

}

resource \"aws_instance\" \"example\" {

ami = \"ami-0fb653ca2d3203ac1\"

instance_type = \"t2.micro\"

tags = {

Name = \"example-server\"

}

}

This code deploys a single virtual server, called an EC2 instance, in
AWS in the us-east-2 (Ohio) region and gives it the name tag
example-server.

Now, imagine you want to deploy this server in three environments: dev,
stage, prod. To do this using workspaces, you first create a workspace
called dev using the terraform workspace new command:

\$ terraform workspace new dev

Created and switched to workspace \"dev\"!

You\'re now on a new, empty workspace. Workspaces isolate their state,
so if you run \"terraform plan\" Terraform will not see any existing
state for this configuration.

And now you can deploy the server in dev using terraform apply:

\$ terraform apply

Terraform will perform the following actions:

\# aws_instance.example will be created

\+ resource \"aws_instance\" \"example\" {

\+ ami = \"ami-0fb653ca2d3203ac1\"

\+ instance_type = \"t2.micro\"

(\...)

}

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?

Terraform will perform the actions described above.

Only \'yes\' will be accepted to approve.

Enter a value:

The plan output shows Terraform will deploy a new EC2 instance, which is
exactly what you want, so you enter yes, and Terraform will deploy your
server.

To deploy to staging, you create a new workspace called stage:

\$ terraform workspace new stage

Created and switched to workspace \"stage\"!

You\'re now on a new, empty workspace. Workspaces isolate their state,
so if you run \"terraform plan\" Terraform will not see any existing
state for this configuration.

And run apply again:

\$ terraform apply

Terraform will perform the following actions:

\# aws_instance.example will be created

\+ resource \"aws_instance\" \"example\" {

\+ ami = \"ami-0fb653ca2d3203ac1\"

\+ instance_type = \"t2.micro\"

(\...)

}

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?

Terraform will perform the actions described above.

Only \'yes\' will be accepted to approve.

Enter a value:

Even though you just deployed an EC2 instance in dev, the plan output
shows Terraform wants to deploy a totally new EC2 instance. That's
because you're now in the stage workspace, so Terraform is using a
separate state file, and knows nothing about the instance already
deployed in dev. Enter yes and Terraform will deploy the new instance in
stage.

Repeat this process one more time for the prod environment:

\$ terraform workspace new prod

\$ terraform apply

At this point, you have three environments (three workspaces), with one
EC2 instance deployed in each one, and exactly one copy of your
Terraform code to manage it all.

Switching between environments

To switch between environments, you need to switch between workspaces
using CLI commands. You can see all your workspaces using the terraform
workspace list command:

\$ terraform workspace list

default

dev

stage

-   prod

    You can switch to a different workspace using the terraform
    workspace select command:

    \$ terraform workspace select dev

    Switched to workspace \"dev\".

    Now, any command you run on this code (e.g., terraform apply) will
    run against the dev workspace.

    Note that if you use workspaces to manage environments, navigating
    your environments and understanding what's deployed is hard. That's
    because you can't see the environments in the code itself, but only
    from the terraform workspace CLI commands, which you have to run on
    one module at a time. So if you have your infrastructure defined
    across many small modules (see: large modules are considered
    harmful), and you're using workspaces, it's hard to answer questions
    like "What's deployed in my dev environment?" and "What are the
    differences between dev and prod?"

    Using different configurations in each environment

    Within your Terraform code, you can look up the name of the current
    workspace using terraform.workspace. This allows you to configure
    your infrastructure differently in each environment:

    resource \"aws_instance\" \"example\" {

    ami = \"ami-0fb653ca2d3203ac1\"

    instance_type = terraform.workspace == \"prod\"

    ? \"m4.large\"

    : \"t2.micro\"

    tags = {

    Name = \"example-server-\${terraform.workspace}\"

    }

    }

    This code configures the name tag to include the workspace name (so
    it's example-server-dev in the dev environment, example-server-stage
    in the stage environment, etc.) and the instance type to use
    different server types in different environments, so that in
    production, you run a larger server (e.g., to handle more traffic),
    whereas in other environments, you run a smaller server (e.g., to
    save money).

    Note that the preceding code uses ternary notation (CONDTION ?
    TRUEVAL : FALSEVAL) to pick an instance type, which works fine if
    there are two options to choose from, but gets messy for more than
    that: e.g., if you had 10 environments and 10 different instance
    types, the syntax for 10 if-else-if-else-if... statements becomes
    unusable. An alternative that scales to more than two options is to
    create a map, where the keys are the environment names and the
    values are the values to use in that environment, and to look up
    terraform.workspace in that map, as follows:

    locals {

    instance_types = {

    dev = \"t2.micro\"

    stage = \"t2.small\"

    prod = \"m4.large\"

    }

    }

    resource \"aws_instance\" \"example\" {

    ami = \"ami-0fb653ca2d3203ac1\"

    instance_type = local.instance_types\[terraform.workspace\]

    tags = {

    Name = \"example-server-\${terraform.workspace}\"

    }

    }

    Using different backends in each environment

    It's a good idea to keep each environment completely isolated: e.g.,
    you'll want to deploy dev into one AWS account, with one S3 bucket
    for a backend, and prod into a totally separate AWS account, with a
    totally separate S3 bucket as a backend. This reduces the risk from
    attacks (an attacker who manages to get access to your dev
    environment still won't have any access to prod) and the risk from
    mistakes (if dev and prod are totally separate accounts, you'll need
    to authenticate to them separately, so you're less likely to
    accidentally make a change in prod which was actually intended for
    dev).

    Unfortunately, Terraform workspaces only support using a single
    backend for all your workspaces. For example, to use S3 as a backend
    to store your Terraform state, you would add the following
    configuration to your Terraform code:

    terraform {

    backend \"s3\" {

    bucket = \"example-bucket\"

    region = \"us-east-2\"

    key = \"example/terraform.tfstate\"

    }

    }

    This code tells Terraform to store state in an S3 bucket called
    example-bucket. To use a different S3 bucket as your backend in
    production, you'd probably be tempted to do the following:

    terraform {

    backend \"s3\" {

    // THIS CODE WILL NOT WORK!!!!

    bucket = (

    terraform.workspace == \"prod\"

    ? \"prod-bucket\"

    : \"example-bucket\"

    )

    // THIS CODE WILL NOT WORK!!!!

    region = \"us-east-2\"

    key = \"example/terraform.tfstate\"

    }

    }

    Unfortunately, the backend block does not allow you to use any
    variables, interpolation, or references, so the preceding code will
    not work. That means that, with workspaces, you can only have a
    single, hard-coded value for bucket, so all of your state for all of
    your environments ends up in the same bucket. This is one of the
    reasons that even HashiCorp's own documentation does not recommend
    using Terraform workspaces for managing environments:
