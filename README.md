Turnkey wordpress is a small shell script that can turn a [turnkey linux](https://www.turnkeylinux.org/) machine into a wordpress server,
including a free domain from noip.com and a certificate from let's encrypt!

First you have to register on [noip.com](https://www.noip.com/), make a domain and keep the ddns username and password.

Enter that info in the script, as well as the name of the domain and the database root password.

You will be requested to enter the root password some more times during the execution of the script, as well as some additional info for the certificates.

Be sure to have activated port forwarding on your router before running the scipt!

The result should be that you can access the wordpress setup dialogs from the domain chosen.

It is suggested to disable root ssh login, make a sudoer user and disable the webmin interface for security reasons.
