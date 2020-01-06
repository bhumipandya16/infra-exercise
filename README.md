# Keyme Infrastructure Engineering Exercise 2020 Q1

### Hello!

We're excited to share this take home exercise with you. We look forward to discussing your solution soon and hope you find this interesting along the way. We know time can be tight for projects like this. Thank you for making time to work on it. On to the challenge!

## Overview

At KeyMe we think [Terraform](https://www.terraform.io/) is pretty great. It played a huge role for us building out our environments, and continues to drive the way we build infrastructure today. We like it as a tool for provisioning AWS resources but more importantly it provides a framework for organizing all the pieces that are required to make KeyMe run. If you haven't used Terraform before (we believe almost all candidates receiving this exercise have at least some exposure) it is conceptually very similar to AWS's cloudformation. If you've used either, we think you'll feel comfortable with the setup here. Using Terraform and a combination of provided code and code you write, we'll build a simple 2-tier application.


## What are we building?

At completion, we'll have an application server "App01" and a database server "Mongo01" each in separate subnets but contained in a single VPC. These 2 instances will be connected such that our app can return a known result from a sample set of data loaded into the database. In the end we'll have..

* 1 VPC
* 1 Internet Gateway
* 1 Public Subnet
* 2 Private Subnets
* 1 NAT Gateway
* 1 MongoDB Instance
* 1 Application Instance


## What are we looking for?

1. Terraform stands up a functional environment - Can we run your code and stand up a new stack?
2. The Application code works - Hitting the `/query` endpoint returns the correct result from the MongoDB sample data set.
3. Useful outputs - When the build completes, is the output helpful/relevant?
4. Written communication - Does your solution include documentation that describes your solution, tips for the reviewer, and any difficulties faced?
5. Opportunities for extension or modification - We'd love to discuss how we can change this environment for the better, how it might change with scale, etc. Keep these in mind as you work.


## Setup

The code and directory structure contained here provides an outline for a Terraform project that, when completed, stands up an environment with a simple running web application. Within `environments/test` you'll find almost everything you need to get started.

`vars.tf` - The global inputs for building this stack. There are a couple variables you will need to modify like "candidate_name" and "provisioning_key". All other variables here can be left unchanged and will inform what the solution looks like.

`main.tf` - The blueprint "root module" for describing the infrastructure that we're building. This file sets up some important configuration related to appropriate Terraform versions and an aws config profile you could use during local testing. The remainder is used to reference modules that you'll be creating to implement the underlying resources. For this exercise, you can leave this file unchanged. It exists to describe the overall system and provide the "method signatures" for each component.

`output.tf` - After a successful run, Terraform can output useful information to the console. The setup contains a few examples. As you build, you'll likely find other information to output. What would be helpful to a user to see when an infrastructure build completes?


## Other helpful info

The VPC module is provided in full as an example. The remaining 3 modules need your help, and with 2 exceptions, are provided empty. In `modules/mongodb/files/user_data.sh` we're providing a quick bootstrapping script that can be used to seed the database with sample data. Secondly, `modules/app/templates/user_data.tpl` can set up the application instance during launch. These 2 shortcuts are there to let you focus on the infrastructure pieces and how they interact.

The following commands will be helpful to get started and to test your code..

`terraform init`  - initialize your Terraform project. 
`terraform get`   - load modules after you add new references to existing modules.
`terraform plan`  - shows what Terraform will build based on current code.
`terraform apply` - actually apply the changes to your AWS testing account.

[Terraform Doc Link](https://www.terraform.io/docs/index.html) - Find variations on these commands and other useful information here.


#### Hints:
* Reading the variable descriptions will help with things like "What AMI should I be using?"
* Work in small cycles, adding each new module implementation once the previous ones are working.
* Modules must output any values you wish to reference in the root module or root module output.
* It's ok to implement the simpliest thing that will work (You don't need to support multiple resource counts if the input variable is set to 1 for example.)
* Pay attention to routing and security groups. When things aren't working, these are frequently involved.
* Take notes as you go. These will be helpful for describing your implementation and providing guidance for a reviewer running your code.

