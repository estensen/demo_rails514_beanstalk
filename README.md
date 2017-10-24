# CS291 Elastic Beanstalk Demo Application

This demo rails application provides a minimal Rails 5 application
that can be launched to elastic beanstalk and configured with a
postgres database.

## Table of Contents

- [Preparing this Rails Application for Elastic Beanstalk](#preparing-this-rails-application-for-elastic-beanstalk)
- [Preparing Your Application for Elastic Beanstalk](#preparing-your-application-for-elastic-beanstalk)
- [Creating Elastic Beanstalk Deployments](#creating-elastic-beanstalk-deployments)
- [Modifying Running Deployments](#modifying-running-deployments)




## Preparing this Rails Application for Elastic Beanstalk

I've set up a linux server on Amazon EC2 that you can utilize for easy interaction with
elasticbeanstalk. (Alternatively, you could set up the CLI for elastic beanstalk on your local machine.)

1. SSH into that server using the provided TEAMNAME.pem file:

        ssh -i TEAMNAME.pem TEAMNAME@ec2.cs291.com

1. On the EC2 instance you just ssh'd into, take note of your aws-access-id and aws-secret-key which can be found via:

        cat ~/TEAMNAME_key.txt

    WARNING: Never commit this credentials into your repository, or put them
    anywhere else that they might be made public.

1. From the home directory, clone this repository:

        git clone https://github.com/scalableinternetservices/demo_rails514_beanstalk.git

1. Change into the project directory, and initialize elasticbeanstalk:

        cd demo_rails514_beanstalk
        eb init

1. Use the us-west-2 region (default).

1. Provide your aws-access-id. (*if prompted*)

1. Provide your aws-secret-key. (*if prompted*)

1. Create a new application (default) for your team if no such application
   already exists.

    * Use your team name as your application's name.

1. Indicate that you are using ruby.

1. For now, choose Ruby 2.4 (Puma) as your platform (default). You can
   experiment with passenger later.

1. Do not continue with CodeCommit (default).

1. Indicate that you do want to set up SSH for your instances (default).

    * Choose the keypair that matches your team's name.
    
1. To test this configuration, skip ahead to section "[Creating Elastic Beanstalk Deployments](#creating-elastic-beanstalk-deployments)", wherein you will deploy this demo project to Elastic Beanstalk.

## Preparing Your Application for Elastic Beanstalk

Use similar steps as above to initialize `eb` for your own project's repository. Note that
`eb init` must be run from the top most directory of your repository.

Next you need to make some changes to your application in order to configure it
to work well with elasticbeanstalk.

1. Ignore most of the elastic beanstalk related files.

    * Make a similar change to `.gitignore` as added here:
      https://github.com/scalableinternetservices/demo_rails514_beanstalk/commit/0b4e5be4363d2219b79c87d962dd9f0f1c7cd09c

1. Update your Gemfile to use the `pg` gem in production, and `sqlite3` in
   development.

    1. Make a similar change to `Gemfile` as added here (do not manually update
       `Gemfile.lock`):
       https://github.com/scalableinternetservices/demo_rails514_beanstalk/commit/1afc197b3bee390d834dfdeedb2921bc3a32851e

    2. Run `bundle install --without-production` to update your `Gemfile.lock`.


1. Configure your production database settings to use postgresql and to fetch
   the right settings from the environment provided by elastic beanstalk.

    0. Make similar changes as added here:
       https://github.com/scalableinternetservices/demo_rails514_beanstalk/commit/5ef2e844a1b94a1b916548cfd013df6cf83dab7f


## Creating Elastic Beanstalk Deployments

Once you have prepared either the demo application, or your application, you
can make various deployments of said application.

### Create a deployment for demo purposes

Use the following command when you are simply testing out changes, or demoing
because this will create a deployment that operates with the cheapest cost.

```bash
eb create -db.engine postgres -db.i db.t2.micro -db.user u --envvars SECRET_KEY_BASE=RANDOM_SECRET --single DEPLOYMENT-NAME
```

Replace `DEPLOYMENT-NAME` with a unique name for your
deployment. Consider `teamname-yourname`.

Replace `RANDOM_SECRET` with some semi-random large string of
alphanumeric characters. Note, for real sites you want this to be
really random as your cookies are signed/encrypted using a key derived
from this string.

### Create a deployment for load testing

When you are ready to run tsung tests, use a form of the following command to
specify the database instance type, and application server instance type.

```bash
eb create -db.engine postgres -db.i DB_INSTANCE_TYPE -db.user u --envvars SECRET_KEY_BASE=RANDOM_SECRET -i INSTANCE_TYPE DEPLOYMENT_NAME
```

Replace `DB_INSTANCE_TYPE` with one of:

* db.m3.medium
* db.m3.large
* db.m3.xlarge
* db.m3.2xlarge
* db.r3.large
* db.r3.xlarge
* db.r3.2xlarge
* (you can use the c3-instance types if CPU bound)

Replace `INSTANCE_TYPE` with one of:

* m3.medium
* m3.large
* m3.xlarge
* m3.2xlarge
* c3.large
* c3.xlarge
* c3.2xlarge
* c3.4xlarge

See the following for differences between the instance types:
* https://aws.amazon.com/ec2/instance-types/#m3
* https://aws.amazon.com/ec2/instance-types/#c3
* https://aws.amazon.com/ec2/instance-types/#r3

## Modifying Running Deployments

### Scale your deployment

Use the web console "configuration" tab for your deployment.

Vertically scale by changing the instance type
[[Ref](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.managing.ec2.html)].

Horizontally scale by adjusting the minimum and maximum number of instances
[[Ref](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.managing.as.html)].

Note: set the minimum and maximum instance count to the same value to keep the
instance number fixed throughout the duration of your test. Verify all
instances are available before running any tests.

### Terminate a deployment

Run `eb terminate` to terminate the active deployment. Alternatively
run `eb terminate DEPLAYMENT_NAME` to terminate a different
deployment.

### Update the rails application

To update the application source code perform the following tasks:

* Run `git pull` to update the copy of the repository.

* (Optional) Check out a branch if you intend to work with a
  branch. Ensure the local copy is up-to-date.

* Run `eb list` to see which deployment is currently active (it will
  have a `*` next to it).

* (If needed) Run `eb use DEPLOYMENT_NAME` to change the active deployment.

* Run `eb deploy` to update the active deployment.
