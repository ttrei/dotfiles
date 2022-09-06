#!/usr/bin/expect

set timeout 20

spawn /usr/bin/m-a prepare

expect "Do you want to continue? \\\[Y/n\\\] " {send "y\r" }

interact
