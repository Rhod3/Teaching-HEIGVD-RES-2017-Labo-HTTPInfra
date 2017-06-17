<?php
 $ip_adress_static = getenv('STATIC_APP');
 $ip_adress_dynamic = getenv('DYNAMIC_APP');
?>
<VirtualHost *:80>
    ServerName demo.res.ch

    ProxyPass '/api/students/' 'http://<?php print "$ip_adress_dynamic"?>/'
    ProxyPassReverse '/api/students/' 'http://<?php print "$ip_adress_dynamic"?>/'

    ProxyPass '/' 'http://<?php print "$ip_adress_static"?>/'
    ProxyPassReverse '/' 'http://<?php print "$ip_adress_static"?>/'
</VirtualHost>