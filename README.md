SML Mail
==

This is a Standard ML program for sending email from one email address to another email address without requiring the password for email ID of the sender. 

* sender : The email ID you want to send the email from
* recepient : The email ID you want to send the email to
* senderID : The "server" for the sender email ID
* host : The email server used for sending message
* msg : Telnet + host + port
* port : 25 is the standard port used globally for the SMTP protocol
* subject : The subject of the email
* content : The message of the email

NOTE : Do not remove the '\r\n' from the variables. Also, The subject must end  with '\r\n\n' if you wish to write a message.
