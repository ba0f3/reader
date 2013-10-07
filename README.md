Welcome to Reader!
======================

Introduction
------------
Reader is an open source web based RSS Reader client, by [VN Nerds](https://github.com/vnnerds) &amp; [Doda100](http://doda100.com)

<a href="http://dl.dropbox.com/u/1097522/Selection_003.png" target="_blank"><img src="http://dl.dropbox.com/u/1097522/Selection_003.png" alt="Preview" style="width: 800px;"/></a>

**This project is under development, and not ready for production use yet.**


How to start
------------

**Install required packages:**
$ sudo apt-get install python-dev python-pip python-lxml python-mysqldb libxslt1-dev
$ sudo pip install -r requirements.txt


**Init database:**
$ ./manage.py db init
$ ./manage.py db migrate
$ ./manage.py db upgrade


**Start server:**
$ ./manage.py runserver


License
-------
This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation; either version 2.1 of the License, or (at your option)
any later version.

This library is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General Public License along
with this library; if not, write to the Free Software Foundation, Inc., 51
Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
