#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
sudo aws s3 cp s3://dev-group7/daffodil.jpeg /var/www/html/
sudo aws s3 cp s3://dev-group7/rose.jpeg /var/www/html/
sudo aws s3 cp s3://dev-group7/hibiscus.jpeg /var/www/html/
sudo aws s3 cp s3://dev-group7/tulip.jpeg /var/www/html/
sudo aws s3 cp s3://dev-group7/daisy.jpeg /var/www/html/
sudo aws s3 cp s3://dev-group7/sunflower.jpeg /var/www/html/
sudo aws s3 cp s3://dev-group7/lilly.jpeg /var/www/html/



echo "
    <h1 align="center">
    
    Our private IP is $myip</h1>
    
    <h1>
    
    <table border="5" bordercolor="grey" align="center">
    <tr>
        <th colspan="3">Group7</th> 
       
    </tr>
    <tr>
     <th colspan="3">Group members:Darshil, Harsh, Bishal</th> 
     </tr>
    </h1>
    <tr>
        <th>image1</th>
        <th>image2</th>
                <th>image3</th>
    </tr>
    <tr>
        <td><img src="daffodil.jpeg" alt="" border=3 height=200 width=300></img></th>
        <td><img src="rose.jpeg" alt="" border=3 height=200 width=300></img></th>
        <td><img src="hibiscus.jpeg" alt="" border=3 height=200 width=300></img></th>
    </tr>
    <tr>
        <td>><img src="tulip.jpeg" alt="" border=3 height=200 width=300></img></th>
        <td><img src="daisy.jpeg" alt="" border=3 height=200 width=300></img></th>
        <td><img src="sunflower.jpeg" alt="" border=3 height=200 width=300></img></th>
    </tr>
</table>">  /var/www/html/index.html

sudo systemctl start httpd
sudo systemctl enable httpd